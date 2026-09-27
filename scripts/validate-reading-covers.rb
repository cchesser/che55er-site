#!/usr/bin/env ruby
# frozen_string_literal: true

# Verify the pinned cover URLs in data/reading.yaml. For entries without a
# working cover URL, --resolve evaluates Google Books, Open Library, and
# Libby/OverDrive CDN and optionally persists the first working result with --write.
#
# Usage:
#   scripts/validate-reading-covers.rb
#   GOOGLE_BOOKS_API_KEY=... scripts/validate-reading-covers.rb --resolve --write
#   scripts/validate-reading-covers.rb --goodreads
#   scripts/validate-reading-covers.rb --goodreads --write
#   scripts/validate-reading-covers.rb --data path/to/reading.yaml --jobs 6
#
# A Libby/OverDrive cover URL is the preferred source: add it as `cover_url`
# when available. The resolver only uses public catalog fallbacks for records
# that do not already have a usable pinned URL.
#--download-covers  Download cover images from Libby CDN and save them locally.
#--cover-dir        Directory to save downloaded covers (default: static/covers)

require 'json'
require 'net/http'
require 'optparse'
require 'timeout'
require 'uri'
require 'yaml'

options = { data: 'data/reading.yaml', jobs: 8, resolve: false, write: false, limit: nil, download_covers: false, cover_dir: 'static/covers', goodreads: false }
OptionParser.new do |parser|
  parser.banner = 'Usage: validate-reading-covers.rb [options]'
  parser.on('--data PATH', 'YAML reading data file') { |value| options[:data] = value }
  parser.on('--jobs COUNT', Integer, 'Concurrent URL checks (default: 8)') { |value| options[:jobs] = value }
  parser.on('--resolve', 'Try Google Books, then Open Library for broken/missing URLs') { options[:resolve] = true }
  parser.on('--write', 'Save successful --resolve choices into the YAML file') { options[:write] = true }
  parser.on('--limit COUNT', Integer, 'Check only the first COUNT books (useful while testing)') { |value| options[:limit] = value }
  parser.on('--download-covers', 'Download cover images from Libby CDN and save them locally') { options[:download_covers] = true }
  parser.on('--cover-dir DIR', 'Directory to save downloaded covers (default: static/covers)') { |value| options[:cover_dir] = value }
  parser.on('--goodreads', 'Validate Goodreads ISBN redirects and pinned Goodreads IDs') { options[:goodreads] = true }
end.parse!

abort '--jobs must be at least 1' if options[:jobs] < 1
abort '--write requires --resolve or --goodreads' if options[:write] && !options[:resolve] && !options[:goodreads]

data = YAML.safe_load(File.read(options[:data]), aliases: false)
abort "No years found in #{options[:data]}" unless data.is_a?(Hash) && data['years'].is_a?(Hash)

books = data['years'].flat_map { |year, entries| entries.map { |book| [year, book] } }
books = books.first(options[:limit]) if options[:limit]

def request(url, method: :head, redirects: 4, range: false)
  uri = URI(url.to_s.gsub('{', '%7B').gsub('}', '%7D'))
  raise 'only HTTP(S) URLs are supported' unless %w[http https].include?(uri.scheme)

  response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https',
                             open_timeout: 8, read_timeout: 12) do |http|
    request = method == :head ? Net::HTTP::Head.new(uri.request_uri) : Net::HTTP::Get.new(uri.request_uri)
    request['User-Agent'] = 'che55er-reading-cover-check/1.0'
    request['Range'] = 'bytes=0-1' if range
    http.request(request)
  end
  if response.is_a?(Net::HTTPRedirection) && redirects.positive?
    return request(URI.join(uri, response['location']).to_s, method: method, redirects: redirects - 1, range: range)
  end
  response
end

def image_url?(url)
  # Use a ranged GET instead of HEAD. Some image CDNs respond differently to
  # HEAD, while browsers always fetch covers with GET. The two-byte range keeps
  # the validation inexpensive without weakening the content-type check.
  response = request(url, method: :get, range: true)
  [200, 206].include?(response.code.to_i) && response['content-type'].to_s.start_with?('image/')
rescue StandardError
  false
end

def google_cover(book)
  queries = ["isbn:#{book['isbn']}", "intitle:\"#{book['title']}\" inauthor:\"#{book['author']}\""]
  queries.each do |query|
    uri = URI('https://www.googleapis.com/books/v1/volumes')
    params = { q: query, maxResults: 1, projection: 'lite' }
    params[:key] = ENV['GOOGLE_BOOKS_API_KEY'] if ENV['GOOGLE_BOOKS_API_KEY'] && !ENV['GOOGLE_BOOKS_API_KEY'].empty?
    uri.query = URI.encode_www_form(params)
    response = request(uri.to_s, method: :get)
    next unless response.is_a?(Net::HTTPSuccess)

    item = JSON.parse(response.body).fetch('items', []).first
    image_links = item&.dig('volumeInfo', 'imageLinks')
    next unless image_links

    return image_links['large'] || image_links['medium'] || image_links['small'] || image_links['thumbnail']
  rescue JSON::ParserError
    next
  end
  nil
end

def fallback_candidates(book)
  candidates = []
  google = google_cover(book)
  candidates << ['Google Books', google] if google
  candidates << ['Open Library', "https://covers.openlibrary.org/b/isbn/#{URI.encode_www_form_component(book['isbn'])}-L.jpg?default=false"] if book['isbn']
  candidates
end

queue = Queue.new
books.each { |entry| queue << entry }
results = []
lock = Mutex.new

workers = Array.new(options[:jobs]) do
  Thread.new do
    loop do
      year, book = queue.pop(true)
      url = book['cover_url']
      valid = url.is_a?(String) && image_url?(url)
      lock.synchronize { results << { year: year, book: book, valid: valid } }
    rescue ThreadError
      break
    end
  end
end
workers.each(&:join)

failed = results.reject { |result| result[:valid] }
puts "Checked #{results.length} pinned cover URL(s): #{results.length - failed.length} valid, #{failed.length} missing or unreachable."

changed = 0
if options[:resolve] && failed.any?
  puts "\nResolving #{failed.length} missing cover(s) (Google Books, then Open Library):"
  failed.each do |result|
    book = result[:book]
    winner = fallback_candidates(book).find do |source, candidate|
      # Open Library limits ISBN cover requests, so pace this fallback.
      sleep 3.1 if source == 'Open Library'
      image_url?(candidate)
    end
    if winner
      source, url = winner
      puts "  #{result[:year]} — #{book['title']}: #{source}"
      if options[:write]
        book['cover_url'] = url
        changed += 1
      end
    else
      warn "  #{result[:year]} — #{book['title']}: no usable candidate"
    end
  end
end

goodreads_failed = []
goodreads_changed = 0
if options[:goodreads]
  def goodreads_result(book)
    path = if book['goodreads_id']
             "/book/show/#{URI.encode_www_form_component(book['goodreads_id'].to_s)}"
           else
             "/book/isbn/#{URI.encode_www_form_component(book['isbn'].to_s)}"
           end
    uri = URI("https://www.goodreads.com#{path}")

    5.times do
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 8, read_timeout: 12) do |http|
        request = Net::HTTP::Get.new(uri.request_uri)
        request['User-Agent'] = 'che55er-reading-validator/1.0'
        request['Accept'] = 'text/html,application/xhtml+xml'
        http.request(request)
      end
      if response.is_a?(Net::HTTPSuccess)
        id = uri.path[%r{/book/show/(\d+)}, 1]
        return [!id.nil?, id, uri.to_s, response.code]
      end
      return [false, nil, uri.to_s, response.code] unless response.is_a?(Net::HTTPRedirection)

      uri = URI.join(uri, response['location'])
    end

    id = uri.path[%r{/book/show/(\d+)}, 1]
    [!id.nil?, id, uri.to_s, 'redirect limit exceeded']
  rescue StandardError => error
    [false, nil, uri&.to_s, error.message]
  end

  queue = Queue.new
  books.each { |entry| queue << entry }
  goodreads_results = []
  workers = Array.new(options[:jobs]) do
    Thread.new do
      loop do
        year, book = queue.pop(true)
        valid, id, final_url, detail = goodreads_result(book)
        lock.synchronize do
          goodreads_results << { year: year, book: book, valid: valid, id: id, final_url: final_url, detail: detail }
        end
      rescue ThreadError
        break
      end
    end
  end
  workers.each(&:join)

  goodreads_failed = goodreads_results.reject { |result| result[:valid] }
  goodreads_results.select { |result| result[:valid] && result[:book]['goodreads_id'].nil? }.each do |result|
    next unless options[:write]

    result[:book]['goodreads_id'] = result[:id]
    goodreads_changed += 1
  end
  puts "Checked #{goodreads_results.length} Goodreads link(s): #{goodreads_results.length - goodreads_failed.length} valid, #{goodreads_failed.length} unresolved."
  goodreads_failed.each do |result|
    warn "  #{result[:year]} — #{result[:book]['title']} (ISBN #{result[:book]['isbn']}): #{result[:detail]}"
  end
end

if options[:write] && (changed.positive? || goodreads_changed.positive?)
  File.write(options[:data], YAML.dump(data))
  puts "\nUpdated #{options[:data]} with #{changed} cover URL(s) and #{goodreads_changed} Goodreads ID(s)."
end

# Download cover images from Libby CDN if requested
if options[:download_covers]
  require 'net/http'
  require 'uri'
  require 'fileutils'

  cover_dir = options[:cover_dir]
  FileUtils.mkdir_p(cover_dir)

  def libby_cover_url(isbn, size: 'large')
    # Libby/OverDrive CDN pattern for cover images.
    # Supports sizes: thumbnail, medium, large
    "https://c.overdrive.com/libby/covers/#{size}/#{isbn}-#{size[0].upcase}#{size[1..]-'L'}.jpg"
  end

  def download_image(url, dest_path)
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', open_timeout: 8, read_timeout: 12) do |http|
      request = Net::HTTP::Get.new(uri.request_uri)
      request['User-Agent'] = 'che55er-reading-covers/1.0'
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess) && response['content-type'].to_s.start_with?('image/')
        File.write(dest_path, response.body)
        true
      else
        false
      end
    end
  rescue StandardError => e
    warn "Failed to download #{url}: #{e.message}"
    false
  end

  # Build a map of year -> books from the data
  data = YAML.safe_load(File.read(options[:data]), aliases: false)
  books = data['years'].flat_map { |year, entries| entries.map { |book| [year, book] } }

  downloaded = 0
  skipped = 0

  books.each do |year, book|
    next unless book['isbn']

    isbn = book['isbn'].to_s
    # Try large cover first, then medium, then thumbnail
    cover_url = nil
    %w[large medium thumbnail].each do |size|
      url = libby_cover_url(isbn, size: size)
      if download_image(url, "#{cover_dir}/#{year}-#{File.basename(url, '.jpg')}")
        cover_url = url
        break
      else
        skipped += 1
      end
    end

    if cover_url
      book['cover_url'] = cover_url
      downloaded += 1
      puts "  #{year} — #{book['title']}: downloaded cover from Libby CDN"
    else
      puts "  #{year} — #{book['title']}: could not download cover from Libby CDN"
    end
  end

  if downloaded.positive?
    File.write(options[:data], YAML.dump(data))
    puts "\nDownloaded #{downloaded} cover image(s) and updated #{options[:data]}."
  else
    puts "\nNo cover images were downloaded from Libby CDN."
  end
end

all_covers_resolved = failed.empty? || (options[:write] && changed == failed.length)
exit(all_covers_resolved && goodreads_failed.empty? ? 0 : 1)

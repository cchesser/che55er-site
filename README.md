## che55er.io source

This repository hosts site content for [che55er.io](https://che55er.io).

### Development

Install [mise](https://mise.jdx.dev/), then install the project's pinned Hugo
extended release and build the site:

```
mise install
mise exec -- hugo --minify
```

### Validation

Utilizing `pyspelling` to enable spelling validation as part of the build process. To run locally:

```
brew install pyspelling
pyspelling -c config/.spellcheck.yml
```

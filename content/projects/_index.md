---
title: projects
description: other things that I work on
showDate: false
showReadingTime: false
showWordCount: false
showZenMode: false
---

Other things that I work on...

## jvmperf.net - Java Performance Workshop

An online guided workshop that explores the performance aspects of a Java project. This project was something I created in 2015 that supported a 4 hour workshop. In 2021, I have been converting it into its own website and updating the content based on all the differences that has occurred with Java in the last few years (containers, Java 11+).

[{{< figure
    src="img/jvmperf-workshop.png"
    alt="jvmperf.net - Java Performance Workshop"
    nozoom="false"
    >}}](https://jvmperf.net)

## hooper - A simple basketball schedule aggregation

As a parent with kids playing different sports, I try my best to manage a shared familiy calendar of all the events, including locations, and reminders based on travel time. I found it difficult having to use different sports apps based on teams or leagues on when and where you need to be. So, I worked on building a simple web app, that:
* Aggregates all teams and games for a given basketball club
* Provides views of By Team (for parents), By Coach (for coaches), and By Tournament (for anyone wanting to explore)
* Includes "Add to Calendar" option for each game (in ICS format), which includes street address location.
* Map links for each game
* Indication of how long to wait between games at a given location. If there is a location change, indicates travel time between the locations. This is achieved by doing geolocation lookup for each street address, then doing travel time calculations.
* Simple "Share" button that will allow you to share the view (url by team) with family members.

[{{< figure
    src="img/hooper-preview.png"
    alt="hooper - basketball schedule"
    nozoom="false"
    >}}](https://hooper.che55er.io)

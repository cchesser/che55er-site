---
title: "The Power of Murphy's Law"
date: 2019-07-17
---

I recently built a [guide on decision making](/guides#decisions-the-pursuit-of-options), which included several different elements on how we form ideas and decisions. The purpose of this guide was to highlight common areas that typically cause strain on us humans when we are in the act of technical decision making. I plan to author another series of blog posts, that take each part of this guide, and expand it with some added dialogue. For this first post, I'm going focus on [Murphy's Law](https://en.wikipedia.org/wiki/Murphy%27s_law) and its influence on our ability to make technical decisions.

## Murphy's Law

Murphy's Law was something I learned early in my professional career. If you are not familar with this law, it was coined by [Edward A Murphy Jr.](https://en.wikipedia.org/wiki/Edward_A._Murphy_Jr) during his work on a high-speed rocket sled experiment for the US Air Force where he shared:

> Anything that can go wrong will go wrong.

This belief was reminded to me when I used to work in a machine shop, and you would extensively try to control all the sources of variance that may disrupt what you were machining. There would always be some unforeseen source that would cause you to incorrectly remove too much material, which would then violate the necessary tolerances of the very thing you were trying to build (requiring you to build it again). Whenever this would happen, I would hear my boss just say: "Murphy...".

I believe this thought (that anything can fail) that can shape our thinking and decision making in ways we don't always expect. In the next two sections, I will share what I have found where this way of thinking was helpful and also hurtful.

## The Good: Plan for Failure

With our software systems becoming more complex, the importance of understanding and embracing the existence of failure is valuable. Through the lens of Murphy's Law, we expect that anything we rely upon will fail. This is helpful through early excercises in system design, in that you try to identify sources of failure and their resulting impact. Essentially, thinking through assumptions your system may have and declaring your reliance on those assumptions is a valuable exercise. This many times can also extrapolate [single points of failure](https://en.wikipedia.org/wiki/Single_point_of_failure), which are paramount in capturing early as these often take longer to identify when they are nestled deep in layers of abstracted infrastructure.

By thinking of Murphy's Law, we expand our perception of what can fail and therefore consider a wide variety of assumptions and dependencies of our systems. As a result, we may be able to identify weaknesses early and hopeful avoid these before we actually ever experience them in the systems we operate.

## The Bad: The Infinite Universe of Failure

While there is some strength in reminding ourselves of Murphy's Law, it is also helpful to remember that it is a cognitive bias that can influence our perception of what is probable. I mentioned earlier that there are benefits in this exploratoration of potential failures, it can also be overwhelming when viewing through this lens. This lens views into the infinite universe of the negative. There are an unlimited amount of things that can fail or go wrong. What I have often seen, is that many experienced engineers have a large list of painful past system failures they have experienced. It is easy for them to recall how each of these could happen in some new system we are building. While these perspectives are valuable, they can be misleading without some added context of probability. For example, sharing at least how many times they may have experience that type of failure over the lifespan of a previous system can help articulate the probability of that failure. This helps in capturing what is a valid concern of this potential failure mode, but also collectively leveraging past experiences on the probability of it occurring, and what type of environment allowed it to occur (valuable context to understand its validity).

![Murphy's Law](/img/murphys-law.png)

Therefore, we understand that we vividly remember our painful failures of the past. These memories are valuable to leverage to ensure we don't allow these to occur again in our lives. However, we must also recognize that sharing additional context, like the system environment that invited the failure and the historical frequency of this failure is important pairing of information. This is so we don't allow ourselves to miss other (more probable) failures due to our bias of these unique and scary past scenarios.

## Recognize the Bias and Embrace Failure

I think it valuable to understand the existence of this bias and that it can invite an overwhelming amount of conditions that may cause failure in your systems. However, I also think it is benefical to always think and consider how dependencies in your system can fail, inviting you to describe how the system should handle it. This endless pursuit helps drive out weaknesses in your system, which is good thing. Just be mindful that you don't want to be blinded by your past failures, but rather insightful on the potential probability of those failures in future systems.
Here is the expanded markdown presentation, broken down into 26 slides. This structure reduces the cognitive load on the audience per slide, while providing rich speaker notes to ensure you have plenty of material to fill a 45-minute slot at a comfortable, engaging pace.

---

# Why Your Systems Behave Strangely

**Systems Thinking for Software Architects**

## Slide 1: Title Slide

**Why Your Systems Behave Strangely**
*Systems Thinking for Software Architects*

*Speaker Notes: Welcome the audience. Introduce yourself and set the stage: We spend our careers building complex things, but often those things surprise us in painful ways in production. Today, we're going to talk about why.*

---

## Slide 2: The Outage We've All Caused

* Have you ever fixed a performance issue...
* ...only to watch it immediately break a downstream service?
* Have you ever scaled up a database to survive a spike...
* ...only to run out of connections instead of CPU?

*Speaker Notes: Ask for a show of hands. We have all played whack-a-mole with distributed systems. You fix a memory leak, and suddenly the network is saturated. This isn't because we are bad engineers; it's because we are treating complex systems as complicated machines.*

---

## Slide 3: The Illusion of Linear Control

**How we want the world to work:**

* A causes B.
* Input = Output.
* Fix the broken part $\rightarrow$ System is fixed.

*Speaker Notes: As engineers, we are trained in linear logic. If a function takes an input, it gives an output. We want to believe that if a system is broken, there is a broken part we can swap out. But software architecture at scale doesn't work like this.*

---

## Slide 4: Non-Linear Reality

**How the world actually works:**

* A influences B.
* B influences C.
* C loops back and changes A.

*Speaker Notes: Distributed systems are non-linear. A system running at 70% capacity behaves totally differently than one at 85% capacity. Small changes don't result in small effects; they result in emergent behavior.*

---

## Slide 5: The "Root Cause" Myth

* Root Cause Analysis (RCA) often lies to us.
* It assumes a single point of failure.
* "Human error" or "Bad deployment" is where learning stops.

*Speaker Notes: When a system fails, we hold a post-mortem and ask the "5 Whys" until we find a "Root Cause." But in complex systems, there is never one root cause. The system required a specific environment, a specific load, and a specific lack of safeguards to fail. Stopping at "someone pushed bad code" prevents systemic learning.*

---

## Slide 6: Our Fascination with Events

* Events are loud.
* Events cause pages at 2:00 AM.
* Our brains are hardwired to react to them.

*Speaker Notes: Donella Meadows, in her book Thinking in Systems, points out that humans are obsessed with events. The crash, the timeout, the memory spike. We spend all our time putting out fires (events) without asking who keeps leaving oily rags near the furnace.*

---

## Slide 7: The Iceberg Model - The Tip

* **The Tip:** Events
* *What just happened?*
* Example: "The payment service crashed at 2:15 PM."
* **Action:** React.

*Speaker Notes: The tip of the iceberg is all we see from the boat. This is the event. If you only operate at this level, your engineering team is just an expensive firefighting squad.*

---

## Slide 8: The Iceberg Model - The Middle

* **The Middle:** Behavior Over Time (Patterns)
* *What is the trend?*
* Example: "Payment failure rates spike every Monday morning at 9:00 AM."
* **Action:** Anticipate.

*Speaker Notes: Below the waterline are patterns. This is where metrics and observability come in. We stop looking at the single crash and start looking at the trend. We can autoscale in anticipation. It's better, but it's still not architecture.*

---

## Slide 9: The Iceberg Model - The Base

* **The Base:** System Structure
* *What causes the patterns?*
* Example: "Batch processing competes with live traffic for the same DB connections."
* **Action:** Design.

*Speaker Notes: This is the architect's domain. The structure of the system *forces* the behavior, which *causes* the events. If you want to stop the 2 AM pages, you have to redesign the system structure.*

---

## Slide 10: Defining a System

> "A system is an interconnected set of elements that is coherently organized in a way that achieves something."
> — Donella Meadows

*Speaker Notes: Notice what isn't in this definition: it's not a list of servers, and it's not a static architecture diagram. It's about how the elements are interconnected and how they behave together.*

---

## Slide 11: System Building Blocks: Stocks & Flows

* **Stocks:** Things that accumulate.
* *Software:* Messages in a queue, open connections, memory allocation.


* **Flows:** Rates of change.
* *Software:* Requests per second (inflow), processing rate (outflow).



*Speaker Notes: Every system is made of stocks and flows. If your inflow (requests) exceeds your outflow (processing), your stock (queue or memory) fills up. When the stock overflows, the system crashes. It's physics.*

---

## Slide 12: System Building Blocks: Buffers

* Buffers are large stocks that absorb shocks.
* They stabilize the system.
* *But*... they introduce delays.

*Speaker Notes: To prevent systems from crashing during spikes, we add buffers. A massive Kafka topic is a buffer. It's great for stability, but if the buffer gets too big, the data is stale by the time it's processed.*

---

## Slide 13: System Building Blocks: Delays

* Information takes time to travel.
* Decisions are made on old data.
* Causes over-correction (The "Shower Temperature" problem).

*Speaker Notes: Delays are the enemy of distributed systems. Think about turning the handle in a shower. You turn it to hot, nothing happens (delay). You turn it more. Suddenly you are boiling, so you crank it to cold. In software, this is auto-scaling based on 5-minute old CPU metrics, causing you to over-provision, then aggressively scale down, creating a yo-yo effect.*

---

## Slide 14: Feedback Loops

* Elements don't just flow; they loop.
* System behavior emerges from these feedback loops.
* Two types: **Reinforcing** and **Balancing**.

*Speaker Notes: Architecture isn't a straight line from user to database. It's a web of loops. How a downstream service responds changes how the upstream service behaves.*

---

## Slide 15: Reinforcing Loops (The Amplifier)

* Loops that compound change.
* Lead to exponential growth... or rapid collapse.
* Often the hidden cause of major outages.

*Speaker Notes: Reinforcing loops are vicious cycles. They take a small problem and amplify it until the system breaks.*

---

## Slide 16: The Thundering Herd Anti-Pattern

1. Service A drops momentarily.
2. Clients hit their timeouts.
3. Clients immediately retry.

*Speaker Notes: Let's look at a classic software reinforcing loop. A service has a minor hiccup. What do clients do? They retry.*

---

## Slide 17: The Herd Arrives

4. Service A comes back online.
5. It is hit by normal traffic **PLUS** the synchronized retries.
6. Service A dies again, immediately.
7. *The loop strengthens.*

*Speaker Notes: The service restarts, but now it's facing 3x the normal traffic because everyone is retrying at exactly the same time. The structure of the system (naive retries) turned a minor latency hiccup into a total system failure. The system defeated itself.*

---

## Slide 18: Balancing Loops (The Stabilizer)

* Loops that seek equilibrium.
* They resist extreme fluctuations.
* They push back against reinforcing loops.

*Speaker Notes: To fix reinforcing loops, architects must intentionally design balancing loops. These are mechanisms that force the system back to a stable state.*

---

## Slide 19: Architectural Balancing Loops

* **Rate Limiting:** Pushes back on inflow when capacity is reached.
* **Circuit Breakers:** Opens the circuit on failure, halting the retry storm.
* **Backpressure:** Downstream tells upstream, "Slow down."

*Speaker Notes: A circuit breaker is the ultimate balancing loop. When the error rate spikes, it says "Stop sending traffic." It breaks the reinforcing loop of the Thundering Herd, giving the broken service time to empty its stock and recover.*

---

## Slide 20: Bounded Rationality

* Actors make rational choices based on *local* information.
* Local optimization often leads to global failure.
* Example: Microservice autoscaling.

*Speaker Notes: Bounded rationality means a component does what's best for itself, not the whole system. A microservice sees high CPU, so it autoscales from 5 to 50 instances. Rational for the service! But those 50 instances instantly overwhelm the shared PostgreSQL database, taking down the entire company.*

---

## Slide 21: Finding Leverage Points

* Where do we intervene in a system?
* Not all changes have equal impact.
* We want maximum leverage.

*Speaker Notes: Meadows wrote a famous essay called "Leverage Points: Places to Intervene in a System." Let's apply her hierarchy to a failing software architecture.*

---

## Slide 22: Scenario: The Bottleneck

**The Problem:**

* High traffic spikes keep dropping user checkouts.
* The database is locking up under load.

*Speaker Notes: We have a standard synchronous web app. Users click buy, the web server talks to the DB, the DB locks while writing. Under heavy load, users get 500 errors.*

---

## Slide 23: Low Leverage (Parameters)

* **Action:** Increase DB RAM, double the connection pool, scale up EC2 instances.
* **Result:** The system survives a bit longer.
* **Why it's low leverage:** It doesn't change the behavior. The next traffic spike just hits the new, higher ceiling.

*Speaker Notes: Changing numbers (parameters) is the lowest form of leverage. It's expensive and it only buys you time. The fundamental structure of the system is exactly the same.*

---

## Slide 24: Medium Leverage (Balancing Loops)

* **Action:** Add strict rate limiting or a circuit breaker to checkout.
* **Result:** The database survives! But users get "Try again later" errors.
* **Why it's medium leverage:** We saved the system from crashing, but degraded the user experience.

*Speaker Notes: This is better. We've added a balancing loop. The system is now resilient to self-destruction. But the business is still losing money because we are turning customers away during peaks.*

---

## Slide 25: High Leverage (System Structure)

* **Action:** Shift from synchronous request/response to **Event-Driven Architecture**.
* **Result:** User clicks "Buy" $\rightarrow$ Success Screen. Order goes into an async queue. DB processes safely in the background.
* **Why it's high leverage:** We fundamentally changed the flow of information.

*Speaker Notes: High leverage changes the paradigm. By introducing a queue (a stock), we completely decoupled the user traffic flow from the database write flow. The bottleneck is gone. The system now absorbs the spike entirely.*

---

## Slide 26: Takeaways for Architects

1. **Stop chasing events:** Look beneath the iceberg for structures causing the patterns.
2. **Audit your loops:** Where are your hidden retry storms? Where do you lack backpressure?
3. **Seek high leverage:** Don't just throw RAM at a problem; redesign the information flow.

*Speaker Notes: The next time your system behaves strangely, don't just ask "what broke?" Ask "what structure allowed this break to happen?" Thank you for your time, and enjoy the rest of KCDC!*


---

Additional Content:
* https://donellameadows.org/wp-content/userfiles/Leverage_Points.pdf
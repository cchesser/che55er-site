# Why Your Systems Behave Strangely
## Systems Thinking for Software Architects

**45-minute talk**

---

# Slide 1 — Why Your Systems Behave Strangely

## Systems Thinking for Software Architects

- Understanding non-linear behavior in distributed systems
- Moving from reactive events to structural architecture
- Applying Donella Meadows' 12 Leverage Points to software design

### Speaker Notes

Welcome everyone. Today we're going to look at distributed software through the lens of systems thinking.

We'll explore why systems surprise us, why traditional root-cause thinking can be misleading, and how architects can intervene at different levels of a system.

The goal isn't to memorize Meadows' twelve points. The goal is to develop a way of asking better architectural questions.

---

# Slide 2 — The Outage We've All Caused

## We've all fixed one thing and broken another

- Fixed a performance issue → broke a downstream service
- Added database connections → exhausted database memory
- Auto-scaled a service → triggered a cascading outage
- Increased retries → made an overloaded dependency worse
- Added a queue → eventually filled the queue

### Speaker Notes

Ask for a show of hands.

"Who has ever fixed a performance problem only to discover that you created another problem somewhere else?"

The important observation is that these are often not bad engineering decisions.

They are locally rational decisions that interact badly with the larger system.

---

# Slide 3 — Linear Expectations vs. Non-Linear Reality

## The mental model we start with

### Linear thinking

`A → B`

- Direct cause and effect
- Doubling the input should roughly double the output
- Find the broken component and fix it

### Systems reality

`A → B → C → A`

- Components influence one another
- Feedback loops amplify or dampen behavior
- Systems have thresholds and boundary conditions
- Small changes can produce disproportionate outcomes

### Speaker Notes

Software engineering trains us to think in terms of deterministic relationships: input, processing, output.

But distributed systems behave dynamically.

A service can look perfectly healthy at 70% utilization and behave completely differently at 90% when queues start growing, latency increases, retries begin, and downstream dependencies become saturated.

The behavior of the whole system cannot always be understood by looking at individual components independently.

---

# Slide 4 — The "Root Cause" Trap

## The question we instinctively ask

> "What broke?"

### Traditional view

- Find the failed component
- Identify the triggering event
- Find the person or deployment responsible
- Fix the immediate cause

### Systems view

> "What conditions allowed this event to become an outage?"

- What feedback loops amplified it?
- What information was missing?
- What delays prevented intervention?
- What rules constrained our response?
- What architectural structure made the failure possible?

### Speaker Notes

We want a single root cause because it gives us a satisfying story.

But complex systems often don't have one meaningful root cause.

A deployment may have triggered the incident, but the deployment didn't create the system's lack of backpressure, its retry behavior, its missing telemetry, or its dependency structure.

The architect's question is not just "what failed?"

It is "why did the system behave this way?"

---

# Slide 5 — The Iceberg Model

## Events are the tip of the system

### Events — React

> "Checkout timed out at 2:15 PM."

### Patterns — Anticipate

> "Checkout timeouts spike during every promotional event."

### System Structure — Design

> "Synchronous database calls, unbounded retries, and no backpressure create a predictable failure mode."

### Speaker Notes

We naturally respond to events because events page us.

But events are the visible surface.

Patterns tell us what keeps happening.

System structure explains why the pattern keeps happening.

Architects have the greatest leverage when they move down the iceberg—from reacting to events toward changing the structures that generate them.

---

# Slide 6 — System Anatomy: Stocks, Flows & Delays

## A useful mental model for software

### Stocks — What accumulates?

- Pending requests
- Queue messages
- Open connections
- Memory
- Work waiting for workers
- Cached data

### Flows — What changes the stocks?

- Requests/second
- Messages/second
- Consumption rate
- Connection creation rate
- Processing throughput

### Delays — How long before the system knows or reacts?

- Detection delay
- Network latency (DNS 😊)
- Polling interval
- Queue wait time
- Deployment propagation
- Human response time

### Speaker Notes

A stock is something that accumulates.

A flow changes the stock.

If incoming work exceeds processing capacity, the stock grows.

This gives us a simple question we can apply to almost any distributed system:

"What is accumulating, what is moving, and how quickly does the system respond?"

---

# Slide 7 — The Retry Storm

## A reinforcing feedback loop

```text
Dependency slows
      ↓
Client times out
      ↓
Client retries
      ↓
Dependency receives more load
      ↓
Dependency slows further
      ↺
```

### The important observation

The original failure may be small.

The system's feedback structure turns it into a large failure.

### Speaker Notes

This is a classic reinforcing loop.

The output of the system feeds back into the system in a way that increases the original problem.

A 100-millisecond latency problem can become a cascading outage when every client interprets the delay as a reason to send more traffic.

This is where Release It! becomes particularly useful: patterns such as timeouts, circuit breakers, bulkheads, backpressure, and exponential backoff are mechanisms for controlling system dynamics.

---

# Slide 8 — Balancing Feedback Loops

## The stabilizer

### Reinforcing loop

`Failure → Retry → More Load → More Failure`

### Balancing loop

`Failure → Detect → Reduce Load → Recover`

### Architectural patterns

- Circuit breakers
- Rate limiting
- Backpressure
- Load shedding
- Health checks
- Autoscaling
- Fail-fast behavior

### Speaker Notes

A balancing loop counteracts a change.

The circuit breaker is a particularly clear example.

Instead of allowing a failing dependency to continue pulling traffic into itself, the system detects the unhealthy condition and changes behavior.

The architecture now contains a mechanism that actively tries to restore stability.

---

# Slide 9 — The Leverage Ladder

## From tuning the system to questioning the system

```text
HIGH LEVERAGE
     ▲
     │   1–3  QUESTION THE SYSTEM
     │
     │   4–6  CHANGE THE SYSTEM
     │
     │   7–9  CONTROL THE SYSTEM
     │
     │  10–12  TUNE THE SYSTEM
     │
     ▼
LOW LEVERAGE
```

### The four tiers

1. **Tune** — parameters, buffers, structure
2. **Control** — delays and feedback loops
3. **Change** — information, rules, self-organization
4. **Question** — goals, paradigms, transcendence

### Speaker Notes

Donella Meadows describes twelve places where we can intervene in a system, ranked from relatively low leverage to extremely high leverage.

We're going to walk up the ladder.

The interesting question isn't whether a particular intervention is "good."

The question is:

"What part of the system are we actually changing?"

---

# Slide 10 — TUNE: #12 Parameters

## Change the number

### System intervention

Change a constant, threshold, or parameter.

### Software examples

- HTTP timeout
- Retry count
- Thread-pool size
- Database connection limit
- Cache TTL
- CPU/memory allocation
- Batch size
- Rate-limit value

### Example

`DB connection pool: 50 → 200`

### Question

> "Did we change the system, or did we change how hard we push the system?"

### Speaker Notes

These interventions are useful and often necessary.

But they are the easiest place to stop.

Increasing a connection pool may relieve one bottleneck while transferring the problem to the database.

Changing a timeout can make a request more likely to succeed—but it can also cause more resources to remain occupied while waiting.

Parameters are not bad.

They are simply low-leverage.

---

# Slide 11 — TUNE: #11 Buffers

## Absorb the mismatch

### System intervention

Increase or redesign the capacity of a stabilizing stock.

### Software examples

- Kafka topics
- Message queues
- Worker pools
- Connection pools
- Caches
- Dead-letter queues
- Thread pools

### Example

```text
Producers
    ↓
┌──────────────┐
│    QUEUE     │  ← buffer
└──────┬───────┘
       ↓
   Consumers
```

### Question

> "Are we solving the imbalance—or storing the imbalance?"

### Speaker Notes

Buffers buy time.

They allow producers and consumers to operate at different rates.

But a buffer doesn't make the underlying flow problem disappear.

If the inflow consistently exceeds the outflow, the stock eventually fills.

This is a useful place to distinguish resilience from capacity: sometimes we want a large buffer; sometimes a large buffer simply delays the failure.

---

# Slide 12 — TUNE: #10 Structure of Stocks & Flows

## Change how work moves

### System intervention

Change the topology through which data, requests, and resources flow.

### Examples

- Monolith → services
- Synchronous calls → asynchronous messaging
- Central database → partitioned/sharded data
- Direct calls → event bus
- Single region → multi-region
- Origin server → CDN

### Example

```text
Before:

Checkout → Inventory DB → Payment DB → Order DB
```

```text
After:

Checkout
    ↓
OrderCreated
    ↓
 Event Bus
 ├── Inventory
 ├── Payment
 ├── Fulfillment
 └── Analytics
```

### Question

> "What if the problem isn't capacity—but the path the work is taking?"

### Speaker Notes

This is the first major jump in leverage.

We're no longer changing a number.

We're changing the structure through which work moves.

This is architecture in the traditional sense—but systems thinking gives us a way to reason about why the structural change affects behavior.

---

# Slide 13 — CONTROL: #9 Delays

## Change how quickly the system knows and reacts

### Examples

- Polling → events
- Batch → streaming
- Synchronous → asynchronous
- Slow telemetry → real-time telemetry
- Long deployment cycles → continuous delivery
- Long reconciliation intervals → faster feedback

### Example

```text
Polling:

Producer → State
             ↑
          every 60s
```

```text
Event-driven:

Producer → Event → Consumer
```

### Question

> "How long does the system operate on stale information?"

### Speaker Notes

Delays aren't inherently bad.

Sometimes we deliberately introduce delays to stabilize a system.

The key is to understand the delay relative to how quickly the system itself is changing.

A control loop that reacts too slowly can overshoot.

A control loop that reacts too quickly can oscillate.

---

# Slide 14 — CONTROL: #8 Balancing Feedback

## Strengthen the mechanism that pushes the system back toward stability

### Release It! examples

**Circuit Breaker**

`Failure rate ↑ → Stop calls → Dependency recovers`

**Rate Limiter**

`Demand ↑ → Restrict inflow → Protect capacity`

**Backpressure**

`Consumer slows → Producer slows → Queue stabilizes`

**Load Shedding**

`Capacity exhausted → Reject work → Protect core system`

### Question

> "Where does the system notice that it is becoming unstable—and what does it do about it?"

### Speaker Notes

This is where Release It! fits beautifully into systems thinking.

These patterns aren't just defensive programming techniques.

They are feedback mechanisms.

They sense something about system state and change system behavior in response.

---

# Slide 15 — CONTROL: #7 Reinforcing Feedback

## Reduce the gain of the runaway loop

### Classic example: retries

```text
Failure
   ↓
Retry
   ↓
More traffic
   ↓
More failure
   ↺
```

### Interventions

- Exponential backoff
- Jitter
- Retry budgets
- Circuit breakers
- Request coalescing
- Cache stampede protection
- Bounded concurrency

### Key distinction

**#8 — Strengthen the balancing loop**

> "Stop when the dependency is unhealthy."

**#7 — Weaken the reinforcing loop**

> "Don't let failure generate synchronized additional load."

### Speaker Notes

This distinction is worth emphasizing.

A circuit breaker and exponential backoff may both improve resilience, but they intervene differently.

One strengthens a balancing mechanism.

The other reduces the gain of a reinforcing mechanism.

Systems thinking gives us language for seeing the difference.

---

# Slide 16 — CHANGE: #6 Information Flows

## Give the system information it didn't have

### Before

```text
Service A
    │
    └── request timeout
            ↓
        "Something failed"
```

### After

```text
Service B

Latency       1.8s
Error rate    23%
Queue depth   91%
Capacity      82%
Health        DEGRADED
```

### Software examples

- OpenTelemetry
- Distributed tracing
- Metrics
- Event streams
- Service discovery
- Runtime configuration
- Dependency graphs
- Audit trails
- Cost telemetry

### Question

> "Who knows what—and when do they know it?"

### Speaker Notes

Information changes what decisions are possible.

Observability is often presented as a way for humans to understand systems.

But information can also feed automated control loops.

A system that knows its dependencies are degraded can behave differently from one that only discovers failure after a timeout.

---

# Slide 17 — CHANGE: #5 Rules

## Change what the system is allowed to do

### Examples

- API contracts
- Rate limits
- Resource quotas
- RBAC
- Network policies
- SLO policies
- Admission policies
- Data-retention rules
- Tenant isolation

### Example rule

> "No tenant may consume more than 20% of shared capacity."

This changes behavior without changing the underlying infrastructure.

### Question

> "What rules cause locally rational behavior to produce globally healthy—or unhealthy—behavior?"

### Speaker Notes

Rules are constraints, incentives, boundaries, and permissions.

A rate limit is not merely a number.

The existence of a rule saying "this actor cannot consume unlimited capacity" changes the dynamics of the system.

---

# Slide 18 — CHANGE: #4 Self-Organization

## Give the system the ability to change itself

### Kubernetes-style reconciliation

```text
Desired State
      ↓
  Controller
      ↓
 Actual State
      │
      └──── observe ────┐
                         ↓
                   Reconcile
                         ↺
```

### Examples

- Kubernetes controllers
- Operators
- GitOps
- Autoscaling
- Service discovery
- Automated canary deployment
- Self-healing infrastructure
- Plugin architectures

### Question

> "Who has the authority to change the structure of the system?"

### Speaker Notes

This is a major jump.

The system isn't simply executing a fixed architecture.

It contains mechanisms that can change the architecture or configuration in response to changing conditions.

Kubernetes is a great example: desired state is declared, and controllers continually work to make reality conform to that state.

---

# Slide 19 — QUESTION: #3 Change the Goal

## The most powerful architectural question

Consider:

> "Checkout must synchronously confirm inventory before responding."

What is the actual goal?

Maybe:

> "Never sell inventory we don't have."

Those are very different requirements.

### Old goal

```text
Checkout
   ↓
Synchronously confirm inventory
   ↓
Respond
```

### New goal

```text
Never oversell
     ↓
Reservation system
     ↓
Eventually consistent workflow
```

### Question

> "Are we optimizing the right thing?"

### Speaker Notes

Goals determine architecture.

If the goal changes, many architectural constraints disappear.

Perhaps the system doesn't actually need synchronous inventory confirmation.

Perhaps the business requirement is preventing overselling, while synchronous consistency was simply one implementation assumption.

This is where architecture becomes requirements engineering and systems thinking.

---

# Slide 20 — QUESTION: #2 Change the Paradigm

## Challenge the assumptions underneath the architecture

### Paradigm shift

**From:**

> "A distributed system should behave like a local function call."

**To:**

> "Distributed systems are inherently asynchronous and failure-prone."

That shift enables:

- Event-driven workflows
- Eventual consistency
- Sagas
- Compensation
- Idempotency
- Immutable events
- Explicit failure states

### Another example

**From:** "Servers should be repaired."

**To:** "Infrastructure should be replaceable."

### Question

> "What assumption are we treating as a law of nature?"

### Speaker Notes

A paradigm is the mental model from which the system's goals, rules, and architecture emerge.

This is much more difficult to change than a parameter.

It may require changing organizational assumptions, product requirements, architecture practices, and even the way teams understand failure.

---

# Slide 21 — QUESTION: #1 Transcend Paradigms

## The architecture is not the truth

### The trap

```text
Monolith
   ↓
Microservices
   ↓
Serverless
   ↓
Event-driven
   ↓
"What's next?"
```

The goal is not to discover the one true architecture.

### The higher-leverage capability

> **Recognize that every architecture is a model—and models can become wrong.**

### Architectural capabilities that enable change

- Replaceable components
- Stable interfaces
- Protocols over implementations
- Composable systems
- Explicit boundaries
- Evolutionary architecture
- Ability to experiment and reverse decisions

### Question

> "How easily can we change our minds?"

### Speaker Notes

This is the hardest leverage point to make concrete.

Don't present it as "use technology X."

The point is epistemic.

We need to recognize that our architectural assumptions are provisional.

The highest-leverage architectural capability may be the ability to abandon a paradigm when the system tells us that the paradigm no longer fits.

---

# Slide 22 — Release It! Is Systems Thinking in Disguise

## Resilience patterns are control mechanisms

| Release It! Pattern | Systems Thinking |
|---|---|
| Timeout | Limits exposure to delay |
| Circuit Breaker | Strengthens balancing feedback |
| Bulkhead | Isolates stocks and flows |
| Rate Limiter | Controls inflow |
| Backpressure | Couples production to capacity |
| Load Shedding | Protects system stability |
| Fail Fast | Reduces failure-handling delay |
| Exponential Backoff | Reduces reinforcing-loop gain |
| Jitter | Prevents synchronized amplification |

### Key idea

> **Release It! gives us patterns for controlling system dynamics. Meadows gives us a vocabulary for understanding why they work.**

### Speaker Notes

This is an important synthesis.

Release It! gives architects concrete engineering patterns.

Systems thinking gives us a way to reason about the dynamics those patterns are controlling.

The patterns become easier to understand when we see the system as a collection of stocks, flows, delays, and feedback loops.

---

# Slide 23 — Case Study: The Database Bottleneck

## One problem, increasingly powerful interventions

| Leverage | Intervention | What changes? |
|---|---|---|
| **#12 Parameter** | Increase DB connections | A number |
| **#11 Buffer** | Add queue capacity | Accumulation |
| **#10 Structure** | Decouple DB-dependent workflows | Flow topology |
| **#9 Delay** | Reduce detection/processing delay | Feedback timing |
| **#8 Feedback** | Circuit breaker / backpressure | System stability |
| **#7 Feedback** | Backoff / jitter | Amplification |
| **#6 Information** | Publish health/capacity signals | What the system knows |
| **#5 Rules** | Enforce quotas / admission control | What actors may do |
| **#4 Self-organization** | Automatically adapt capacity/workflow | Who can change structure |
| **#3 Goal** | Optimize for reservation rather than synchronous confirmation | What success means |
| **#2 Paradigm** | Treat distributed work as asynchronous | Mental model |
| **#1 Transcendence** | Make the architecture intentionally evolvable | Ability to change models |

### Speaker Notes

Walk from the bottom of the table toward the top.

Don't imply that #12 is bad and #1 is always good.

The point is that each intervention changes a different aspect of the system.

The architectural question is:

"Which level of intervention does this problem actually require?"

---

# Slide 24 — Interactive Exercise: What Would You Do?

## Black Friday checkout is failing

### Current conditions

- Requests are timing out
- Inventory DB is at 95% CPU
- Clients retry three times
- Queue depth is growing
- Autoscaling is adding checkout instances

### Ask the audience

> **"What would you change?"**

Let the audience propose solutions.

### Then classify the answers

- Increase timeout → **#12**
- Increase DB capacity → **#12**
- Increase queue → **#11**
- Change synchronous flow → **#10**
- Faster health signals → **#9 / #6**
- Circuit breaker → **#8**
- Backoff + jitter → **#7**
- Better telemetry → **#6**
- Admission control → **#5**
- Automated adaptation → **#4**
- Change checkout goal → **#3**
- Change distributed-systems assumptions → **#2**

### Speaker Notes

This should be interactive.

Don't immediately give them the ladder.

Let the audience generate the answers first.

Then classify their answers.

The goal is for them to discover that most of our instinctive responses live at the bottom of the ladder.

---

# Slide 25 — Post-Incident Analysis: Climb the Ladder

## Don't stop at "fix the thing"

After an incident, ask:

### 1. What happened?

**Event**

> Checkout timed out.

### 2. What pattern produced it?

**Pattern**

> Timeouts happen during traffic spikes.

### 3. What structure produced the pattern?

**Structure**

> Synchronous dependency + retries + no backpressure.

### 4. What feedback loops were involved?

**Dynamics**

> Retry amplification + insufficient balancing mechanisms.

### 5. What intervention are we proposing?

**Leverage**

> Parameter? Buffer? Feedback? Information? Rule? Goal? Paradigm?

### Speaker Notes

This changes the postmortem conversation.

If every action item is "change configuration X," we may be fixing symptoms.

A stronger postmortem asks whether we can introduce a new feedback mechanism, improve information flow, change a rule, or eliminate the structural condition that created the recurring pattern.

---

# Slide 26 — Architectural Takeaways

## Systems Thinking changes the questions architects ask

### 1. Beware the Event Trap

> Events are symptoms. Structure generates behavior over time.

### 2. Find the Loops

> Ask what amplifies failure and what counteracts it.

### 3. Look for Stocks, Flows & Delays

> What accumulates? What moves? How quickly does the system react?

### 4. Climb the Leverage Ladder

> Don't stop at parameters when the problem is structural.

### 5. Question the Goal

> Sometimes the highest-leverage architectural change is changing what "success" means.

### Final thought

> **Good architecture doesn't just survive failure. It changes the dynamics that produce failure.**

### Speaker Notes

Systems thinking gives architects a richer vocabulary for reasoning about resilience.

Instead of asking only "What component failed?" we ask:

"What structure created this behavior?"

Instead of only adding capacity, we ask:

"What flow is overwhelming what stock?"

Instead of simply adding retries, we ask:

"What feedback loop are we creating?"

And instead of assuming our architecture is correct, we ask:

"How easily can we change our minds?"

---

# Appendix — Meadows' 12 Leverage Points

## Lowest → Highest Leverage

**12. Constants, parameters, numbers**

Such as subsidies, taxes, standards.

**11. The sizes of buffers and other stabilizing stocks, relative to their flows**

**10. The structure of material stocks and flows**

Such as transport networks and population age structures.

**9. The lengths of delays, relative to the rate of system change**

**8. The strength of negative feedback loops, relative to the impacts they are trying to correct against**

**7. The gain around driving positive feedback loops**

**6. The structure of information flows**

Who does and does not have access to what kinds of information.

**5. The rules of the system**

Such as incentives, punishments, and constraints.

**4. The power to add, change, evolve, or self-organize system structure**

**3. The goals of the system**

**2. The mindset or paradigm out of which the system—its goals, structure, rules, delays, and parameters—arises**

**1. The power to transcend paradigms**

### Source

Donella Meadows, *Leverage Points: Places to Intervene in a System*.


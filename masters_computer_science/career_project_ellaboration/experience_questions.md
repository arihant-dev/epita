# Behavioral Interview Questions and Answers

> **Techniques used:** STAR (Situation, Task, Action, Result), KISS (Keep It Simple, Stupid)
> **Context:** 4+ years as a Software Engineer at Thriwe (Delhi, India), building Go microservices for a benefits-as-a-service platform serving 2-3M users and enterprise clients (HSBC, Mastercard). Currently pursuing Master's at EPITA, Paris.

---

## Table of Contents

1. [Tell Me About Yourself](#1-tell-me-about-yourself)
2. [Leadership & Ownership](#2-leadership--ownership)
3. [Technical Decision-Making](#3-technical-decision-making)
4. [Failure & Learning](#4-failure--learning)
5. [Conflict & Disagreement](#5-conflict--disagreement)
6. [Prioritization Under Pressure](#6-prioritization-under-pressure)
7. [Teamwork & Collaboration](#7-teamwork--collaboration)
8. [Mentoring & Developer Productivity](#8-mentoring--developer-productivity)
9. [Handling Ambiguity](#9-handling-ambiguity)
10. [Adaptability & Growth](#10-adaptability--growth)
11. [System Design & Architecture](#11-system-design--architecture)
12. [Motivation & Career](#12-motivation--career)
13. [Projects](#13-projects)

---

## 1. Tell Me About Yourself

### Q: Walk me through your background.

> **Tip:** 60-90 seconds. Present → Past → Future.

I'm currently pursuing a Master's in Computer Science at EPITA in Paris, specializing in distributed systems and cloud computing. Before this, I spent over four years as a Software Engineer at Thriwe, a benefits-as-a-service platform in India serving around 2-3 million users with enterprise clients like HSBC and Mastercard.

At Thriwe, I was part of a 16-developer team where I led the architecture and development of several core microservices — including notifications, discovery, admin, and inventory — as we migrated from a legacy PHP monolith to a Go microservices architecture. I built event-driven pipelines with Kafka processing 5,000+ events per second, designed a centralized notification service handling 10,000+ daily messages, and implemented CI/CD pipelines that cut deployment time by 67%.

I'm now looking for an internship starting March 2026 where I can apply my backend and distributed systems experience in a new environment, and continue growing as an engineer.

---

## 2. Leadership & Ownership

### Q: Tell me about a time you took ownership of a critical system.

**Situation:** Early in my career at Thriwe, our CTO approached me with a need for a centralized notification service. The requirement was clear — build it as a reusable Go library so any developer could plug it into their service and enable SMS, email, or WhatsApp notifications without re-implementing the integration logic.

**Task:** I needed to design and build this system from scratch — defining the architecture, choosing providers, and ensuring reliability for a platform serving millions of users across India.

**Action:** I designed a fan-out architecture using AWS SNS as the entry point, which distributed messages to separate Lambda functions per channel (SMS via MSG91, marketing emails via Mailchimp, transactional/OTP emails via Amazon SES, and WhatsApp). For reliability, I implemented the pipeline as SNS → EventBridge → SQS with configurable retries and Dead Letter Queues for failed messages. Each Lambda was deployed multi-region for fault tolerance, and I built in idempotency keys to prevent duplicate notifications. I packaged the entire client-side as a Go library — any developer could import it, initialize with their service name, and call `Send()` with the channel and template. Monitoring was handled through CloudWatch logs and alarms.

**Result:** The service handled 10,000+ notifications per day. The library was adopted across multiple teams and significantly reduced integration time for new notification channels. The architecture sustained 99.9% availability under peak loads. This was one of my first major ownership experiences and it taught me to think in terms of developer experience, not just system correctness.

---

### Q: Describe a project where you were the technical lead.

**Situation:** Thriwe's legacy PHP monolith was creating frequent production incidents — slow APIs, hidden bugs surfacing as fire-drill JIRA tickets, and a redundant codebase that made every change risky. Leadership decided to migrate to a microservices architecture in Go.

**Task:** I was the lead architect on four of the ten new services — Notification Service, Discovery Service, Admin Service, and Inventory Service — while also contributing as an engineer across the others.

**Action:** We decomposed the monolith into ten bounded services: Discovery, Inventory, Data Pipeline, Auth, Feedback, Notification, Payment, Data Analytics, Voucher & Coupon, and Admin. The hardest part was defining data boundaries. The legacy system had tightly coupled database queries spanning what should have been separate domains. I had to redesign how data was accessed — introducing cross-service pagination where a single user query might aggregate results from Discovery and Inventory databases. For data migration, we did systematic project-by-project hard cutovers rather than a strangler-fig pattern, migrating one vertical at a time over roughly three months per project.

**Result:** Critical API response times improved by 30%. Production incidents dropped significantly as each service had clear ownership and isolated failure domains. The migration also forced us to document service boundaries and contracts, which became the foundation for our team's API design standards going forward.

---

## 3. Technical Decision-Making

### Q: Tell me about a difficult technical decision you made and how you approached it.

**Situation:** During the monolith-to-microservices migration at Thriwe, we had to decide how to handle data that was previously joined across tables in a single database but now lived in separate services with separate databases.

**Task:** I needed to find a pattern that allowed services to remain independently deployable while still supporting user-facing features that required data from multiple domains — for example, a search result that needed both discovery metadata and inventory availability.

**Action:** I evaluated several approaches: API gateway aggregation, a Backend-For-Frontend (BFF) layer, and client-side composition. I chose service-to-service REST calls with cursor-based pagination at the API layer. For cases where latency was critical, we introduced Kafka-based data replication so that the Discovery service maintained a lightweight read-replica of inventory availability. I documented the trade-offs for the team — consistency guarantees, added operational complexity of Kafka, and fallback behavior when a downstream service was unavailable.

**Result:** The approach gave us sub-200ms response times on search endpoints while keeping services loosely coupled. The pagination pattern became a team standard. More importantly, I learned that the "right" architecture is the one your team can operate — not the most theoretically elegant one.

---

### Q: Why did you choose Kafka for your event-driven pipelines?

**Situation:** We needed a messaging backbone for our analytics pipelines that would feed near real-time metrics to banking partners like HSBC and Mastercard.

**Task:** Select a messaging system that could handle 5,000+ events per second, support multiple consumer groups (analytics, reporting, audit), and integrate with our existing Go services.

**Action:** Kafka was already in use for some internal pipelines, and our CTO had deep operational experience with it. I evaluated alternatives (SQS, RabbitMQ) but Kafka's partitioned log model was a natural fit — we needed replay capability for backfills, multiple independent consumers reading the same stream, and high throughput with ordering guarantees per partition. Our four-person team set up topic partitioning by client and event type. We tracked transaction volumes, redemption rates, user engagement patterns, and conversion funnels for banking partners, while retaining all raw events for internal analysis.

**Result:** The pipeline processed 5,000+ events per second reliably. Banking partners got near real-time dashboards. We did encounter a consumer failure incident early on that caused data loss (covered in the failure section below), which led us to add consumer health monitoring, idempotent processing, and offset commit safeguards.

---

## 4. Failure & Learning

### Q: Tell me about a time you failed. What did you learn?

**Situation:** I was responsible for migrating a golf course booking system from our legacy PHP monolith to the new Go microservices architecture. I had built the new system, so I understood it well, but I had limited context on the legacy system's full feature set.

**Task:** Execute a complete migration — all booking, search, and management features — with a hard cutover and no parallel running period.

**Action:** I took notes and attended knowledge-transfer sessions with the original PHP developers to map every feature. I built the new service, tested it, and we cut over. However, I missed two critical features buried deep in the legacy codebase: an alternative golf course recommendation engine (triggered when a user's first choice was unavailable) and a guest quota handling system (which enforced limits on how many guests a member could bring per booking period).

**Result:** In the first month after cutover, we experienced roughly 25% overbooking because the guest quota logic was absent, and user conversion dropped because the recommendation fallback was missing. We had to compensate affected customers, resulting in significant revenue loss. I fixed it by going back to the legacy system myself — not relying on second-hand knowledge — and creating a comprehensive feature map documenting every feature, dependency, data flow, and edge case. I fixed both features over a weekend and deployed them.

**Learning:** I now treat migrations as adversarial — I assume the documentation is incomplete and the legacy system has hidden behavior. I create feature maps before writing a single line of new code. This experience also taught me that understanding the business logic is just as important as understanding the technical implementation.

---

### Q: Describe a production incident you were involved in. How did you handle it?

**Story 1 — Notification Cascade Failure:**

**Situation:** Our notification service used Mailchimp for marketing emails. Mailchimp is known for intermittent downtime in the Indian region. During one such outage, the email Lambda kept failing and retrying, which caused the SQS queue to back up massively.

**Task:** The cascading effect was severe — not just emails, but all notification channels were impacted because the backed-up queue and exponentially increasing Lambda invocations consumed our AWS concurrency limits. Transactional SMS and OTP messages stopped going out entirely.

**Action:** I immediately implemented manual throttling to stop the bleeding, then worked on a permanent fix. I introduced circuit breakers per notification channel — if a provider's failure rate exceeded a threshold within a time window, we'd open the circuit and route messages to the DLQ for later retry, rather than letting them consume resources. I also separated the Lambda concurrency pools per channel so that one channel's failure could never starve another.

**Result:** After implementing circuit breakers and isolated concurrency pools, we never had a cross-channel cascade again. The system maintained 99.9% availability even during subsequent provider outages. This became my go-to example for why you design for failure from day one, not after the first outage.

---

**Story 2 — Kafka Consumer Data Loss:**

**Situation:** Our Kafka analytics pipeline experienced a consumer failure incident where the consumer process crashed mid-batch.

**Task:** When the consumer restarted, it resumed from the last committed offset — but because we were auto-committing offsets before processing was complete, a batch of events was marked as consumed but never actually processed. This created a silent data gap in our analytics.

**Action:** I switched from auto-commit to manual offset commits that only fire after successful processing and persistence. I added idempotency keys to each event so that if a consumer processed the same event twice during recovery, it would be deduplicated at the storage layer. I also set up consumer lag monitoring with alerts — if any consumer group fell behind by more than a configurable threshold, we'd get notified before it became a data quality issue.

**Result:** We eliminated silent data loss entirely. Consumer lag alerts caught two subsequent issues before they impacted downstream analytics. The idempotent processing pattern was adopted across all our Kafka consumers as a team standard.

---

## 5. Conflict & Disagreement

### Q: Tell me about a time you disagreed with a teammate or manager.

**Situation:** During the initial release of our Admin Service, we were in the testing phase for a milestone demo to stakeholders. A few days before the deadline, leadership pushed a feature forward from the next milestone — row-level locking on the booking dashboard — into the current sprint. This meant we had to implement a non-trivial concurrency feature while simultaneously completing QA on existing functionality.

**Task:** I disagreed with the decision to squeeze in a new feature during the testing phase. My concern was that it would destabilize the code we'd already validated and risk the demo.

**Action:** I raised my concerns clearly: the risk of regression, the compressed timeline, and the potential impact on the demo. But I also proposed a solution rather than just objecting. I suggested we containerize the new feature's development in an isolated environment with its own test suite, and run QA on the existing codebase in parallel without merging until both streams were green. I worked with the team to split responsibilities — two engineers continued testing the stable build while two (including me) implemented the locking feature in a feature branch with independent CI.

**Result:** We delivered both the stable demo and the row-locking feature on time. The parallel containerized approach became a pattern we reused for similar last-minute scope additions. I learned that disagreement is productive when you pair it with an alternative — saying "no" is less useful than saying "yes, and here's how we can de-risk it."

---

## 6. Prioritization Under Pressure

### Q: How do you handle competing priorities and tight deadlines?

**Situation:** Same scenario as the Admin Service milestone above — we were in the testing phase with a deadline for a stakeholder demo when an unplanned feature (row-level locking) was pulled forward into our sprint.

**Task:** I had to balance three competing priorities: complete QA on the existing features (non-negotiable for the demo), implement the new locking feature (business priority from leadership), and maintain code quality (no shortcuts that would create tech debt for the next sprint).

**Action:** I triaged by impact and risk. The demo was the hard deadline, so the stable build's QA was priority one. The locking feature was important but could not be allowed to destabilize existing code — so I isolated it. I split the team's workload explicitly: assigned the two engineers most familiar with the existing code to QA, and took on the new feature with one other developer. I set up a simple rule — no merges to main until both workstreams had passing CI independently. I communicated timelines and risks clearly to the product manager daily, so there were no surprises.

**Result:** Both delivered on time. The key lesson: when everything is urgent, separate the streams of work physically (branches, containers, CI pipelines) so that one priority can't contaminate another. And over-communicate with stakeholders — they'd rather hear "we're tracking but it's tight" than be surprised by a delay.

---

## 7. Teamwork & Collaboration

### Q: How do you work with cross-functional teams and external stakeholders?

**Situation:** At Thriwe, we served enterprise clients like HSBC and Mastercard through a benefits-as-a-service platform. While we didn't interact with the enterprises directly, we worked closely with product managers who translated client requirements and with third-party vendors who provided the on-ground fleet for services like airport transfers.

**Task:** Ensure that engineering deliverables met business requirements defined through a multi-layered stakeholder chain — enterprise client → product manager → engineering.

**Action:** We used a structured Agile workflow with JIRA milestones broken into stories and tasks. I participated in sprint planning, where I'd push back on ambiguous stories — asking for acceptance criteria, edge cases, and priority rankings before committing to a sprint. For vendor integrations (airport transfer fleet management), I worked directly with vendor technical teams to define API contracts, error handling, and SLA expectations. I documented integration patterns so that when we onboarded new vendors, the process was repeatable.

**Result:** Structured sprint planning and clear API contracts reduced mid-sprint scope changes. Vendor integration time decreased as we built a library of integration patterns. I learned that in a B2B2C environment, the most important engineering skill is translating business requirements into technical constraints — and pushing back early when the two don't align.

---

### Q: Describe your working style. How would your colleagues describe you?

My former colleagues would describe me as methodical at the start and fast once I have context. I tend to take calculated, deliberate steps when entering a new problem space — reading the code, understanding the constraints, mapping dependencies — before I start executing. But once I have that mental model, I move quickly and tend to deliver beyond what was initially scoped.

My role on a team sits between thinking and executing. I'm not purely an architect who draws diagrams, and I'm not purely a coder who takes tickets. I'm the person who wants to understand *why* we're building something, designs the approach, and then builds it myself. I'm most effective when I can own a system end-to-end — from schema design to deployment pipeline.

---

## 8. Mentoring & Developer Productivity

### Q: Tell me about a time you improved your team's productivity.

**Situation:** At Thriwe, onboarding new developers took roughly two weeks. Each engineer had to manually set up the development environment — installing dependencies, configuring database connections, seeding test data, and getting all interconnected services running locally. The process was undocumented and relied on tribal knowledge.

**Task:** Reduce onboarding friction so new hires could contribute meaningful code faster.

**Action:** I standardized the entire local development environment using Docker Compose. I created a single `docker-compose.yml` that spun up all core services (API servers, PostgreSQL, Redis, Kafka) with pre-seeded data and health checks. I wrote a setup guide and a Makefile with common commands (`make dev`, `make test`, `make seed`). I also onboarded junior engineers personally, walking them through the architecture, the service boundaries, and our deployment pipeline — not just "how to run it" but "why it's built this way."

**Result:** Onboarding time dropped from 2 weeks to 2 days. New developers could run the entire platform locally within hours and submit their first PR within their first week. The Docker Compose setup also became the foundation for our CI pipeline, ensuring parity between local and CI environments. Junior engineers I mentored became independent contributors faster because they understood the system's architecture, not just their assigned service.

---

## 9. Handling Ambiguity

### Q: Tell me about a project where requirements were unclear or kept changing.

**Situation:** We were building the first version of the Admin Dashboard — a central tool for operations teams to monitor bookings, execute actions on booking data, and view analytics. The requirements were fluid because no one had a clear picture of what "admin capabilities" meant at scale.

**Task:** Deliver a functional admin dashboard despite shifting requirements, particularly around how admin actions (cancellations, modifications, status changes) should propagate back to the source services.

**Action:** Initially, we implemented admin actions as direct API calls to internal service endpoints. This worked for simple operations, but as requirements evolved, we hit limitations — some actions needed to trigger cascading updates across multiple services, and we were constrained by whether the target service had exposed the right API. I recognized this was an architectural dead end. I proposed switching to a Kafka-based event pipeline where admin actions were published as events, and each downstream service consumed and reacted to the events relevant to it. This decoupled the admin service from the internal API surface of every other service. I also took ownership of the state management responsibility — our team became the owner of admin action state transitions, rather than depending on downstream services to report back.

**Result:** The event-driven approach handled requirements changes naturally — adding a new admin action meant adding a new event type, not negotiating a new API endpoint with another team. The architecture scaled to support the full operations team. I learned that when requirements keep changing, the answer is usually to invest in a more flexible architecture rather than constantly patching a rigid one.

---

## 10. Adaptability & Growth

### Q: Tell me about a time you had to learn something new quickly.

**Situation:** I joined Thriwe as an iOS mobile developer. About nine months in, the company hired a new CTO who had a vision to migrate from the legacy PHP monolith to a Go microservices architecture. He needed developers who could make the transition quickly.

**Task:** Transition from iOS/Swift development to backend Go development and become productive enough to help lead the microservices migration.

**Action:** I immersed myself in Go — not just the language syntax, but the ecosystem: concurrency patterns (goroutines, channels), the standard library's HTTP server, database/sql, and testing conventions. I started with small internal tools to build confidence, then took on progressively larger services. Within a few months, I was the lead architect on four core microservices. I also invested time in understanding distributed systems concepts — CAP theorem, eventual consistency, idempotent operations — because I realized that knowing Go wasn't enough; I needed to think differently about how systems communicate.

**Result:** The transition reshaped my entire career trajectory. Going from mobile to backend forced me to think about systems holistically — not just "does this screen render correctly" but "what happens when this service is down, when the database is slow, when the network partitions." It was the single biggest professional growth moment in my career and directly led to my interest in distributed systems, which is now my area of focus at EPITA.

---

### Q: Why did you leave a stable career to pursue a Master's degree in France?

I'd been at Thriwe for over four years, and I'd grown significantly — from an iOS developer to a backend engineer leading microservices architecture. But I was getting comfortable, and I recognized that comfort is the beginning of stagnation.

I'd always wanted to study abroad — for the cultural exposure, the different engineering perspectives, and the experience of building a life in a new country. Earlier in my career, I didn't have the financial means or the professional experience to make it worthwhile. By 2024, I had both. EPITA's program in Paris was strong in the areas I wanted to deepen — distributed systems, advanced algorithms, cloud computing — and France offered a culture and language I was genuinely curious about.

It was a calculated risk: I traded a senior role and a steady income for the chance to grow in ways that a familiar environment couldn't offer. I don't regret it.

---

## 11. System Design & Architecture

### Q: How do you approach designing a new system or service?

My approach follows a pattern:

1. **Understand the business context:** What problem are we solving, who is the user, and what are the non-negotiable requirements (latency, consistency, availability)?
2. **Map the data model:** Before writing code, I sketch the entities, their relationships, and where the data boundaries lie. This is where most architectural mistakes happen — getting the data model wrong cascades into everything.
3. **Define failure modes:** I ask "what happens when X is unavailable?" for every external dependency. This drives decisions about retries, circuit breakers, DLQs, and fallback behavior.
4. **Start simple, evolve with evidence:** I don't over-engineer upfront. I build the simplest thing that works, instrument it with monitoring, and let production data guide optimization. The notification service started without circuit breakers — we added them after a real incident proved they were needed.
5. **Document decisions:** I write down the trade-offs we considered and why we chose what we chose. This is as valuable as the code itself, especially in a team setting.

---

### Q: How do you ensure reliability in the systems you build?

Reliability at Thriwe was a constant concern because we served enterprise clients with SLA expectations. My approach:

- **Idempotency everywhere:** Every write operation gets an idempotency key. If a message, API call, or event is processed twice, the system produces the same result. This was a lesson from our Kafka data loss incident.
- **Circuit breakers and bulkheads:** After the Mailchimp cascade failure, I never deploy a system that calls an external provider without a circuit breaker. I also isolate failure domains — one provider's outage should never affect another channel.
- **Dead Letter Queues:** Every asynchronous pipeline has a DLQ. Failed messages go there for inspection and replay, not into a void.
- **Monitoring before features:** I set up CloudWatch alarms, consumer lag alerts, and health endpoints before building business features. You can't fix what you can't see.
- **Chaos testing mindset:** I think about what happens when things go wrong before they go wrong. This doesn't mean I run formal chaos engineering — it means I ask "what if this dependency is slow?" and design accordingly.

---

## 12. Motivation & Career

### Q: Why are you interested in this role / company?

> **Tip:** Customize this for each company. Template below.

I'm drawn to [Company] because of [specific technical challenge / product / team culture]. My background in building Go microservices, event-driven pipelines, and cloud infrastructure at scale aligns with [specific aspect of their stack or product]. I'm particularly interested in [specific area — e.g., observability, distributed data systems, developer tools] because [connect to your experience].

I'm looking for a team where I can contribute immediately with my backend and systems experience, while also learning from engineers who push me to think differently. My Master's program has given me time to deepen my theoretical foundations — now I want to apply them in a production environment again.

---

### Q: Where do you see yourself in 5 years?

I want to be a senior engineer or tech lead working on distributed systems at scale — ideally in a company where infrastructure decisions directly impact user experience. I'm drawn to problems like real-time data processing, service reliability, and developer platform tooling.

Longer term, I see myself growing into a role where I can influence technical strategy — not just building systems, but deciding which systems to build and how they fit together. My experience at Thriwe showed me that the most impactful engineers aren't the ones who write the most code, but the ones who make the right architectural decisions early.

---

## 13. Projects

### Q: Tell me about a personal project you're proud of.

**Forest BD Viewer (Go, Next.js, PostGIS, Redis, Docker):**

**Situation:** During my studies at EPITA, I was learning about French geography — the regions, departments, communes — and simultaneously exploring PostGIS for geospatial querying. At Thriwe, I'd run a proof-of-concept using PostGIS to identify sectors where we could replace third-party vendors with our own fleet for airport transfers, so I had prior exposure to spatial data problems.

**Task:** I wanted to build a full-stack geospatial visualization platform that let users explore French forest ecosystems and land parcels on an interactive map, combining two government datasets (IGN's BD Foret V2 forest inventory and Etalab's Cadastre parcel registry).

**Action:** I built a Go backend with GraphQL (gqlgen) and the Echo framework, a Next.js frontend with Mapbox GL JS, PostGIS for spatial queries, and Redis for Mapbox Vector Tile (MVT) caching. The hardest challenges were:
- **Data ingestion:** The government data source had recently changed formats, so I had to fall back to a community-maintained GitHub copy with correct GeoJSON. I wrote Python scripts using ogr2ogr and psycopg2 for ingestion.
- **LiDAR performance:** LiDAR data requests were timing out for large regions, so I broke the selected area into smaller sub-regions, fetched 16MB chunks per goroutine concurrently, and combined them for serving.
- **Rendering at scale:** Instead of serving raw GeoJSON (which is enormous for thousands of forest parcels), I used Mapbox Vector Tiles (MVT) for bandwidth-efficient rendering with client-side styling.

**Result:** The platform supports zoom-level progressive disclosure (region → department → commune → forest parcels → cadastre), polygon analysis (draw a boundary and get forest coverage stats, species breakdowns, parcel counts), and multi-language support (EN/FR). It's a project that combines my backend systems experience with genuine curiosity about my new home country.

---

**Command Shell (Go):**

Built a POSIX-compliant shell from scratch in Go as part of a CodeCrafters challenge, aligned with my Unix shell scripting course at EPITA. I deliberately avoided standard library functions for process management (`os/exec`) to force myself to work with system calls directly — `fork`, `exec`, `wait`, signal handling (`SIGINT`, `SIGTSTP`).

This taught me how Unix process groups work, how file descriptors are inherited across forks, how pipe chains are constructed (each `|` creates a new pipe, forking a child whose stdout is wired to the next child's stdin), and how shells manage job control. It gave me a much deeper understanding of what happens beneath the abstractions I use daily and the OS primitives that power container runtimes and orchestration tools I work with.

---

## Quick Reference: Common Behavioral Questions Mapped to Stories

| Question Theme | Primary Story | Backup Story |
|---|---|---|
| Leadership / Ownership | Notification Service (built from scratch) | Migration lead on 4 services |
| Technical Decision | Data boundaries in migration | Kafka vs SQS selection |
| Failure / Learning | Golf course migration (25% overbooking) | Kafka consumer data loss |
| Production Incident | Mailchimp cascade → circuit breakers | Kafka offset → idempotency |
| Conflict / Disagreement | Admin Service row-locking scope push | — |
| Prioritization | Parallel testing + feature dev | — |
| Teamwork / Collaboration | B2B2C stakeholder management | Vendor API integrations |
| Mentoring / Productivity | Docker Compose onboarding (2wk → 2d) | Junior engineer mentoring |
| Ambiguity | Admin Dashboard evolving requirements | — |
| Adaptability | iOS → Backend → Distributed Systems | India → France career move |
| System Design | Notification architecture (SNS fan-out) | Forest BD Viewer (MVT + PostGIS) |
| Personal Project | Forest BD Viewer | Command Shell |

---

## Tips for Delivery

1. **Time yourself:** Each answer should be 1.5-2.5 minutes. Practice with a timer.
2. **Lead with impact:** Start with the result or the stakes, then go into details. "We were overbooking by 25%..." grabs attention faster than "So we had this PHP system..."
3. **Quantify everything:** 30% faster APIs, 10K notifications/day, 2 weeks → 2 days, 25% overbooking, 5K events/second. Numbers make stories credible.
4. **Own your failures:** The golf course migration story is your strongest answer precisely *because* you admit the mistake clearly, quantify the impact, and show what you changed.
5. **Connect to the role:** End every answer with what you learned and how it applies to the job you're interviewing for.
6. **Be honest about scope:** You worked in a 16-person dev team, not a 500-person org. This is a strength — you had end-to-end ownership that engineers at large companies rarely get.
7. **French context:** If interviewing in France, mention your willingness to learn French (A2, enrolled in B1 intensive) and your genuine interest in French culture (the Forest BD Viewer project is proof).

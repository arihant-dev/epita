# Implementation Brief: Green IT — Avoiding Software Obsolescence
## Agent / Researcher Document — Presentation Construction Guide

> **Purpose:** This document tells any agent or researcher exactly how to build each slide of the Green IT presentation. It defines the structure, the analytical frameworks to apply, the data sources to use, what to watch out for, and what "done" looks like for each deliverable.

---

## 0. Overall Framing

**Topic:** How to avoid software obsolescence — through the lens of Green IT.

**Audience:** EPITA Master's class — technically literate, sustainability-aware, expects rigorous frameworks not just bullet points.

**Total slides:** 5 substantive slides (+ optional title/conclusion). Each slide is independently coherent but builds on the previous.

**Tone:** Academic-practitioner hybrid. Frameworks must be correctly applied (not decorative). Real data preferred over estimates. Acknowledge uncertainty where it exists.

**Key distinction to maintain throughout:** software obsolescence ≠ hardware failure. Software-driven hardware retirement is the core mechanism we are analysing. Never conflate the two.

---

## 1. SLIDE 1 — Strategic Theoretical Analysis

### What this slide must contain

Four analytical outputs, presented compactly:
1. **Implementation steps** (how an organisation actually does this)
2. **Cost-benefit analysis** (economic framing)
3. **SWOT analysis** (strategic positioning)
4. **Impact on IT performance** (operational framing)

---

### 1.1 Implementation Steps

**Order of steps — use this sequence, do not reorder:**

1. Audit existing application portfolio against sustainability/lifecycle criteria
2. Adopt a green software design standard (Green Software Foundation SCI, Blue Angel criteria, or ISO 14044 LCA)
3. Redesign for modularity and backwards compatibility (no forced full rebuilds)
4. Commit to extended Long-Term Support (LTS) windows — minimum target: 7 years security patches
5. Remove software locks, parts pairing, and contractual repair restrictions
6. Open-source software at end-of-life so community can continue maintenance
7. Measure and disclose digital emissions (Software Carbon Intensity — SCI metric)
8. Seek third-party certification (Blue Angel DE, TCO Certified, EU Ecodesign label)

**What to watch out for:** Steps 5 and 6 are often omitted by companies claiming green credentials but still practising planned obsolescence. Flag this explicitly on the slide.

---

### 1.2 Cost-Benefit Analysis

**Frame it as: short-term cost vs. long-term gain.**

| Item | Cost | Benefit |
|---|---|---|
| Extended software support | Higher engineering hours | Avoided device replacement cost (HW procurement) |
| Modular architecture refactor | Upfront redesign investment | Lower future maintenance cost, fewer full rebuilds |
| Open-sourcing EOL software | Legal/IP review overhead | Community takes over maintenance cost |
| Certification (Blue Angel etc.) | Audit fees, process change | Market differentiation, regulatory compliance buffer |
| Delayed hardware refresh cycles | Compatibility management | CapEx reduction (devices last longer) |

**Key figure to include if available:** ThoughtWorks reported 20–30% energy reduction for clients migrating to renewable-backed cloud as part of green software practices. Use as a concrete benefit anchor.

**What to watch out for:** The cost side is visible and immediate; the benefit side is diffuse and long-term. The slide must address this asymmetry explicitly — it is the main reason organisations resist implementation.

---

### 1.3 SWOT Analysis

Apply to an organisation choosing to implement anti-obsolescence practices:

| | Helpful | Harmful |
|---|---|---|
| **Internal** | **Strengths:** Reduced IT CapEx over time; compliance with EU Right-to-Repair (ahead of mandate); brand differentiation; lower technical debt from modular design | **Weaknesses:** Short-term engineering cost increase; organisational inertia; legacy codebases resistant to modularisation; requires retraining dev teams |
| **External** | **Opportunities:** EU Ecodesign & Right-to-Repair legislation creates market pressure (all competitors must comply by 2026); growing consumer preference for sustainable brands (Nielsen: 66% willing to pay more); Green Public Procurement criteria (Germany, France) favour certified software | **Threats:** Competitors using greenwashing to appear compliant without real change; open-source maintenance communities may be fragile; chipset vendor EOL timelines outside your control (structural technical constraint) |

**What to watch out for:** Do not make the SWOT generic. Every cell must be specific to software obsolescence, not just "Green IT" broadly.

---

### 1.4 Impact on IT Performance

Frame along three axes:

- **Energy efficiency:** Lightweight, optimised software reduces CPU/RAM demand → lower energy per operation → extended hardware useful life without performance degradation.
- **Security posture:** Extended patch support closes the vulnerability window that opens when software goes EOL. Unpatched legacy software is a primary enterprise security risk.
- **Operational resilience:** Modular architectures are easier to maintain, update, and audit. Fewer cascading failures from monolithic upgrades.

**Tension to acknowledge:** There is a real trade-off — older hardware running newer (heavier) software may under-perform. The solution is writing *leaner* software, not just *longer-supported* software. These are related but distinct goals.

---

## 2. SLIDE 2 — Ecological Theoretical Analysis: KAYA Equation

### What this slide must contain

- The KAYA identity applied to software obsolescence
- A modular breakdown of each variable
- Three scenarios (A, B, A vs B over time) projected to 2030 / 2040 / 2050
- A rebound effect check

---

### 2.1 The KAYA Identity

**Standard form:**

```
CO₂ = P × (GDP/P) × (E/GDP) × (CO₂/E)
```

Where:
- **P** = Population
- **GDP/P** = Economic output per capita (affluence)
- **E/GDP** = Energy intensity of the economy
- **CO₂/E** = Carbon intensity of energy

**Adapted form for software obsolescence:**

Software obsolescence primarily affects the **E/GDP** term (energy intensity) and indirectly the **CO₂/E** term (through device manufacturing emissions). Expand the equation for ICT specifically:

```
CO₂_ICT = P × (Devices/P) × (E/Device) × (CO₂/E)
```

Where:
- **Devices/P** = Number of active digital devices per person (↑ with obsolescence, ↓ with longevity)
- **E/Device** = Energy consumed per device lifetime (includes embodied energy of manufacturing)
- **CO₂/E** = Carbon intensity of the energy powering those devices

**Software obsolescence acts on:**
- `Devices/P` ↑ — by forcing premature replacement, increasing the total device fleet
- `E/Device` ↑ — manufacturing a new device consumes 70–80% of its lifetime energy budget upfront (embodied energy); avoiding this is the largest lever
- `CO₂/E` — indirect: device manufacturing relies on fossil-fuel-heavy supply chains in Asia

---

### 2.2 Modular Variable Evaluation — Build this table

For each variable, assess: current value, realistic change by 2030/2040/2050, and the mechanism by which anti-obsolescence software affects it.

| Variable | 2025 baseline | 2030 | 2040 | 2050 | Mechanism |
|---|---|---|---|---|---|
| Global device fleet (Devices/P) | ~4 devices/person (connected) | Grows without intervention | Stabilises with longevity policy | Could decline | Extended SW support → fewer replacement cycles |
| Embodied carbon per new device | ~70 kg CO₂e (smartphone) | Gradual reduction via manufacturing efficiency | Larger reduction if fleet growth slows | Significant reduction | Fewer devices manufactured |
| Device operational energy (E/Device) | ~3–5 kWh/year (smartphone) | Efficiency gains (chips) | Further efficiency | Near-zero marginal with renewables | Lightweight SW reduces idle compute |
| Grid carbon intensity (CO₂/E) | ~0.4 kg CO₂/kWh global avg | ~0.3 (grid decarbonisation) | ~0.15 | ~0.05–0.1 | Decoupled from SW obsolescence — exogenous |
| E-waste volume | 62 Mt (2022) | 82 Mt if nothing changes | ? | ? | SW longevity is primary lever to reduce this |

**What to watch out for:** The grid decarbonisation variable (CO₂/E) will improve regardless of software policy. The agent must isolate what software obsolescence specifically affects — primarily the device fleet size and embodied energy, not operational energy per se. Do not conflate the two.

---

### 2.3 Scenario Construction

**Scenario A — Do nothing (business as usual):**
- Device refresh cycles remain ~2–3 years for smartphones, ~4–5 for laptops
- E-waste grows to 82 Mt by 2030, potentially 100+ Mt by 2040
- Embodied carbon from device manufacturing remains the dominant ICT emission category
- Software continues to drop support for functional hardware

**Scenario B — Implement anti-obsolescence:**
- Device refresh cycles extend to 7–10 years (Fairphone model: 60.9% of devices active 4+ years after purchase)
- New device manufacturing demand falls proportionally
- E-waste growth flattens; potential absolute decline by 2040 if EU regulation scales globally
- Embodied carbon per unit of ICT service delivered drops significantly

**A vs B over time (longitudinal comparison):**
- Present as a diverging chart: both lines start at the same point (2025), Scenario A curves upward, Scenario B curves flat then downward
- Key inflection point: 2030 (EU Right-to-Repair mandatory across all member states; chipset vendors begin designing for longer kernel support under regulatory pressure)
- By 2050: gap between A and B represents cumulative avoided embodied carbon

**Rebound effect check (B vs start):**
- **Definition:** Rebound = efficiency gains that encourage increased consumption, wiping out the savings.
- **Risk here:** If software longevity makes devices cheaper to run, organisations may deploy *more* devices per person, expanding the fleet and negating the per-device savings.
- **Check:** Compare Scenario B's fleet size trajectory against Scenario A. If `Devices/P` grows faster in B due to "affordability" of longevity, a rebound is occurring.
- **How to assess:** Plot `Total fleet CO₂` (not per-device CO₂) for both scenarios. If B's total fleet CO₂ by 2040 is not clearly below A's, there is a rebound problem.
- **Mitigation levers for rebound:** Policy caps on device-per-person ratios (EPR fees on new devices), organisational BYOD-reduction policies, institutional device pooling.

**What to watch out for:** The rebound effect is the most intellectually rigorous part of this slide. Do not skip it. Professors will ask about it. The point is: a strategy that looks good on per-device metrics can still fail on aggregate metrics. B must be better than start on *total system* CO₂, not just *per-device* CO₂.

---

## 3. SLIDE 3 — Other Ecological and Social Benefits

### What this slide must contain

Two sections: (A) 9 Planetary Boundaries, (B) Social Benefits.

---

### 3.1 Ecological: 9 Planetary Boundaries (Stockholm Resilience Centre framework)

**The 9 boundaries:**

Map software obsolescence impact to each:

| Boundary | Impact from SW obsolescence | Direction with anti-obsolescence |
|---|---|---|
| **Climate change** | Embodied carbon from device manufacturing; operational energy | ↓ (primary lever) |
| **Biosphere integrity** | Mining for rare earth elements (cobalt, lithium, coltan) destroys habitat | ↓ (fewer devices manufactured) |
| **Land-system change** | Mining operations require land clearance | ↓ |
| **Freshwater use** | Semiconductor fabrication is water-intensive | ↓ |
| **Biogeochemical flows (N/P)** | E-waste processing contaminates soil/water with toxic materials | ↓ |
| **Ocean acidification** | Indirect: CO₂ emissions from device lifecycle | ↓ |
| **Atmospheric aerosol loading** | Informal e-waste processing (burning) releases particulates | ↓ |
| **Novel entities (chemical pollution)** | Lead, mercury, cadmium in e-waste — most toxic waste stream per unit | ↓ (strongest direct link) |
| **Stratospheric ozone depletion** | Some refrigerants in data centre cooling; manufacturing chemicals | Minor / indirect |

**What to watch out for:** Not all boundaries are equally affected. The strongest direct links are: Climate change, Novel entities (e-waste toxicity), Biosphere integrity (mining). Present these three as primary, the others as secondary. Do not claim equal impact across all nine — that weakens credibility.

**Key fact to anchor the slide:** In a typical landfill, e-waste can account for 70% of total toxicity despite being a small fraction of volume. This is the Novel Entities boundary violation in concrete terms.

---

### 3.2 Social Benefits

Frame under three dimensions:

**1. Environmental justice / intergenerational equity**
- E-waste disproportionately affects the Global South, where informal processing occurs under hazardous conditions (workers, often children, exposed to lead, cadmium, mercury)
- Software obsolescence in the Global North generates toxic burden in the Global South
- Anti-obsolescence directly reduces this inequity

**2. Digital inclusion**
- Extended software support keeps older, cheaper devices functional longer
- Enables lower-income users and developing economies to access functional devices without buying new hardware
- Open-source OS alternatives (LineageOS, /e/OS) are free — eliminating the "pay for support" barrier

**3. Labour and supply chain ethics**
- Fewer devices manufactured → less demand for coltan, cobalt, lithium from conflict-affected supply chains (DRC, etc.)
- Fairphone example: actively sources fairtrade/conflict-free materials as a model; anti-obsolescence reduces the frequency of needing these supply chains at all

**What to watch out for:** The social benefits section is often treated as an afterthought. It must be presented with the same rigour as the ecological section. Use the "technological justice" framing — who bears the cost of our upgrade culture, and who benefits from reducing it.

---

## 4. SLIDE 4 — Real World: Identifying Companies and Actual Implications

### What this slide must contain

- Companies actually implementing anti-obsolescence
- Their actual strategic implications (not theoretical)
- Their actual ecological outcomes (measured, not estimated)

---

### 4.1 Company Matrix

Build a comparative table:

| Company | What they actually do | Strategic implication | Ecological outcome (measured) |
|---|---|---|---|
| **Fairphone** | Modular smartphone, 7yr OS / 8yr security, endorses community ROMs | Niche market (100k–145k units/yr), profitable as of 2024, premium price (€549) | 60.9% of devices active 4+ yrs post-purchase; avg longevity 4.7 yrs (exceeds their own target) |
| **Framework Laptop** | Upgradeable CPU/RAM/ports, sold spare parts openly | Growing share in sustainability-conscious professional market | Fewer full laptop replacements; modular upgrades instead of whole-unit purchase |
| **Murena / /e/OS** | Open-source Android fork, extending Fairphone 3 support beyond Android EOL (post Aug 2026) | No commercial incentive for obsolescence; purely longevity-driven | Keeps 2019 devices operational in 2026+ — 7+ year device lifespan demonstrated |
| **LineageOS** | Community ROM for 200+ device models, including abandoned flagships | Decentralised, non-profit — immune to commercial obsolescence pressures | Demonstrably extends device life by 3–5 years beyond manufacturer EOL |
| **German Environment Agency** | Blue Angel label for software (2022 desktop, 2024 mobile/server) | Creates a verified certification market; procurement criterion for public sector | Measurable criteria: energy consumption per task, hardware requirements documentation |

---

### 4.2 Strategic Implications (actual, not theoretical)

- The EU market is moving: right-to-repair is law (2024), ecodesign for smartphones is in force (June 2025). Manufacturers who ignored this are now in compliance mode, not choice mode.
- Fairphone proved the modular model is commercially viable at small scale but has not scaled to mainstream. The EU mandate is the forcing function that large players cannot avoid.
- Open-source community ROMs are the most authentic anti-obsolescence mechanism but require technical literacy — not a mass-market solution alone.
- Green Public Procurement (GPP) criteria in Germany, France mean that software sold to government must meet sustainability criteria — a significant B2G market pressure.

---

### 4.3 Actual Ecological Outcomes (where data exists)

**What to watch out for:** This is the hardest section to populate honestly. Most companies report aspirational targets, not measured outcomes. The agent must distinguish clearly:
- **Measured:** Fairphone device longevity data (4.7 yr avg, independently verifiable)
- **Estimated:** Embodied carbon savings from extended device life (can be modelled from ADEME or lifecycle databases)
- **Claimed but unverified:** Most corporate sustainability reports — flag these explicitly

If hard data is unavailable, say so. Use language like "no independently verified outcome data available for this claim."

---

## 5. SLIDE 5 — Greenwashing: Claims vs Reality (Specific Company)

### What this slide must contain

Focus on **one company** in depth. Apple is the strongest case study due to volume of evidence, ongoing legal proceedings, and the contrast between their sustainability marketing and actual practices.

---

### 5.1 Greenwashing Framework

Use a Claims vs Evidence matrix:

| Claim made | Evidence supporting it | Evidence against it | Verdict |
|---|---|---|---|
| 100% renewable energy for all Apple operations | Data centres and stores across 44 countries verified renewable | Manufacturing supply chain (Foxconn etc.) not included; Scope 3 emissions massive | Partial — operations only, not product lifecycle |
| Apple Watch "carbon neutral" | Some offset projects cited | Lawsuits filed; offsets criticised as "questionably effective"; additionality unclear | Contested — legally challenged |
| USB-C switch is eco-friendly | Reduces cable waste going forward | All pre-2020 Lightning accessories instantly obsolete; forced new purchases | Greenwashing — eco framing for commercially-driven transition |
| Software updates improve device life | True for first few years | Older iPhones refused OS updates; parts pairing via serial number restricts repair; investigated by Paris prosecutor (Dec 2023) | Planned obsolescence — contradicts stated sustainability goals |
| "We weren't given the mission to make this repairable" | (Quote from senior iPhone engineer, cited in Brian Merchant's *The One Device*) | Apple has actively opposed Right-to-Repair legislation | Direct evidence of anti-longevity design philosophy |

---

### 5.2 What to Look for When Analysing Any Company's Claims

**Red flags (likely greenwashing):**
- Green operational claims (data centres) combined with planned obsolescence products
- Carbon neutrality via offsets without emissions reduction
- Market-based vs location-based emissions divergence (Microsoft and Google both show this)
- Opposition to right-to-repair legislation while claiming sustainability leadership
- No independently verified third-party certification

**Green flags (likely authentic):**
- Long software support commitments with contractual weight (Fairphone's published 8-year commitment)
- Third-party certification: Blue Angel (Germany), TCO Certified, EU Ecodesign compliance with repairability score
- Open-sourcing EOL software so community can continue maintenance
- Endorsing and not obstructing community ROM projects
- Publicly funded, non-commercial actors (German Environment Agency, open-source projects)

**What to watch out for:** The greenwashing slide should not become a generic corporate-bashing exercise. It must use the Claims vs Evidence matrix structure with specific, sourced examples. Unsourced claims on either side must be excluded.

---

## 6. Cross-Slide Guidelines and Quality Checks

### Data sourcing rules

- Prefer: Stockholm Resilience Centre (Planetary Boundaries), ADEME (French environment agency for LCA data), Green Software Foundation (SCI metric), EU Commission publications, peer-reviewed sources
- Use with caution: Corporate sustainability reports (flag as self-reported)
- Avoid: Unsourced statistics, round numbers without citations, claims older than 5 years in a fast-moving field

### Visual design principles for slides

- Each slide: one primary framework (SWOT, KAYA, 9 Boundaries) + data points anchoring it
- Avoid decorative charts — every chart must encode data that cannot be expressed in a sentence
- For the KAYA slide: a diverging line chart (Scenario A vs B, 2025–2050) is mandatory; the scenario table alone is insufficient
- For the Planetary Boundaries slide: a radar/spider chart or annotated boundary diagram is conventional and expected
- For the greenwashing slide: the Claims vs Evidence matrix is more compelling than bullet points

### Language discipline

- "Software obsolescence" vs "planned obsolescence" — use both but distinguish. Planned = intentional. Software obsolescence = the broader phenomenon including unintentional cases.
- "Embodied carbon" = CO₂ from manufacturing a device. "Operational carbon" = CO₂ from using it. Keep these separate — most of the opportunity is in embodied carbon.
- "Rebound effect" must be named and addressed. Do not avoid it because it complicates the narrative. Addressing it strengthens the analysis.
- Scenario labels: use "Scenario A (BAU)" and "Scenario B (intervention)" consistently across all slides.

### What "done" looks like for each slide

| Slide | Done when... |
|---|---|
| Slide 1 (Strategic) | All 4 frameworks present; cost-benefit has at least 2 concrete figures; SWOT has no generic cells |
| Slide 2 (KAYA) | Equation written in ICT-adapted form; all variables named and mapped; 3 scenarios described; rebound check explicitly addressed |
| Slide 3 (Ecological/Social) | 9 Boundaries mapped with honest impact differentiation; social section has all 3 dimensions; no boundary overclaimed |
| Slide 4 (Real World) | At least 4 companies with measured (not estimated) outcomes where available; strategic implications link to actual policy timelines |
| Slide 5 (Greenwashing) | One company analysed in depth; Claims vs Evidence matrix populated; red/green flag framework present |

---

## 7. Suggested Research Sequence for an Agent

1. Lock the KAYA variable table first — it sets the quantitative backbone for slides 2 and 3.
2. Build the company matrix (Slide 4) using Fairphone's annual report, EU Commission publications, and Green Software Foundation documentation.
3. Run the Apple greenwashing matrix (Slide 5) using: Paris prosecutor press releases, Apple's own Environment Progress Reports, HOP Association filings, Merchant's *The One Device*.
4. Populate the 9 Planetary Boundaries impact table (Slide 3) using Stockholm Resilience Centre's own published boundary status and ADEME lifecycle data.
5. Synthesise the strategic frameworks (Slide 1) last — they should reflect the empirical findings from slides 2–5, not precede them.

---

*Document version: 1.0 — prepared for Green IT class, EPITA Paris. Refine as new regulatory data emerges (EU Right-to-Repair transposition deadline: July 2026).*
# Project Management Principles — Lecture 3
## Scope (Perimeter) Management & Requirement Management

### Overview
This lecture covers scope management techniques with a focus on the Delphi Technique, scope baseline concepts, and practical steps for defining and controlling project scope.

---

## Delphi Technique
The Delphi Technique is an iterative, expert-based method used to reach consensus on complex decisions (e.g., estimates for cost, schedule, or risk).

Key characteristics:
- Multiple-step method used to estimate future demand, cost, schedule, or risks
- Involves a panel of subject-matter experts
- High level of anonymity for participants to avoid peer pressure or bias
- Facilitated and iterative through questionnaire rounds

### Delphi Method Process
1. Problem identification  
2. Selection of experts  
3. Design questionnaire(s)  
4. Round 1: collect individual expert responses  
5. Analyze responses and provide anonymized feedback  
6. Subsequent questionnaire rounds to converge toward consensus  
7. Finalize consensus and document results

### Components
- Panel of experts  
- Facilitator (or moderator)  
- Questionnaires (anonymous)  
- Iterative rounds and feedback  
- Anonymity to reduce bias

### Benefits & Limitations
- Benefits: reduces groupthink, leverages expert knowledge, useful for forecasting and estimation  
- Limitations: can be time-consuming; success depends on expert selection and good facilitation

---

## Project Management Triangle
Time — Cost — Quality (scope interacts with these constraints; often shown as Scope, Time, Cost)

---

## Goals vs Objectives
A goal is a high-level statement of intent (the destination).  
An objective is a specific, measurable milestone on the way to the goal.

### SMART Criteria for Objectives
- S — Specific  
- M — Measurable  
- A — Achievable  
- R — Relevant  
- T — Time-bound

---

## Scope Management (High-level process)
1. Plan Scope Management  
2. Collect Requirements  
3. Define Scope  
4. Create WBS (Work Breakdown Structure)  
5. Validate Scope  
6. Control Scope

### Scoping Assessment
Scoping assessment is performed during project initiation to define project boundaries, major deliverables, assumptions, and constraints.

### Verify Scope
Verify Scope is the formal acceptance of completed deliverables. It ensures deliverables meet agreed requirements and is part of Monitoring & Controlling.

### Deliverables
Deliverables are tangible or intangible outputs that are measurable and provided to stakeholders.

---

## Work Breakdown Structure (WBS)
- WBS decomposes project work into smaller, manageable components.  
- The WBS Dictionary describes each WBS element (scope, deliverables, assumptions, acceptance criteria).

---

## Project Scope Baseline
A scope baseline is the approved version of:
- Project scope statement  
- Work Breakdown Structure (WBS)  
- WBS dictionary

It serves as the reference for project execution and scope control.

How to baseline your project scope:
1. Define scope — write a clear scope statement that lists project scope, major deliverables, assumptions, and constraints.  
2. Create the WBS and WBS dictionary to break work down into manageable components and describe each element.  
3. Approve the scope — obtain stakeholder sign-off and use a documented change control process (e.g., change control board) to handle changes.  
4. Once approved, the scope becomes the project scope baseline and is used to measure and control project performance.

---

## Control Scope Process
Perform Integrated Change Control to manage changes to baselines and project documents.

Perform Integrated Change Control — Inputs, Tools & Techniques, Outputs
- Inputs:
  - Project management plan  
  - Work performance data  
  - Change requests  
  - Project documents  
  - Organizational process assets / EEFs (as applicable)
- Tools & Techniques:
  - Expert judgment  
  - Change control meetings (e.g., Change Control Board)  
  - Impact analysis  
  - Decision-making techniques
- Outputs:
  - Approved change requests  
  - Project management plan updates  
  - Project documents updates  
  - Change log updates

---

## Change Request Process
A change is any modification to a plan, project document, or baseline.

A change request is a formal proposal documenting necessary information for a change.

Typical flow:
1. Identify need for change -> create change request.  
2. Assess the impact on scope, time, cost, quality, risk, and resources.  
3. Perform integrated change control (review by appropriate authority or change control board).  
4. Approve or reject change requests.  
5. If approved — implement changes and update the project management plan and relevant project documents.  
6. Record the decision and update the change log.

---

## Variance
Variance is the difference between planned and actual performance. It helps identify deviations from the project plan.

## Scope Creep
Scope creep refers to uncontrolled changes or continuous growth in a project’s scope without adjustments to time, cost, and resources. It often results from poor initial scope definition or inadequate change control.

Level of Detail
Low      
|
|
|
|
|High


## WBS
 - includes the project management works
 - work package: lowest level of WBS component which can be scheduled, cost estimated, monitored, and controlled
 - WBS Structure can be organized by:
   - Deliverable
   - Phase
   - Responsibility
   - Subprojects

### Time Management - Project Time Management Process
- Definition of activities - Structure de Découpage du Projet(SDP) in French
    - Predecessors and succesors
    - logical resources
    - constraints
    - Non-negotiable dates
- Scheduling Activities
- Resources Estimate
- Duration Estimate
- Develop Schedule
- Control Schedule

## Sequencing
- Precedence Diagramming Method (PDM)
    - Finish to Start (FS)
    - Finish to Finish (FF)
    - Start to Start (SS)
    - Start to Finish (SF)

## PERT NETWORK
- Program Evaluation and Review Technique
- Founded in the 1950s by the US Navy
- Used to analyze and represent the tasks involved in completing a project
- Uses probabilistic time estimates
- Determines the critical path


## Critical Path Method
- Float or slack time is the ampount of time that an activity can be delayed without affecting the project completion date
- Critical Path is the longest path through the network with zero float
- The critical path is also the shortest time in which the project can be completed

## Critical Path Methid
- Total Float = Late Start - Early Start


A -> B
  -> C
       -> D -> E
                -> F -> G
                        -> H


A: 10
B: 3  Predecessor: A
C: 5 Predecessor: B
D: 30 Predecessor: B
E: 12 Predecessor: B & C
F: 8 Predecessor: E
G: 15 

Critical Path: A -> B -> D -> F -> G
            10 + 3 + 30 + 8 + 15 = 66

a->c->e->f->g

10+20+40+20 +10= 100


(P+4*M+O)/6
P- Pessimistic Time
M - Most Likely Time
O - Optimistic Time

Notes
- Proper scoping and baselining can be the difference between a successful and a failed project.  
- Keep scope documentation clear, versioned, and subject to formal change control.
- Lack of proper initial scoping and baselining can lead to scope creep, uncontrolled changes, and project failure.


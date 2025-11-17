### Project Management Practice - Notes - Lecture 6

## Quality Management Process
1. Quality Planning
   - Identify quality requirements and standards for the project and its deliverables.
   - Document how the project will demonstrate compliance with quality requirements.
2. Quality Assurance
   - Apply planned quality activities to ensure that the project employs all processes needed to meet requirements.
   - Focus on process improvement and prevention of defects.
3. Quality Control
   - Monitor and record results of executing the quality activities.
   - Identify ways to eliminate causes of unsatisfactory performance.   

# Quality Management Plan Contains:
- Project Management Approach
- Review of process
- Major control points
- Inspection and acceptance criteria

# Quality indicators
- What are the indicators that will be used to measure quality?

# Quality checklist
- A list of items to inspect to ensure quality standards are met

# Six Sigma
- A data-driven approach and methodology for eliminating defects in any process.
- A Six Sigma process is one in which 99.99966%, 3.4(DPMO - Defects Per Million Opportunities) of all opportunities to produce some feature of a part are statistically expected to be free of defects.
- Focuses on process improvement and variation reduction through the application of Six Sigma improvement projects.
- Uses DMAIC (Define, Measure, Analyze, Improve, Control) methodology for existing processes and DMADV (Define, Measure, Analyze, Design, Verify) for new processes.
- Invented by Motorola in 1986 and popularized by General Electric in the 1990s.


| Sigma level | Sigma (with 1.5σ shift) | DPMO | Percent defective | Percentage yield | Short-term Cpk | Long-term Cpk |
|---:|:---:|---:|---:|---:|---:|---:|
| 1 | −0.5 | 691,462 | 69% | 31% | 0.33 | −0.17 |
| 2 | 0.5 | 308,538 | 31% | 69% | 0.67 | 0.17 |
| 3 | 1.5 | 66,807 | 6.7% | 93.3% | 1.00 | 0.5 |
| 4 | 2.5 | 6,210 | 0.62% | 99.38% | 1.33 | 0.83 |
| 5 | 3.5 | 233 | 0.023% | 99.977% | 1.67 | 1.17 |
| 6 | 4.5 | 3.4 | 0.00034% | 99.99966% | 2.00 | 1.5 |
| 7 | 5.5 | 0.019 | 0.0000019% | 99.9999981% | 2.33 | 1.83 |


- DPMO represents the number of defects in a process per one million opportunities. It is calculated as:
  DPMO = (Number of Defects / (Number of Units * Number of Opportunities per Unit)) * 1,000,000

## Six Sigma Methodologies
1. DMAIC (for existing processes)
    - Define: Identify the problem and project goals.   
    - Measure: Collect data and establish baseline performance.
    - Analyze: Identify root causes of defects and issues.
    - Improve: Implement solutions to address root causes.
    - Control: Monitor the process to ensure improvements are sustained.
2. DMADV (for new processes)
    - Define: Define project goals and customer deliverables.
    - Measure: Measure and identify critical quality characteristics.
    - Analyze: Analyze options to meet customer needs.
    - Design: Design the process or product to meet customer needs.
    - Verify: Verify the design performance and ability to meet customer needs.

# Control Diagrams
- Used to determine whether a manufacturing or business process is in a state of control.
- Consist of a central line (average), upper control limit (UCL), and lower control limit (LCL).
- Points outside the control limits indicate that the process is out of control and requires investigation.
- Help identify trends, shifts, or any unusual patterns in the process over time.

# Structure of a Control Chart
Element             | Description
--------------------|-------------------------------
X Axis              | Time or sequence of observations

Y Axis              | Measured value of the quality characteristic

Central Line (CL)   | Average or mean of the measured values

Upper Control Limit (UCL) | Upper threshold indicating process variation limit

Lower Control Limit (LCL) | Lower threshold indicating process variation limit

Data Points        | Individual measurements plotted over time

- Process is in control if all points are within UCL and LCL and show random patterns.
- Process is out of control if points fall outside UCL or LCL or show non-random patterns.

# Cause -and-Effect Diagram (Ishikawa or Fishbone Diagram)
- The Ishikawa diagram, also known as a fishbone diagram or cause-and-effect diagram, developed by Kaoru Ishikawa, is a tool used for quality management and problem-solving.
- A visual tool used to systematically identify and present possible causes of a specific problem or effect.
- Helps teams brainstorm and categorize potential causes of quality issues.
- Main categories often include: People, Processes, Equipment, Materials, Environment, and Management.
- The diagram resembles a fishbone, with the problem statement at the head and the causes branching off as bones.

Purpose
- To analyze and identify root causes of quality problems.
- To organize brainstorming ideas into categories for easier analysis.
- To support continuous improvement efforts by identifying areas for process enhancement.

Structure
- The head of the fish represents the problem or effect.
- The main bones branching off represent major categories of causes.
- Sub-branches represent specific causes within each category.

** Ishikawa Diagram Example **
- Ishikawa diagrams often follow the "6 Ms" framework for manufacturing:
1. Manpower (People)
2. Methods (Processes)
3. Machines (Equipment)
4. Materials
5. Measurements
6. Mother Nature (Environment)

## Pareto Chart
- A Pareto chart is a type of bar chart that represents the frequency or impact of problems or causes in a process; it is based on the Pareto Principle. Named after Vilfredo Pareto, who observed that roughly 80% of effects come from 20% of causes.
- Based on the Pareto Principle (80/20 rule), which states that roughly 80% of effects come from 20% of causes.
- Helps identify the most significant factors contributing to a problem.
- Bars are arranged in descending order of frequency or impact, with a cumulative line graph overlay to show the cumulative percentage.
- In Six Sigma, Pareto charts are used to prioritize issues for improvement by focusing on the "vital few" causes that contribute most to defects or problems.

** Pareto Chart Example **
- The left vertical axis represents the frequency or count of occurrences.
- The right vertical axis represents the cumulative percentage.
- The horizontal axis lists the categories of causes or problems.
- Bars represent the frequency of each cause, arranged in descending order.
- A line graph shows the cumulative percentage of total occurrences.

## Tests
- Unit Tests
- Integration Tests
- Conversion Tests
- System Tests
- Acceptance Tests
- Performance Tests
- Stress Tests
- Usability Tests

## ISO Standards
- ISO 15504 (SPICE) - Software Process Improvement and Capability Determination

- Process Capability Assement - A process capability assessment evaluates how well a process can produce output that meets specified quality standards or customer requirements.


### Human Resource
9.1 Develop Human Resource Plan
9.2 Set up Project Team
9.3 Manage Project Team

# RACI Matrix
- RACI is a responsibility assignment matrix that outlines the roles and responsibilities of team members in relation to project tasks or deliverables.
- RACI stands for:
  - Responsible: The person(s) who perform the work to complete the task.
  - Accountable: The person who is ultimately answerable for the task's completion and has decision-making authority.
  - Consulted: The person(s) who provide input, expertise, or advice on the task.
  - Informed: The person(s) who need to be kept updated on the task's progress or completion.
- The RACI matrix helps clarify roles, improve communication, and prevent misunderstandings within the project team.

# Benefits of RACI Matrix
- Clarifies roles and responsibilities
- Improves communication among team members
- Prevents role confusion and overlaps
- Enhances accountability for task completion
- Facilitates stakeholder engagement and involvement
- Reduction of risks related to project delays and miscommunication

# Human Resources Plan includes but is not limited to:
- Roles and responsibilities
- Organizational charts
- Staffing management plan
- Training needs
- Recognition and rewards
- Compliance requirements

# Resource Allocation
- Resource allocation is the process of assigning and managing assets in a way that supports an organization's strategic
- Take into account resource availability, project priorities, and deadlines

# Train the Team

# Stages of Development of group(Tuckman, 1965)
1. Forming(inclusion) - Team acquaints and establishes ground rules. Formalities are preserved and members are treated as strangers.
2. Storming(assault) - Members start to communicate their feelings but still view themselves as individuals rather than part of the team. They resist control by group leaders and show hostility.
3. Norming(cooperation) - People feel part of the team and realize that they can achieve work if they accept other viewpoints.
4. Performing(productivity) - The team works in an open and trusting atmosphere where flexibility is the key and hierarchy is of little importance. The team makes most of the decisions against criteria agreed with the leader.
5. Adjourning(termination) - The team disbands after achieving its goals, and members move on to other tasks or projects.
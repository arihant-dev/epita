# Lecture 1 : Software Quality Assurance


## Fundamentals

- Quality Assurance (QA)
- Quality Control (QC)

Testers evaluate the products modules to identify errors, gaps or missing requirements.

It can be done both:
- Manually
- Automatedly

Clean Code - respects and matches the clients requirements, bug-free code, error-free code.

First Manual Testing and then Automation Testing


Regression Testing - Test previous builds as per the features and then test the final version 
for changes and bugs.


### Who does testing?

- Testers
- Automation Engineers
- SW Developer
- Project Manager
- End User Testing (Beta Testing)

It depends on the process and the associated stakeholders of the project(s).

### Quality Control vs Quality Assurance

| Quality Control | Quality Assurance |
|:------------:|:-------------:|
| Focuses on Actual testing (Practical) | Focuses on processes and procedures (Theoritical) |
| Defect Identification | Defect Prevention |
| Product-oriented activities | Process-oriented activities |
| Corrective activities | Preventive activities |
| Time depends on the phase of testing | Takes time |

### Principles of SW Testing

- Testing shows the presence of defects
- Exhaustive Testing - Impossible
- Early Testing
- Defect Clustering - 80% of the defects comes from 20% of the modules
- Pesticide Paradox - Repeating the same tests on a module wouldn't help finding any new bugs
- Testing is Context Dependent
- Absence of Error/Fallacy

### Role of QA/Automation Tester

- Automation QA Tester
- Functional QA Tester

#### Preparation 

- Test planning - test data, mock data, api-keys, auth tokens
- Test execution
- Defect management
- Collaboration

**Confirmation Testing (Report --- RCA --- Follow-Up)**

### Jargon releated to SW Testing:

- Defect - Error found by a tester that reflects a deviation between the requirement and actual test results
- Bug - A defect announced by a tester and acknowledged by a developer
- Reporting - A document containing information on total count of test cases, number of passed,
              failed, unexpected, modules tested, total number of defects and so on.
- Testware - The documentation of all the testing artifacts that guide the overall testing process.

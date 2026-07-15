# Normalization Exercise: Enrollments

## Original Table

| EnrollmentID | StudentID | StudentName | StudentEmail | StudentAddress | Course1Code | Course1Name | Course1Instructor | Course1Credits | Course2Code | Course2Name | Course2Instructor | Course2Credits | Semester | Year |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | S1 | Alice | a@mail.com | Paris | CS101 | Databases | Dr. Smith | 3 | CS102 | Networks | Dr. Jones | 4 | Fall | 2025 |
| 2 | S2 | Bob | b@mail.com | Lyon | CS101 | Databases | Dr. Smith | 3 | NULL | NULL | NULL | NULL | Fall | 2025 |

## Anomalies

**Insert:** Cannot add a new course without a student enrolled.

**Update:** If Dr. Smith changes name, must update all rows with CS101.

**Delete:** If Bob drops CS101, we lose Bob's student info (if only course).

## Normalization

### 1NF: Remove repeating groups

Split Course1 and Course2 into separate rows.

| EnrollmentID | StudentID | StudentName | StudentEmail | StudentAddress | CourseCode | CourseName | Instructor | Credits | Semester | Year |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | S1 | Alice | a@mail.com | Paris | CS101 | Databases | Dr. Smith | 3 | Fall | 2025 |
| 1 | S1 | Alice | a@mail.com | Paris | CS102 | Networks | Dr. Jones | 4 | Fall | 2025 |
| 2 | S2 | Bob | b@mail.com | Lyon | CS101 | Databases | Dr. Smith | 3 | Fall | 2025 |

### 2NF: Remove partial dependencies

Student info depends only on StudentID, not on CourseCode.

**Students**

| StudentID | StudentName | StudentEmail | StudentAddress |
| --- | --- | --- | --- |
| S1 | Alice | a@mail.com | Paris |
| S2 | Bob | b@mail.com | Lyon |

**CourseInfo**

| CourseCode | CourseName | Instructor | Credits |
| --- | --- | --- | --- |
| CS101 | Databases | Dr. Smith | 3 |
| CS102 | Networks | Dr. Jones | 4 |

### 3NF: Remove transitive dependencies

No transitive dependencies remain. Final tables:

**Students**

| StudentID | StudentName | StudentEmail | StudentAddress |
| --- | --- | --- | --- |
| S1 | Alice | a@mail.com | Paris |
| S2 | Bob | b@mail.com | Lyon |

**Courses**

| CourseCode | CourseName | Instructor | Credits |
| --- | --- | --- | --- |
| CS101 | Databases | Dr. Smith | 3 |
| CS102 | Networks | Dr. Jones | 4 |

**Enrollments**

| EnrollmentID | StudentID | CourseCode | Semester | Year |
| --- | --- | --- | --- | --- |
| 1 | S1 | CS101 | Fall | 2025 |
| 1 | S1 | CS102 | Fall | 2025 |
| 2 | S2 | CS101 | Fall | 2025 |

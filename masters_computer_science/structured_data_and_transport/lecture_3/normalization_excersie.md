# Normalization Exercise: Enrollments

## Original Table

- EnrollmentID
- StudentID
- StudentName
- StudentEmail
- Course1Code
- Course1Name
- Course1Instructor
- Course1Credits
- Course2Code
- Course2Name
- Course2Instructor
- Course2Credits
- Semester
- Year

## Anomalies

- Insert: Can't add a course without a student
- Update: If instructor changes, must update every row
- Delete: If student drops course, lose student info

## 1NF: Atomic values

Each cell has one value, no repeating groups.

## 2NF: No partial dependencies

Student info depends only on StudentID.
Course info depends only on CourseCode.

## 3NF: No transitive dependencies

No transitive dependencies here. Done.

## Final Tables

### Students

- StudentID
- StudentName
- StudentEmail

### Instructors

- InstructorID
- InstructorName

### Courses

- CourseCode
- CourseName
- InstructorID
- Credits

### Enrollments

- EnrollmentID
- StudentID
- CourseCode
- Semester
- Year

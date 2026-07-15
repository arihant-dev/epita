# Lecture 3: Structured Data and Transport

 RAM                         RAM
 |                            /\
 |                             |
 |Serilization                 |Deserialization
 |                             |
 \/                          FILE
 FILE

## OSI Model

1. Physical Layer
2. Data Link Layer
3. Network Layer
4. Transport Layer
5. Session Layer
6. Presentation Layer
7. Application Layer

## API (Application Programming Interface)

An application programming interface is a connection between computers
or between computer programs.

- Semantic Versoning = Major.Minor.Patch
- Backward Compatibility != Breaking Change

## Behaviour Driven Development(BDD)

## Database Anomalies

> Anomalies in DBMS are caused by poor management of storing
> everything in the flat database, lack of normalization, data redundancy,
> and improper use of primary or foreign keys.

### Insert Anomaly

> I have no way to represent the addition of something new

### Update Anomaly

> Modifying one thing causes semantically unrelated updates across
> the system (see also: hard / loose coupling)

### Deletion Anomaly

> Deletion of an object can cause unrelated and undesired
> information loss

## Normal Forms

> Normal forms are a set of progressive rules (or design checkpoints)
> for relational schemas that reduce redundancy and prevent data anomalies.

| Constraint | UNF | 1NF | 2NF | 3NF | BCNF | 4NF | 5NF |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Unique rows | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Scalar columns only | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| No partial dependency | ✗ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ |
| No transitive dependency | ✗ | ✗ | ✗ | ✓ | ✓ | ✓ | ✓ |
| FDs begin with superkey | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ | ✓ |
| No non-trivial MVDs | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ |
| Trivial join dependency | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ |

### Simple Explanation with Examples

#### UNF (Unnormalized Form)

- No rules enforced
- Example: Table with repeating groups

| StudentID | Name | Courses |
| --- | --- | --- |
| 1 | Alice | Math, Physics |
| 2 | Bob | Chemistry |

#### 1NF (First Normal Form)

- Each cell contains a single atomic value
- Eliminate repeating groups

| StudentID | Name | Course |
| --- | --- | --- |
| 1 | Alice | Math |
| 1 | Alice | Physics |
| 2 | Bob | Chemistry |

#### 2NF (Second Normal Form)

- Must be in 1NF
- No partial dependency
- Example: StudentID + Course → StudentName is partial
- Fix: Split into separate tables

#### 3NF (Third Normal Form)

- Must be in 2NF
- No transitive dependency
- Example: StudentID → DeptID → DeptName
- Fix: Move DeptName to a Department table

#### BCNF (Boyce-Codd Normal Form)

- Stricter 3NF
- Every determinant must be a candidate key
- Example: Course → Teacher AND Teacher → Course
- Fix: Split so each table has a key as the sole determinant

#### 4NF (Fourth Normal Form)

- Must be in BCNF
- No non-trivial multi-valued dependencies
- Example: StudentID →→ Course AND StudentID →→ Hobby
- Fix: Split into StudentCourses and StudentHobbies

#### 5NF (Fifth Normal Form)

- Must be in 4NF
- Every join dependency is trivial
- Eliminates all decomposition problems
- Cannot be broken down further without loss

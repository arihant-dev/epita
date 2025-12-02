# Relationship Databases

## Notes from Lecture 1 - Modeling

## Databases

Why?

- Difference between file systems and databases
  - File systems: store data in files, limited querying capabilities, data redundancy, and inconsistency.
  - Databases: structured data storage, advanced querying, data integrity, and reduced redundancy.
Goals
- Stores and query data
- Transparent implementation for users
- Efficient data retrieval and manipulation

## Databases: 3 different languages

- Model data: Data definition language (DDL)
- Query data: Data manipulation language (DML)
- Control data: Data control language (DCL)

## DDL

- Create, alter, drop database objects (tables, indexes, views, etc.)

## DML

- Select, insert, update, delete data in tables

## DCL

- Grant, revoke permissions on database objects

## Column Types

- Integer
- Float
- Char(n)
- Varchar(n)
- Text
- Date
- Boolean
- Timestamp
- DateTime
- JSON
- Blob

## ACID Properties

- Atomicity: All operations in a transaction are completed successfully or none are.
- Consistency: A transaction brings the database from one valid state to another valid state.
- Isolation: Transactions are isolated from each other until they are completed.
- Durability: Once a transaction is committed, it remains so, even in the event of a system failure.

## Database Normalization

- Reduce redundancy
- Avoid anomalies (insertion, update, deletion)
- Improve data integrity
- Optimize storage

## Normal Forms

1. First Normal Form (1NF): Eliminate repeating groups; ensure atomicity of data
2. Second Normal Form (2NF): Eliminate partial dependencies; ensure all non-key attributes depend on the whole primary key
3. Third Normal Form (3NF): Eliminate transitive dependencies; ensure non-key attributes depend only on the primary key
4. Boyce-Codd Normal Form (BCNF): A stronger version of 3NF
5. Fourth Normal Form (4NF): Eliminate multi-valued dependencies
6. Fifth Normal Form (5NF): Eliminate join dependencies

## Types of Relationships

- One-to-One (1:1): Each record in Table A corresponds to one record in Table B
- One-to-Many (1:N): Each record in Table A corresponds to multiple records in Table B
- Many-to-Many (M:N): Multiple records in Table A correspond to multiple records in Table B (requires a junction table)

[Test Preparation](https://pgexercises.com/questions/basic/where3.html)
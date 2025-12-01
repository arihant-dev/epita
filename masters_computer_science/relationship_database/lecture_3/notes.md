# Lecture 3 - Relationship Databases

## SQL Joins

- INNER JOIN: Returns records that have matching values in both tables.
- LEFT JOIN (or LEFT OUTER JOIN): Returns all records from the left table, and the matched records from the right table. If no match, NULLs are returned for columns from the right table.
- RIGHT JOIN (or RIGHT OUTER JOIN): Returns all records from the right table, and the matched records from the left table. If no match, NULLs are returned for columns from the left table.
- FULL JOIN (or FULL OUTER JOIN): Returns all records when there is a match in either left or right table. If no match, NULLs are returned for columns from the table without a match.
- CROSS JOIN: Returns the Cartesian product of the two tables, i.e., all possible combinations of records from both tables.

## Join Syntax Examples

```sql
-- INNER JOIN
SELECT A.column1, B.column2
FROM TableA A
INNER JOIN TableB B ON A.common_field = B.common_field;
-- LEFT JOIN
SELECT A.column1, B.column2
FROM TableA A
LEFT JOIN TableB B ON A.common_field = B.common_field;
-- RIGHT JOIN
SELECT A.column1, B.column2
FROM TableA A
RIGHT JOIN TableB B ON A.common_field = B.common_field;
-- FULL JOIN
SELECT A.column1, B.column2
FROM TableA A
FULL JOIN TableB B ON A.common_field = B.common_field;
-- CROSS JOIN
SELECT A.column1, B.column2
FROM TableA A
CROSS JOIN TableB B;
```

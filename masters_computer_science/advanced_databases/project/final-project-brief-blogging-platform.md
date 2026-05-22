# Final Project: Blogging Platform Data Layer (MongoDB)

## Overview

Build the data layer for a small blogging platform using MongoDB. You will design the database, load the
provided seed data, and implement a fixed set of operations. You are graded on correctness against the
acceptance criteria (Section 6), the quality of your schema design, and your written justification of design
choices (Section 4).

Your submission is a single mongosh script (JavaScript run by the MongoDB shell). You choose how to
structure your collections and queries — this brief defines only the inputs and expected outputs, and the
implementation is yours.

---

## Learning objectives

- Model one-to-many and many-to-many relationships in a document database.
- Make and defend embed-vs-reference decisions.
- Write queries and aggregations that produce deterministic, correctly ordered results.
- Choose indexes that fit your query patterns.

---

## 1. Data your platform must store

Three kinds of entity. The fields below are the minimum required. How you organize them into collections
— and what you embed vs. reference — is your decision (see Section 4).

- **User** — username (unique), display name, bio, avatar URL, the set of users they follow, account
  creation date.
- **Post** — author, title, body, list of tags, like count, creation date.
- **Comment** — the post it belongs to, author, text, creation date.

---

## 2. Functions you must implement

Implement the following operations as JavaScript functions in your mongosh script, using exactly these
names and parameters. Each return shape is fixed so results can be checked automatically.

Two identifier types are used: a user id (e.g. u_alice ) for internal references, and a username (e.g.
alice ) for lookup. See the seed data.

### getProfile(username)

Look up a user by username. Returns { username, displayName, bio, followingCount, postCount } , or null
if no such user. postCount is the number of posts that user authored. - Example: getProfile("alice") → {
username: "alice", displayName: "Alice Martin", bio: "...", followingCount: 2, postCount: 1 }

---

### follow(userId, targetId) / unfollow(userId, targetId)

follow adds targetId to userId 's following set; calling it twice with the same pair must not create a
duplicate. A user cannot follow themselves — reject and make no change. unfollow removes the pair;
unfollowing a pair that does not exist is a no-op. Both return true if they changed anything, else false . -
Example: follow("u_carol", "u_carol") → false , no change.

---

### createPost(authorId, { title, body, tags })

Creates a post. likeCount starts at 0, creation date defaults to the current time, tags are normalized per
your Section 4 rule. Returns the new post's id.

---

### addComment(postId, authorId, text)

Adds a comment to the given post. Returns the new comment's id. If postId does not exist, return null
and make no change.

---

### likePost(postId)

Increases the post's like count by 1. Returns the new like count. - Example: likePost("p1") → 6 .

---

### getFeed(userId, { limit = 20, skip = 0 })

Returns posts authored by users that userId follows, newest first. Does not include userId 's own posts.
When two posts share a creation date, order them by post id ascending so the result is deterministic.
Supports pagination via limit and skip . Returns an ordered array of { id, authorId, title, tags,
likeCount, createdAt, commentCount } . - Example (seed data): getFeed("u_alice") → posts in this exact
order: p2, p4, p1, p5 .

---

### getTopTags(n = 5)

Returns the n most-used tags across all posts, ranked by the number of posts that use each tag. Sort by
count descending; break ties by tag name ascending. Returns an ordered array of { tag, count } . -
Example (seed data): getTopTags(5) → [{mongodb,4}, {database,3}, {intro,2}, {aggregation,1},
{design,1}]

---

## 3. Provided seed dataset

Load this exact data before testing. Every example output above and every acceptance criterion in Section
6 is defined against it. Store it however your schema requires.

### Users

| id     | username | display name | follows (ids)        |
|--------|----------|--------------|----------------------|
| u_alice | alice   | Alice Martin | u_bob, u_carol       |
| u_bob  | bob      | Bob Nguyen   | u_alice              |
| u_carol | carol   | Carol Diaz   | (none)               |
| u_dave | dave     | Dave Olsen   | u_alice, u_bob, u_carol |

### Posts

| id | author | title | tags | likeCount | createdAt (UTC) |
|----|--------|-------|------|-----------|------------------|
| p1 | u_bob  | Getting Started with MongoDB | mongodb, database | 5 | 2024-01-10 09:00 |
| p2 | u_carol | Indexing Tips | mongodb, performance | 12 | 2024-01-12 08:00 |
| p3 | u_alice | My First Post | intro | 0 | 2024-01-11 10:00 |
| p4 | u_bob | Aggregation Deep Dive | mongodb, aggregation | 7 | 2024-01-12 08:00 |
| p5 | u_carol | Schema Design Basics | mongodb, database, design | 3 | 2024-01-09 14:00 |
| p6 | u_dave | Hello World | intro, database | 1 | 2024-01-13 11:00 |

### Comments

| on post | author | text | createdAt (UTC) |
|---------|--------|------|-----------------|
| p1 | u_alice | Welcome! | 2024-01-10 10:00 |
| p2 | u_alice | Very useful. | 2024-01-12 09:30 |
| p2 | u_bob | Saved. | 2024-01-12 11:00 |

Note: posts p2 and p4 share a creation time on purpose — your getFeed ordering must handle the tie.

---

## 4. Design decisions you must make and justify

Submit a short DESIGN.md (about one page) answering:

1. How did you organize entities into collections? Which relationships did you embed, which did you
reference, and why? Consider how comments grow over time and how the feed is queried.
2. How do you keep tag matching consistent — is "MongoDB" the same tag as "mongodb" ? State your rule.
3. Which indexes did you create, and which query does each one support?
4. The like count is a single number. What does that design fail to prevent, and how would you fix it given more time?

---

## 5. Deliverables

- A single mongosh script (`.js`) that loads the seed dataset and defines all the operations from Section 2.
- DESIGN.md with your answers from Section 4.
- A short README giving the exact mongosh command used to run your script.

### Example: running and using your script

Run your script with mongosh . The --shell flag keeps an interactive prompt open after the file finishes, so
the operations you defined stay callable:

```
$ mongosh --shell "mongodb://localhost:27017/blog_project" your-script.js

blog_project> getProfile("alice")
{
username: 'alice',
displayName: 'Alice Martin',
bio: 'Backend developer.',
followingCount: 2,
postCount: 1
}

blog_project> getFeed("u_alice").map(p => p.id)
[ 'p2', 'p4', 'p1', 'p5' ]

blog_project> getTopTags(5)
[
{ tag: 'mongodb', count: 4 },
{ tag: 'database', count: 3 },
{ tag: 'intro', count: 2 },
{ tag: 'aggregation', count: 1 },
{ tag: 'design', count: 1 }
]
```

Without --shell , mongosh runs the file and exits immediately — the seed data still loads, but you cannot
call the operations afterward. Put the exact command you used in your README .

---

## 6. Acceptance criteria

Your submission passes when, run against the seed data:

1. getProfile("alice") returns followingCount 2 and postCount 1.
2. getProfile for an unknown username returns null .
3. getFeed("u_alice") returns post ids [p2, p4, p1, p5] in that order.
4. getFeed("u_dave") returns [p2, p4, p3, p1, p5] — dave follows everyone but himself.
5. getFeed for a user who follows no one returns an empty array.
6. getTopTags(5) returns the five {tag, count} pairs in the order shown in Section 2.
7. getTopTags(3) returns only the first three of those.
8. follow called twice with the same pair leaves the following set unchanged.
9. follow(x, x) returns false and changes nothing.
10. addComment increases the post's comment count by exactly 1; addComment on a missing post returns
null .
11. likePost increases the like count by exactly 1.
12. A duplicate username cannot be inserted.

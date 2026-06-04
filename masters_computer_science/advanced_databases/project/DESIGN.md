# Design Decisions

## 1. Collections and relationships

Three collections: `users`, `posts`, `comments`.

**Embedded: `following` inside `users`.** The following list is read every time `getFeed` runs and is always needed alongside user data. Embedding avoids a join. The list is bounded in practice (a user follows a finite number of people), so the document will not grow past the 16 MB limit.

**Referenced: `comments` in a separate collection.** A post can accumulate an unbounded number of comments over time. Embedding them inside `posts` would cause the post document to grow with every comment, triggering repeated document relocations and eventually hitting the size limit. Separating them means adding a comment is a single insert plus an `$inc` on `commentCount`, with no post document growth.

**Referenced: `posts` linked to users via `authorId`.** Posts are queried independently (feed, tags) and do not need to live inside the user document. `postCount` is computed on the fly in `getProfile` via `countDocuments` since it is not on a hot path.

Each post stores a denormalized `commentCount` so `getFeed` can return it without a `$lookup` or a count query per post.

## 2. Tag normalization

Tags are trimmed, lowercased, and deduplicated per post at write time (both in seed data and `createPost`). `"MongoDB"`, `" mongodb "`, and `"mongodb"` all resolve to `"mongodb"`. This is done once at insertion so queries and aggregations do not need case-insensitive matching.

## 3. Indexes

| Index | Collection | Supports |
|---|---|---|
| `{ username: 1 }` unique | `users` | `getProfile` lookup by username. Uniqueness enforces the "no duplicate username" constraint. |
| `{ authorId: 1, createdAt: -1, _id: 1 }` | `posts` | `getFeed` — filters by `authorId` (`$in`), then sorts by `createdAt` desc and `_id` asc. The compound index covers both the filter and the sort order, so MongoDB can satisfy the query with an index scan instead of an in-memory sort. |
| `{ tags: 1 }` | `posts` | Multikey index. Not used by `getTopTags` (which must scan all posts to count), but would support a hypothetical "find posts by tag" query. |
| `{ postId: 1 }` | `comments` | `addComment` checks post existence via `posts`, but this index supports retrieving all comments for a given post if needed. |

## 4. Like count limitation

`likeCount` is a single integer incremented by `likePost(postId)`. Since the function takes no `userId`, the same user can like the same post multiple times — there is nothing to enforce uniqueness.

**Fix:** Change the signature to `likePost(postId, userId)`. Create a `likes` collection with a unique compound index on `{ postId: 1, userId: 1 }`. Each call inserts a document into `likes`; the unique index rejects duplicates. Maintain `likeCount` on the post via `$inc` only when the insert succeeds, or compute it on the fly with `countDocuments`. The trade-off is an extra collection and a two-step write versus a single atomic `$inc`.

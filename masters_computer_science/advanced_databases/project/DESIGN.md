# Design Decisions

1. **Collections and relationships:** Three collections: `users`, `posts`, `comments`. `users.following` stores user ids. `posts.authorId` stores the author id. `comments` are separate and store `postId` and `authorId`, so posts do not grow without bound. Each post keeps a `commentCount` for fast feed reads.
2. **Tag normalization:** Tags are trimmed, lowercased, and deduplicated per post. Example: `MongoDB`, ` mongodb `, and `mongodb` are treated as the same tag.
3. **Indexes:** 
   - Unique index on `users.username` to enforce uniqueness and speed `getProfile`.
   - Index on `posts` `{ authorId, createdAt, _id }` for feed queries and deterministic order.
   - Index on `posts.tags` for tag aggregation.
   - Index on `comments.postId` for comment lookups.
4. **Like count limitation:** A single `likeCount` cannot prevent duplicate likes because `likePost(postId)` lacks a `userId` parameter. To fix this, change the function signature to `likePost(postId, userId)` and store likes in a separate `likes` collection with a unique compound index on `{ postId, userId }`.

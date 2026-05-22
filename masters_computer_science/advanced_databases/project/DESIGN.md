# Design Decisions

1. **Collections and relationships:** Three collections: `users`, `posts`, `comments`. `users.following` stores user ids. `posts.authorId` stores the author id. `comments` are separate and store `postId` and `authorId`, so posts do not grow without bound. Each post keeps a `commentCount` for fast feed reads.
2. **Tag normalization:** Tags are trimmed, lowercased, and deduplicated per post. Example: `MongoDB`, ` mongodb `, and `mongodb` are treated as the same tag.
3. **Indexes:** 
   - Unique index on `users.username` to enforce uniqueness and speed `getProfile`.
   - Index on `posts` `{ authorId, createdAt, _id }` for feed queries and deterministic order.
   - Index on `posts.tags` for tag aggregation.
   - Index on `comments.postId` for comment lookups.
4. **Like count limitation:** A single `likeCount` does not prevent the same user from liking multiple times. A better fix is a `postLikes` collection with a unique `(postId, userId)` constraint and derive counts from it.

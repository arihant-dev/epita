# Design Decisions

1. **Collections and relationships:** Three collections: `users`, `posts`, `comments`. `users.following` stores user ids. `posts.authorId` stores the author id. `comments` are separate and store `postId` and `authorId`, so posts do not grow without bound. Each post keeps a `commentCount` for fast feed reads. We only query if the target user exists. The follower is verified by the update's matched count.
2. **Tag normalization:** Tags are trimmed, lowercased, and deduplicated per post. Example: `MongoDB`, ` mongodb `, and `mongodb` are treated as the same tag.
3. **Indexes:** 
   - Unique index on `users.username` supports user lookup in `getProfile`.
   - Index `{ authorId: 1, createdAt: -1, _id: 1 }` on `posts` supports fetching and sorting the feed in `getFeed`.
   - Index on `posts.tags` is unused by `getTopTags` (which does a collection scan to count tags), but would support querying posts by a tag.
   - Index on `comments.postId` supports retrieving comments belonging to a specific post.
4. **Like count limitation:** A single `likeCount` cannot prevent duplicate likes because `likePost(postId)` lacks a `userId` parameter. To fix this, change the function signature to `likePost(postId, userId)` and store likes in a separate `likes` collection with a unique compound index on `{ postId, userId }`.

const database = db.getSiblingDB("blog_project");
const users = database.getCollection("users");
const posts = database.getCollection("posts");
const comments = database.getCollection("comments");
const counters = database.getCollection("counters");

function normalizeTag(tag) {
  if (tag === null || tag === undefined) return "";
  return tag.toString().trim().toLowerCase();
}

function normalizeTags(tags) {
  if (!Array.isArray(tags)) return [];
  const normalized = tags.map(normalizeTag).filter((t) => t.length > 0);
  return Array.from(new Set(normalized));
}

function nextSequence(name) {
  const doc = counters.findOneAndUpdate(
    { _id: name },
    { $inc: { seq: 1 } },
    { returnNewDocument: true, upsert: true }
  );
  return doc.seq;
}

function seedData() {
  users.deleteMany({});
  posts.deleteMany({});
  comments.deleteMany({});
  counters.deleteMany({});

  users.createIndex({ username: 1 }, { unique: true });
  posts.createIndex({ authorId: 1, createdAt: -1, _id: 1 });
  posts.createIndex({ tags: 1 });
  comments.createIndex({ postId: 1 });

  users.insertMany([
    {
      _id: "u_alice",
      username: "alice",
      displayName: "Alice Martin",
      bio: "Backend developer.",
      avatarUrl: "https://example.com/avatars/alice.png",
      following: ["u_bob", "u_carol"],
      createdAt: new Date("2024-01-01T09:00:00Z"),
    },
    {
      _id: "u_bob",
      username: "bob",
      displayName: "Bob Nguyen",
      bio: "Data engineer.",
      avatarUrl: "https://example.com/avatars/bob.png",
      following: ["u_alice"],
      createdAt: new Date("2024-01-02T09:00:00Z"),
    },
    {
      _id: "u_carol",
      username: "carol",
      displayName: "Carol Diaz",
      bio: "Database designer.",
      avatarUrl: "https://example.com/avatars/carol.png",
      following: [],
      createdAt: new Date("2024-01-03T09:00:00Z"),
    },
    {
      _id: "u_dave",
      username: "dave",
      displayName: "Dave Olsen",
      bio: "Platform architect.",
      avatarUrl: "https://example.com/avatars/dave.png",
      following: ["u_alice", "u_bob", "u_carol"],
      createdAt: new Date("2024-01-04T09:00:00Z"),
    },
  ]);

  posts.insertMany([
    {
      _id: "p1",
      authorId: "u_bob",
      title: "Getting Started with MongoDB",
      body: "A beginner-friendly overview of MongoDB basics.",
      tags: normalizeTags(["mongodb", "database"]),
      likeCount: 5,
      commentCount: 1,
      createdAt: new Date("2024-01-10T09:00:00Z"),
    },
    {
      _id: "p2",
      authorId: "u_carol",
      title: "Indexing Tips",
      body: "Practical indexing guidance for faster queries.",
      tags: normalizeTags(["mongodb", "performance"]),
      likeCount: 12,
      commentCount: 2,
      createdAt: new Date("2024-01-12T08:00:00Z"),
    },
    {
      _id: "p3",
      authorId: "u_alice",
      title: "My First Post",
      body: "Hello, world! Sharing my first update.",
      tags: normalizeTags(["intro"]),
      likeCount: 0,
      commentCount: 0,
      createdAt: new Date("2024-01-11T10:00:00Z"),
    },
    {
      _id: "p4",
      authorId: "u_bob",
      title: "Aggregation Deep Dive",
      body: "Exploring aggregation pipelines with real examples.",
      tags: normalizeTags(["mongodb", "aggregation"]),
      likeCount: 7,
      commentCount: 0,
      createdAt: new Date("2024-01-12T08:00:00Z"),
    },
    {
      _id: "p5",
      authorId: "u_carol",
      title: "Schema Design Basics",
      body: "How to think about schema decisions in MongoDB.",
      tags: normalizeTags(["mongodb", "database", "design"]),
      likeCount: 3,
      commentCount: 0,
      createdAt: new Date("2024-01-09T14:00:00Z"),
    },
    {
      _id: "p6",
      authorId: "u_dave",
      title: "Hello World",
      body: "Setting up a simple app with MongoDB.",
      tags: normalizeTags(["intro", "database"]),
      likeCount: 1,
      commentCount: 0,
      createdAt: new Date("2024-01-13T11:00:00Z"),
    },
  ]);

  comments.insertMany([
    {
      _id: "c1",
      postId: "p1",
      authorId: "u_alice",
      text: "Welcome!",
      createdAt: new Date("2024-01-10T10:00:00Z"),
    },
    {
      _id: "c2",
      postId: "p2",
      authorId: "u_alice",
      text: "Very useful.",
      createdAt: new Date("2024-01-12T09:30:00Z"),
    },
    {
      _id: "c3",
      postId: "p2",
      authorId: "u_bob",
      text: "Saved.",
      createdAt: new Date("2024-01-12T11:00:00Z"),
    },
  ]);

  counters.insertMany([
    { _id: "postId", seq: 6 },
    { _id: "commentId", seq: 3 },
  ]);
}

seedData();

function getProfile(username) {
  const user = users.findOne(
    { username },
    { username: 1, displayName: 1, bio: 1, following: 1 }
  );
  if (!user) return null;
  const followingCount = Array.isArray(user.following) ? user.following.length : 0;
  const postCount = posts.countDocuments({ authorId: user._id });
  return {
    username: user.username,
    displayName: user.displayName,
    bio: user.bio,
    followingCount,
    postCount,
  };
}

function follow(userId, targetId) {
  if (userId === targetId) return false;
  const targetExists = users.findOne({ _id: targetId }, { _id: 1 });
  if (!targetExists) return false;
  const result = users.updateOne(
    { _id: userId },
    { $addToSet: { following: targetId } }
  );
  return result.modifiedCount > 0;
}

function unfollow(userId, targetId) {
  if (userId === targetId) return false;
  const result = users.updateOne(
    { _id: userId },
    { $pull: { following: targetId } }
  );
  return result.modifiedCount > 0;
}

function createPost(authorId, { title, body, tags }) {
  const postId = `p${nextSequence("postId")}`;
  posts.insertOne({
    _id: postId,
    authorId,
    title,
    body,
    tags: normalizeTags(tags),
    likeCount: 0,
    commentCount: 0,
    createdAt: new Date(),
  });
  return postId;
}

function addComment(postId, authorId, text) {
  const post = posts.findOne({ _id: postId }, { _id: 1 });
  if (!post) return null;
  const commentId = `c${nextSequence("commentId")}`;
  comments.insertOne({
    _id: commentId,
    postId,
    authorId,
    text,
    createdAt: new Date(),
  });
  posts.updateOne({ _id: postId }, { $inc: { commentCount: 1 } });
  return commentId;
}

function likePost(postId) {
  const post = posts.findOneAndUpdate(
    { _id: postId },
    { $inc: { likeCount: 1 } },
    { returnNewDocument: true }
  );
  return post ? post.likeCount : null;
}

function getFeed(userId, { limit = 20, skip = 0 } = {}) {
  const user = users.findOne({ _id: userId }, { following: 1 });
  if (!user || !Array.isArray(user.following) || user.following.length === 0)
    return [];
  const following = user.following.filter((id) => id !== userId);
  if (following.length === 0) return [];
  return posts
    .aggregate([
      { $match: { authorId: { $in: following } } },
      { $sort: { createdAt: -1, _id: 1 } },
      { $skip: skip },
      { $limit: limit },
      {
        $project: {
          _id: 0,
          id: "$_id",
          authorId: 1,
          title: 1,
          tags: 1,
          likeCount: 1,
          createdAt: 1,
          commentCount: 1,
        },
      },
    ])
    .toArray();
}

function getTopTags(n = 5) {
  return posts
    .aggregate([
      { $unwind: "$tags" },
      { $group: { _id: "$tags", count: { $sum: 1 } } },
      { $sort: { count: -1, _id: 1 } },
      { $limit: n },
      { $project: { _id: 0, tag: "$_id", count: 1 } },
    ])
    .toArray();
}

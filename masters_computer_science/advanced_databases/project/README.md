# Blogging Platform Data Layer

MongoDB data layer for a blogging platform. The script creates three collections (`users`, `posts`, `comments`), loads seed data, and registers all required query functions.

## Prerequisites

- MongoDB 7.0+
- mongosh 2.0+

## Run

```
mongosh --shell "mongodb://localhost:27017/blog_project" blog_project.js
```

`--shell` keeps the prompt open so the functions remain callable. The script drops and re-seeds the database on every run.

## Usage

```
blog_project> getProfile("alice")
blog_project> getFeed("u_alice")
blog_project> getTopTags(5)
blog_project> likePost("p1")
blog_project> follow("u_carol", "u_alice")
blog_project> addComment("p1", "u_bob", "Nice post.")
blog_project> createPost("u_alice", { title: "New Post", body: "Content.", tags: ["mongodb"] })
```

## Loom Video

https://www.loom.com/share/9403c66f99314b518375315fbdcf1411
# Social Network API Versioning

## 0.1.0

Chat feature:

- Person A can initiate a chat with person B
- Allows A and B to exchange text messages

```yaml
[User]
id: string

[Conversation]
id: string

[ConversationUser]
id: string
userId: string (FK: User)
conversationId: string (FK: Conversation)

[Message]
id: string
conversationId: string (FK: Conversation)
userId: string (FK: User)
content: text

[Initiate Chat] -> Conversation
*participantId: User

[Send Message] -> Message
*conversationId: Conversation
*content: string
```

## 0.2.0

posts:

- People can send text "posts" (messages)

walls:

- A collection of one's posts, publicly accessible
- Newest first

```yaml
[Post]
id: string
authorId: string (FK: User)
content: text
createdAt: timestamp

[Get User Wall] -> List of Post
*userId: User

[Create Post] -> Post
*content: string
```

## 0.3.0

reactions:

- People can "like" a post (once)
- The number of likes is publicly displayed on the post

```yaml
[Reaction]
id: string
postId: string (FK: Post)
userId: string (FK: User)

[Like Post] -> Reaction
*postId: Post

[Unlike Post] -> void
*postId: Post

[Get Post Likes] -> Count
*postId: Post
```

**Migration:** No changes to existing tables. Just add the Reaction table.

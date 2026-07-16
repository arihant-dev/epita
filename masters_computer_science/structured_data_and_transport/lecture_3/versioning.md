# Social Network API Versioning

## 0.1.0

Chat feature:

- Person A can initiate a chat with person B
- Allows A and B to exchange text messages

```yaml
[Chat]
chatId: string
participants: list of PersonIDs
messages: list of Message

[Message]
senderId: PersonID
content: string
timestamp: datetime

[Initiate Chat] -> Chat
*participantId: PersonID

[Send Message] -> Message
*chatId: ChatID
*content: string
```

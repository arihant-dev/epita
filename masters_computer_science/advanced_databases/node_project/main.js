import { MongoClient } from "mongodb";
import express from "express";

const app = express();

app.use(express.json());

 
let db = await connectToDatabase();

async function connectToDatabase() {
    const uri = process.env.MONGO_URI || "mongodb://localhost:27017/epita";
    const client = new MongoClient(uri);

    await client.connect();
    const db = client.db();

    
    console.log("Connected to MongoDB");
    return db;
}

async function createTextIndex() {
    await db.collection("posts").createIndex({ title: "text", content: "text" });
    await db.collection("posts").deleteMany({}); // Clear existing data to avoid duplicates
    await db.collection("students").deleteMany({}); // Clear existing data to avoid duplicates
    console.log("Text index created on posts collection");
}

await createTextIndex();

async function insertSampleData() {
    const students = [
        { name: "Alice", age: 22, major: "Computer Science" },
        { name: "Bob", age: 24, major: "Mathematics" },
        { name: "Charlie", age: 21, major: "Physics" }
    ];

    const posts = [
        { name: "post-1", title: "Introduction to MongoDB", content: "MongoDB is a NoSQL database..." },
        { name: "post-2", title: "Advanced MongoDB Queries", content: "Learn how to use aggregation pipelines..." },
        { name: "post-3", title: "MongoDB Text Search", content: "Text search allows you to search for text in your documents..." },
        { name: "post-4", title: "Node.js and MongoDB", content: "Using MongoDB with Node.js is easy..." },
        { name: "post-5", title: "MongoDB Indexing", content: "Indexes improve query performance..." },
        { name: "post-6", title: "MongoDB Replication", content: "Replication provides high availability..." },
        { name: "post-7", title: "MongoDB Sharding", content: "Sharding distributes data across multiple servers..." }
    ];

    await db.collection("students").insertMany(students);
    await db.collection("posts").insertMany(posts);
    console.log("Sample data inserted");
}

await insertSampleData();

app.get('/students', async (req, res) => {
    const students = await db.collection("students").find().toArray();
    res.json(students);
});
app.post('/students', async (req, res) => {
    const student = req.body;
    await db.collection("students").insertOne(student);
    res.status(201).json({ message: "Student added successfully" });
});

app.get('/posts', async (req, res) => {
    const searchTerm = req.query.search || "";
    const limit = parseInt(req.query.limit) || 2;
    const skip = parseInt(req.query.skip) || 0;
    const posts = await db.collection("posts")
    .find(
        { $text: { $search: searchTerm } },
        { score: { $meta: "textScore" } },
    )
    .project({ name: 1, title: 1, content: 1, score: { $meta: "textScore" }, _id: 0 })
    .sort({ score: { $meta: "textScore" } })
    .limit(limit)
    .skip(skip)
    .toArray();
    res.json(posts);
})

app.listen(3000, () => {
    console.log("Server is running on port 3000");
});
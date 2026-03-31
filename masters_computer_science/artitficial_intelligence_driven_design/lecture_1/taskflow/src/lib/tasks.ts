import {
  collection,
  addDoc,
  serverTimestamp,
  Timestamp,
  updateDoc,
  doc,
} from "firebase/firestore";
import { db } from "@/lib/firebase";

export type Priority = "high" | "medium" | "low";

export interface TaskData {
  title: string;
  description: string;
  priority: Priority;
  dueDate: string | null; // ISO date string or null
  completed: boolean;
  createdAt: Timestamp | ReturnType<typeof serverTimestamp>;
  completedAt: Timestamp | ReturnType<typeof serverTimestamp> | null;
}

export interface Task extends TaskData {
  id: string;
}

export async function createTask(
  uid: string,
  data: {
    title: string;
    description: string;
    priority: Priority;
    dueDate: string | null;
  }
): Promise<string> {
  const tasksRef = collection(db, "users", uid, "tasks");

  const docRef = await addDoc(tasksRef, {
    title: data.title.trim(),
    description: data.description.trim(),
    priority: data.priority,
    dueDate: data.dueDate,
    completed: false,
    createdAt: serverTimestamp(),
    completedAt: null,
  });

  return docRef.id;
}

export async function toggleTaskStatus(
  uid: string,
  taskId: string,
  newStatus: boolean
): Promise<void> {
  const taskRef = doc(db, "users", uid, "tasks", taskId);

  await updateDoc(taskRef, {
    completed: newStatus,
    completedAt: newStatus ? serverTimestamp() : null,
  });
}

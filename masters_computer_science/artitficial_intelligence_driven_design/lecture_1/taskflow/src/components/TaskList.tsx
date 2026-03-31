"use client";

import { useEffect, useState } from "react";
import { db } from "@/lib/firebase";
import { collection, onSnapshot, query, orderBy } from "firebase/firestore";
import { Task, toggleTaskStatus } from "@/lib/tasks";

interface TaskListProps {
  userId: string;
}

export default function TaskList({ userId }: TaskListProps) {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [toggling, setToggling] = useState<string | null>(null);

  useEffect(() => {
    if (!userId) return;

    const tasksRef = collection(db, "users", userId, "tasks");
    const q = query(tasksRef, orderBy("createdAt", "desc"));

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const taskList: Task[] = [];
      snapshot.forEach((doc) => {
        taskList.push({ id: doc.id, ...doc.data() } as Task);
      });
      setTasks(taskList);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [userId]);

  const handleToggle = async (taskId: string, currentStatus: boolean) => {
    if (!userId || toggling) return;
    
    setToggling(taskId);
    try {
      await toggleTaskStatus(userId, taskId, !currentStatus);
    } catch (err) {
      console.error("STDOUT::ERR", err);
    } finally {
      setToggling(null);
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case "high": return "bg-red-600";
      case "medium": return "bg-primary";
      case "low": return "bg-green-600";
      default: return "bg-secondary";
    }
  };

  const formatId = (id: string) => {
    const hash = id.split("").reduce((acc, char) => acc + char.charCodeAt(0), 0);
    return `#${(hash % 10000).toString().padStart(4, "0")}`;
  };

  if (loading) {
    return (
      <div className="p-4 text-xs font-bold uppercase italic text-secondary animate-pulse">
        Fetching_Records...
      </div>
    );
  }

  if (tasks.length === 0) {
    return (
      <div className="p-8 text-center bg-white border-2 border-dashed border-secondary/20 m-2">
        <div className="text-[10px] font-bold text-secondary uppercase mb-2">Null_Pointer: No tasks found.</div>
        <div className="text-[9px] text-secondary/60">Initialize your first task sub-routine to begin.</div>
      </div>
    );
  }

  return (
    <div className="inset-bevel m-1 bg-white overflow-x-auto flex-1">
      <table className="w-full text-left text-[11px] border-collapse">
        <thead className="bg-surface-container-highest">
          <tr className="divide-x divide-secondary/20">
            <th className="p-1 font-bold border-b border-secondary">ID</th>
            <th className="p-1 font-bold border-b border-secondary">TASK_NAME</th>
            <th className="p-1 font-bold border-b border-secondary">PRIO</th>
            <th className="p-1 font-bold border-b border-secondary">STATUS</th>
            <th className="p-1 font-bold border-b border-secondary text-center px-2">ACTION</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-secondary/10">
          {tasks.map((task) => (
            <tr 
              key={task.id} 
              className={`hover:bg-tertiary/5 cursor-default group transition-opacity ${
                task.completed ? "opacity-60 grayscale-[0.5]" : ""
              }`}
            >
              <td className="p-1 font-bold text-secondary/70">{formatId(task.id || "")}</td>
              <td className="p-1">
                <div className={`font-bold truncate max-w-[200px] ${task.completed ? "line-through text-secondary" : ""}`}>
                  {task.title}
                </div>
                {task.description && (
                  <div className="text-[9px] text-secondary leading-tight line-clamp-1">{task.description}</div>
                )}
              </td>
              <td className="p-1 whitespace-nowrap">
                <span className={`w-2 h-2 inline-block ${getPriorityColor(task.priority)} mr-1 border border-black`}></span>
                <span className="uppercase text-[10px]">{task.priority}</span>
              </td>
              <td className="p-1">
                <button 
                  onClick={() => handleToggle(task.id, task.completed)}
                  disabled={toggling === task.id}
                  className={`flex items-center gap-2 group/check ${toggling === task.id ? "cursor-wait" : "cursor-pointer"}`}
                >
                  <div className="w-4 h-4 inset-bevel bg-white flex items-center justify-center relative">
                    {task.completed && (
                      <span className="font-black text-[12px] leading-none text-black select-none">X</span>
                    )}
                  </div>
                  <span className={`uppercase text-[9px] font-black ${task.completed ? "text-green-700" : "text-tertiary"}`}>
                    {task.completed ? "DONE" : "ACTIVE"}
                  </span>
                </button>
              </td>
              <td className="p-1 text-center">
                <button className="px-2 border border-secondary/40 text-[9px] font-bold hover:bg-background outset-bevel active-press">
                  EDIT
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

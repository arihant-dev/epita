"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { collection, onSnapshot, orderBy, query } from "firebase/firestore";
import ConfigNotice from "@/components/ConfigNotice";
import TaskForm from "@/components/TaskForm";
import TaskList from "@/components/TaskList";
import { useAuth } from "@/lib/auth-context";
import { getFirebaseDb } from "@/lib/firebase";
import { Task, toggleTaskStatus, Priority } from "@/lib/tasks";

const priorityCards = [
  { label: "High", key: "high", color: "bg-red-600" },
  { label: "Medium", key: "medium", color: "bg-primary" },
  { label: "Low", key: "low", color: "bg-green-600" },
] as const;

function getTodayDateKey() {
  const today = new Date();
  today.setMinutes(today.getMinutes() - today.getTimezoneOffset());
  return today.toISOString().slice(0, 10);
}

export default function Home() {
  const { user, loading, isConfigured, configError } = useAuth();
  const [tasks, setTasks] = useState<Task[]>([]);
  const [tasksLoading, setTasksLoading] = useState(true);
  const [taskError, setTaskError] = useState<string | null>(null);
  const [pendingTaskId, setPendingTaskId] = useState<string | null>(null);
  const router = useRouter();

  useEffect(() => {
    if (loading) {
      return;
    }

    if (!isConfigured) {
      setTasks([]);
      setTasksLoading(false);
      return;
    }

    if (!user) {
      router.replace("/auth");
      return;
    }

    const db = getFirebaseDb();

    if (!db) {
      setTasksLoading(false);
      setTaskError(configError ?? "Firebase is unavailable in this environment.");
      return;
    }

    setTasksLoading(true);
    const tasksRef = collection(db, "users", user.uid, "tasks");
    const tasksQuery = query(tasksRef, orderBy("createdAt", "desc"));

    const unsubscribe = onSnapshot(
      tasksQuery,
      (snapshot) => {
        const nextTasks: Task[] = [];
        snapshot.forEach((taskDoc) => {
          const data = taskDoc.data();
          // Ensure all required fields exist with safe defaults
          if (data && data.title) {
            nextTasks.push({
              id: taskDoc.id,
              title: data.title || '',
              description: data.description || '',
              priority: (data.priority || 'medium') as Priority,
              dueDate: data.dueDate || null,
              completed: data.completed ?? false,
              createdAt: data.createdAt,
              completedAt: data.completedAt || null,
            } as Task);
          }
        });
        setTaskError(null);
        setTasksLoading(false);
        setTasks(nextTasks);
      },
      (error) => {
        console.error("TASK SYNC ERROR", error);
        setTasksLoading(false);
        setTaskError("SYNC ERROR: Realtime task feed is unavailable.");
      }
    );

    return () => unsubscribe();
  }, [configError, isConfigured, loading, router, user]);

  const handleToggle = async (task: Task) => {
    if (!user || pendingTaskId || !task || !task.id) {
      return;
    }

    const nextCompleted = !task.completed;
    setPendingTaskId(task.id);
    setTaskError(null);
    setTasks((currentTasks) =>
      currentTasks.map((currentTask) =>
        currentTask.id === task.id
          ? {
              ...currentTask,
              completed: nextCompleted,
              completedAt: nextCompleted ? currentTask.completedAt : null,
            }
          : currentTask
      )
    );

    try {
      await toggleTaskStatus(user.uid, task.id, nextCompleted);
    } catch (error) {
      console.error("TASK STATUS ERROR", error);
      setTasks((currentTasks) =>
        currentTasks.map((currentTask) =>
          currentTask.id === task.id ? task : currentTask
        )
      );
      setTaskError("STATUS UPDATE FAILED: Could not persist the task state.");
    } finally {
      setPendingTaskId(null);
    }
  };

  const totalTasks = tasks.length;
  const highPriorityTasks = tasks.filter((task) => task.priority === "high").length;
  const completedTasks = tasks.filter((task) => task.completed).length;
  const dueTodayTasks = tasks.filter(
    (task) => !task.completed && task.dueDate === getTodayDateKey()
  ).length;
  const completionRate =
    totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

  if (!isConfigured) {
    return (
      <div className="flex min-h-[calc(100vh-72px)] items-center justify-center p-6">
        <ConfigNotice
          title="Deployment setup incomplete"
          body="The dashboard was built successfully, but this environment is missing the public Firebase values required to authenticate users and read tasks."
        />
      </div>
    );
  }

  if (loading || !user) {
    return (
      <div className="flex flex-1 items-center justify-center bg-surface animate-pulse">
        <div className="text-[10px] font-bold uppercase tracking-widest text-secondary">
          Initializing Terminal...
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-4 bg-surface p-3">
      <div className="flex flex-wrap items-center justify-between gap-2 bg-surface-container-highest p-2 outset-bevel">
        <h1 className="text-lg font-black uppercase tracking-tight">
          System Dashboard // Overview
        </h1>
        <div className="text-[10px] font-bold uppercase italic text-secondary">
          v1.1 Runtime
        </div>
      </div>

      {taskError && (
        <div className="outset-bevel bg-red-50 p-3 text-[10px] font-bold uppercase text-red-700">
          {taskError}
        </div>
      )}

      <div className="grid grid-cols-1 gap-3 md:grid-cols-4">
        <div className="outset-bevel bg-background p-3">
          <div className="mb-1 text-[10px] font-bold uppercase text-secondary">
            Total Tasks
          </div>
          <div className="text-3xl font-black text-black">{totalTasks}</div>
          <div className="mt-1 text-[9px] font-bold uppercase text-secondary">
            Active workspace records
          </div>
        </div>
        <div className="outset-bevel bg-background p-3">
          <div className="mb-1 text-[10px] font-bold uppercase text-secondary">
            Completed
          </div>
          <div className="text-3xl font-black text-green-700">{completedTasks}</div>
          <div className="mt-2 h-2 w-full bg-white p-[1px] inset-bevel">
            <div
              className="h-full bg-green-600"
              style={{ width: `${completionRate}%` }}
            />
          </div>
        </div>
        <div className="outset-bevel bg-background p-3">
          <div className="mb-1 text-[10px] font-bold uppercase text-secondary">
            High Priority
          </div>
          <div className="text-3xl font-black text-red-600">{highPriorityTasks}</div>
          <div className="mt-1 text-[9px] font-bold uppercase text-red-800">
            Attention required
          </div>
        </div>
        <div className="outset-bevel bg-background p-3">
          <div className="mb-1 text-[10px] font-bold uppercase text-secondary">
            Due Today
          </div>
          <div className="text-3xl font-black text-black">{dueTodayTasks}</div>
          <div className="mt-1 text-[9px] font-bold uppercase text-secondary">
            Open deadlines
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-4 xl:grid-cols-12">
        <div className="xl:col-span-4">
          <TaskForm />
        </div>

        <div className="xl:col-span-8 flex flex-col gap-4">
          <div className="outset-bevel flex flex-1 flex-col bg-background">
            <div className="flex items-center justify-between border-b-2 border-secondary bg-surface-container-highest p-1 text-[11px] font-bold uppercase">
              <span>Recent Tasks Log.dat</span>
              <span className="text-[9px] font-normal italic lowercase text-secondary">
                sync: realtime
              </span>
            </div>

            <TaskList
              tasks={tasks}
              loading={tasksLoading}
              pendingTaskId={pendingTaskId}
              onToggle={handleToggle}
            />

            <div className="flex justify-between gap-2 bg-surface-container-low p-2 text-[10px] font-bold uppercase text-secondary">
              <span>{totalTasks} records loaded</span>
              <span>{Math.max(totalTasks - completedTasks, 0)} active tasks</span>
            </div>
          </div>

          <div className="outset-bevel flex flex-col bg-background">
            <div className="bg-surface-container-highest p-1 text-[11px] font-bold uppercase border-b-2 border-secondary">
              Priority Distribution
            </div>
            <div className="flex gap-4 overflow-x-auto p-3">
              {priorityCards.map((item) => {
                const count = tasks.filter((task) => task.priority === item.key).length;
                const width = totalTasks > 0 ? Math.round((count / totalTasks) * 100) : 0;

                return (
                  <div key={item.key} className="min-w-[90px] flex-1 space-y-1">
                    <div className="flex justify-between text-[9px] font-bold uppercase">
                      <span>{item.label}</span>
                      <span>{count}</span>
                    </div>
                    <div className="h-3 w-full border border-black bg-white p-[1px]">
                      <div
                        className={`${item.color} h-full border-r border-black`}
                        style={{ width: `${width}%` }}
                      />
                    </div>
                    <div className="text-[9px] uppercase text-secondary">{width}%</div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

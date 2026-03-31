"use client";

import TaskForm from "@/components/TaskForm";
import { useAuth } from "@/lib/auth-context";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import TaskList from "@/components/TaskList";
import { Task } from "@/lib/tasks";
import { db } from "@/lib/firebase";
import { collection, onSnapshot, query, orderBy } from "firebase/firestore";

export default function Home() {
  const { user, loading } = useAuth();
  const [tasks, setTasks] = useState<Task[]>([]);
  const router = useRouter();

  useEffect(() => {
    if (loading) return;
    if (!user) {
      router.push("/auth");
      return;
    }

    const tasksRef = collection(db, "users", user.uid, "tasks");
    const q = query(tasksRef, orderBy("createdAt", "desc"));

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const taskList: Task[] = [];
      snapshot.forEach((doc) => {
        taskList.push({ id: doc.id, ...doc.data() } as Task);
      });
      setTasks(taskList);
    });

    return () => unsubscribe();
  }, [user, loading, router]);

  const totalTasks = tasks.length;
  const highPriorityTasks = tasks.filter(t => t.priority === "high").length;
  const completedTasks = tasks.filter(t => t.completed).length;
  const completionRate = totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

  if (loading || !user) {
    return (
      <div className="flex flex-1 items-center justify-center bg-surface animate-pulse">
        <div className="text-[10px] font-bold uppercase tracking-widest text-secondary">
          Initializing_Terminal...
        </div>
      </div>
    );
  }

  return (
    <div className="p-3 bg-surface space-y-4">
      {/* Dashboard Header */}
      <div className="flex justify-between items-center bg-surface-container-highest outset-bevel p-2">
        <h1 className="text-lg font-black uppercase tracking-tight">
          System Dashboard // Overview
        </h1>
        <div className="text-[10px] font-bold text-secondary uppercase italic">
          v1.0.97 Runtime
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
        <div className="outset-bevel bg-background p-3">
          <div className="text-[10px] font-bold text-secondary uppercase mb-1">Total Tasks</div>
          <div className="text-3xl font-black text-black">{totalTasks}</div>
          <div className="text-[9px] text-tertiary font-bold mt-1 underline cursor-pointer hover:text-black">
            VIEW ALL →
          </div>
        </div>
        <div className="outset-bevel bg-background p-3">
          <div className="text-[10px] font-bold text-secondary uppercase mb-1">Completed</div>
          <div className="text-3xl font-black text-green-700">{completedTasks}</div>
          <div className="w-full bg-white h-2 inset-bevel mt-2 p-[1px]">
            <div className="bg-green-600 h-full" style={{ width: `${completionRate}%` }}></div>
          </div>
        </div>
        <div className="outset-bevel bg-background p-3">
          <div className="text-[10px] font-bold text-secondary uppercase mb-1">High Priority</div>
          <div className="text-3xl font-black text-red-600">{highPriorityTasks}</div>
          <div className="text-[9px] font-bold mt-1 text-red-800 uppercase">Attention Required</div>
        </div>
        <div className="outset-bevel bg-background p-3">
          <div className="text-[10px] font-bold text-secondary uppercase mb-1">Work Hours</div>
          <div className="text-3xl font-black text-black">--.-</div>
          <div className="text-[9px] font-bold mt-1 text-secondary uppercase">This Week</div>
        </div>
      </div>

      {/* Middle Content Area */}
      <div className="grid grid-cols-1 xl:grid-cols-12 gap-4">
        {/* Left Column: Form */}
        <div className="xl:col-span-4">
          <TaskForm />
        </div>

        {/* Right Column: List & Distribution */}
        <div className="xl:col-span-8 flex flex-col gap-4">
          {/* Real-time Task Table */}
          <div className="outset-bevel bg-background flex flex-col flex-1">
            <div className="bg-surface-container-highest p-1 border-b-2 border-secondary font-bold text-[11px] uppercase flex justify-between items-center">
              <span>Recent_Tasks_Log.dat</span>
              <span className="text-[9px] font-normal lowercase italic text-secondary">
                last sync: realtime
              </span>
            </div>
            
            <TaskList userId={user.uid} />

            <div className="p-1 bg-surface-container-low flex justify-end gap-1">
              <button className="px-2 border border-black outset-bevel text-[10px] font-bold bg-background active-press">
                &lt; PREV
              </button>
              <button className="px-2 border border-black outset-bevel text-[10px] font-bold bg-background active-press">
                NEXT &gt;
              </button>
            </div>
          </div>

          {/* Distribution Small Card */}
          <div className="outset-bevel bg-background flex flex-col">
            <div className="bg-surface-container-highest p-1 border-b-2 border-secondary font-bold text-[11px] uppercase">
              Resource Distribution
            </div>
            <div className="p-3 flex gap-4 overflow-x-auto">
              {[
                { label: "DEV", val: 45, color: "bg-primary" },
                { label: "UX", val: 30, color: "bg-green-600" },
                { label: "DB", val: 25, color: "bg-yellow-500" },
              ].map((item) => (
                <div key={item.label} className="flex-1 min-w-[80px] space-y-1">
                  <div className="flex justify-between text-[9px] font-bold uppercase">
                    <span>{item.label}</span>
                    <span>{item.val}%</span>
                  </div>
                  <div className="w-full h-3 bg-white border border-black p-[1px]">
                    <div className={`${item.color} h-full border-r border-black`} style={{ width: `${item.val}%` }}></div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

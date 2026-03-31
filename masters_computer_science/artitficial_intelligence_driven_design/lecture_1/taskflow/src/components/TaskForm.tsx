"use client";

import { useState } from "react";
import { useAuth } from "@/lib/auth-context";
import { createTask, Priority } from "@/lib/tasks";

export default function TaskForm() {
  const { user } = useAuth();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [priority, setPriority] = useState<Priority>("medium");
  const [dueDate, setDueDate] = useState("");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) {
      setError("AUTH_ERROR: User session required.");
      return;
    }

    if (!title.trim()) {
      setError("VALIDATION_ERROR: Title cannot be null.");
      return;
    }

    setLoading(true);
    setError(null);
    setSuccess(false);

    try {
      await createTask(user.uid, {
        title,
        description,
        priority,
        dueDate: dueDate || null,
      });

      setTitle("");
      setDescription("");
      setPriority("medium");
      setDueDate("");
      setSuccess(true);
      setTimeout(() => setSuccess(false), 3000);
    } catch (err) {
      console.error("STDOUT::ERR", err);
      setError("SYSTEM_ERROR: Storage transaction failed.");
    } finally {
      setLoading(false);
    }
  };

  if (!user) return null;

  return (
    <div className="outset-bevel bg-background p-1 w-full max-w-sm">
      <div className="bg-secondary text-white px-2 py-0.5 text-[11px] font-bold flex justify-between items-center mb-1">
        <span>NEW_TASK_DIALOGUE.EXE</span>
        <div className="flex gap-1">
          <div className="w-3 h-3 outset-bevel bg-background"></div>
          <div className="w-3 h-3 outset-bevel bg-background"></div>
        </div>
      </div>
      
      <form onSubmit={handleSubmit} className="p-3 bg-surface space-y-4">
        {error && (
          <div className="p-2 text-[10px] bg-red-50 border border-red-400 text-red-700 font-bold uppercase">
            {error}
          </div>
        )}
        
        {success && (
          <div className="p-2 text-[10px] bg-green-50 border border-green-400 text-green-700 font-bold uppercase">
            COMMIT_SUCCESS: Sub-routine updated.
          </div>
        )}

        <div className="space-y-1">
          <label htmlFor="title" className="block text-[10px] font-bold text-black uppercase">
            Task_Title_Buffer
          </label>
          <div className="inset-bevel bg-white p-0.5">
            <input
              id="title"
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Enter record name..."
              className="w-full px-2 py-1 bg-transparent border-none focus:ring-1 focus:ring-tertiary outline-none text-xs"
              maxLength={120}
            />
          </div>
        </div>

        <div className="space-y-1">
          <label htmlFor="description" className="block text-[10px] font-bold text-black uppercase">
            Extended_Description
          </label>
          <div className="inset-bevel bg-white p-0.5">
            <textarea
              id="description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Add technical details..."
              rows={3}
              className="w-full px-2 py-1 bg-transparent border-none focus:ring-1 focus:ring-tertiary outline-none text-xs resize-none"
              maxLength={500}
            />
          </div>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-1">
            <label htmlFor="priority" className="block text-[10px] font-bold text-black uppercase">
              Priority_Lvl
            </label>
            <div className="inset-bevel bg-white p-0.5">
              <select
                id="priority"
                value={priority}
                onChange={(e) => setPriority(e.target.value as Priority)}
                className="w-full px-2 py-1 bg-transparent border-none focus:ring-0 outline-none text-xs uppercase"
              >
                <option value="low">03_LOW</option>
                <option value="medium">02_MED</option>
                <option value="high">01_HIGH</option>
              </select>
            </div>
          </div>

          <div className="space-y-1">
            <label htmlFor="dueDate" className="block text-[10px] font-bold text-black uppercase">
              Deadline_Date
            </label>
            <div className="inset-bevel bg-white p-0.5">
              <input
                id="dueDate"
                type="date"
                value={dueDate}
                onChange={(e) => setDueDate(e.target.value)}
                className="w-full px-1 py-1 bg-transparent border-none focus:ring-0 outline-none text-xs"
                min={new Date().toISOString().split("T")[0]}
              />
            </div>
          </div>
        </div>

        <div className="pt-2">
          <button
            type="submit"
            disabled={loading}
            className="w-full py-2 px-4 outset-bevel bg-background text-black font-bold uppercase tracking-tight active-press text-xs hover:text-tertiary"
          >
            {loading ? "PROCESSING..." : "SUBMIT_RECORD"}
          </button>
        </div>
      </form>
    </div>
  );
}

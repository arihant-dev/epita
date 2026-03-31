"use client";

import Link from "next/link";
import { useAuth } from "@/lib/auth-context";
import { auth } from "@/lib/firebase";

export default function Header() {
  const { user } = useAuth();

  return (
    <header className="fixed top-0 w-full h-12 z-50 flex items-center justify-between px-2 bg-background border-t-2 border-l-2 border-white border-r-2 border-b-2 border-secondary border-b-2 border-black">
      <div className="flex items-center gap-4">
        <Link href="/" className="text-lg font-black text-black uppercase tracking-tighter hover:text-tertiary">
          TaskFlow v1.0
        </Link>
        <div className="hidden md:flex inset-bevel bg-surface flex items-center px-1 h-7">
          <span className="material-symbols-outlined text-gray-500 mr-2" style={{ fontSize: '18px' }}>search</span>
          <input
            className="bg-transparent border-none focus:ring-0 text-xs w-48 p-0 h-full placeholder:italic"
            placeholder="Search tasks..."
            type="text"
          />
        </div>
      </div>
      
      <div className="flex items-center gap-2">
        {user ? (
          <div className="hidden sm:flex items-center gap-1 px-2 border-x border-secondary/20 h-full">
            <span className="material-symbols-outlined text-secondary" style={{ fontSize: '14px' }}>person</span>
            <span className="text-[9px] font-bold uppercase text-secondary truncate max-w-[120px]">
              {user.email || "GUEST_USER"}
            </span>
          </div>
        ) : (
          <button className="outset-bevel bg-background px-3 py-0.5 text-xs font-bold active-press flex items-center gap-1 hover:text-tertiary hover:underline">
            <span className="material-symbols-outlined" style={{ fontSize: '18px' }}>help</span>
            <span className="uppercase tracking-tighter">HELP</span>
          </button>
        )}
        
        {user ? (
          <button 
            onClick={() => auth.signOut()}
            className="outset-bevel bg-background px-3 py-0.5 text-xs font-bold active-press flex items-center gap-1 hover:text-red-700 hover:underline"
          >
            <span className="material-symbols-outlined" style={{ fontSize: '18px' }}>exit_to_app</span>
            <span className="uppercase tracking-tighter">LOGOUT</span>
          </button>
        ) : (
          <Link 
            href="/auth"
            className="outset-bevel bg-background px-3 py-0.5 text-xs font-bold active-press flex items-center gap-1 hover:text-tertiary hover:underline"
          >
            <span className="material-symbols-outlined" style={{ fontSize: '18px' }}>login</span>
            <span className="uppercase tracking-tighter">LOGIN</span>
          </Link>
        )}
      </div>
    </header>
  );
}

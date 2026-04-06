"use client";

import { useState } from "react";
import { 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword 
} from "firebase/auth";
import { auth } from "@/lib/firebase";
import { useRouter } from "next/navigation";

export default function AuthForm() {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      if (isLogin) {
        await signInWithEmailAndPassword(auth, email, password);
      } else {
        await createUserWithEmailAndPassword(auth, email, password);
      }
      router.push("/");
    } catch (err) {
      const message = err instanceof Error ? err.message : "SYSTEM_AUTH_FAILURE: Protocol invalid.";
      console.error("AUTH_FAULT", err);
      setError(message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="outset-bevel bg-background p-1 w-full max-w-sm">
      <div className="bg-secondary text-white px-2 py-0.5 text-[11px] font-bold flex justify-between items-center mb-1">
        <span>{isLogin ? "USER_SIGN_IN.EXE" : "NEW_USER_REGISTRATION.EXE"}</span>
        <div className="flex gap-1">
          <div className="w-3 h-3 outset-bevel bg-background"></div>
          <div className="w-3 h-3 outset-bevel bg-background"></div>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="p-4 bg-surface space-y-4">
        {error && (
          <div className="p-2 text-[10px] bg-red-50 border border-red-400 text-red-700 font-bold uppercase leading-tight">
            CRITICAL_ERROR: {error}
          </div>
        )}

        <div className="space-y-1">
          <label className="block text-[10px] font-bold text-black uppercase">
            User_Identifier (Email)
          </label>
          <div className="inset-bevel bg-white p-0.5">
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              className="w-full px-2 py-1 bg-transparent border-none focus:ring-1 focus:ring-tertiary outline-none text-xs"
              placeholder="user@taskflow.network"
            />
          </div>
        </div>

        <div className="space-y-1">
          <label className="block text-[10px] font-bold text-black uppercase">
            Access_Key (Password)
          </label>
          <div className="inset-bevel bg-white p-0.5">
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              minLength={6}
              className="w-full px-2 py-1 bg-transparent border-none focus:ring-1 focus:ring-tertiary outline-none text-xs text-black"
              placeholder="********"
            />
          </div>
        </div>

        <div className="pt-2 space-y-3">
          <button
            type="submit"
            disabled={loading}
            className="w-full py-2 outset-bevel bg-background text-black font-bold uppercase tracking-tight active-press text-xs hover:text-tertiary disabled:opacity-50"
          >
            {loading ? "INITIALIZING..." : isLogin ? "AUTHENTICATE" : "REGISTER_USER"}
          </button>
          
          <div className="groove-line"></div>
          
          <button
            type="button"
            onClick={() => setIsLogin(!isLogin)}
            className="w-full text-[10px] font-bold text-secondary uppercase hover:text-tertiary underline cursor-pointer"
          >
            {isLogin 
              ? "No terminal access? REGISTER_NEW_USER" 
              : "Already have a key? RETURN_TO_SIGN_IN"}
          </button>
        </div>
      </form>
    </div>
  );
}

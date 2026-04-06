"use client";

import { useState } from "react";
import { 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword 
} from "firebase/auth";
import ConfigNotice from "@/components/ConfigNotice";
import {
  getFirebaseConfigErrorMessage,
  isFirebaseConfigured,
  requireFirebaseAuth,
} from "@/lib/firebase";
import { useRouter } from "next/navigation";

export default function AuthForm() {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  if (!isFirebaseConfigured) {
    return (
      <ConfigNotice
        title="Authentication is unavailable"
        body="This deployment is missing the Firebase keys required for sign in and sign up."
      />
    );
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const auth = requireFirebaseAuth();

      if (isLogin) {
        await signInWithEmailAndPassword(auth, email, password);
      } else {
        await createUserWithEmailAndPassword(auth, email, password);
      }
      router.push("/");
    } catch (err) {
      const message = err instanceof Error
        ? err.message
        : getFirebaseConfigErrorMessage();
      console.error("AUTH FAULT", err);
      setError(message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="outset-bevel bg-background p-1 w-full max-w-sm">
      <div className="bg-secondary text-white px-2 py-0.5 text-[11px] font-bold flex justify-between items-center mb-1">
        <span>{isLogin ? "USER SIGN IN.EXE" : "NEW USER REGISTRATION.EXE"}</span>
        <div className="flex gap-1">
          <div className="w-3 h-3 outset-bevel bg-background"></div>
          <div className="w-3 h-3 outset-bevel bg-background"></div>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="p-4 bg-surface space-y-4">
        {error && (
          <div className="p-2 text-[10px] bg-red-50 border border-red-400 text-red-700 font-bold uppercase leading-tight">
            CRITICAL ERROR: {error}
          </div>
        )}

        <div className="space-y-1">
          <label htmlFor="email" className="block text-[10px] font-bold text-black uppercase">
            User Identifier (Email)
          </label>
          <div className="inset-bevel bg-white p-0.5">
            <input
              type="email"
              name="email"
              id="email"
              autoComplete={isLogin ? "email" : "email"}
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              className="w-full px-2 py-1 bg-transparent border-none focus:ring-1 focus:ring-tertiary outline-none text-xs"
              placeholder="user@taskflow.network"
            />
          </div>
        </div>

        <div className="space-y-1">
          <label htmlFor="password" className="block text-[10px] font-bold text-black uppercase">
            Access Key (Password)
          </label>
          <div className="inset-bevel bg-white p-0.5">
            <input
              type="password"
              name="password"
              id="password"
              autoComplete={isLogin ? "current-password" : "new-password"}
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
            {loading ? "INITIALIZING..." : isLogin ? "AUTHENTICATE" : "REGISTER USER"}
          </button>
          
          <div className="groove-line"></div>
          
          <button
            type="button"
            onClick={() => setIsLogin(!isLogin)}
            className="w-full text-[10px] font-bold text-secondary uppercase hover:text-tertiary underline cursor-pointer"
          >
            {isLogin 
              ? "No terminal access? REGISTER NEW USER" 
              : "Already have a key? RETURN TO SIGN IN"}
          </button>
        </div>
      </form>
    </div>
  );
}

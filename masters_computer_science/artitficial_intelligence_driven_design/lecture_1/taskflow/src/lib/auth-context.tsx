"use client";

import {
  createContext,
  useContext,
  useEffect,
  useState,
  ReactNode,
} from "react";
import {
  User,
  onAuthStateChanged,
  signOut as firebaseSignOut,
} from "firebase/auth";
import {
  getFirebaseAuth,
  getFirebaseConfigErrorMessage,
  isFirebaseConfigured,
} from "@/lib/firebase";

interface AuthContextType {
  user: User | null;
  loading: boolean;
  isConfigured: boolean;
  configError: string | null;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  loading: true,
  isConfigured: isFirebaseConfigured,
  configError: null,
  signOut: async () => {},
});

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [configError, setConfigError] = useState<string | null>(
    isFirebaseConfigured ? null : getFirebaseConfigErrorMessage()
  );

  useEffect(() => {
    if (!isFirebaseConfigured) {
      setUser(null);
      setConfigError(getFirebaseConfigErrorMessage());
      setLoading(false);
      return;
    }

    const auth = getFirebaseAuth();

    if (!auth) {
      setUser(null);
      setConfigError(getFirebaseConfigErrorMessage());
      setLoading(false);
      return;
    }

    setConfigError(null);
    const unsubscribe = onAuthStateChanged(auth, (firebaseUser) => {
      setUser(firebaseUser);
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const signOut = async () => {
    const auth = getFirebaseAuth();

    if (!auth) {
      return;
    }

    await firebaseSignOut(auth);
    setUser(null);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        loading,
        isConfigured: isFirebaseConfigured && !configError,
        configError,
        signOut,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);

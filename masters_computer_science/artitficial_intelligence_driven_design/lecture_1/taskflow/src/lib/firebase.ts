import { getApp, getApps, initializeApp, type FirebaseApp } from "firebase/app";
import { getAuth, type Auth } from "firebase/auth";
import { getFirestore, type Firestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
};

const requiredFirebaseEnvVars = {
  NEXT_PUBLIC_FIREBASE_API_KEY: firebaseConfig.apiKey,
  NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN: firebaseConfig.authDomain,
  NEXT_PUBLIC_FIREBASE_PROJECT_ID: firebaseConfig.projectId,
  NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET: firebaseConfig.storageBucket,
  NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID: firebaseConfig.messagingSenderId,
  NEXT_PUBLIC_FIREBASE_APP_ID: firebaseConfig.appId,
};

export const missingFirebaseEnvVars = Object.entries(requiredFirebaseEnvVars)
  .filter(([, value]) => !value)
  .map(([key]) => key);

export const isFirebaseConfigured = missingFirebaseEnvVars.length === 0;

let app: FirebaseApp | null = null;
let auth: Auth | null = null;
let db: Firestore | null = null;
let firebaseInitializationError: string | null = null;

function setFirebaseInitializationError(error: unknown) {
  firebaseInitializationError =
    error instanceof Error
      ? error.message
      : "Firebase configuration is invalid for this environment.";
}

function initializeFirebaseApp(): FirebaseApp | null {
  if (!isFirebaseConfigured) {
    return null;
  }

  try {
    if (!app) {
      app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApp();
    }

    firebaseInitializationError = null;
    return app;
  } catch (error) {
    setFirebaseInitializationError(error);
    return null;
  }
}

export function getFirebaseAuth(): Auth | null {
  const firebaseApp = initializeFirebaseApp();

  if (!firebaseApp) {
    return null;
  }

  try {
    auth ??= getAuth(firebaseApp);
    firebaseInitializationError = null;
    return auth;
  } catch (error) {
    setFirebaseInitializationError(error);
    return null;
  }
}

export function getFirebaseDb(): Firestore | null {
  const firebaseApp = initializeFirebaseApp();

  if (!firebaseApp) {
    return null;
  }

  try {
    db ??= getFirestore(firebaseApp);
    firebaseInitializationError = null;
    return db;
  } catch (error) {
    setFirebaseInitializationError(error);
    return null;
  }
}

export function getFirebaseConfigErrorMessage() {
  if (firebaseInitializationError) {
    return `Firebase configuration error: ${firebaseInitializationError}`;
  }

  if (missingFirebaseEnvVars.length === 0) {
    return "Firebase is not configured for this environment.";
  }

  return `Missing public Firebase environment variables: ${missingFirebaseEnvVars.join(", ")}.`;
}

export function requireFirebaseAuth(): Auth {
  const firebaseAuth = getFirebaseAuth();

  if (!firebaseAuth) {
    throw new Error(getFirebaseConfigErrorMessage());
  }

  return firebaseAuth;
}

export function requireFirebaseDb(): Firestore {
  const firestore = getFirebaseDb();

  if (!firestore) {
    throw new Error(getFirebaseConfigErrorMessage());
  }

  return firestore;
}

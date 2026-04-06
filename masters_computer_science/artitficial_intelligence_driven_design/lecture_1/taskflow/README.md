# TaskFlow

TaskFlow is a small Next.js App Router application for the workshop sprint in `lecture_1`. It implements the completed user stories for:

- Email/password authentication with Firebase Auth
- Task creation with title, description, priority, and due date
- Realtime task listing from Firestore
- Marking tasks as completed

## Local development

Use Node `20.x`.

```bash
nvm use
npm install
npm run dev
```

Helpful checks:

```bash
npm run lint
npm run typecheck
npm run build
```

## Required environment variables

Copy `.env.example` to `.env.local` and fill in the Firebase web app values:

```bash
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=
```

The app now fails gracefully when these are missing, but authentication and Firestore features will stay disabled until they are set.

## Vercel deployment

1. Make sure the Vercel project points at the `taskflow` application directory.
   If you import the whole `epita` monorepo, the root directory must target `masters_computer_science/artitficial_intelligence_driven_design/lecture_1/taskflow`.
2. Add the six `NEXT_PUBLIC_FIREBASE_*` variables above in Vercel Project Settings -> Environment Variables.
3. Keep the project on Node `20.x`.
   This repo pins Node through `package.json` so Vercel can use a supported version from source control.

Without the Firebase variables, Vercel was previously failing during prerender with `Firebase: Error (auth/invalid-api-key)` while building `/_not-found`.

# US4 — Sign In / Sign Up by Email

| Field | Value |
|---|---|
| **Title** | As a visitor, I can sign up and sign in by email so that my tasks are saved to my account |
| **Type** | User Story |
| **Priority** | 🔴 Must Have |
| **Labels** | `feature`, `auth`, `firebase`, `frontend`, `must-have` |
| **Epic** | Authentication |
| **Story Points** | 5 |
| **Sprint** | Sprint 1 |
| **Status** | 📋 To Do |
| **Assignee** | — |
| **Created** | 2026-03-31 |
| **Updated** | 2026-03-31 |

---

## User Story

> **As a** new or returning visitor,
> **I want to** sign up with my email and password, or sign in if I already have an account,
> **so that** my tasks are securely stored and accessible only to me.

## Description

The application must provide an authentication flow using Firebase Authentication (email/password provider). A dedicated auth page (or combined form with tabs/toggle) allows the user to register a new account or log in to an existing one. After successful authentication, the user is redirected to the task list. A sign-out mechanism must also be available.

## Acceptance Criteria

- [ ] **AC-4.1 — Auth page:** A `/login` (or `/auth`) page is accessible to unauthenticated users with two modes: **Sign Up** and **Sign In**, switchable via tabs or a toggle link.
- [ ] **AC-4.2 — Sign Up form fields:** Email input (validated format) and Password input (minimum 6 characters, as required by Firebase). A "Confirm Password" field is present and must match the password.
- [ ] **AC-4.3 — Sign Up flow:** On valid submission, `createUserWithEmailAndPassword` is called. On success, the user is redirected to the task list page (`/`).
- [ ] **AC-4.4 — Sign In form fields:** Email input and Password input.
- [ ] **AC-4.5 — Sign In flow:** On valid submission, `signInWithEmailAndPassword` is called. On success, the user is redirected to the task list page (`/`).
- [ ] **AC-4.6 — Validation errors:** Inline validation messages are shown for: empty email, invalid email format, password too short (< 6 chars), passwords don't match (sign-up).
- [ ] **AC-4.7 — Firebase error handling:** User-friendly messages are displayed for Firebase errors, including:
  - `auth/email-already-in-use` → "An account with this email already exists."
  - `auth/user-not-found` → "No account found with this email."
  - `auth/wrong-password` → "Incorrect password."
  - `auth/too-many-requests` → "Too many attempts. Please try again later."
- [ ] **AC-4.8 — Auth state persistence:** The session persists across page reloads (Firebase default: `browserLocalPersistence`). The user remains signed in until they explicitly sign out.
- [ ] **AC-4.9 — Auth context:** An `AuthContext` (React Context) is available application-wide, providing: `user` (current Firebase user or `null`), `loading` (boolean), `signOut` function.
- [ ] **AC-4.10 — Sign out:** A "Sign Out" button is visible in the app header/nav when the user is authenticated. Clicking it calls `signOut()` from Firebase and redirects to the login page.
- [ ] **AC-4.11 — Route protection:** All task-related routes redirect unauthenticated users to `/login`. The `/login` page redirects already-authenticated users to `/`.
- [ ] **AC-4.12 — Loading state:** While Firebase is determining auth state on initial load, a full-page loading spinner is shown (prevents flash of login page for already-authenticated users).

## Technical Notes

- Use Firebase SDK v9+ modular imports (`firebase/auth`).
- `AuthContext` should wrap the app in `layout.tsx` and use `onAuthStateChanged` to track the session.
- Consider using Next.js middleware for route protection (optional, client-side redirect is acceptable for workshop scope).

## UI/UX Considerations

- The auth page should feel welcoming: centered card layout, app logo/name at top, minimal distractions.
- Password field should have a show/hide toggle.
- The active tab (Sign In / Sign Up) should be clearly highlighted.
- Submission button should show a loading spinner while the request is in flight, and be disabled to prevent double submission.

## Dependencies

- None — this is a foundational story. US1, US2, and US3 depend on this.

## Definition of Done

- [ ] All acceptance criteria pass.
- [ ] Code reviewed and merged to `main`.
- [ ] Firebase Authentication enabled for Email/Password provider in Firebase Console.
- [ ] Firestore Security Rules require `request.auth != null` for all task operations.
- [ ] Tested: sign up → sign out → sign in → see tasks → sign out flow works end-to-end.
- [ ] Works on latest Chrome, Firefox, and Safari.

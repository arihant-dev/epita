# TaskFlow — Product Backlog

> Single source of truth for all user stories, issue tracking, and sprint planning.
> Reference: [vision.md](./vision.md)

---

## Backlog Overview

| ID | Title | Epic | Priority | Status | Points | Sprint | Assignee |
|----|-------|------|----------|--------|--------|--------|----------|
| US1 | Create a Task | Task Management | 🔴 Must Have | 📋 To Do | 5 | Sprint 1 | — |
| US2 | View Task List (sort & filter) | Task Management | 🔴 Must Have | 📋 To Do | 5 | Sprint 1 | — |
| US3 | Mark Task as Completed | Task Management | 🔴 Must Have | 📋 To Do | 2 | Sprint 1 | — |
| US4 | Sign In / Sign Up by Email | Authentication | 🔴 Must Have | 📋 To Do | 5 | Sprint 1 | — |
| US5 | Edit an Existing Task | Task Management | 🟡 Should Have | 📋 To Do | 3 | — | — |
| US6 | Delete a Task | Task Management | 🟡 Should Have | 📋 To Do | 2 | — | — |
| US7 | Filter by Priority | Task Management | 🟡 Should Have | 📋 To Do | 2 | — | — |
| US8 | Dashboard with Statistics | Analytics | 🟢 Could Have | 📋 To Do | 5 | — | — |
| US9 | Dark Mode | UI/UX | 🟢 Could Have | 📋 To Do | 3 | — | — |
| US10 | Export Tasks to CSV | Data Export | 🟢 Could Have | 📋 To Do | 3 | — | — |

**Status legend:** 📋 To Do · 🚧 In Progress · ✅ Done · ❌ Cancelled

---

## Sprint 1 — Foundation (17 pts)

> **Goal:** Deliver a working app where users can sign up, create tasks, view them, and mark them complete.
> **Velocity target:** 17 points
> **Implementation order:** US4 → US1 → US2 → US3

---

## Issue Details

<!-- ═══════════════════════════════════════════════════════════════════ -->

### US1 — Create a Task

| Field | Value |
|---|---|
| **Title** | As a user, I can create a new task so that I can track my to-dos |
| **Type** | User Story |
| **Priority** | 🔴 Must Have |
| **Labels** | `feature`, `tasks`, `firestore`, `frontend`, `must-have` |
| **Epic** | Task Management |
| **Story Points** | 5 |
| **Sprint** | Sprint 1 |
| **Status** | 📋 To Do |
| **Assignee** | — |
| **Created** | 2026-03-31 |
| **Updated** | 2026-03-31 |

#### User Story

> **As a** logged-in user,
> **I want to** create a new task by providing a title, description, priority, and due date,
> **so that** I can keep track of things I need to do.

#### Description

The user should be able to open a task-creation form (modal or dedicated page), fill in the required and optional fields, and submit the task. The task is persisted in Firestore under the user's `tasks` sub-collection and immediately appears in the task list.

#### Acceptance Criteria

- [ ] **AC-1.1 — Form availability:** A clearly visible "Add Task" / "+" button is present on the task list page.
- [ ] **AC-1.2 — Required field – Title:** The form contains a text input for the task title (max 120 characters). Submission is blocked if the title is empty, and an inline validation error is displayed.
- [ ] **AC-1.3 — Optional field – Description:** The form contains a textarea for description (max 500 characters). Leaving it empty is allowed.
- [ ] **AC-1.4 — Optional field – Priority:** The form contains a selector (dropdown or radio group) with three options: `High`, `Medium`, `Low`. Default value is `Medium`.
- [ ] **AC-1.5 — Optional field – Due date:** The form contains a date picker. Only future dates (today or later) are selectable. Leaving it empty is allowed.
- [ ] **AC-1.6 — Persistence:** On successful submission the task document is created in Firestore at `users/{uid}/tasks/{taskId}` with fields: `title`, `description`, `priority`, `dueDate`, `completed` (default `false`), `createdAt` (server timestamp).
- [ ] **AC-1.7 — Optimistic UI:** The new task appears in the task list immediately (optimistic update) without requiring a full page reload.
- [ ] **AC-1.8 — Success feedback:** A toast / snackbar notification confirms "Task created successfully".
- [ ] **AC-1.9 — Error handling:** If the Firestore write fails, a user-friendly error message is displayed and the optimistic update is rolled back.
- [ ] **AC-1.10 — Auth guard:** Unauthenticated users cannot access the creation form; they are redirected to the sign-in page.

#### Technical Notes

- Use a Client Component (`"use client"`) for the form since it requires interactivity.
- Use `addDoc` or `setDoc` from the Firebase SDK to write to Firestore.
- Validate on the client side; consider Firestore Security Rules for server-side validation.

#### UI/UX Considerations

- The form should be accessible (proper labels, keyboard navigation, ARIA attributes).
- On mobile, the form should be full-screen or a bottom sheet; on desktop, a centered modal is acceptable.

#### Dependencies

- US4 (Sign In / Sign Up) must be completed first — task creation requires an authenticated user.

#### Definition of Done

- [ ] All acceptance criteria pass.
- [ ] Code reviewed and merged to `main`.
- [ ] No console errors or warnings related to this feature.
- [ ] Works on latest Chrome, Firefox, and Safari.
- [ ] Firestore Security Rules updated and tested.

---

<!-- ═══════════════════════════════════════════════════════════════════ -->

### US2 — View Task List with Sorting & Filters

| Field | Value |
|---|---|
| **Title** | As a user, I can view my task list with sorting and filters so that I can find tasks easily |
| **Type** | User Story |
| **Priority** | 🔴 Must Have |
| **Labels** | `feature`, `tasks`, `firestore`, `frontend`, `must-have` |
| **Epic** | Task Management |
| **Story Points** | 5 |
| **Sprint** | Sprint 1 |
| **Status** | 📋 To Do |
| **Assignee** | — |
| **Created** | 2026-03-31 |
| **Updated** | 2026-03-31 |

#### User Story

> **As a** logged-in user,
> **I want to** see all my tasks in a list and be able to sort and filter them,
> **so that** I can quickly find and focus on the most relevant tasks.

#### Description

After signing in, the user lands on a dashboard / task-list page that fetches and displays all of their tasks from Firestore. The list supports sorting by different criteria and basic filtering (at minimum by completion status). The list updates in real-time when tasks are added, modified, or deleted.

#### Acceptance Criteria

- [ ] **AC-2.1 — Default view:** On page load, all tasks for the authenticated user are fetched from `users/{uid}/tasks` and displayed in a list/card layout.
- [ ] **AC-2.2 — Task card content:** Each task item displays: title, priority badge (color-coded), due date (formatted, e.g. "Apr 5, 2026"), and completion status (checkbox or visual indicator).
- [ ] **AC-2.3 — Sort by due date:** The user can sort tasks by due date (ascending = soonest first, descending = latest first).
- [ ] **AC-2.4 — Sort by priority:** The user can sort tasks by priority (High → Medium → Low or reverse).
- [ ] **AC-2.5 — Sort by creation date:** The user can sort tasks by creation date (newest first or oldest first).
- [ ] **AC-2.6 — Filter by status:** The user can filter to show: All tasks, Active (not completed) only, or Completed only.
- [ ] **AC-2.7 — Empty state:** If the user has no tasks, a friendly empty-state illustration/message is shown with a call-to-action to create the first task.
- [ ] **AC-2.8 — Real-time updates:** When a task is added or changed (e.g. in another tab), the list updates automatically via Firestore `onSnapshot`.
- [ ] **AC-2.9 — Loading state:** While tasks are being fetched, a skeleton loader or spinner is displayed.
- [ ] **AC-2.10 — Auth guard:** Unauthenticated users are redirected to the sign-in page.

#### Technical Notes

- Use `onSnapshot` for real-time listening on the user's tasks collection.
- Sorting can be done client-side (given workshop-scale data) or via Firestore `orderBy` queries.
- This is a Client Component due to real-time subscription and interactive controls.

#### UI/UX Considerations

- Sort and filter controls should be in a toolbar above the list.
- Priority badges should use consistent colors: `High` = red, `Medium` = amber/yellow, `Low` = green.
- Overdue tasks (past due date, not completed) should have a visual warning (e.g. red text or icon).

#### Dependencies

- US4 (Sign In / Sign Up) — requires authentication context.
- US1 (Create a Task) — there must be tasks to display (though the empty state covers this).

#### Definition of Done

- [ ] All acceptance criteria pass.
- [ ] Code reviewed and merged to `main`.
- [ ] Performs well with at least 50 tasks (no visible lag).
- [ ] Works on latest Chrome, Firefox, and Safari.
- [ ] Responsive: usable on mobile (≥ 375px) and desktop.

---

<!-- ═══════════════════════════════════════════════════════════════════ -->

### US3 — Mark a Task as Completed

| Field | Value |
|---|---|
| **Title** | As a user, I can mark a task as completed so that I can track my progress |
| **Type** | User Story |
| **Priority** | 🔴 Must Have |
| **Labels** | `feature`, `tasks`, `firestore`, `frontend`, `must-have` |
| **Epic** | Task Management |
| **Story Points** | 2 |
| **Sprint** | Sprint 1 |
| **Status** | 📋 To Do |
| **Assignee** | — |
| **Created** | 2026-03-31 |
| **Updated** | 2026-03-31 |

#### User Story

> **As a** logged-in user,
> **I want to** mark a task as completed (or undo that action),
> **so that** I can track which tasks are done and which still need attention.

#### Description

Each task in the list should have a toggle (checkbox or similar control) that sets the task's `completed` field to `true` or `false` in Firestore. The UI should immediately reflect the change and provide visual feedback distinguishing completed tasks from active ones.

#### Acceptance Criteria

- [ ] **AC-3.1 — Toggle control:** Each task item has a checkbox (or equivalent toggle) that the user can click to mark the task as completed.
- [ ] **AC-3.2 — Firestore update:** Clicking the toggle updates the `completed` field of the corresponding Firestore document at `users/{uid}/tasks/{taskId}`.
- [ ] **AC-3.3 — Optimistic UI:** The task's visual state changes immediately on click (before Firestore confirms the write).
- [ ] **AC-3.4 — Visual distinction:** Completed tasks are visually distinct from active tasks (e.g. strikethrough title, reduced opacity, muted colors, or moved to a "Completed" section).
- [ ] **AC-3.5 — Undo (toggle back):** The user can click the toggle again to mark a completed task as active (sets `completed` back to `false`).
- [ ] **AC-3.6 — Timestamp:** When a task is marked complete, a `completedAt` timestamp is recorded. When toggled back, `completedAt` is set to `null`.
- [ ] **AC-3.7 — Error handling:** If the Firestore update fails, the optimistic UI change is reverted and an error message is shown.
- [ ] **AC-3.8 — Auth guard:** Only the owning user can toggle their own tasks (enforced by Firestore Security Rules).

#### Technical Notes

- Use `updateDoc` from the Firebase SDK to patch the `completed` and `completedAt` fields.
- The real-time listener from US2 will automatically propagate the change to other open tabs/sessions.

#### UI/UX Considerations

- The checkbox hit target should be at least 44×44 px for mobile accessibility.
- Consider a brief micro-animation (e.g. checkmark fill, confetti) on completion for a satisfying interaction.
- Completed tasks should remain visible (not auto-hidden) unless the user applies a filter.

#### Dependencies

- US1 (Create a Task) — tasks must exist to be marked.
- US2 (View Task List) — the toggle lives inside the task list UI.
- US4 (Sign In / Sign Up) — requires authentication.

#### Definition of Done

- [ ] All acceptance criteria pass.
- [ ] Code reviewed and merged to `main`.
- [ ] Toggle works reliably with rapid clicks (debounced or queued).
- [ ] Firestore Security Rules tested: user A cannot toggle user B's tasks.

---

<!-- ═══════════════════════════════════════════════════════════════════ -->

### US4 — Sign In / Sign Up by Email

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

#### User Story

> **As a** new or returning visitor,
> **I want to** sign up with my email and password, or sign in if I already have an account,
> **so that** my tasks are securely stored and accessible only to me.

#### Description

The application must provide an authentication flow using Firebase Authentication (email/password provider). A dedicated auth page (or combined form with tabs/toggle) allows the user to register a new account or log in to an existing one. After successful authentication, the user is redirected to the task list. A sign-out mechanism must also be available.

#### Acceptance Criteria

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

#### Technical Notes

- Use Firebase SDK v9+ modular imports (`firebase/auth`).
- `AuthContext` should wrap the app in `layout.tsx` and use `onAuthStateChanged` to track the session.
- Consider using Next.js middleware for route protection (optional, client-side redirect is acceptable for workshop scope).

#### UI/UX Considerations

- The auth page should feel welcoming: centered card layout, app logo/name at top, minimal distractions.
- Password field should have a show/hide toggle.
- The active tab (Sign In / Sign Up) should be clearly highlighted.
- Submission button should show a loading spinner while the request is in flight, and be disabled to prevent double submission.

#### Dependencies

- None — this is a foundational story. US1, US2, and US3 depend on this.

#### Definition of Done

- [ ] All acceptance criteria pass.
- [ ] Code reviewed and merged to `main`.
- [ ] Firebase Authentication enabled for Email/Password provider in Firebase Console.
- [ ] Firestore Security Rules require `request.auth != null` for all task operations.
- [ ] Tested: sign up → sign out → sign in → see tasks → sign out flow works end-to-end.
- [ ] Works on latest Chrome, Firefox, and Safari.

---

<!-- ═══════════════════════════════════════════════════════════════════ -->
<!-- TEMPLATE — Copy this section to create a new user story            -->
<!-- ═══════════════════════════════════════════════════════════════════ -->

<!--
### USXX — [Short Title]

| Field | Value |
|---|---|
| **Title** | As a [persona], I can [action] so that [benefit] |
| **Type** | User Story |
| **Priority** | 🔴 Must Have / 🟡 Should Have / 🟢 Could Have / ⚪ Won't Have |
| **Labels** | `feature`, `...` |
| **Epic** | [Epic Name] |
| **Story Points** | — |
| **Sprint** | — |
| **Status** | 📋 To Do |
| **Assignee** | — |
| **Created** | YYYY-MM-DD |
| **Updated** | YYYY-MM-DD |

#### User Story

> **As a** [persona],
> **I want to** [action],
> **so that** [benefit].

#### Description

[Detailed description of the feature and its context.]

#### Acceptance Criteria

- [ ] **AC-XX.1 — [Short name]:** [Testable criterion]
- [ ] **AC-XX.2 — [Short name]:** [Testable criterion]

#### Technical Notes

- [Implementation guidance, SDK methods, architectural decisions.]

#### UI/UX Considerations

- [Accessibility, responsive design, interaction patterns.]

#### Dependencies

- [List any blocking user stories.]

#### Definition of Done

- [ ] All acceptance criteria pass.
- [ ] Code reviewed and merged to `main`.
- [ ] [Additional DoD items as needed.]

---
-->

## Changelog

| Date | Author | Change |
|------|--------|--------|
| 2026-03-31 | — | Initial backlog created with US1–US4 fully specified; US5–US10 listed in overview |

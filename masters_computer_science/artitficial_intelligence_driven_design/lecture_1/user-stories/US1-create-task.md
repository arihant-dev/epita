# US1 — Create a Task

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

---

## User Story

> **As a** logged-in user,
> **I want to** create a new task by providing a title, description, priority, and due date,
> **so that** I can keep track of things I need to do.

## Description

The user should be able to open a task-creation form (modal or dedicated page), fill in the required and optional fields, and submit the task. The task is persisted in Firestore under the user's `tasks` sub-collection and immediately appears in the task list.

## Acceptance Criteria

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

## Technical Notes

- Use a Client Component (`"use client"`) for the form since it requires interactivity.
- Use `addDoc` or `setDoc` from the Firebase SDK to write to Firestore.
- Validate on the client side; consider Firestore Security Rules for server-side validation.

## UI/UX Considerations

- The form should be accessible (proper labels, keyboard navigation, ARIA attributes).
- On mobile, the form should be full-screen or a bottom sheet; on desktop, a centered modal is acceptable.

## Dependencies

- [US4 — Sign In / Sign Up](./US4-auth-email.md) must be completed first — task creation requires an authenticated user.

## Definition of Done

- [ ] All acceptance criteria pass.
- [ ] Code reviewed and merged to `main`.
- [ ] No console errors or warnings related to this feature.
- [ ] Works on latest Chrome, Firefox, and Safari.
- [ ] Firestore Security Rules updated and tested.

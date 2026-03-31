# US2 — View Task List with Sorting & Filters

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

---

## User Story

> **As a** logged-in user,
> **I want to** see all my tasks in a list and be able to sort and filter them,
> **so that** I can quickly find and focus on the most relevant tasks.

## Description

After signing in, the user lands on a dashboard / task-list page that fetches and displays all of their tasks from Firestore. The list supports sorting by different criteria and basic filtering (at minimum by completion status). The list updates in real-time when tasks are added, modified, or deleted.

## Acceptance Criteria

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

## Technical Notes

- Use `onSnapshot` for real-time listening on the user's tasks collection.
- Sorting can be done client-side (given workshop-scale data) or via Firestore `orderBy` queries.
- This is a Client Component due to real-time subscription and interactive controls.

## UI/UX Considerations

- Sort and filter controls should be in a toolbar above the list.
- Priority badges should use consistent colors: `High` = red, `Medium` = amber/yellow, `Low` = green.
- Overdue tasks (past due date, not completed) should have a visual warning (e.g. red text or icon).

## Dependencies

- [US4 — Sign In / Sign Up](./US4-auth-email.md) — requires authentication context.
- [US1 — Create a Task](./US1-create-task.md) — there must be tasks to display (though the empty state covers this).

## Definition of Done

- [ ] All acceptance criteria pass.
- [ ] Code reviewed and merged to `main`.
- [ ] Performs well with at least 50 tasks (no visible lag).
- [ ] Works on latest Chrome, Firefox, and Safari.
- [ ] Responsive: usable on mobile (≥ 375px) and desktop.

# US3 — Mark a Task as Completed

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

---

## User Story

> **As a** logged-in user,
> **I want to** mark a task as completed (or undo that action),
> **so that** I can track which tasks are done and which still need attention.

## Description

Each task in the list should have a toggle (checkbox or similar control) that sets the task's `completed` field to `true` or `false` in Firestore. The UI should immediately reflect the change and provide visual feedback distinguishing completed tasks from active ones.

## Acceptance Criteria

- [ ] **AC-3.1 — Toggle control:** Each task item has a checkbox (or equivalent toggle) that the user can click to mark the task as completed.
- [ ] **AC-3.2 — Firestore update:** Clicking the toggle updates the `completed` field of the corresponding Firestore document at `users/{uid}/tasks/{taskId}`.
- [ ] **AC-3.3 — Optimistic UI:** The task's visual state changes immediately on click (before Firestore confirms the write).
- [ ] **AC-3.4 — Visual distinction:** Completed tasks are visually distinct from active tasks (e.g. strikethrough title, reduced opacity, muted colors, or moved to a "Completed" section).
- [ ] **AC-3.5 — Undo (toggle back):** The user can click the toggle again to mark a completed task as active (sets `completed` back to `false`).
- [ ] **AC-3.6 — Timestamp:** When a task is marked complete, a `completedAt` timestamp is recorded. When toggled back, `completedAt` is set to `null`.
- [ ] **AC-3.7 — Error handling:** If the Firestore update fails, the optimistic UI change is reverted and an error message is shown.
- [ ] **AC-3.8 — Auth guard:** Only the owning user can toggle their own tasks (enforced by Firestore Security Rules).

## Technical Notes

- Use `updateDoc` from the Firebase SDK to patch the `completed` and `completedAt` fields.
- The real-time listener from US2 will automatically propagate the change to other open tabs/sessions.

## UI/UX Considerations

- The checkbox hit target should be at least 44×44 px for mobile accessibility.
- Consider a brief micro-animation (e.g. checkmark fill, confetti) on completion for a satisfying interaction.
- Completed tasks should remain visible (not auto-hidden) unless the user applies a filter.

## Dependencies

- [US1 — Create a Task](./US1-create-task.md) — tasks must exist to be marked.
- [US2 — View Task List](./US2-view-task-list.md) — the toggle lives inside the task list UI.
- [US4 — Sign In / Sign Up](./US4-auth-email.md) — requires authentication.

## Definition of Done

- [ ] All acceptance criteria pass.
- [ ] Code reviewed and merged to `main`.
- [ ] Toggle works reliably with rapid clicks (debounced or queued).
- [ ] Firestore Security Rules tested: user A cannot toggle user B's tasks.

# TaskFlow - Vision Document

## Summary
Collaborative task management application allowing users to
create, organize, and track their tasks with authentication
and persistent data.

## Tech Stack
- **Frontend**: Next.js 14, TypeScript, Tailwind CSS
- **Auth**: Firebase Authentication (email/password)
- **Database**: Firestore (NoSQL, real-time)
- **Hosting**: Vercel (continuous deployment via GitHub)

## Architecture
- App Router (src/app/)
- Server Components by default, Client Components for interactivity
- AuthContext for session management
- Firestore for persistence ("tasks" collection per user)

## User Stories (MoSCoW)
### Must Have
- [ ] US1: Create a task (title, description, priority, due date)
- [ ] US2: View task list with sorting and filters
- [ ] US3: Mark a task as completed
- [ ] US4: Sign in / sign up by email

### Should Have
- [ ] US5: Edit an existing task
- [ ] US6: Delete a task
- [ ] US7: Filter by priority (high/medium/low)

### Could Have
- [ ] US8: Dashboard with statistics
- [ ] US9: Dark mode
- [ ] US10: Export tasks to CSV

## Architecture Decisions
- Firestore over PostgreSQL: no need for complex relations,
  native real-time, free for workshop volume
- Tailwind over CSS modules: faster prototyping,
  design system consistency
- App Router over Pages Router: Next.js 14+ standard,
  better Server Components support
# TaskLite

## Overview

TaskLite is a small, baseline task-management application. It lets a user create tasks, view all of them, mark a task as open or completed, and delete a task. This is the initial baseline version — it intentionally implements only the core task CRUD/status workflow described below.

## Baseline features

- **Create task** — add a new task with a required title.
- **View tasks** — list all tasks, newest first.
- **Mark task complete/open** — toggle a task's status between `OPEN` and `COMPLETED`.
- **Delete task** — remove a task permanently.

## Technology stack

**Backend**
- Node.js
- Express
- TypeScript
- Prisma ORM
- SQLite
- Zod (request validation)
- CORS

**Frontend**
- React
- TypeScript
- Vite

## Project folder structure

```
tasklite-ai-sdlc/
├── backend/
│   ├── prisma/
│   │   ├── schema.prisma       # Datasource, TaskStatus enum, Task model
│   │   └── migrations/         # Prisma migration history
│   ├── src/
│   │   ├── server.ts           # Entry point, starts the HTTP server
│   │   ├── app.ts              # Express app setup (CORS, JSON, routes, error handler)
│   │   ├── lib/                # Prisma client instance
│   │   ├── routes/             # Route definitions (health, tasks)
│   │   ├── controllers/        # Request handlers for tasks
│   │   ├── validators/         # Zod schemas for request bodies
│   │   ├── middleware/         # Global error handler
│   │   └── utils/              # Shared helpers (HttpError)
│   └── .env                    # DATABASE_URL and PORT
├── frontend/
│   └── src/
│       ├── App.tsx             # Root component
│       ├── types/              # Task and TaskStatus types
│       ├── services/           # API client (fetch wrappers)
│       └── components/         # TaskForm, TaskList, TaskItem
├── docs/
├── scripts/
└── tests/
```

## Prerequisites

- Node.js (v18 or later recommended)
- npm

## Backend setup and run instructions

```bash
cd backend
npm install
```

Ensure `backend/.env` contains:

```
DATABASE_URL="file:./dev.db"
PORT=3000
```

Run the Prisma migration to create the SQLite database:

```bash
npx prisma migrate dev
```

Start the backend:

```bash
npm run dev     # development (watch mode)
# or
npm run build   # compile TypeScript
npm run start   # run the compiled build
```

The API runs at `http://localhost:3000/api`.

## Frontend setup and run instructions

```bash
cd frontend
npm install
npm run dev
```

The app runs at `http://localhost:5173` and calls the backend API at `http://localhost:3000/api`.

## Prisma migration command

From the `backend` folder, whenever `schema.prisma` changes:

```bash
npx prisma migrate dev
```

## API endpoint summary

| Method | Endpoint                | Description                              |
|--------|--------------------------|-------------------------------------------|
| GET    | `/api/health`            | Health check, returns `{ "status": "UP" }` |
| GET    | `/api/tasks`             | List all tasks, newest first               |
| POST   | `/api/tasks`             | Create a task (`{ "title": string }`)      |
| PATCH  | `/api/tasks/:id/status`  | Update task status (`{ "status": "OPEN" \| "COMPLETED" }`) |
| DELETE | `/api/tasks/:id`         | Delete a task                              |

## Running the backend and frontend locally

1. Start the backend first: `cd backend && npm run dev` (listens on port 3000).
2. In a separate terminal, start the frontend: `cd frontend && npm run dev` (listens on port 5173).
3. Open `http://localhost:5173` in a browser to use the app.

## Future enhancements (not implemented in this baseline)

The following are explicitly **out of scope** for this baseline version and may be added later:

- Task priority
- Due dates
- Filters
- Sorting
- Dashboard
- Overdue indicators
- Playwright end-to-end tests
- Docker

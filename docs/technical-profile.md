# Technical Profile — TaskLite

**Last Updated:** 2026-09-30  
**Maintained by:** Claude (documentation-reviewer agent) + human review

---

## 1. Project Overview

TaskLite is a lightweight task management application. It provides a REST API for creating, reading, updating, and deleting tasks, and a React-based frontend for end users.

---

## 2. Repository Structure

```
tasklite-ai-sdlc-claude/
├── backend/           Node.js + Express + TypeScript + Prisma
├── frontend/          React + TypeScript + Vite
├── docs/              Project documentation
└── scripts/           Developer utility scripts
```

---

## 3. Backend Stack

| Technology | Version | Purpose |
|-----------|---------|---------|
| Node.js | 20 LTS | Runtime |
| TypeScript | 5.x | Language |
| Express | 4.x | HTTP framework |
| Prisma | 5.x | ORM |
| PostgreSQL | 15+ | Database |
| Zod | 3.x | Request validation |
| Jest | 29.x | Testing |
| ts-jest | 29.x | TypeScript Jest transformer |
| ESLint | 8.x | Linting |

---

## 4. Frontend Stack

| Technology | Version | Purpose |
|-----------|---------|---------|
| React | 18.x | UI framework |
| TypeScript | 5.x | Language |
| Vite | 5.x | Build tool |
| ESLint | 8.x | Linting |

---

## 5. Database Schema (Prisma)

### Task Model

| Field | Type | Constraints |
|-------|------|------------|
| `id` | Int | Primary key, auto-increment |
| `title` | String | Required |
| `description` | String? | Optional |
| `completed` | Boolean | Default: false |
| `createdAt` | DateTime | Default: now() |
| `updatedAt` | DateTime | Auto-updated |

---

## 6. API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| GET | `/tasks` | List all tasks |
| POST | `/tasks` | Create a task |
| GET | `/tasks/:id` | Get task by ID |
| PATCH | `/tasks/:id` | Update a task |
| DELETE | `/tasks/:id` | Delete a task |

---

## 7. Environment Variables

These variables are required at runtime. **Values are never documented here — only names.**

### Backend

| Variable | Required | Default | Description |
|----------|---------|---------|-------------|
| `DATABASE_URL` | Yes | None | PostgreSQL connection string |
| `PORT` | No | 3000 | HTTP server port |
| `NODE_ENV` | No | development | Runtime environment |

### Documentation Sync (Automated Documentation Sync feature)

| Variable | Required | Default | Description |
|----------|---------|---------|-------------|
| `DOCS_SYNC_SOURCE_DIRS` | No | `backend/src,frontend/src` | Comma-separated directories to watch |
| `DOCS_SYNC_OUTPUT_DIR` | No | `docs/api` | Output directory for generated Markdown |
| `DOCS_SYNC_EXCLUDE` | No | `node_modules,dist,coverage` | Exclusion patterns |
| `DOCS_SYNC_DEBOUNCE_MS` | No | `500` | File watcher debounce in milliseconds |
| `DOCS_SYNC_USE_POLLING` | No | `false` | Enable polling mode for network drives |
| `DOCS_SYNC_LOG_LEVEL` | No | `info` | Log level: debug, info, warn, error |

---

## 8. npm Scripts

### Backend (`backend/`)

| Script | Command | Description |
|--------|---------|-------------|
| `dev` | `ts-node src/server.ts` | Start dev server |
| `build` | `tsc` | Compile TypeScript |
| `start` | `node dist/server.js` | Start production server |
| `test` | `jest` | Run test suite |
| `lint` | `eslint src/` | Run ESLint |
| `docs:sync` | Not yet added | One-shot documentation sync |
| `docs:watch` | Not yet added | Watch mode documentation sync |
| `docs:check` | Not yet added | CI drift check |

### Frontend (`frontend/`)

| Script | Command | Description |
|--------|---------|-------------|
| `dev` | `vite` | Start dev server |
| `build` | `vite build` | Production build |
| `lint` | `eslint src/` | Run ESLint |

---

## 9. Known Technical Debt

| ID | Description | Severity | Owner |
|----|-------------|---------|-------|
| TD-001 | No authentication on API endpoints | High | Not Identified |
| TD-002 | No rate limiting on the API | Medium | Not Identified |
| TD-003 | `docs/api/` is maintained manually — no automated sync | Medium | This feature |
| TD-004 | No structured logging in the backend | Low | Not Identified |
| TD-005 | No CI pipeline configured | High | Not Identified |

---

## 10. Development Setup

```bash
# Install dependencies
cd backend && npm install
cd frontend && npm install

# Set up database
cd backend && npx prisma migrate dev

# Start backend
cd backend && npm run dev

# Start frontend (separate terminal)
cd frontend && npm run dev
```

Prerequisites: Node.js 20 LTS, PostgreSQL 15+

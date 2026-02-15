# Product03 PhaseA: Projects MVP Plan

## Scope
- Add Hub UI pages for Projects list and detail (minimal).
- Add Hub API routes for listing/creating and reading projects.
- Keep implementation as a scaffold: in-memory store unless a DB tool already exists.

## Detected DB Tooling
- Detected: `none`

## Data Model (Proposed)
- `Project`
  - `id`: UUID (string)
  - `name`: string (required)
  - `description`: string (optional)
  - `status`: `active` | `archived` (default: `active`)
  - `createdAt`: ISO string
  - `updatedAt`: ISO string

Notes:
- PhaseA stores projects in-memory (process-local). This resets on restart and is not shared across replicas.

## API Contract
- `GET /api/projects`
  - 200: `{ projects: Project[] }`
- `POST /api/projects`
  - Request: `{ name: string, description?: string }`
  - 201: `{ project: Project }`
  - 400: `{ error: string }`
- `GET /api/projects/[id]`
  - 200: `{ project: Project }`
  - 404: `{ error: string }`

## UI (Hub)
- `/projects`
  - list projects
  - create button (minimal)
- `/projects/[id]`
  - show project detail (minimal)

## Migration Strategy (PhaseB+)
- If `none` is already adopted in repo: add a Projects table/model and swap store to DB implementation.
- If no DB tool exists:
  - Recommended: Postgres + Prisma (or Drizzle) with explicit migrations.
  - Add a `projects` table with indexes on `id` and `status`.
  - Keep API contract stable; only replace storage implementation.

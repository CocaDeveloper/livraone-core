# Projects Contract (Product03)

## Database Contract

This feature persists Projects data.

### Tables

#### `projects`

- `id` uuid primary key (generated)
- `org_id` uuid not null
- `name` text not null
- `status` text not null (default `active`)
- `address` text null
- `created_at` timestamptz not null (default now)
- `updated_at` timestamptz not null (default now)

#### `project_members`

- `project_id` uuid not null (FK -> `projects.id`, on delete cascade)
- `user_id` uuid not null
- `role` text not null
- `created_at` timestamptz not null (default now)
- primary key (`project_id`, `user_id`)

### Environment Variables (Names Only)

- `DATABASE_URL` (PostgreSQL connection string)

Note: In the VPS Compose stack, `DATABASE_URL` is derived from SSOT values in `/etc/livraone/hub.env` (names only).

## API Contract

### Project Shape

`Project`:
- `id` (string UUID)
- `name` (string)
- `description` (string, optional)
- `status` (`active` | `archived`)
- `createdAt` (ISO string)
- `updatedAt` (ISO string)

### Endpoints

- `GET /api/projects`
  - 200
  - body: `{ "items": Project[] }`

- `POST /api/projects`
  - request JSON: `{ "name": string, "description"?: string }`
  - 201
  - body: `{ "item": Project }`
  - 400 if JSON invalid or `name` missing

- `GET /api/projects/:id`
  - 200
  - body: `{ "item": Project }`
  - 404 if missing: `{ "error": "not_found" }`

## Invariants

- Response keys are stable:
  - list uses `items`
  - single uses `item`
- `id` is always present and is a UUID string.
- `name` is always present and non-empty.
- Timestamps are ISO strings.

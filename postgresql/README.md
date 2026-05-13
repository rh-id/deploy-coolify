# PostgreSQL 18.3

Standalone PostgreSQL 18.3 via Docker Compose. Designed for Coolify's Docker Compose deployment mode.

## Quick Start

1. Copy `.env.example` to `.env` and set your password:
   ```bash
   cp .env.example .env
   ```
2. Edit `.env` — set `POSTGRES_PASSWORD` to a strong value
3. Deploy:
   ```bash
   docker compose up -d
   ```

## Coolify Setup

1. Create a new service in Coolify
2. Set the **Build Pack** to **Docker Compose**
3. Set the **Docker Compose Location** to `postgresql/docker-compose.yml`
4. Set the **Environment Variables** (see table below)
5. Configure **Persistent Storage** for `/var/lib/postgresql`
6. Deploy

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `POSTGRES_PASSWORD` | **Yes** | — | PostgreSQL superuser password |
| `POSTGRES_DB` | No | `app` | Database created on first init |
| `POSTGRES_USER` | No | `postgres` | PostgreSQL superuser name |

## Data Persistence

Data is stored in the `pgdata` named volume (`/var/lib/postgresql`). The database is initialized only on first run — subsequent restarts reuse existing data.

> **Note:** PostgreSQL 18+ changed its data directory structure. The volume mount point is `/var/lib/postgresql` (not `/var/lib/postgresql/data`). See [docker-library/postgres#1259](https://github.com/docker-library/postgres/pull/1259) for details.

## File Structure

```
postgresql/
├── docker-compose.yml
├── .env.example
└── README.md
```

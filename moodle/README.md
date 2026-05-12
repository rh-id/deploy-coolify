# Moodle 5.2 (PostgreSQL)

All-in-one Docker image running Moodle 5.2 with PostgreSQL, Apache, and PHP 8.3 in a single container. Designed for Coolify's Dockerfile deployment mode.

**No manual installation required** — set the required environment variables, deploy, and Moodle installs itself via CLI on first run.

## Quick Start

1. Create a new **Public Repository** service in Coolify (or connect this repo)
2. Set the **Build Pack** to **Dockerfile**
3. Set the **Dockerfile Location** to `moodle/Dockerfile`
4. Set these **Environment Variables**:

| Variable | Required | Example |
|---|---|---|
| `MOODLE_WWWROOT` | **Yes** | `https://moodle.example.com` |
| `MOODLE_PASSWORD` | **Yes** | your admin password |

5. Configure **Persistent Storage** for both paths:

| Mount Path | Purpose |
|---|---|
| `/var/lib/postgresql/data` | PostgreSQL database |
| `/var/moodledata` | Moodle file storage (uploads, cache, etc.) |

6. Deploy — Moodle installs automatically, no installation page needed

## Architecture

| Component | Details |
|---|---|
| Base image | `moodlehq/moodle-php-apache:8.3` |
| Moodle | 5.2 (`MOODLE_502_STABLE`) |
| Database | PostgreSQL 18 (in-container, configurable via build arg) |
| Process manager | supervisord (postgres + apache + cron) |

## Build Args

| Arg | Default | Description |
|---|---|---|
| `MOODLE_BRANCH` | `MOODLE_502_STABLE` | Moodle Git branch |
| `PG_MAJOR` | `18` | PostgreSQL major version |

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `MOODLE_WWWROOT` | **Yes** | — | Full public URL (e.g. `https://moodle.example.com`) |
| `MOODLE_PASSWORD` | **Yes** | — | Admin account password — must be set before first deploy |
| `MOODLE_DATABASE_NAME` | No | `moodle` | PostgreSQL database name |
| `MOODLE_DATABASE_USER` | No | `moodle` | PostgreSQL user |
| `MOODLE_DATABASE_PASSWORD` | No | `moodlepass` | PostgreSQL password |
| `MOODLE_DATABASE_PORT` | No | `5432` | PostgreSQL port |
| `MOODLE_USERNAME` | No | `admin` | Moodle admin username |
| `MOODLE_EMAIL` | No | `admin@example.com` | Moodle admin email |
| `MOODLE_SITE_NAME` | No | `Moodle Site` | Moodle site full name |

## How It Works

1. **First deploy** — set `MOODLE_WWWROOT` and `MOODLE_PASSWORD`, then deploy. The container initializes PostgreSQL, creates the database, runs Moodle's CLI installer, and generates `config.php`. Everything is automatic.
2. **Subsequent deploys** — the container detects existing data and skips initialization. Services start via supervisord.
3. **Cron** — Moodle's scheduled tasks run every minute automatically.

> **Important:** The CLI installer only runs once (when `config.php` doesn't exist). If you deploy without setting `MOODLE_WWWROOT` and `MOODLE_PASSWORD` the first time, Moodle won't install and you'll need to redeploy with them set.

## Data Persistence

You **must** configure Coolify persistent storage for these paths — otherwise data is lost when the container is replaced:

- `/var/lib/postgresql/data` — PostgreSQL database
- `/var/moodledata` — Moodle file storage

## File Structure

```
moodle/
└── Dockerfile
```

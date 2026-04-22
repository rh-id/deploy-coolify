# deploy-coolify

Dockerfile-based deployments for [Coolify](https://coolify.io).

## Moodle 5.2 (PostgreSQL)

All-in-one Docker image running Moodle 5.2 with PostgreSQL, Apache, and PHP 8.3 in a single container. Designed for Coolify's Dockerfile deployment mode.

### Architecture

| Component | Details |
|---|---|
| Base image | `moodlehq/moodle-php-apache:8.3` |
| Moodle | 5.2 (`MOODLE_502_STABLE`) |
| Database | PostgreSQL 18 (in-container, configurable via build arg) |
| Process manager | supervisord (postgres + apache + cron) |
| Document root | `/var/www/html/public` (Moodle 5.1+ security feature) |

### Build Args

| Arg | Default | Description |
|---|---|---|
| `MOODLE_BRANCH` | `MOODLE_502_STABLE` | Moodle Git branch |
| `PG_MAJOR` | `18` | PostgreSQL major version |

To change the PostgreSQL version, set the `PG_MAJOR` build arg in Coolify's service settings (e.g. `PG_MAJOR=16`). This installs PostgreSQL from the [official PostgreSQL APT repository](https://wiki.postgresql.org/wiki/Apt).

### Coolify Setup

1. Create a new **Public Repository** service in Coolify (or connect this repo)
2. Set the **Build Pack** to **Dockerfile**
3. Set the **Dockerfile Location** to `moodle/Dockerfile`
4. (Optional) Set **Build Args** — e.g. `PG_MAJOR=18` for a different PostgreSQL version
5. Configure **Persistent Storage** for both paths:

| Mount Path | Purpose |
|---|---|
| `/var/lib/postgresql/data` | PostgreSQL database |
| `/var/moodledata` | Moodle file storage (uploads, cache, etc.) |

6. Set the required **Environment Variables** (see below)
7. Deploy

### Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `MOODLE_WWWROOT` | **Yes** | — | Full public URL (e.g. `https://moodle.example.com`) |
| `MOODLE_PASSWORD` | **Yes** | — | Admin account password |
| `MOODLE_DATABASE_NAME` | No | `moodle` | PostgreSQL database name |
| `MOODLE_DATABASE_USER` | No | `moodle` | PostgreSQL user |
| `MOODLE_DATABASE_PASSWORD` | No | `moodlepass` | PostgreSQL password |
| `MOODLE_DATABASE_PORT` | No | `5432` | PostgreSQL port |
| `MOODLE_USERNAME` | No | `admin` | Moodle admin username |
| `MOODLE_EMAIL` | No | `admin@example.com` | Moodle admin email |
| `MOODLE_SITE_NAME` | No | `Moodle Site` | Moodle site full name |

`MOODLE_WWWROOT` and `MOODLE_PASSWORD` must be set before the first deployment. The Moodle CLI installer runs automatically on first boot when `config.php` does not exist.

### How It Works

1. **First run** — the entrypoint initializes PostgreSQL, creates the database/user, runs Moodle's CLI installer (`admin/cli/install.php`), and generates `config.php`
2. **Subsequent runs** — detects existing PostgreSQL data and skips initialization; starts all services via supervisord
3. **Cron** — Moodle's scheduled tasks run every minute via `/etc/cron.d/moodle`

### Data Persistence

The Dockerfile declares two volumes (`/var/lib/postgresql/data` and `/var/moodledata`). You **must** configure Coolify persistent storage for these paths to ensure data survives redeployments. Without explicit Coolify persistent storage, data may be lost when the container is replaced.

`config.php` is regenerated from environment variables on each fresh container start, so it does not need a persistent volume.

### File Structure

```
moodle/
├── Dockerfile             # All-in-one image definition
├── docker-entrypoint.sh   # PostgreSQL init, Moodle CLI installer, startup
├── supervisord.conf       # Process manager (postgres, apache, cron)
└── php-production.ini     # PHP production settings (opcache, memory, uploads)
```

## License

[MIT](LICENSE)

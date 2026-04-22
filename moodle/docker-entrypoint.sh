#!/bin/bash
set -e

MOODLE_DATABASE_NAME="${MOODLE_DATABASE_NAME:-moodle}"
MOODLE_DATABASE_USER="${MOODLE_DATABASE_USER:-moodle}"
MOODLE_DATABASE_PASSWORD="${MOODLE_DATABASE_PASSWORD:-moodlepass}"
MOODLE_DATABASE_PORT="${MOODLE_DATABASE_PORT:-5432}"
MOODLE_USERNAME="${MOODLE_USERNAME:-admin}"
MOODLE_EMAIL="${MOODLE_EMAIL:-admin@example.com}"
MOODLE_SITE_NAME="${MOODLE_SITE_NAME:-Moodle Site}"

mkdir -p /var/run/postgresql /var/moodledata
chown postgres:postgres /var/run/postgresql
chown www-data:www-data /var/moodledata

if [ ! -d "/var/lib/postgresql/data/base" ]; then
    echo "[init] Initializing PostgreSQL..."
    mkdir -p /var/lib/postgresql/data
    chown -R postgres:postgres /var/lib/postgresql/data

    su postgres -c "initdb -D /var/lib/postgresql/data --encoding=UTF8 --locale=C.UTF-8"
    sed -i 's/scram-sha-256/md5/g' /var/lib/postgresql/data/pg_hba.conf

    su postgres -c "pg_ctl -D /var/lib/postgresql/data -w start"
    su postgres -c "psql -c \"CREATE USER ${MOODLE_DATABASE_USER} WITH PASSWORD '${MOODLE_DATABASE_PASSWORD}' LOGIN;\""
    su postgres -c "psql -c \"CREATE DATABASE ${MOODLE_DATABASE_NAME} OWNER ${MOODLE_DATABASE_USER} ENCODING 'UTF8';\""
    su postgres -c "pg_ctl -D /var/lib/postgresql/data -w stop"
    echo "[init] PostgreSQL initialized."
fi

su postgres -c "pg_ctl -D /var/lib/postgresql/data -w start"

echo "[init] Waiting for PostgreSQL..."
until pg_isready -h localhost -q; do sleep 1; done
echo "[init] PostgreSQL ready."

if [ ! -f /var/www/html/config.php ] && [ -n "${MOODLE_WWWROOT}" ] && [ -n "${MOODLE_PASSWORD}" ]; then
    echo "[init] Running Moodle installer..."
    php /var/www/html/admin/cli/install.php \
        --wwwroot="${MOODLE_WWWROOT}" \
        --dataroot=/var/moodledata \
        --dbtype=pgsql \
        --dbhost=localhost \
        --dbname="${MOODLE_DATABASE_NAME}" \
        --dbuser="${MOODLE_DATABASE_USER}" \
        --dbpass="${MOODLE_DATABASE_PASSWORD}" \
        --dbport="${MOODLE_DATABASE_PORT}" \
        --adminuser="${MOODLE_USERNAME}" \
        --adminpass="${MOODLE_PASSWORD}" \
        --adminemail="${MOODLE_EMAIL}" \
        --fullname="${MOODLE_SITE_NAME}" \
        --shortname="${MOODLE_SITE_NAME}" \
        --non-interactive \
        --agree-license

    chown www-data:www-data /var/www/html/config.php
    chown -R www-data:www-data /var/moodledata
    echo "[init] Moodle installed."
fi

if [ -f /var/www/html/config.php ] && ! grep -q 'sslproxy' /var/www/html/config.php; then
    sed -i '/require_once.*lib\/setup\.php/i $CFG->sslproxy = true;' /var/www/html/config.php
    echo "[init] Added SSL proxy support to config.php."
fi

su postgres -c "pg_ctl -D /var/lib/postgresql/data -w stop" 2>/dev/null || true

echo "* * * * * www-data php /var/www/html/admin/cli/cron.php > /dev/null 2>&1" \
    > /etc/cron.d/moodle
chmod 0644 /etc/cron.d/moodle

echo "[init] Starting services..."
exec "$@"

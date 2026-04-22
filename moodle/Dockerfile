FROM moodlehq/moodle-php-apache:8.3

ARG MOODLE_BRANCH=MOODLE_502_STABLE
ARG PG_MAJOR=18
ENV PG_MAJOR=${PG_MAJOR}
ENV PATH="/usr/lib/postgresql/${PG_MAJOR}/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl \
       ca-certificates \
       gnupg \
    && install -d /usr/share/postgresql-common/pgdg \
    && curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc \
       --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    && echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] \
       http://apt.postgresql.org/pub/repos/apt $(. /etc/os-release && echo $VERSION_CODENAME)-pgdg main" \
       > /etc/apt/sources.list.d/pgdg.list \
    && echo "postgresql-${PG_MAJOR} postgresql-${PG_MAJOR}/create_main_cluster boolean false" \
       | debconf-set-selections \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       git \
       postgresql-${PG_MAJOR} \
       postgresql-client-${PG_MAJOR} \
       supervisor \
       cron \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/postgresql/${PG_MAJOR}/main

RUN git clone --depth 1 --branch ${MOODLE_BRANCH} \
    https://github.com/moodle/moodle.git /var/www/html

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

RUN mkdir -p /var/moodledata /var/run/postgresql /var/log/supervisor \
    && chown -R www-data:www-data /var/moodledata \
    && chown postgres:postgres /var/run/postgresql

COPY php-production.ini /usr/local/etc/php/conf.d/zz-production.ini
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

VOLUME ["/var/lib/postgresql/data", "/var/moodledata"]

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

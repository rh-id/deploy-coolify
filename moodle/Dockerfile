FROM moodlehq/moodle-php-apache:8.3

ARG MOODLE_BRANCH=MOODLE_502_STABLE
ARG PG_MAJOR=15
ENV PG_MAJOR=${PG_MAJOR}
ENV PATH="/usr/lib/postgresql/${PG_MAJOR}/bin:${PATH}"

RUN echo "postgresql-${PG_MAJOR} postgresql-${PG_MAJOR}/create_main_cluster boolean false" \
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

RUN mkdir -p /var/moodledata /var/run/postgresql /var/log/supervisor \
    && chown -R www-data:www-data /var/moodledata \
    && chown postgres:postgres /var/run/postgresql \
    && if [ -d /var/www/html/public ]; then \
         sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' \
           /etc/apache2/sites-available/000-default.conf; \
       fi

COPY php-production.ini /usr/local/etc/php/conf.d/zz-production.ini
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

VOLUME ["/var/lib/postgresql/data", "/var/moodledata"]

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

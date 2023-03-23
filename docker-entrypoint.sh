#!/bin/sh
set -e

if [ -n "${NEWRELIC_LICENSE}" ]; then
    { \
        echo "extension = newrelic.so"; \
        echo "[newrelic]"; \
        echo "newrelic.license = ${NEWRELIC_LICENSE}"; \
        echo "newrelic.application_logging.forwarding.log_level = ERROR"; \
        echo "newrelic.browser_monitoring.auto_instrument = false"; \
    } > /usr/local/etc/php/conf.d/newrelic.ini

    if [ -n "${NEWRELIC_DAEMON_ADDRESS}" ]; then
        echo "newrelic.daemon.address = ${NEWRELIC_DAEMON_ADDRESS}" >> /usr/local/etc/php/conf.d/newrelic.ini
    fi

    if [ -z "${NEWRELIC_APP_NAME}" ]; then
        if [ -n "${WP_HOME}" ]; then
            # Extract the domain name from the WP_HOME variable
            # e.g. https://example.com => example.com
            appname=$(echo "${WP_HOME}" | awk -F[/:] '{print $4}')
            echo "newrelic.appname = ${appname}" >> /usr/local/etc/php/conf.d/newrelic.ini
        fi
    else
        echo "newrelic.appname = ${NEWRELIC_APP_NAME}" >> /usr/local/etc/php/conf.d/newrelic.ini
    fi
else
    echo "New Relic license key or daemon address not set. Skipping New Relic setup."
fi

exec "$@"

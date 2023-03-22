#!/bin/sh
set -e

if [ -n "${NEWRELIC_LICENSE}" ] && [ -n "${NEWRELIC_DAEMON_ADDRESS}" ]; then
    { \
        echo "extension = newrelic.so"; \
        echo "newrelic.license = ${NEWRELIC_LICENSE}"; \
        echo "newrelic.daemon.address = ${NEWRELIC_DAEMON_ADDRESS}"; \
        echo "newrelic.application_logging.forwarding.log_level = ERROR"; \
        echo "newrelic.browser_monitoring.auto_instrument = false"; \
    } > /usr/local/etc/php/conf.d/newrelic.ini

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

if [ -n "${COMPOSER_TOKEN}" ]; then
    composer config -g github-oauth.github.com "${COMPOSER_TOKEN}"
else
    echo "Composer token not set. Skipping Composer setup."
fi

if [ -n "${METABOX_API_KEY}" ]; then
    composer config -g repositories.metabox\.io composer "https://packages.metabox.io/${METABOX_API_KEY}"
else
    echo "metabox.io API key not set. Skipping metabox.io setup."
fi

if [ -n "${YOAST_TOKEN}" ]; then
    composer config -g http-basic.my.yoast.com token "${YOAST_TOKEN}"
else
    echo "Yoast token not set. Skipping Yoast Premium setup."
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

exec "$@"

ARG PHP_VERSION=8.2

FROM --platform=$BUILDPLATFORM heycart-cli AS creation
ARG HEYCART_VERSION=6.5.8.12

RUN <<EOF
    set -e

    apk add --no-cache bash jq

    git clone -q https://github.com/heycart/heycart.git -b v$HEYCART_VERSION --depth=1 /shop
    cd /shop
    rm -rf .github .git
    composer config version $HEYCART_VERSION

    if ! jq -e '.["require-dev"]["phpstan/phpdoc-parser"]' composer.json > /dev/null 2>&1; then
        echo "phpstan/phpdoc-parser not found in require-dev, adding it..."

        jq '.["require-dev"]["phpstan/phpdoc-parser"] = "~1"' composer.json > composer.json.tmp

        mv composer.json.tmp composer.json
    fi

    composer install

    export APP_URL=http://localhost:8000

    export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
    export NPM_CONFIG_ENGINE_STRICT=false
    npm install --prefix src/Administration/Resources/app/administration --no-audit --no-fund
    npm install --prefix src/Storefront/Resources/app/storefront --no-audit --no-fund
    composer build:js:admin
    composer build:js:storefront || true
    find . -name 'node_modules' -type d -prune -print -exec rm -rf '{}' \;
EOF

COPY --chmod=555 --chown=1000:1000 <<EOF /shop/config/packages/override.yaml
parameters:
    env(TRUSTED_PROXIES): 'REMOTE_ADDR'

framework:
    trusted_proxies: '%env(TRUSTED_PROXIES)%'
    trusted_headers: [ 'x-forwarded-host',  'x-forwarded-proto',  'x-forwarded-for' ]

heycart:
    auto_update:
        enabled: false
    store:
        frw: false
EOF


FROM --platform=$BUILDPLATFORM base AS setup

ARG HEYCART_VERSION=6.5.8.12

COPY --from=creation --chown=www-data /shop /var/www/html

RUN --mount=type=cache,id=sqldump-dev=${HEYCART_VERSION},sharing=locked,target=/var/cache/sql <<EOF
    set -e
    /usr/bin/mariadbd --basedir=/usr --datadir=/var/lib/mariadb --plugin-dir=/usr/lib/mariadb/plugin --user=www-data --skip-networking &
    until mariadb-admin -hlocalhost ping; do sleep 1; done

    php bin/console system:install --create-database --force
    mariadb -hlocalhost -uroot -proot heycart -e "DELETE FROM sales_channel WHERE id = 0x98432def39fc4624b33213a56b8c944d"
    php bin/console user:create "admin" --admin --password="heycart" -n
    php bin/console sales-channel:create:storefront --name=Storefront --url="http://localhost:8000"
    php bin/console theme:change --all Storefront
    mariadb -hlocalhost -uroot -proot -e "SET GLOBAL innodb_fast_shutdown=0"
    mariadb -hlocalhost -uroot -proot heycart -e "INSERT INTO system_config (id, configuration_key, configuration_value, sales_channel_id, created_at, updated_at) VALUES (0xb3ae4d7111114377af9480c4a0911111, 'core.frw.completedAt', '{\"_value\": \"2019-10-07T10:46:23+00:00\"}', NULL, '2019-10-07 10:46:23.169', NULL);"
    rm -rf var/cache/* /var/tmp/*
    php bin/console

    sudo chown -R www-data /var/cache/sql/

    mariadb-dump -hlocalhost heycart | gzip > /var/cache/sql/heycart.sql.gz
EOF

FROM base

COPY --from=heycart/heycart-cli /usr/local/bin/heycart-cli /usr/local/bin/heycart-cli
COPY --from=setup /var/www/html /var/www/html

ARG HEYCART_VERSION=6.5.8.12

RUN --mount=type=cache,id=sqldump-dev=${HEYCART_VERSION},sharing=locked,target=/var/cache/sql <<EOF
    set -eo pipefail
    /usr/bin/mariadbd --basedir=/usr --datadir=/var/lib/mariadb --plugin-dir=/usr/lib/mariadb/plugin --user=www-data --skip-networking &
    until mariadb-admin  -hlocalhost ping; do sleep 1; done

    mariadb -hlocalhost -e 'CREATE DATABASE heycart'
    zcat /var/cache/sql/heycart.sql.gz | mariadb -hlocalhost heycart
EOF

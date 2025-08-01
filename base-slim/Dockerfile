# syntax=docker/dockerfile:1
# check=skip=SecretsUsedInArgOrEnv

ARG PHP_VERSION=8.3

FROM ghcr.io/shyim/wolfi-php/nginx:${PHP_VERSION}

ARG PHP_VERSION=8.3
ARG TARGETARCH

ENV DATABASE_URL=mysql://root:root@127.0.0.1/heycart \
    APP_SECRET=def00000bb5acb32b54ff8ee130270586eec0e878f7337dc7a837acc31d3ff00f93a56b595448b4b29664847dd51991b3314ff65aeeeb761a133b0ec0e070433bff08e48 \
    LOCK_DSN=flock \
    PHP_MEMORY_LIMIT=512M \
    PHP_POST_MAX_SIZE=128M \
    PHP_UPLOAD_MAX_FILESIZE=128M \
    COMPOSER_ROOT_VERSION=1.0.0 \
    APP_URL=http://localhost:8000 \
    NPM_CONFIG_ENGINE_STRICT=false \
    MAILER_URL=smtp://127.0.0.1:1025 \
    TRUSTED_PROXIES=REMOTE_ADDR \
    HEYCART_CACHE_ID=docker \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    NPM_CONFIG_ENGINE_STRICT=false \
    NPM_CONFIG_FUND=false \
    NPM_CONFIG_AUDIT=false \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    MAILER_DSN=smtp://127.0.0.1:1025

COPY --link rootfs /

RUN --mount=type=cache,id=apk-${TARGETARCH},sharing=locked,target=/var/cache/apk <<EOF
    set -e

    ln -s /var/cache/apk /etc/apk/cache

    apk update
    apk upgrade

    apk add --update \
        libstdc++ \
        posix-libc-utils \
        coreutils \
        bash \
        bash-completion \
        valkey-cli \
        curl \
        nodejs-22 \
        npm \
        git \
        git-completion \
        patch \
        sudo \
        shadow \
        openssh-client \
        openssh-keygen \
        composer \
        php-${PHP_VERSION} \
        php-${PHP_VERSION}-fileinfo \
        php-${PHP_VERSION}-openssl \
        php-${PHP_VERSION}-ctype \
        php-${PHP_VERSION}-curl \
        php-${PHP_VERSION}-xml \
        php-${PHP_VERSION}-dom \
        php-${PHP_VERSION}-phar \
        php-${PHP_VERSION}-simplexml \
        php-${PHP_VERSION}-xmlreader \
        php-${PHP_VERSION}-xmlwriter \
        php-${PHP_VERSION}-bcmath \
        php-${PHP_VERSION}-iconv \
        php-${PHP_VERSION}-mbstring \
        php-${PHP_VERSION}-gd \
        php-${PHP_VERSION}-intl \
        php-${PHP_VERSION}-pdo \
        php-${PHP_VERSION}-pdo_mysql \
        php-${PHP_VERSION}-mysqlnd \
        php-${PHP_VERSION}-pcntl \
        php-${PHP_VERSION}-sockets \
        php-${PHP_VERSION}-bz2 \
        php-${PHP_VERSION}-gmp \
        php-${PHP_VERSION}-soap \
        php-${PHP_VERSION}-ftp \
        php-${PHP_VERSION}-zip \
        php-${PHP_VERSION}-sodium \
        php-${PHP_VERSION}-opcache \
        php-${PHP_VERSION}-zstd \
        php-${PHP_VERSION}-redis \
        php-${PHP_VERSION}-apcu \
        php-${PHP_VERSION}-pcov \
        php-${PHP_VERSION}-tideways \
        php-${PHP_VERSION}-blackfire \
        php-${PHP_VERSION}-xdebug \
        openssl-config \
        mariadb-11.2-client \
        jq

    rm /etc/apk/cache

    ldconfig

    usermod -u 1000 www-data
    groupmod -g 1000 www-data

    echo '/bin/bash' >> /etc/shells
    echo 'www-data ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
    chsh -s /bin/bash www-data

    echo -e "[client]\nuser=root\npassword=root\nhost=database" > /home/www-data/.my.cnf

    sudo rm -rf /var/www/html/public

    chown -R 1000:1000 /var/www /home/www-data

    echo -e "blackfire.agent_socket=tcp://blackfire:8307" | sudo tee -a /etc/php/conf.d/blackfire.ini

    mv /etc/php/conf.d/blackfire.ini /etc/php/conf.d/blackfire.disabled
    mv /etc/php/conf.d/xdebug.ini /etc/php/conf.d/xdebug.disabled
    mv /etc/php/conf.d/tideways.ini /etc/php/conf.d/tideways.disabled
    mv /etc/php/conf.d/pcov.ini /etc/php/conf.d/pcov.disabled

    sed -i 's/client_max_body_size 8M;/client_max_body_size 128M;/' /etc/nginx/nginx.conf

EOF

COPY --from=heycart/heycart-cli:bin /heycart-cli /usr/local/bin/heycart-cli

ENTRYPOINT ["/entrypoint"]
CMD ["/usr/bin/hivemind", "/etc/Procfile"]

USER www-data

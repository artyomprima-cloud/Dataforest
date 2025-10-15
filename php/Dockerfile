FROM php:8.2-cli-alpine AS build

RUN apk add --no-cache \
        libxml2-dev \
        autoconf \
        gcc \
        g++ \
        make \
        protobuf-dev \
        libressl-dev \
        oniguruma-dev \
        bash \
        curl \
        openssh-client \
        git \
        zlib-dev \
        icu-dev \
        hiredis-dev \
        && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS

# Install SOAP extension
RUN docker-php-ext-install soap

# Install protobuf extension via PECL
RUN pecl install protobuf \
    && docker-php-ext-enable protobuf

# Install Redis extension via PECL
RUN pecl install redis \
    && docker-php-ext-enable redis

# Clean up build dependencies
RUN apk del .build-deps

# Stage 2: Final runtime image (minimal)
FROM php:8.2-fpm-alpine

RUN apk add --no-cache git grpc-cpp grpc-dev $PHPIZE_DEPS && \
    GRPC_VERSION=$(apk info grpc -d | grep grpc | cut -d- -f2) && \
    git clone --depth 1 -b v${GRPC_VERSION} https://github.com/grpc/grpc /tmp/grpc && \
    cd /tmp/grpc/src/php/ext/grpc && \
    phpize && \
    ./configure && \
    make && \
    make install && \
    rm -rf /tmp/grpc && \
    apk del --no-cache git grpc-dev $PHPIZE_DEPS && \
    echo "extension=grpc.so" > /usr/local/etc/php/conf.d/grpc.ini

# Copy PHP extensions and config from build stage
COPY --from=build /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=build /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d

COPY app /var/www/html

CMD ["php-fpm"] 


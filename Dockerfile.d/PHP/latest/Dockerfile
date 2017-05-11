FROM php:fpm-alpine
LABEL maintainer NanGua <nangua.ws@gmail.com>

# phalcon 版本
ENV PHALCON_VERSION=3.1.2

ENV PHPIZE_DEPS \
		autoconf \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkgconf \
		re2c
		
RUN set -xe \
	&& cd /tmp \
	&& apk add --no-cache --virtual .ext_deps \
	$PHPIZE_DEPS \
	git \
	bash \
	curl-dev \
	libedit-dev \
	libxml2-dev \
	openssl-dev \
	sqlite-dev \
	zlib-dev \
	freetype-dev libpng-dev libjpeg-turbo-dev \
	&& apk add --no-cache freetype libpng libjpeg-turbo \
	&& docker-php-ext-configure zip --with-zlib-dir \
	&& docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include --with-png-dir=/usr/include --with-jpeg-dir=/usr/include \
	# && NPROC=$(getconf _NPROCESSORS_ONLN) \
	&& docker-php-ext-install zip pdo pdo_mysql gd \
	# && curl -LO https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz \
	# && tar xzf v${PHALCON_VERSION}.tar.gz \
	# && cd cphalcon-${PHALCON_VERSION}/build \
	# && sh install \
	# && echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini \
	# && curl -LO https://github.com/phalcon/phalcon-devtools/archive/v${PHALCON_VERSION}.tar.gz \
	# && tar xzf v${PHALCON_VERSION}.tar.gz \
	# && mv phalcon-devtools-${PHALCON_VERSION} /usr/local/phalcon-devtools \
	# && ln -s /usr/local/phalcon-devtools/phalcon.php /usr/local/bin/phalcon \
	&& git clone --depth=1 https://github.com/phalcon/cphalcon.git \
	&& cd cphalcon/build \
	&& ./install \
	&& rm -rf /tmp/* \
	#&& echo "extension=phalcon.so" > /etc/php/conf.d/phalcon.ini \
	&& pecl install redis \
	&& docker-php-ext-enable redis \
	&& rm -rf /tmp/pear \
	&& apk del --no-cache .ext_deps

WORKDIR /var/www/html

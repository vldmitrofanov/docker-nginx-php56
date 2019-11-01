FROM ubuntu:16.04
LABEL maintainer="shirker2006@gmail.com"

ENV OS_LOCALE="en_US.UTF-8"
RUN apt-get clean && apt-get -y update && apt-get install -y locales
RUN locale-gen ${OS_LOCALE}
ENV LANG=${OS_LOCALE} \
    LANGUAGE=${OS_LOCALE} \
    LC_ALL=${OS_LOCALE} \
	NGINX_CONF_DIR=/etc/nginx
ENV PHP_RUN_DIR=/run/php \
    PHP_LOG_DIR=/var/log/php \
    PHP_CONF_DIR=/etc/php/5.6 \
    PHP_DATA_DIR=/var/lib/php

COPY ./supervisord.conf /etc/supervisor/conf.d/
COPY ./app /var/www/app/

RUN	\
	BUILD_DEPS='software-properties-common python-software-properties wget' \
	&& apt-get update \
	&& echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
	&& apt-get install --no-install-recommends -y ${BUILD_DEPS} \
    && wget -O - http://nginx.org/keys/nginx_signing.key | apt-key add - \
	&& echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list \
	&& echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install apt-file -y \
	&& apt-file update 
RUN	\
	apt-get install mysql-client vim lsof iputils-ping -y \
	#&& add-apt-repository -y ppa:jukito-gmail/php5.6 \
	&& add-apt-repository -y ppa:ondrej/php \
	&& apt-get update \
	# Install PHP libraries
	&& apt-get install -y php5.6 \
	#&& apt install php5.6-dev libmcrypt-dev php-pear -y\
	&& apt-get install -y curl php5.6-fpm php5.6-cli php5.6-readline php5.6-mbstring php5.6-zip php5.6-intl php5.6-xml php5.6-json php5.6-curl php5.6-mcrypt php5.6-gd php5.6-pgsql php5.6-mysql php-pear \
	# && php5enmod mcrypt \
	#&&  pecl channel-update pecl.php.net \
    #&&  pecl install mcrypt-1.0.1 \
	&& echo "apc.enable_cli=1" >> ${PHP_CONF_DIR}/mods-available/apc.ini \
	# Install composer
	&& curl -sS https://getcomposer.org/installer | php -- --version=1.6.5 --install-dir=/usr/local/bin --filename=composer \
	&& echo \
	&& mkdir -p ${PHP_LOG_DIR}  && mkdir -p ${PHP_RUN_DIR} 
	# Cleaning
RUN	\
	apt-get install -y nginx \
	&& rm -rf  ${NGINX_CONF_DIR}/sites-enabled/* ${NGINX_CONF_DIR}/sites-available/* \
	# Install supervisor
	&& apt-get install -y supervisor && mkdir -p /var/log/supervisor \
	&& chown nginx:nginx /var/www/app/ -Rf \
	# Cleaning
	&& apt-get purge -y --auto-remove ${BUILD_DEPS} \
	&& apt-get autoremove -y && apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	# Forward request and error logs to docker log collector
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

COPY ./configs/nginx.conf ${NGINX_CONF_DIR}/nginx.conf
COPY ./configs/app.conf ${NGINX_CONF_DIR}/sites-enabled/app.conf
COPY ./configs/www.conf ${PHP_CONF_DIR}/fpm/pool.d/www.conf
COPY ./configs/php.ini ${PHP_CONF_DIR}/fpm/conf.d/custom.ini
COPY ./configs/php-fpm.conf ${PHP_CONF_DIR}/fpm/php-fpm.conf 

RUN sed -i "s@PHP_RUN_DIR@${PHP_RUN_DIR}@g" ${PHP_CONF_DIR}/fpm/php-fpm.conf \
    && sed -i "s@PHP_LOG_DIR@${PHP_LOG_DIR}@g" ${PHP_CONF_DIR}/fpm/php-fpm.conf \
    && chown nginx:nginx ${PHP_DATA_DIR} -Rf

WORKDIR /var/www/app/

EXPOSE 80 443

#CMD ["/usr/bin/supervisord"]
# PHP_DATA_DIR store sessions
VOLUME ["${PHP_RUN_DIR}", "${PHP_DATA_DIR}"]
CMD ["/usr/bin/supervisord"]

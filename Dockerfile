# =============================================================================
#
# CentOS-7, Apache 2.2, PHP 7.1, MySql, OCI8
#
# =============================================================================
FROM centos:centos7
MAINTAINER SeonGyuHwang <hsg377@gmail.com>

ARG uid=1000

# -----------------------------------------------------------------------------
# Import the RPM GPG keys for Repositories
# -----------------------------------------------------------------------------
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
	&& rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

# -----------------------------------------------------------------------------
# Apache + PHP
# -----------------------------------------------------------------------------
RUN	yum -y update \
	&& yum --setopt=tsflags=nodocs -y install \
	gcc \
	gcc-c++ \
	httpd \
	mod_ssl \
	php71w \
	php71w-opcache \
	php71w-cli \
	php71w-devel \
	php71w-common \
	php71w-gd \
	php71w-intl \
	php71w-mbstring \
	php71w-mcrypt \
	php71w-mysql \
	php71w-openssl \
	php71w-curl \
	php71w-pdo \
	php71w-pear \
	php71w-soap \
	php71w-xml \
	php71w-xmlrpc \
	php71w-pecl-apcu \
	zip \
	unzip \
	build-essential \
	systemtap-sdt-devel \
	libfreetype6-dev \
	libjpeg62-turbo-dev \
	libmcrypt-dev \
	libpng-dev \
	libaio \
	&& rm -rf /var/cache/yum/* \
	&& yum clean all

RUN export PHP_DTRACE=yes
RUN echo 'export PHP_DTRACE=yes' >> /root/.bashrc

# -----------------------------------------------------------------------------
# UTC Timezone & Networking
# -----------------------------------------------------------------------------
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
	&& echo "NETWORKING=yes" > /etc/sysconfig/network

# -----------------------------------------------------------------------------
# Global Apache configuration changes
# Disable Apache directory indexes
# Disable Apache language based content negotiation
# Disable all Apache modules and enable the minimum
# Enable ServerStatus access via /_httpdstatus to local client
# Apache tuning
# -----------------------------------------------------------------------------
RUN sed -i \
	-e 's~^ServerSignature On$~ServerSignature Off~g' \
	-e 's~^ServerTokens OS$~ServerTokens Prod~g' \
	-e 's~^#ServerName \(.*\)$~ServerName localhost~g' \
	-e 's~^DirectoryIndex \(.*\)$~DirectoryIndex \1 index.php~g' \
	-e 's~^Group apache$~Group app~g' \
	-e 's~^IndexOptions \(.*\)$~#IndexOptions \1~g' \
	-e 's~^IndexIgnore \(.*\)$~#IndexIgnore \1~g' \
	-e 's~^AddIconByEncoding \(.*\)$~#AddIconByEncoding \1~g' \
	-e 's~^AddIconByType \(.*\)$~#AddIconByType \1~g' \
	-e 's~^AddIcon \(.*\)$~#AddIcon \1~g' \
	-e 's~^DefaultIcon \(.*\)$~#DefaultIcon \1~g' \
	-e 's~^ReadmeName \(.*\)$~#ReadmeName \1~g' \
	-e 's~^HeaderName \(.*\)$~#HeaderName \1~g' \
	-e 's~^LanguagePriority \(.*\)$~#LanguagePriority \1~g' \
	-e 's~^ForceLanguagePriority \(.*\)$~#ForceLanguagePriority \1~g' \
	-e 's~^AddLanguage \(.*\)$~#AddLanguage \1~g' \
	-e 's~^\(LoadModule .*\)$~#\1~g' \
	-e 's~^\(#LoadModule version_module modules/mod_version.so\)$~\1\n#LoadModule reqtimeout_module modules/mod_reqtimeout.so~g' \
	-e 's~^#LoadModule mime_module ~LoadModule mime_module ~g' \
	-e 's~^#LoadModule log_config_module ~LoadModule log_config_module ~g' \
	-e 's~^#LoadModule setenvif_module ~LoadModule setenvif_module ~g' \
	-e 's~^#LoadModule status_module ~LoadModule status_module ~g' \
	-e 's~^#LoadModule authz_host_module ~LoadModule authz_host_module ~g' \
	-e 's~^#LoadModule dir_module ~LoadModule dir_module ~g' \
	-e 's~^#LoadModule alias_module ~LoadModule alias_module ~g' \
	-e 's~^#LoadModule rewrite_module ~LoadModule rewrite_module ~g' \
	-e 's~^#LoadModule expires_module ~LoadModule expires_module ~g' \
	-e 's~^#LoadModule deflate_module ~LoadModule deflate_module ~g' \
	-e 's~^#LoadModule headers_module ~LoadModule headers_module ~g' \
	-e 's~^#LoadModule alias_module ~LoadModule alias_module ~g' \
	-e '/#<Location \/server-status>/,/#<\/Location>/ s~^#~~' \
	-e '/<Location \/server-status>/,/<\/Location>/ s~Allow from .example.com~Allow from localhost 127.0.0.1~' \
	-e 's~^StartServers \(.*\)$~StartServers 3~g' \
	-e 's~^MinSpareServers \(.*\)$~MinSpareServers 3~g' \
	-e 's~^MaxSpareServers \(.*\)$~MaxSpareServers 3~g' \
	-e 's~^ServerLimit \(.*\)$~ServerLimit 10~g' \
	-e 's~^MaxClients \(.*\)$~MaxClients 10~g' \
	-e 's~^MaxRequestsPerChild \(.*\)$~MaxRequestsPerChild 1000~g' \
	/etc/httpd/conf/httpd.conf

# -----------------------------------------------------------------------------
# Limit process for the application user
# -----------------------------------------------------------------------------
RUN { \
		echo ''; \
		echo $'apache\tsoft\tnproc\t30'; \
		echo $'apache\thard\tnproc\t50'; \
		echo $'app\tsoft\tnproc\t30'; \
		echo $'app\thard\tnproc\t50'; \
	} >> /etc/security/limits.conf

# -----------------------------------------------------------------------------
# Global PHP configuration changes
# -----------------------------------------------------------------------------
RUN sed -i \
	-e 's~^;date.timezone =$~date.timezone = Asia/Seoul~g' \
	-e 's~^;user_ini.filename =$~user_ini.filename =~g' \
	-e 's~^;always_populate_raw_post_data = -1$~always_populate_raw_post_data = -1~g' \
	-e 's/^short_open_tag.*/short_open_tag = On/' \
	-e 's/^register_globals.*/register_globals = Off/' \
	-e 's/^allow_url_fopen.*/allow_url_fopen = On/' \
	-e 's/^post_max_size.*/post_max_size = 256M/' \
	-e 's/^upload_max_filesize.*/upload_max_filesize = 256M/' \
	/etc/php.ini

# -----------------------------------------------------------------------------
# Add default service users
# -----------------------------------------------------------------------------
RUN useradd -u ${uid} -d /var/www/app -m app \
	&& usermod -a -G app apache

# -----------------------------------------------------------------------------
# Set permissions
# -----------------------------------------------------------------------------
RUN chown -R app:app /var/www/app \
	&& chmod 777 /var/www/app \
	&& chmod -R g+w /var/www/app

RUN mkdir -p /home/{acushnet-web,wwwtitleistapparel} \
	&& chown -R app:app /home \
	&& chmod 777 /home \
	&& chmod -R g+w /home

# -----------------------------------------------------------------------------
# Virtual hosts configuration
# -----------------------------------------------------------------------------
ADD etc/httpd/conf.d/ /etc/httpd/conf.d

# -----------------------------------------------------------------------------
# oci8 setup
# -----------------------------------------------------------------------------
ADD oracle/instantclient-basiclite-linux.x64-19.3.0.0.0dbru.zip /tmp/
ADD oracle/instantclient-sdk-linux.x64-19.3.0.0.0dbru.zip /tmp/
ADD oracle/instantclient-sqlplus-linux.x64-19.3.0.0.0dbru.zip /tmp/

RUN unzip /tmp/instantclient-basiclite-linux.x64-19.3.0.0.0dbru.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-19.3.0.0.0dbru.zip -d /usr/local/
RUN unzip /tmp/instantclient-sqlplus-linux.x64-19.3.0.0.0dbru.zip -d /usr/local/

RUN ln -s /usr/local/instantclient_19_3 /usr/local/instantclient
RUN ln -s /usr/local/instantclient/lib* /usr/lib
RUN ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus

RUN echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"' >> /root/.bashrc
RUN echo 'umask 002' >> /root/.bashrc

RUN echo 'instantclient,/usr/local/instantclient' | pecl install oci8-2.2.0
RUN echo "extension=oci8.so" > /etc/php.d/php-oci8.ini

# -----------------------------------------------------------------------------
# Remove packages
# -----------------------------------------------------------------------------
RUN yum -y remove \
	gcc \
	gcc-c++ \
	&& rm -rf /var/cache/yum/* \
	&& yum clean all

# -----------------------------------------------------------------------------
# Set default environment variables used to identify the service container
# -----------------------------------------------------------------------------
ENV SERVICE_UNIT_APP_GROUP app-1 
ENV	SERVICE_UNIT_LOCAL_ID 1
ENV	SERVICE_UNIT_INSTANCE 1

# -----------------------------------------------------------------------------
# Set default environment variables used to configure the service container
# -----------------------------------------------------------------------------
ENV APACHE_SERVER_ALIAS "" 
ENV	APACHE_SERVER_NAME app-1.local 
ENV	APP_HOME_DIR /var/www/app
ENV	DATE_TIMEZONE UTC 
ENV	HTTPD /usr/sbin/httpd 
ENV	SERVICE_USER app 
ENV	SERVICE_USER_GROUP app 
ENV	SERVICE_USER_PASSWORD "" 
ENV	SUEXECUSERGROUP false 
ENV	TERM xterm
ENV DB_MYSQL_PORT_3306_TCP_ADDR ""
ENV DB_MYSQL_PORT_3306_TCP_PORT ""

# -----------------------------------------------------------------------------
# Set Environment variable
# -----------------------------------------------------------------------------
RUN localedef -i en_GB -f UTF-8 en_GB.UTF-8
ENV LANG en_GB.UTF-8

# -----------------------------------------------------------------------------
# Set ports
# -----------------------------------------------------------------------------
EXPOSE 80
EXPOSE 443

# -----------------------------------------------------------------------------
# Copy files into place
# -----------------------------------------------------------------------------
CMD ["/usr/sbin/httpd", "-DFOREGROUND"]
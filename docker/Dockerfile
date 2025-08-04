# Based on example https://github.com/oracle/docker-images/blob/main/OracleLinuxDevelopers/oraclelinux8/php/8.0-apache/Dockerfile

# Start build from official Oracle Linux 8 image
FROM oraclelinux:8

# Install required repos and packages
RUN dnf -y install oracle-instantclient-release-el8 && \
    dnf -y install oracle-instantclient-basic oracle-instantclient-devel oracle-instantclient-sqlplus && \
    dnf -y module enable php:8.2 httpd:2.4 && \
    dnf -y install \
        httpd \
        httpd-filesystem \
        httpd-tools \
        mod_http2 \
        php \
        php-cli \
        php-common \
        php-json \
        php-mbstring \
        php-mysqlnd \
        php-pdo \
        php-xml \
        php-pear \
        php-devel && \
    rm -rf /var/cache/dnf \
    && \
    # Disable event module and enable prefork so that mod_php is enabled
    sed -i 's/#LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/' /etc/httpd/conf.modules.d/00-mpm.conf && \
    sed -i 's/LoadModule mpm_event_module modules\/mod_mpm_event.so/#LoadModule mpm_event_module modules\/mod_mpm_event.so/' /etc/httpd/conf.modules.d/00-mpm.conf && \
    # Disable HTTP2 as it is not supported with the prefork module
    sed -i 's/LoadModule http2_module modules\/mod_http2.so/#LoadModule http2_module modules\/mod_http2.so/' /etc/httpd/conf.modules.d/10-h2.conf && \
    sed -i 's/LoadModule proxy_http2_module modules\/mod_proxy_http2.so/#LoadModule proxy_http2_module modules\/mod_proxy_http2.so/' /etc/httpd/conf.modules.d/10-proxy_h2.conf \
    && \
    # Redirect logging to stdout/stderr for container logging to work
    sed -i 's/;error_log = syslog/error_log = \/dev\/stderr/' /etc/php.ini && \
    ln -sf /dev/stdout /var/log/httpd/access_log && \
    ln -sf /dev/stderr /var/log/httpd/error_log && \
    ln -sf /dev/stdout /var/log/httpd/ssl_access_log && \
    ln -sf /dev/stderr /var/log/httpd/ssl_error_log && \
    # Disable userdirs and the auto-generated welcome message
    rm -f /etc/httpd/conf.d/{userdir.conf,welcome.conf}
    
# Set environment variables for Oracle Instant Client libraries
ENV PATH=$PATH:/usr/lib/oracle/21/client64/bin
ENV ORACLE_HOME=/usr/lib/oracle/21/client64
ENV TNS_ADMIN=/usr/lib/oracle/21/network/admin
ENV LD_LIBRARY_PATH=$ORACLE_HOME/lib


# Install OCI8 PHP extension using PECL
RUN echo instantclient,/usr/lib/oracle/21/client64/lib | pecl install oci8 \
    && echo "extension=oci8.so" > /etc/php.d/20-oci8.ini

# Configure httpd
COPY ./config/httpd/*.conf /etc/httpd/conf.d/

# Disable directory listing, specifically for virtual directory '/icons/small/'
RUN sed -i 's/Options Indexes MultiViews FollowSymlinks/Options MultiViews FollowSymlinks/' /etc/httpd/conf.d/autoindex.conf

# Secure php
COPY ./config/php/*.ini /etc/php.d/

# copy the application source files:
COPY ./src/frontend/ /var/www/html/
COPY ./src/backend/ /usr/src/app/includes

# Set WORKDIR to webroot to set default context for remaining commands
WORKDIR /var/www/html

# Set entry point for passing commands from the host
ENTRYPOINT ["/usr/sbin/httpd"]

# Start the daemon to keep process running
CMD ["-D", "FOREGROUND"]


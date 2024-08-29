# Start build from official CentOS 7 / Perl 524 image
FROM centos:centos7

# Image starts with non-root user default, switch to root for installation steps
#USER root

# Set ENV variables for Oracle
ENV LD_LIBRARY_PATH /usr/lib/oracle/18.3/client64/lib
ENV PATH /usr/lib/oracle/18.3/client64/lib:/usr/lib/oracle/18.3/client64/bin:${PATH}
ENV ORACLE_HOME /usr/lib/oracle/18.3/client64
ENV TNS_ADMIN /usr/lib/oracle/18.3/network/admin

# NEW ENV variables
ENV APACHE_SERVER_NAME picahi.nmfs.local

# Basic package udpate and cleanup and Apache
RUN yum -y update && yum clean all && yum -y install httpd
RUN yum -y install mod_ssl

# Install perl and all dependencies and cleanup yum cache at end
RUN yum -y install perl \
                    perl-Authen-SASL \
                    perl-BSD-Resource \
                    perl-CGI \
                    perl-CPAN \
                    perl-Compress-Raw-Zlib \
                    perl-Compress-Zlib \
                    perl-Convert-ASN1 \
                    perl-DBI \
                    perl-DBD-MySQL \
                    perl-DBD-Oracle \
                    perl-Date-Manip \
                    perl-Digest-HMAC \
                    perl-Digest-SHA \
                    perl-Digest-SHA1 \
                    perl-ExtUtils-MakeMaker \
                    perl-ExtUtils-ParseXS \
                    perl-GSSAPI \
                    perl-HTML-Parser \
                    perl-HTML-Tagset \
                    perl-IO-Compress-Base \
                    perl-IO-Compress-Zlib \
                    perl-IO-Socket-SSL \
                    perl-LDAP \
                    perl-Module-Pluggable \
                    perl-Net-LibIDN \
                    perl-Net-SSLeay \
                    perl-Pod-Escapes \
                    perl-Pod-Simple \
                    perl-Test-Harness \
                    perl-Text-Iconv \
                    perl-Test-Simple \
                    perl-URI \
                    perl-XML-Filter-BufferText \
                    perl-XML-LibXML \
                    perl-XML-NamespaceSupport \
                    perl-XML-SAX \
                    perl-XML-SAX-Writer \
                    perl-YAML-Syck \
                    perl-devel \
                    perl-libs \
                    perl-libwww-perl \
                    perl-version \
                    && yum clean all && rm -rf /var/cache/yum

# Install dev related tools including gcc for compiling DB::Oracle Perl module
RUN yum -y groupinstall "Development Tools"

# Copy Oracle RPM(s)
COPY ./oracle/oracle-instantclient18.3-*.rpm /oracle-client-rpms/

# Install Oracle RPM(s)
RUN yum -y localinstall /oracle-client-rpms/oracle-instantclient18.3-basic-18.3.0.0.0-2.x86_64.rpm && \
    yum -y localinstall /oracle-client-rpms/oracle-instantclient18.3-devel-18.3.0.0.0-2.x86_64.rpm && \
    yum -y localinstall /oracle-client-rpms/oracle-instantclient18.3-odbc-18.3.0.0.0-2.x86_64.rpm && \
    yum -y localinstall /oracle-client-rpms/oracle-instantclient18.3-sqlplus-18.3.0.0.0-2.x86_64.rpm && \
    yum -y localinstall /oracle-client-rpms/oracle-instantclient18.3-tools-18.3.0.0.0-2.x86_64.rpm

# Download/install/cleanup DB::Oracle Perl module from source
#RUN curl -O https://cpan.metacpan.org/authors/id/P/PY/PYTHIAN/DBD-Oracle-1.66.tar.gz
#RUN tar xvf DBD-Oracle-1.66.tar.gz
#RUN mv DBD-Oracle-1.66/lib/DBD /usr/share/perl5/vendor_perl
#RUN rm -Rf DBD-Oracle-1.66 DBD-Oracle-1.66.tar.gz
#RUN perl Makefile.pl

# Install cpanminus for zero config cpan module installation for DBD::Oracle installation
RUN curl -L http://cpanmin.us | perl - --self-upgrade

# Install Oracle DBD module using cpanm (much simpler process than cpan or perl -mcpan methods)
# the "force" is needed because the self-tests fail trying to connect to a database
# which causes the install to abort
RUN cpanm --force DBD::Oracle

# Install Oracle DBD module
#RUN perl -MCPAN -e 'install DBD::Oracle'

# Remove all dev packages for security purposes to not allow compilation in container
#RUN yum -y groupremove "Development Tools" \
#                    && yum clean all && rm -rf /var/cache/yum

# Copy perl-based systemctl
# This script doesn't work as advertised
#COPY /etc/systemctl.py /usr/bin/systemctl

# Copy Oracle tnsnames file
COPY ./oracle/tnsnames.ora /usr/lib/oracle/18.3/network/admin/

# Copy our custom httpd.conf and ssl.conf to override default
COPY ./httpd/httpd.conf /etc/httpd/conf/
COPY ./httpd/ssl.conf /etc/httpd/conf.d/

# NEW: Copy host certs
COPY ./etc/picahi.nmfs.local.public /etc/pki/tls/private
COPY ./etc/picahi.crt /etc/pki/tls/certs
COPY ./etc/DOD_ca_1.cer /etc/pki/tls/certs
RUN chmod 644 /etc/pki/tls/certs/picahi.crt
RUN chmod 644 /etc/pki/tls/certs/DOD_ca_1.cer

# Copy custom perl-script to specified CGI directory
COPY ./src/ /var/www/

# Set WORKDIR to webroot to set default context for remaining commands
WORKDIR /var/www/cgi-bin

# Set proper permissions for Perl scripts to execute
RUN chmod +x *.pl

# Set entry point for passing commands from the host
ENTRYPOINT ["/usr/sbin/httpd"]

# Start the daemon to keep process running
CMD ["-D", "FOREGROUND"]

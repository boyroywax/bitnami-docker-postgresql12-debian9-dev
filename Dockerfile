FROM bitnami/minideb:stretch
LABEL maintainer "Bitnami <containers@bitnami.com>"

ARG PostgresqlVersion="9.6.16-1"
ARG PostgresqlChkSum="a58944dc3c1079eaf7c34733ce75b82a99183f7f356d7e07e83797df1889064f"
ARG PostGISVer="3.0.1dev"
ARG GeosVer="3.8.0"
# ARG PLv8Ver="2.3.13"

ENV BITNAMI_PKG_CHMOD="-R g+rwX" \
    HOME="/" \
    OS_ARCH="amd64" \
    OS_FLAVOUR="debian-9" \
    OS_NAME="linux" \
    POST_GIS_VER=${PostGISVer} \
    GEOS_VER=${GeosVer} \
    PLV8_VER=${PLv8Ver}


COPY prebuildfs /
# Install required system packages and dependencies
RUN install_packages ca-certificates curl libbsd0 libc6 libedit2 libffi6 libgcc1 libgmp10 libgnutls30 libhogweed4 libicu57 libidn11 libldap-2.4-2 liblzma5 libncurses5 libnettle6 libnss-wrapper libp11-kit0 libsasl2-2 libsqlite3-0 libssl1.1 libstdc++6 libtasn1-6 libtinfo5 libuuid1 libxml2 libxslt1.1 locales procps unzip zlib1g build-essential libtool autoconf unzip wget libproj-dev libgdal-dev git python libc++-dev libxml2-dev proj-bin sqlite3
RUN . ./libcomponent.sh && component_unpack "postgresql" ${PostgresqlVersion} --checksum ${PostgresqlChkSum}
RUN curl --silent -L https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64 > /usr/local/bin/gosu && \
    echo 0b843df6d86e270c5b0f5cbd3c326a04e18f4b7f9b8457fa497b0454c4b138d7 /usr/local/bin/gosu | sha256sum --check && \
    chmod u+x /usr/local/bin/gosu && \
    mkdir -p /opt/bitnami/licenses && \
    curl --silent -L https://raw.githubusercontent.com/tianon/gosu/master/LICENSE > /opt/bitnami/licenses/gosu-1.11.txt
RUN echo 'en_GB.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen

COPY rootfs /
RUN /postunpack.sh
ENV BITNAMI_APP_NAME="postgis" \
    BITNAMI_IMAGE_VERSION="${PostgresqlVersion}-debian-9-r23" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    NAMI_PREFIX="/.nami" \
    NSS_WRAPPER_LIB="/usr/lib/libnss_wrapper.so" \
    PATH="/opt/bitnami/postgresql/bin:$PATH"

VOLUME [ "/bitnami/postgresql", "/docker-entrypoint-initdb.d", "/docker-entrypoint-preinitdb.d" ]

EXPOSE 5432

USER 1001
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/run.sh" ]
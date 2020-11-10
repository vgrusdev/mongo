#FROM debian:jessie
FROM ubuntu:xenial

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -g 1999 -r mongodb && useradd  -u 1999 -r -g mongodb mongodb && \
 apt-get update \
	&& apt-get install -y --no-install-recommends \
		numactl \
	&& rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates wget \
#           gpg gpg-agent dirmngr \
        && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" 
#
RUN	export GNUPGHOME="$(mktemp -d)" \
#	&& gpg --keyserver https://ha.pool.sks-keyservers.net \
        && gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 \
#        && gpg --keyserver hkps://hkps.pool.sks-keyservers.net \
             --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
	&& apt-get purge -y --auto-remove ca-certificates wget

# pub   4096R/A15703C6 2016-01-11 [expires: 2018-01-10]
#       Key fingerprint = 0C49 F373 0359 A145 1858  5931 BC71 1F9B A157 03C6
# uid                  MongoDB 3.6 Release Signing Key <packaging@mongodb.com>
# RUN apt-key adv --keyserver ha.pool.sks-keyservers.net \

# VG
#RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 \
#              --recv-keys 9DA31620334BD75D9DCB49F368818C72E52529D4
#
#ENV MONGO_MAJOR 4.0
#ENV MONGO_VERSION 4.0.20
#ENV MONGO_REPO=repo.mongodb.org
#ENV MONGO_PACKAGE mongodb-enterprise
#
## RUN echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/$MONGO_MAJOR main" > /etc/apt/sources.list.d/mongodb-org.list
#RUN echo "deb http://$MONGO_REPO/apt/ubuntu xenial/${MONGO_PACKAGE%-unstable}/$MONGO_MAJOR multiverse" | tee "/etc/apt/sources.list.d/${MONGO_PACKAGE%-unstable}.list"
#
#
RUN set -x \
	&& apt-get update \
	&& apt-get install -y \
#		${MONGO_PACKAGE}=$MONGO_VERSION \
#		${MONGO_PACKAGE}-server=$MONGO_VERSION \
#		${MONGO_PACKAGE}-shell=$MONGO_VERSION \
#		${MONGO_PACKAGE}-mongos=$MONGO_VERSION \
#		${MONGO_PACKAGE}-tools=$MONGO_VERSION \
  ca-certificates krb5-locales libcurl3 libgssapi-krb5-2 libidn11 libk5crypto3 \
  libkeyutils1 libkrb5-3 libkrb5support0 libldap-2.4-2 librtmp1 libsasl2-2 \
  libsasl2-modules libsasl2-modules-db libssh2-1 libssl1.0.0 \
  openssl \
	&& rm -rf /var/lib/apt/lists/* 
#	&& rm -rf /var/lib/mongodb \
#	&& mv /etc/mongod.conf /etc/mongod.conf.orig

RUN mkdir -p /data/db /data/configdb \
	&& chown -R mongodb:mongodb /data/db /data/configdb
VOLUME /data/db /data/configdb

LABEL description="OEM(non-modified) version of mongo image with fixed uid for user(1999)"

COPY bin/* /usr/bin/
COPY docker-entrypoint.sh /entrypoint.sh
COPY mongod.conf /etc/mongod.conf.orig

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 27017
CMD ["mongod"]

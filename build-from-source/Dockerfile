FROM ubuntu:16.04
MAINTAINER Valery Gruzdsev
RUN apt-get update && \
    apt-get install -y gcc libcurl4-openssl-dev python2.7-dev \
    libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-thread-dev \
    libssl-dev build-essential && \
    mkdir -p /data/db
 EXPOSE 27017 28017
# CMD ["mongod"]
CMD ["/bin/bash"]


# hadolint ignore=DL3006
FROM "ubuntu:noble"

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends curl openjdk-17-jre-headless && \
    mkdir /opt/activemq && \
    curl -L "https://www.apache.org/dyn/closer.cgi?filename=/activemq/6.1.3/apache-activemq-6.1.3-bin.tar.gz&action=download" -o /opt/activemq/activemq-bin.tar.gz && \
    rm -rf /var/lib/apt/lists/*

WORKDIR "/opt/activemq"

RUN echo "e47e907a85a9625e3e19ccea1bab293eba842e58d30b12936087ececbb65a14297d527152ad276f6f759ad403ad91308671eec66db06ada4d331f903762cc0b4 *activemq-bin.tar.gz" > activemq-bin.tar.gz.sha512 && \
    sha512sum -c activemq-bin.tar.gz.sha512 && \
    tar xzf activemq-bin.tar.gz --strip-components 1 && \
    useradd -r -M -d /opt/activemq activemq && \
    chown -R activemq:activemq /opt/activemq && \
    chown -h activemq:activemq /opt/activemq && \
    rm activemq-bin.tar.gz activemq-bin.tar.gz.sha512

USER activemq

ENTRYPOINT [ "bin/activemq" ]

CMD [ "console" ]

LABEL org.opencontainers.image.created="2024-08-22T11:08:25Z" \
      org.opencontainers.image.source="https://github.com/indigo423/opennms-playground.git" \
      org.opencontainers.image.vendor="no42.org" \
      org.opencontainers.image.authors="ronny@no42.org" \
      org.opencontainers.image.licenses="MIT" \
      io.artifacthub.package.readme-url="https://github.com/indigo423/opennms-playground/blob/main/README.md"

# MQTT:         1883/tcp
# AMQP:         5672/tcp
# UI:           8161/tcp
# STOMP:        61613/tcp
# WS:           61614/tcp
# ActiveMQ TCP: 61616/tcp
EXPOSE 1883/tcp 5672/tcp 8161/tcp  61613/tcp 61614/tcp 61616/tcp

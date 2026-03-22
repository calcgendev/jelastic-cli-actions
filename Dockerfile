# Use supported OpenJDK image (Temurin)
FROM eclipse-temurin:17-jdk-alpine

# Install required packages
RUN apk add --no-cache \
    curl \
    bash \
    jq \
    parallel

# Create User and Group
ENV USER=docker
ENV _UID=12345
ENV _GID=23456

RUN mkdir /cli && \
    addgroup -g "$_GID" "$USER" && \
    adduser -D -h /cli -G "$USER" -u "$_UID" "$USER" && \
    chown -R $USER:$USER /cli

# Set working directory
WORKDIR /cli

# Switch user
USER docker

# Enable pipefail
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Jelastic CLI
RUN curl -fsSL ftp://ftp.jelastic.com/pub/cli/jelastic-cli-installer.sh | bash

# Copy entrypoints
COPY entrypoint.sh /cli/entrypoint.sh
COPY entrypoint-github.sh /cli/entrypoint-github.sh

# Make sure scripts are executable
RUN chmod +x /cli/entrypoint.sh /cli/entrypoint-github.sh

ENTRYPOINT ["/cli/entrypoint.sh"]

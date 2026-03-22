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

# Install Jelastic CLI under /cli/jelastic (entrypoint hardcodes this path).
# The stock installer runs `java -jar -Duser.home=...`; JVM -D options must come before -jar,
# otherwise setup does not create /cli/jelastic/.../signin.
RUN curl -fsSL -o /cli/jelastic-cli.jar ftp://ftp.jelastic.com/pub/cli/jelastic-cli.jar && \
    java -Duser.home=/cli -jar /cli/jelastic-cli.jar setup && \
    chown -R docker:docker /cli && \
    test -x /cli/jelastic/users/authentication/signin

# Copy entrypoints
COPY entrypoint.sh /cli/entrypoint.sh
COPY entrypoint-github.sh /cli/entrypoint-github.sh

# ✅ Run chmod as root (IMPORTANT)
RUN chmod +x /cli/entrypoint.sh /cli/entrypoint-github.sh

# Switch to non-root user AFTER permissions are set
USER docker

# Enable pipefail
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENTRYPOINT ["/cli/entrypoint.sh"]

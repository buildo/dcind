FROM alpine:3.6

ENV DOCKER_VERSION=18.06.3-ce \
  DOCKER_COMPOSE_VERSION=1.24.1 \
  ENTRYKIT_VERSION=0.4.0

# Install Docker and Docker Compose
RUN apk --update --no-cache \
  add curl device-mapper py-pip iptables && \
  rm -rf /var/cache/apk/* && \
  curl https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz | tar zx && \
  mv /docker/* /bin/ && chmod +x /bin/docker* && \
  apk --update --no-cache add --virtual build-deps gcc musl-dev libffi-dev openssl-dev python3-dev python2-dev make && \
  pip install docker-compose==${DOCKER_COMPOSE_VERSION} && \
  apk del build-deps

# Install entrykit
RUN curl -L https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz | tar zx && \
  chmod +x entrykit && \
  mv entrykit /bin/entrykit && \
  entrykit --symlink

# Include useful functions to start/stop docker daemon in garden-runc containers in Concourse CI.
# Example: source /docker-lib.sh && start_docker
COPY docker-lib.sh /docker-lib.sh

ENTRYPOINT [ \
  "switch", \
  "shell=/bin/sh", "--", \
  "codep", \
  "/bin/docker daemon" \
  ]

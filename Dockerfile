ARG NODE_VERSION=22.18.0
ARG N8N_VERSION=snapshot
ARG LAUNCHER_VERSION=1.4.0
ARG TARGETPLATFORM

FROM n8nio/n8n:latest

# Скачиваем и устанавливаем runtime, launcher и т.д.
FROM alpine:3.22.0 AS launcher-downloader
# … (код скачивания launcher остаётся) …

FROM system-deps AS runtime
ARG N8N_VERSION
ARG N8N_RELEASE_TYPE=dev

ENV NODE_ENV=production
ENV N8N_RELEASE_TYPE=${N8N_RELEASE_TYPE}
ENV NODE_ICU_DATA=/usr/local/lib/node_modules/full-icu
ENV SHELL=/bin/sh
ENV WEBHOOK_URL=${WEBHOOK_URL}
ENV N8N_EDITOR_BASE_URL=${N8N_EDITOR_BASE_URL}
ENV N8N_HOST=${N8N_HOST}
ENV N8N_PERSONALIZATION_ENABLED=false
ENV N8N_PUSH_BACKEND=sse
ENV N8N_PROTOCOL=https

WORKDIR /home/node

# Убираем копирование ./compiled, просто используем штатные файлы n8n
# Если тебе нужно дополнить его модификациями — делай это иначе

COPY docker/images/n8n/docker-entrypoint.sh /
COPY docker/images/n8n/n8n-task-runners.json /etc/n8n-task-runners.json

RUN cd /usr/local/lib/node_modules/n8n && \
    ln -s /usr/local/lib/node_modules/n8n/bin/n8n /usr/local/bin/n8n && \
    mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node

RUN cd /usr/local/lib/node_modules/n8n/node_modules/pdfjs-dist && npm install @napi-rs/canvas

EXPOSE 5678/tcp

USER node

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]

LABEL org.opencontainers.image.title="n8n" \
      org.opencontainers.image.description="Workflow Automation Tool" \
      org.opencontainers.image.source="https://github.com/n8n-io/n8n" \
      org.opencontainers.image.url="https://n8n.io" \
      org.opencontainers.image.version=${N8N_VERSION}

# nanobot v0.3.5 built from the upstream release tag (there is no official image).
# Mirrors upstream's Dockerfile; only the source now comes from a pinned git checkout.
FROM alpine/git:2.54.0 AS src
RUN git clone --depth 1 --branch v0.3.5 https://github.com/HKUDS/nanobot.git /src \
    && test "$(git -C /src rev-parse HEAD)" = "1bb712d3488915ca4ed9ccc1a93067ff722f5ab9"

FROM node:24-bookworm-slim AS webui-builder
WORKDIR /app
COPY --from=src /src/webui/package.json /src/webui/package-lock.json ./webui/
WORKDIR /app/webui
RUN npm ci
COPY --from=src /src/webui/ ./
COPY --from=src /src/packages/client-events/ /app/packages/client-events/
RUN mkdir -p /app/nanobot/web && npm run build

FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates git bubblewrap openssh-client libmagic1 && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /app
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:$PATH"
RUN uv venv --seed "$VIRTUAL_ENV"

COPY --from=src /src/pyproject.toml /src/README.md /src/LICENSE /src/THIRD_PARTY_NOTICES.md /src/hatch_build.py ./
RUN mkdir -p nanobot && touch nanobot/__init__.py && \
    NANOBOT_SKIP_WEBUI_BUILD=1 uv pip install --python "$VIRTUAL_ENV/bin/python" --no-cache . && \
    rm -rf nanobot
COPY --from=src /src/nanobot/ nanobot/
COPY --from=src /src/scripts/install_channel_dependencies.py scripts/
COPY --from=webui-builder /app/nanobot/web/dist/ nanobot/web/dist/
RUN NANOBOT_SKIP_WEBUI_BUILD=1 uv pip install --python "$VIRTUAL_ENV/bin/python" --no-cache .

# Telegram and WhatsApp channel dependencies are preinstalled; enable them with env vars.
ARG NANOBOT_CHANNELS=whatsapp,telegram
RUN for channel in $(printf '%s' "$NANOBOT_CHANNELS" | tr ',' ' '); do \
        python -m scripts.install_channel_dependencies "$channel"; \
    done

RUN useradd -m -u 1000 -s /bin/bash nanobot && \
    mkdir -p /home/nanobot/.nanobot && \
    chown -R nanobot:nanobot /home/nanobot /app/.venv
COPY --from=src /src/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh && chmod +x /usr/local/bin/entrypoint.sh

# The entrypoint chowns the volume, then drops to the nanobot user.
USER root
ENV HOME=/home/nanobot PYTHONUNBUFFERED=1 PYTHONFAULTHANDLER=1
EXPOSE 8765
ENTRYPOINT ["entrypoint.sh"]
CMD ["gateway"]

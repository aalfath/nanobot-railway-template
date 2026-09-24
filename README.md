# Deploy and Host nanobot on Railway

nanobot is an ultra-lightweight personal AI agent from HKU's Data Intelligence Lab, a small alternative to OpenClaw. It chats through a web UI, Telegram, WhatsApp and other channels, remembers context, runs tools such as file editing, shell, web search and cron jobs, and works with Anthropic, OpenAI, OpenRouter and many other providers.

## About Hosting nanobot

This template builds nanobot v0.3.5 from the upstream release tag through a small public wrapper repository, because upstream publishes no image. The gateway serves the bundled WebUI and a WebSocket chat channel on the public domain; both require `NANOBOT_WEB_TOKEN`, and WebSocket connections without an issued token are refused. Configuration comes from `NANOBOT_*` variables, so no config file is needed. Sessions, memory and the agent workspace live on a Railway volume and survive redeploys. The agent runs as a non-root user and its tools are restricted to the workspace. You must supply an LLM API key. It fits the Hobby plan.

## Common Use Cases

- A personal AI assistant reachable from the browser and chat apps
- Scheduled agent tasks with cron and memory
- A lightweight self-hosted alternative to OpenClaw or Hermes

## Dependencies for nanobot Hosting

- `aalfath/nanobot-railway-template` (builds nanobot v0.3.5 from the pinned release commit)
- An Anthropic API key (or another provider's)
- A Railway volume at `/home/nanobot/.nanobot`

### Deployment Dependencies

- [nanobot on GitHub](https://github.com/HKUDS/nanobot)
- [nanobot v0.3.5 release](https://github.com/HKUDS/nanobot/releases/tag/v0.3.5)
- [Wrapper repository](https://github.com/aalfath/nanobot-railway-template)
- [Railway volumes](https://docs.railway.com/reference/volumes)

### Implementation Details

| Service | Source | Networking | Storage |
| --- | --- | --- | --- |
| nanobot | `aalfath/nanobot-railway-template` | public domain on 8765 | volume at `/home/nanobot/.nanobot` |

| Variable | Default | Purpose |
| --- | --- | --- |
| `NANOBOT_PROVIDERS__ANTHROPIC__API_KEY` | empty (required) | Your Anthropic API key |
| `NANOBOT_AGENTS__DEFAULTS__MODEL` | `anthropic/claude-sonnet-5` | Default model |
| `NANOBOT_WEB_TOKEN` | generated | Secret the WebUI asks for |
| `NANOBOT_TOOLS__RESTRICT_TO_WORKSPACE` | `true` | Keeps file and shell tools inside the workspace |

Nested settings map to variables with `__`. For example, to use OpenRouter instead:

```bash
NANOBOT_PROVIDERS__OPENROUTER__API_KEY=sk-or-...
NANOBOT_AGENTS__DEFAULTS__MODEL=openrouter/anthropic/claude-sonnet-5
```

Notes:

- Telegram and WhatsApp channel dependencies are preinstalled; enable them with `NANOBOT_CHANNELS__TELEGRAM__*` variables.
- Settings saved in the WebUI take precedence over the variables after a restart.
- This template was tested without an LLM key: a chat turn reached the provider, but no model reply was checked.

This is a community-maintained deployment package and does not imply affiliation with or endorsement by HKUDS or the nanobot project.

## Why Deploy nanobot on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying nanobot on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.

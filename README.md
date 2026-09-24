# nanobot on Railway

Builds [nanobot](https://github.com/HKUDS/nanobot) v0.3.5 from the upstream release tag (pinned commit) for a Railway template. Upstream publishes no container image.

The gateway and WebUI listen on port 8765. Configure it with `NANOBOT_*` environment variables (nested keys use `__`).

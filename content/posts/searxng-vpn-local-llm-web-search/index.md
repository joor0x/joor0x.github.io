---
title: "Give Your Local LLM Eyes: SearXNG Behind a VPN for Private Web Search"
author: "joor0x"
date: 2026-05-30
description: "Self-host SearXNG behind a VPN and wire it into Open WebUI + Ollama, so your local models can search the internet privately — no Google, no API keys, no leaks."
tags: ["privacy", "self-hosted", "searxng", "vpn", "ollama", "open-webui", "local-llm", "cybersecurity"]
showToc: true
TocOpen: true
---

Running models locally with Ollama is great for privacy: nothing leaves your machine. But it comes with a hard ceiling — your model only knows what it was trained on. Ask it about something that happened last week and it confidently makes things up.

The usual fix is to plug in a web search API (Tavily, Serper, Brave). The problem? You're back to shipping every query to a third party with an API key tied to your name.

There's a better way: **self-host [SearXNG](https://docs.searxng.org/)**, route it through a **VPN**, and let **Open WebUI** use it as the search backend for **Ollama**. Your model gets internet access, your queries get scattered across dozens of search engines from a VPN exit IP, and nothing is tied to a personal account.

I know SearXNG because 'agent-zero' https://github.com/agent0ai/agent-zero use it internally. Make a try if you want an open source fully autonomous agents running in your home lab.

Below, I'll show you how to configure it in your environment concisely:

Ask Claude or ChatGPT how to install it in your setup.

This post is not intended to provide a full installation guide.

---

## Why This Beats a Search API

| | Web Search API (Tavily/Serper) | Self-hosted SearXNG + VPN |
|---|---|---|
| Query privacy | Sent to a vendor, tied to API key | Scattered across engines from VPN IP |
| Cost | Per-query billing | Free |
| Rate limits | Yes | Only what upstream engines impose |
| IP exposure | Vendor + your server IP | VPN exit IP only |
| Lock-in | Vendor-specific | Open source, swappable engines |

The trade-off is honest: upstream engines (Google, Bing) sometimes rate-limit or temporarily block SearXNG instances, especially shared VPN exit IPs. SearXNG rotates across ~70 engines, so a single block rarely breaks search — but it's less bulletproof than a paid API. For a private home setup, that's fine.

---

## Hardening Notes

- **Don't expose port 8080 to the internet.** SearXNG's API has no auth. Keep it on your LAN
- **Pick a VPN with a real no-logs policy.** The VPN sees your search-bound traffic; choose a provider you'd trust with it. I'd recommend PIA.

---

You end up with a fully local AI that can *see* the internet — without Google watching, without an API bill (just the electricity bill and the monthly GPU cost you're still paying), and without a single query traceable back to you. Your model gets eyes; you keep your privacy.

---
title: "Free Scheduled VMs: Run Periodic Jobs on GitHub Actions (No Server Required)"
author: "joor0x"
date: 2026-06-12
description: "Use GitHub Actions as free cron-scheduled VMs to run periodic jobs. Real example: a Forex calendar feed that updates hourly and serves AI agents."
tags: ["github-actions", "automation", "cron", "ai-agents", "forex", "free-tier", "devops", "llms-txt"]
showToc: true
TocOpen: true
---

You probably think of GitHub Actions as a CI tool: push code, run tests, deploy. But strip away the CI framing and what's left is something more interesting — **a free virtual machine that boots on a cron schedule, runs whatever you want, and shuts down**.

No VPS bill. No Raspberry Pi humming in a closet. No "did my home server lose power again?" Every scheduled run gets a fresh Ubuntu VM with 4 vCPUs, 16 GB of RAM, Python, Node, Docker, and internet access. For public repositories, it costs exactly nothing.

That's a cron server. Let's use it like one.

---

## The Pattern

The recipe is three pieces:

1. **A script** that does the periodic work (scrape, poll an API, compute something)
2. **A workflow** with a `schedule` trigger that runs it
3. **The repo itself as storage** — the workflow commits its output back, and `raw.githubusercontent.com` becomes your free, CDN-backed API endpoint

```yaml
on:
  schedule:
    - cron: '0 * * * *'   # every hour
  workflow_dispatch:       # manual trigger for testing

jobs:
  scrape:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: 'pip'
      - run: pip install -r requirements.txt
      - run: python scraper.py scrape
      - name: Commit results
        run: |
          git config --global user.name "github-actions[bot]"
          git config --global user.email "github-actions[bot]@users.noreply.github.com"
          git add -f news/
          if ! git diff-index --quiet HEAD --; then
            git commit -m "Auto-update data [skip ci]"
            git push
          fi
```

The `[skip ci]` in the commit message matters — without it, the data commit can trigger other workflows and you end up in a loop. The `if ! git diff-index` guard avoids empty commits when nothing changed. And `workflow_dispatch` lets you trigger a run by hand instead of waiting for the next cron tick.

A side effect I've grown to like: because output is committed to git, **you get versioned data for free**. Every snapshot is a commit. Want to know what the feed looked like last Tuesday? `git log`.

---

## It's free, not magic. (Know the limitations)


| Constraint | Reality |
|---|---|
| Cron precision | **Not guaranteed.** Runs can start 5–30+ min late under load. Fine for hourly jobs, useless for "exactly at 9:00:00" |
| Minimum interval | 5 minutes between scheduled runs |
| Job duration | 6 hours max per job |
| Cost | Free unlimited minutes for **public repos**; 2,000 min/month free on private repos |
| Auto-disable | Schedules pause after **60 days of repo inactivity** (any commit resets the clock — the bot's own commits count) |
| No persistence | The VM is wiped after every run. State must live in the repo, artifacts, or external storage |
| Not for secrets-heavy work | Public repo means public logs and public output. Secrets go in repo Settings → Secrets, never in code |
| ToS | GitHub explicitly forbids crypto mining and using Actions as a general compute farm. Periodic data jobs are fine; abuse is not |

The delayed-cron caveat is the one that bites people. If your use case tolerates "roughly every hour," you're golden. If it needs second-level precision, pay for a it or deploy it in the home lab..

---

## Working Example: A Forex Calendar Feed for AI Agents

Theory is cheap, so here's the pattern running in production: [**forex-factory-agent-feed**](https://github.com/joor0x/forex-factory-agent-feed).

Forex Factory publishes the most widely used economic calendar in trading — central bank decisions, NFP, CPI releases. Problem: it's a website, not an API, and scraping it from every bot that needs it is rate-limited and against their ToS. So instead, **one scraper runs hourly on GitHub Actions and publishes a clean JSON feed that anything can consume**:

```
https://raw.githubusercontent.com/joor0x/forex-factory-agent-feed/main/news/calendar.json
```

Every hour, a fresh VM boots, scrapes the calendar (currencies, impact levels, actual/forecast/previous values), normalizes everything to ISO-8601 UTC timestamps, validates it against a JSON Schema, and commits the result. Tiered storage keeps the latest snapshot, canonical monthly files, and timestamped history. Total infrastructure cost: zero.

A rule engine on top can fire Telegram or webhook alerts N minutes before high-impact events — also from the same free runner.

### Making the Feed Agent-Ready

Here's the part that's becoming a pattern of its own. A JSON URL is enough for a script, but if you want **LLM agents** to consume your data correctly, you need to document the contract in a form agents actually read. The repo ships two files for that:

**`llms.txt`** — the emerging convention for telling LLMs how to use a resource. It lives at the repo root and spells out exactly what tripped me up when parsing the data myself: dates are `dd/mm/yyyy` (an agent assuming US format silently shifts your events by months), `time` can be `"All Day"` instead of `HH:MM`, numeric fields are strings with possible `null`s, and the safe move is to consume the `datetime_utc` field and ignore local times entirely.

**`AGENTS.md`** — instructions for coding agents (Claude Code, Cursor, Copilot) working *on* the repo. It states the project layout, the config priority order, and one rule worth quoting:

> Scraping Forex Factory directly is rate-limited and against their ToS; always prefer this URL.

That single line means an agent asked to "get this week's high-impact USD events" reaches for the published feed instead of writing yet another scraper. The documentation isn't decoration — it changes agent behavior.

The result: any agent — a trading bot, a Claude session with web access, a LangChain pipeline — can discover the feed, understand its quirks without trial and error, and pull structured economic data from a URL that updates itself.

---

## What Else Fits This Pattern

Anything periodic, stateless-per-run, and tolerant of fuzzy timing:

- Price/availability monitors that commit a JSON snapshot
- Daily digests pushed to Telegram
- Uptime checks for your self-hosted services
- Aggregating RSS/API data into a single feed your local LLM can read
- Nightly backups of small datasets to a private repo

You get a fleet of free, ephemeral VMs on a schedule, version-controlled output, and a global CDN serving the results. The only real costs are the constraints in the table above — and for most periodic jobs, they simply don't matter.

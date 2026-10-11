+++
title = 'A Power Outage Took Down My Homelab and I Never Noticed'
date = 2026-10-11
description = 'A power cut on vacation left two homelab servers offline without me knowing. Here is how I set up free monitoring with Healthchecks.io in 30 minutes.'
tags = ['homelab', 'self-hosted', 'monitoring', 'healthchecks', 'linux']
+++

This week I was away on vacation when the power went out at home. When it came back, most of the homelab booted up fine. Two servers didn't.

The worst part wasn't the downtime. It was that **I had no idea**. Nothing alerted me, and I only found out days later when I tried to use a service that wasn't there.

A homelab without monitoring is a homelab you're hoping works. So I fixed that, and it took about 30 minutes.

## Why Healthchecks.io

[Healthchecks.io](https://healthchecks.io/) uses a simple idea called a **dead man's switch**: instead of something checking your servers from the outside, each server pings a unique URL on a schedule. If a ping doesn't arrive on time, you get an alert.

That's exactly the right model for a homelab behind NAT:

- No open ports or exposed services needed
- Free tier covers 20 checks, more than enough for a personal setup
- Alerts via email, Telegram, Signal, ntfy, Discord and many more
- Open source, so you can self-host it later if you want

## The Setup in Four Steps

### 1. Create an account and one check per server

Sign up, then create a check for each machine. Give it a clear name (`nas`, `proxmox-01`, etc.) and set the **period** (how often a ping is expected) and the **grace time** (how late it can be before alerting). I used a 5-minute period with a 5-minute grace.

Each check gives you a unique ping URL like `https://hc-ping.com/<uuid>`.

### 2. Add a cron job on each server

On every server, add a line to the crontab (`crontab -e`):

```bash
*/5 * * * * curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/<uuid>
```

Every 5 minutes the server says "I'm alive". If it goes down, doesn't boot, or loses its network, the pings stop.

### 3. Connect an alert channel

In **Integrations**, add where you want to be notified. Email works out of the box; I also added a mobile push notification so I'd see it immediately, even on vacation.

### 4. Test it

Stop the cron job on one machine (or just unplug it) and wait for the grace period to pass. If the alert arrives, you're done.

## Bonus: Monitor Backups and Scheduled Jobs Too

The same trick works for anything that runs on a schedule. Append the ping to your backup script so you only get a "success" signal when it actually finishes:

```bash
./backup.sh && curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/<uuid>
```

A silent backup failure is just as dangerous as a dead server, and usually discovered at a much worse moment.

## Lessons Learned

- **Things will fail when you're not around.** Power cuts don't wait for you to be home.
- **Silent failures are the real problem.** Downtime is annoying; not knowing about it is worse.
- **Monitoring doesn't need to be complex.** A cron job and a free service cover 90% of what a homelab needs.

The next thing on my list is checking why those two servers didn't come back on their own (BIOS "restore on AC power loss" is the usual suspect). But at least now, if it happens again, I'll know within minutes instead of days.

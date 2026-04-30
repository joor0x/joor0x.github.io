---
title: "I Was Going to Write About Immich. Then Google Signed With the Pentagon."
author: "joor0x"
date: 2026-04-30
draft: false
description: "My self-hosted alternatives to Google: Posteo, Syncthing, Immich, Ollama, Firefox, Kagi — and why the Pentagon AI deal made me publish this now."
tags: ["privacy", "self-hosting", "degoogle", "homelab", "immich", "syncthing", "posteo"]
showToc: true
TocOpen: true
---

I had a different post queued up for this week.

It was going to be a practical post about Immich: how I finally moved my photo library away from Google Photos, how the timeline view works, how face recognition feels, how “on this day” memories hit differently when they are not attached to an advertising profile.

That was the plan.

Then Google signed a classified AI deal with the Pentagon.

According to reporting this week, the agreement gives the U.S. Department of Defense access to Gemini for classified work under terms broad enough to cover “any lawful government purpose.” More than 600 Google employees reportedly signed an open letter asking the company not to do it. The contract also reportedly requires Google to help adjust AI safety filters at the government’s request.

So the post changed.

Immich is still in here. But the bigger picture deserved the headline.

## Why this matters

I am not going to write the usual privacy lecture. Most people already know the basic trade.

For years, the implicit deal with Google was:

> We give you our data.  
> You give us polished services that are free, fast, and better than the alternatives.

That was already uncomfortable. Gmail, Photos, Drive, Maps, Android, Chrome — the convenience was real, but so was the extraction. The business model was never just software. It was profiling, prediction, attention capture, and advertising.

But the perimeter has shifted.

The same cloud infrastructure, identity systems, data pipelines, and AI models that make consumer services convenient are now being integrated into classified government workflows. Whatever your politics, that is a different bargain from the one most users thought they were making when they uploaded their inbox, family photos, location history, and documents.

And once that perimeter shifts, so does the meaning of “private.” If your content, metadata, behavioral history, or AI interactions become relevant to something framed as a national security priority — whether for political, commercial, geopolitical, or intelligence reasons — you should assume they may be requested, processed, retained, analyzed, or repurposed under rules you will never see and cannot negotiate.

That does not mean every photo or email is being read by a person in a bunker. It means the infrastructure, incentives, and legal pathways are increasingly aligned so that, when the state decides something matters, your data is not really yours in any practical sense. It is available.

If your email, photos, files, browser, search history, maps, contacts, calendar, phone backup, and AI assistant all live inside one company, then changing your mind later is not a setting. It is a migration project.

The good news: the alternatives have quietly become good enough.

Not perfect. Not as seamless. Not always cheaper.

Here is my current stack.

---

# My current stack

## Email — Posteo

Posteo costs €1/month. It is based in Germany. No ads, no inbox profiling, no AI training on your emails, and no attempt to turn your mailbox into a growth platform.

It also supports the things I actually want from email:

- IMAP/SMTP
- CalDAV calendar sync
- CardDAV contacts sync
- Two-factor authentication
- Anonymous signup and payment options
- No advertising model
- No Google account dependency

The important privacy distinction is encryption.

Gmail uses encryption in transit, but Gmail is not end-to-end encrypted by default. Google can process your mailbox server-side because that is how features like search, spam filtering, smart replies, categorization, and integrations work.

Posteo is not magic either. Traditional email is not automatically end-to-end encrypted unless both sides use something like OpenPGP or S/MIME. But Posteo gives you a much cleaner privacy model: encrypted storage options, optional incoming email encryption, OpenPGP/Mailvelope support, and no business model based on reading or profiling your inbox.

So the honest version is this:

> Posteo is not automatically E2E for every email.  
> But it lets me use real end-to-end encryption when I need it, and unlike Gmail, it is not built around extracting value from my mailbox.

That is the point.

My setup is boring:

- Thunderbird on Lubuntu
- Thunderbird on Android
- Posteo for mail, calendar, and contacts

What I gave up: Gmail’s search, ecosystem bundling, and the comfort of having everything tied to one account.

What I got: an inbox that feels like email again.

---

## Cloud — Syncthing

Syncthing is the one most people do not realize they want.

Google Drive’s mental model is:

> Upload everything to the mothership.  
> Then download it somewhere else.

Syncthing’s model is:

> My devices already exist.  
> Let them talk to each other directly.

My setup:

- Desktop running Lubuntu with large disks
- Laptop running Lubuntu
- Raspberry Pi 5 nodes that stay online
- Phone

Folders are defined per device. Permissions are explicit. Data is encrypted in transit between nodes. There is no central cloud provider, no quota, no “your Drive is full” banner, and no upsell.

If my laptop is off, the Raspberry Pi nodes keep things available. If one machine dies, the data still exists elsewhere.

But sync is not backup.

For backup, I use Restic to an off-site target. That part matters. Syncthing protects availability. Restic protects history. They solve different problems.

---

## Photos — Immich

This was supposed to be the whole post.

Immich is the Google Photos replacement the self-hosting world needed.

It gives you:

- Mobile auto-upload
- Timeline view
- Albums
- Shared albums
- Face recognition
- Object and content search
- “On this day” memories
- Docker deployment
- PostgreSQL backend
- Local machine-learning inference

It is not just “good for open source.” It is genuinely good.

And photos are the category where vendor lock-in hurts the most. Documents matter, but photos have emotional half-life. Your child’s first year, family trips, old apartments, friends, grandparents, random ordinary days that become important later — you do not want all of that trapped behind one company’s subscription, export format, and product roadmap.

If you only migrate one Google service, I would start with photos.

---

## AI — Ollama + Claude

My AI setup has two tiers.

### Local: Ollama

For anything sensitive, I use Ollama locally on my desktop with the RTX 5070 Ti.

That includes:

- Code containing credentials
- Banking-related notes
- personal drafts
- private project ideas
- anything involving client or work-sensitive data

The rule is simple:

> If the prompt contains a secret, it does not leave the machine.

Local models are not always the best models. But they are the right models when the main requirement is control.

### Hosted: Claude

For heavier reasoning, long-form writing, architecture reviews, and difficult thinking, I still use Claude.

That is not ideological. It is operational.

Sometimes quality matters more than locality. Sometimes locality matters more than quality. The mistake is pretending one tool should handle every risk profile.

My split is:

> Sensitive in, hosted out.

If the data is private, Ollama gets it.  
If the data is not private and I need the best reasoning, I use the better hosted model.

---

# Other categories worth replacing

DeGoogling is a Pareto problem.

The first 20% of effort gets you 80% of the benefit. After that, the alternatives get more fragmented and the trade-offs become more personal.

Here is the rest of the map.

---

## Maps — Organic Maps / CoMaps

Organic Maps is OpenStreetMap-based, works offline, has no ads, and does not try to become a recommendation engine.

It is fast, minimal, and practical.

Best for:

- Travel
- Hiking
- Walking routes
- Casual navigation
- Offline maps

There is also CoMaps, a 2025 fork of Organic Maps created after governance concerns in the original project. Same general philosophy: offline maps, open data, less tracking. Didn't try it yet.

What you give up compared with Google Maps:

- Live traffic
- Street View
- Business data freshness
- Some local reviews

For most actual navigation, I do not miss much.

---

## Search — Kagi / DuckDuckGo / Brave Search

I pay for Kagi.

€10/month feels expensive until you remember what the alternative business model is.

Kagi’s results are cleaner, less SEO-poisoned, and better for technical searches. The ability to boost, block, or downgrade domains is genuinely useful.

For free options:

- DuckDuckGo is good enough for casual search.
- Brave Search is also usable and independent enough to be interesting.

Google Search is no longer obviously the best search engine. It is the default habit.

That is different.

---

## Browser — Firefox

Chrome is one of the most efficient surveillance vectors Google ships.

Firefox is the obvious replacement.

My setup:

- Firefox
- uBlock Origin
- Multi-Account Containers
- Hardened user.js
- Separate containers for work, banking, shopping, and random browsing
- Duck essentials for private email accounts

Boring. Works.

That is the goal.

---

## YouTube — NewPipe / FreeTube / Invidious

You are not going to replace YouTube’s catalog.

But you can replace the client.

Options:

- NewPipe on Android
- FreeTube on desktop
- Invidious instances when available

Benefits:

- No login
- No ads
- No recommendation algorithm
- Local subscriptions
- Background audio
- Less tracking

This is not about pretending YouTube does not exist. It is about refusing the default client.

---

## DNS — Quad9 / NextDNS

Stop using `8.8.8.8`.

Quad9 is simple: privacy-focused DNS, based in Switzerland, with malicious-domain blocking by default.

NextDNS is more configurable: per-device profiles, blocklists, analytics, parental controls, and tracker blocking at the resolver level.

Set it once on the router and every device on the network becomes cleaner.

---

## Mobile OS — GrapheneOS / CalyxOS / LineageOS

This is the boss fight.

The cleanest path is usually:

> Pixel + GrapheneOS

GrapheneOS lets you run sandboxed Google Play services if you need them, or avoid them entirely if you do not.

I have not made the jump on my main phone yet. Banking apps, family logistics, baby photos, authentication apps — the usual friction.

But it is on the list.

At some point, replacing Google services while carrying a stock Google phone becomes the obvious contradiction.

---

# Cost and effort

People say deGoogling is hard and expensive.

They are half right.

My recurring monthly cost is roughly:

- Posteo: €1
- Kagi: €10
- Optional backup/storage costs depending on target

So the recurring software cost is not the main issue.

The real cost is hardware, time, and maintenance.

Yes, I spent around €3000 on a desktop with a GPU powerful enough to run local AI models and stay online most of the time. But that was not a “save money versus Google One” decision.

If this is only about price, Google One 2TB for around €9.99/month is obviously easier.

The point is not that self-hosting is cheaper.

The point is that it changes the relationship.

With Google, I am renting convenience from a company whose incentives are not aligned with mine.

With Posteo, Syncthing, Immich, Restic, Firefox, and Ollama, I own more of the surface area. Not all of it. But enough that I can reason about it.

---

# The actual bargain

This post was not supposed to be political.

I wanted to write about my photo library.

But the Pentagon deal landed in the middle of writing it, and the throughline became impossible to ignore:

> Every service in the “convenient” column comes with terms that can change tomorrow.

And those terms may now include uses of the same infrastructure, models, and data-adjacent systems that the original users never meaningfully agreed to.

The alternatives are not perfect.

Posteo’s UI is plain.  
Immich needs maintenance.  
Syncthing requires you to think about devices as peers instead of clients.  
Ollama models are not always as good as hosted ones.  
Firefox still lives in a Chrome-shaped web.  

But none of these tools are trying to profile my inbox.  
None of them need to monetize my baby photos.  
None of them are nudging me into a single identity layer for email, search, storage, maps, browser, phone, and AI.  
And none of them require me to accept that “convenient” means “strategically dependent.”

That feels like the bargain I want to be in.

Next post: probably Immich for real — the setup, the Docker stack, the ML model choice, and the Google Takeout import workflow.

The post I was going to write before Monday.

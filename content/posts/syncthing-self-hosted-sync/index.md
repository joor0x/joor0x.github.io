+++
title = 'Syncthing: Take Back Control of Your Data with Self-Hosted Sync'
date = 2025-12-07T23:34:36+01:00
draft = true
description = 'Why I ditched Google Drive and Dropbox for Syncthing. A peer-to-peer file sync solution where you own your data and hold the encryption keys.'
tags = ['privacy', 'self-hosted', 'syncthing', 'obsidian']
+++

When you upload files to Google Drive, Dropbox, or iCloud, you're not really in control. These companies hold the encryption keys. They can read your data. They can share it with authorities. They can train AI models on it. You're essentially renting storage space where the landlord has a master key.

Syncthing offers a different approach: peer-to-peer synchronization where your data never touches a third-party server.

## What Is Syncthing?

[Syncthing](https://syncthing.net/) is an open-source, continuous file synchronization program. It syncs files directly between your devices using end-to-end encryption. No cloud. No middleman. No subscription fees.

The architecture is simple:
- Each device runs the Syncthing daemon
- Devices discover each other and establish encrypted connections
- Files sync directly between devices over your local network or the internet

## Why I Switched

I'll admit it: I got seduced by Notion. The sleek interface, the databases, the endless customization options. It's genuinely a great app. But I was handing over all my notes to a company without end-to-end encryption, trusting them with years of personal thoughts and ideas.

The irony? I spent more time making my notes look pretty than actually writing them. Tweaking icons, adjusting layouts, perfecting templates. Notion became a productivity sink disguised as a productivity tool.

So I went back to pure Markdown with [Obsidian](https://obsidian.md/). Plain text files I actually own. No vendor lock-in. No proprietary format. And with Syncthing, no need to trust a third party with my data.

With cloud providers:
- **You don't own the encryption keys** - The provider can decrypt your files
- **Your data is a product** - It can be analyzed, sold, or used for AI training
- **Account suspension risks** - Lose access to your account, lose your files
- **Privacy policies change** - What's private today might not be tomorrow

With Syncthing:
- **You hold all the keys** - Data is encrypted in transit between your devices
- **No third-party access** - Your files never leave your devices
- **No account to suspend** - It's just software running on your hardware
- **Open source** - The code is auditable

## Setting It Up

The initial setup takes about 15 minutes per device:

1. **Install Syncthing** on each device (available for Linux, Windows, macOS, Android, and iOS via third-party apps)
2. **Open the web UI** (default: `http://127.0.0.1:8384`)
3. **Add remote devices** by exchanging device IDs
4. **Share folders** between devices

For my Obsidian setup, I share a single folder between my desktop and phone. The sync happens instantly when both devices are online.

### Android Setup

On Android, I use the official [Syncthing app](https://play.google.com/store/apps/details?id=com.nutomic.syncthingandroid). For Obsidian specifically, you just point both apps to the same folder.

### Handling Conflicts

In months of daily use, I've rarely encountered conflicts. Syncthing handles concurrent edits well. When conflicts do occur, it creates a `.sync-conflict` file rather than silently overwriting your work.

## Set It and Forget It

After the initial configuration, Syncthing runs in the background. No manual syncing. No upload buttons. Files just appear on your other devices within seconds.

The only maintenance I do:
- Keep the app updated
- Occasionally check the web UI if something seems off (it rarely does)

## Trade-offs

Syncthing isn't for everyone:

- **Both devices need to be online** to sync (no cloud buffer)
- **No web access** to your files
- **Initial setup** requires some technical comfort
- **Storage is limited** to your device capacity

If you need to share files with others or access them from any browser, traditional cloud storage still has its place. But for personal syncing between your own devices, Syncthing is a solid alternative.

## Final Thoughts

Your data belongs to you. With Syncthing, you can sync your files across devices without surrendering control to a corporation. It's free, open-source, and once configured, it just works.

For privacy-conscious users who want to keep their data off corporate servers, Syncthing is worth the 15-minute setup investment.

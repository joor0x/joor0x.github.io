---
title: "Disposable Kali in Docker: Recover a Forgotten ZIP Password"
author: "joor0x"
date: 2026-05-10
draft: true
description: "Spin up a throwaway Kali Linux container with Docker, then use John the Ripper to recover the password of an encrypted ZIP file — no VMs, no mess."
tags: ["cybersecurity", "docker", "kali-linux", "john-the-ripper", "password-cracking", "pentesting", "containers"]
showToc: true
TocOpen: true
---

## Why Run Kali in a Container?

Let's be honest: modern workflows — especially if you're experimenting with AI agents like Agent-Zero or automated LLM pipelines — demand environments that are programmatic and ephemeral. An AI agent isn't going to navigate a GUI-heavy VM; it's going to spin up a container, execute its task, and vanish.

The container approach offers:

- **Isolation** — your host OS stays clean. No rogue binaries, no broken dependencies.
- **Speed** — the official `kalilinux/kali-rolling` image starts in seconds, not minutes.
- **AI-Ready** — it's much easier to pipe instructions into a Docker socket than a virtualized desktop.

Don't get me wrong—most of us still have a dusty, blue-branded Kali USB stick sitting in a desk drawer somewhere. There’s an undeniable tactile nostalgia to that "physical swiss army knife" of OSs. It reminds us of a time when pentesting meant a dedicated laptop and a reboot. But in 2026, for a quick task on your daily driver, that physical barrier is a relic of the past.

In this post we'll build a tiny "Zip-Ripper" image and use it to recover a forgotten password from an encrypted ZIP archive — a classic entry-level password recovery task.

---

## 1. The Lab: A Custom Kali Image

We start from the official rolling image and add **John the Ripper** plus the `zip` utilities. Save this as `Dockerfile`:

```dockerfile
# Start with the official Kali rolling image
FROM kalilinux/kali-rolling

# Update and install John the Ripper and ZIP utilities
RUN apt-get update && apt-get install -y \
    john \
    zip \
    && apt-get clean

# Set the working directory
WORKDIR /lab
```

Build it and drop into a shell:

```bash
# Build the image
docker build -t kali-zipper .

# Run the container interactively
docker run -it --name my-kali-lab kali-zipper /bin/bash
```

If you want files to survive between runs, mount a host folder with `-v "$PWD/lab:/lab"`.

---

## 2. The Mission: Create a Target

Inside the container, simulate the "forgotten password" scenario by creating a small file and locking it behind a weak password:

```bash
echo "This is some top-secret crypto data." > secret.txt
zip -P "password123" secure_archive.zip secret.txt
```

We now have an encrypted `secure_archive.zip` and we'll pretend we don't remember the password.

---

## 3. Extract the Hash

You can't feed John the ZIP file directly. First, you extract a representation of the password — the **hash** — using `zip2john`, which ships with John the Ripper:

```bash
zip2john secure_archive.zip > zip_hash.txt
```

`zip_hash.txt` now contains everything John needs to start guessing.

---

## 4. The Crack

Run John against the hash with its default wordlist and rules:

```bash
john zip_hash.txt
```

For a weak password like `password123`, John will return the answer in seconds:

```
password123      (secure_archive.zip/secret.txt)
```

---

## 5. Clean Up

When you're done, exit the container and wipe it. Nothing leaks back onto the host:

```bash
exit
docker rm my-kali-lab
```

The `kali-zipper` image is still cached, so the next session is one `docker run` away.

---

## A Quick Reality Check (Out of Scope)

Ok. this is a "Hello World" for pentesting. Real-world password recovery is much grittier. For the sake of keeping this post focused on the Docker workflow, I am intentionally skipping:

- **AES-256 vs. ZipCrypto** — standard `zip -P` uses legacy ZipCrypto, which is cryptographically broken and can be cracked via known-plaintext attacks regardless of password length. Modern 7z/AES-256 archives are a different beast entirely.
- **GPU Power** — for real recovery, you'd want to pass your GPU (like an RTX 5070 Ti) into the container to use `hashcat` for billions of guesses per second.
- **Masks & Rules** — when you remember "the password started with 'S' and ended with '26'", you use masks.
- **AI Orchestration** — while I mentioned AI agents, this demo is manual. Showing Agent-Zero autonomously building and executing this cycle is a deep dive for another day.

---

## The Ethical Takeaway

ZIP encryption is only as strong as the password you choose. A short, dictionary-friendly password like `password123` collapses in seconds on a CPU. Bump it to **12+ characters with symbols** and the same attack runs for years — and that's before you bring GPUs or hashcat into the mix.

Two things to remember:

- **Entropy is the only real defence.** Use a password manager (my choice KeePassXC) and let it generate the password for you.
- **Containers are great pentest sandboxes.** Throwaway environments make it safe to experiment with offensive tools without polluting your daily computer.

---

## TL;DR

| Step | Command |
|---|---|
| Build the lab | `docker build -t kali-zipper .` |
| Enter the lab | `docker run -it --name my-kali-lab kali-zipper /bin/bash` |
| Extract hash | `zip2john secure_archive.zip > zip_hash.txt` |
| Crack | `john zip_hash.txt` |
| Show result | `john --show zip_hash.txt` |
| Tear down | `exit && docker rm my-kali-lab` |

A Kali container turns a potential panic into a five-minute experiment. It's faster than a VM, cleaner than a local install, and much more convenient than finding that old USB stick.

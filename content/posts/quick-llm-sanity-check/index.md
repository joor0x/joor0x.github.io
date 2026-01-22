+++
title = 'My Go-To Prompt for Testing Local LLMs'
date = 2025-11-04T18:51:41+01:00
draft = false
description = "A quick and dirty sanity check I use to test local LLM models running on Ollama with my RTX 5070 Ti."
tags = ["llm", "ollama", "local-ai", "nvidia"]
+++

Running local LLMs is kinda addictive. New model drops? Gotta try it. But here's the thing—you need a quick way to check if a model's actually *thinking* or just spitting out vibes.

## The Prompt

Here's my go-to sanity check:

> **What is the number that rhymes with the word we use to describe a tall plant?**

That's it. Dead simple.

## Why This Works

It's not about being hard. It's about being *consistent*. The model needs to:

1. Know that a tall plant is a **tree**
2. Find a number that rhymes with "tree" → **three**
3. Actually connect the dots

No fancy reasoning chains. No multi-step math. Just basic word association and a tiny bit of logic. If a model fumbles this one, it's probably not ready for the real stuff.

## My Setup

I run everything my GPU can handle locally through [Ollama](https://ollama.ai/) on an RTX 5070 Ti. No cloud, no API costs, just raw local inference. When a new model drops, I pull it down and throw this prompt at it first. Takes two seconds.

## The Takeaway

You don't need elaborate benchmarks for a quick sanity check. Sometimes a dumb little riddle does the job. If your local model *can't* nail "tree → three," it's probably not ready for more difficult tasks. Simple as that.

Now go test your models.

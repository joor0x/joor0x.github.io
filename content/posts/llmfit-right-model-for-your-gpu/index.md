---
title: "llmfit: Does It Actually Pick the Right Model for Your GPU?"
author: "joor0x"
date: 2026-03-20
draft: true
description: "llmfit promises to end trial and error when choosing local LLMs for your hardware. I tested its coding recommendation on my RTX 5070 Ti setup."
tags: ["ai", "llm", "tools", "local-llm", "gpu"]
showToc: true
TocOpen: true
cover:
  image: "images/cover.webp"
  alt: "llmfit CLI showing GPU model fit status"
  relative: true
---

Downloading a 30GB model only to watch it OOM on your GPU is a rite of passage in the local LLM world. **llmfit** wants to skip that step entirely: detect your hardware, scan a database of 500+ models, and tell you exactly which one to run --- before you download anything.

The idea is solid. But is the recommendation actually good? I tested it on my own setup.

## What Is llmfit?

[llmfit](https://github.com/AlexsJones/llmfit) is an open-source CLI tool written in Rust that:

1. **Detects your hardware** --- CPU, RAM, GPU(s), VRAM, memory bandwidth
2. **Scores each model** across four dimensions: Quality, Speed, Fit, and Context
3. **Selects the optimal quantization** (from Q8 down to Q2) that fits your VRAM
4. **Ranks models** by a weighted composite score tailored to your use case

You can also use the web version at [llmfit.io](https://llmfit.io/) if you prefer not to install anything.

### Installation

```bash
# macOS / Linux
brew install llmfit

# Windows
scoop install llmfit

# Or from source
cargo build --release
```

## How the Scoring Works

llmfit evaluates each model on four axes, scored 0--100:

| Dimension   | What It Measures |
|-------------|-----------------|
| **Quality** | Parameter count, model family reputation, quantization penalty |
| **Speed**   | Estimated tokens/sec based on memory bandwidth |
| **Fit**     | How well the model uses available VRAM (sweet spot: 50--80%) |
| **Context** | Context window capability vs. what the use case needs |

The weights shift depending on the use case:

| Use Case   | Quality | Speed | Fit  | Context |
|------------|---------|-------|------|---------|
| General    | 0.30    | 0.30  | 0.20 | 0.20    |
| **Coding** | **0.35**| **0.30**| **0.20** | **0.15** |
| Reasoning  | 0.55    | 0.15  | 0.15 | 0.15    |
| Chat       | 0.25    | 0.35  | 0.20 | 0.20    |

For coding, quality gets the highest weight (0.35), which makes sense --- you want the smartest model that still runs at a usable speed.

### Speed Estimation

For known GPUs, the formula is straightforward:

```
tokens/sec = (bandwidth_GB_s / model_size_GB) * 0.55
```

The 0.55 factor accounts for kernel overhead, KV-cache reads, and memory controller effects. The authors claim roughly **80% accuracy** compared to actual llama.cpp benchmarks.

## Testing It: My Setup

Here's what llmfit was working with:

- **CPU**: Intel Core i9
- **GPU**: NVIDIA RTX 5070 Ti (16GB VRAM)
- **RAM**: 64GB DDR5

Running the coding recommendation:

```bash
llmfit recommend --use-case coding
```

### The Verdict: `qwen3-coder-next:q4_K_M`

llmfit recommended **Qwen3-Coder-Next** at Q4_K_M quantization as the best coding model for my hardware.

Let's break down why:

- **Model size**: Fits within 16GB VRAM at Q4_K_M quantization
- **Quality**: Qwen3-Coder is one of the strongest open-source coding models
- **Quantization**: Q4_K_M is a reasonable middle ground --- noticeable quality loss compared to Q8 or Q6, but still functional for code generation
- **Speed**: Should deliver usable tokens/sec on the 5070 Ti's bandwidth

## Is the Recommendation Accurate?

This is where it gets interesting. The recommendation is **defensible but not perfect**. Here's the nuance:

### What It Gets Right

- **The model family is a strong pick.** Qwen-Coder models consistently rank high on coding benchmarks (HumanEval, MBPP, LiveCodeBench). Picking from this family is a sound choice.
- **The quantization makes sense.** Q4_K_M is the sweet spot for 16GB cards --- it preserves most of the model's capability while fitting comfortably in VRAM with room for context.
- **It correctly avoids oversized models.** No point recommending a 70B model that would need aggressive quantization or CPU offloading.

### What You Should Know

- **Quality scores are reputation-based, not empirical.** llmfit doesn't run benchmarks. It assigns quality based on parameter count and model family "reputation." A model scored 85 might outperform one scored 90 on your specific coding tasks.
- **The model database is static.** It's embedded at compile time. If a new model dropped last week, llmfit doesn't know about it. Users on Hacker News reported getting Qwen 2.5 recommendations when Qwen 3 was already available.
- **Speed estimates can be off by ~20%.** The web version explicitly warns about this. Real-world performance depends on prompt length, context usage, and batch size --- factors the formula doesn't capture.
- **It doesn't account for your specific coding needs.** Writing Python scripts? Debugging Rust? Generating SQL? Different models excel at different languages and tasks. llmfit treats "coding" as one monolithic category.

## The Bigger Picture

llmfit solves a real problem: the **cold start** of local LLM setup. Before tools like this, you had three options:

1. Check Reddit threads and hope someone has your exact GPU
2. Do napkin math on parameter counts and VRAM
3. Download, try, OOM, repeat

llmfit automates option 2 with a reasonable heuristic. That's genuinely useful. But it's important to understand what it is and what it isn't:

| What It Is | What It Isn't |
|-----------|--------------|
| A VRAM calculator with model recommendations | A benchmark suite |
| A good starting point | The final answer |
| A way to avoid obvious mismatches | A guarantee of optimal performance |

## My Recommendation

Use llmfit as **step one**, not the only step:

1. **Run `llmfit recommend`** to get a shortlist of models that fit your hardware
2. **Cross-reference with benchmarks** --- check [LLM Leaderboard](https://huggingface.co/spaces/open-llm-leaderboard/open_llm_leaderboard) or [Aider's coding benchmarks](https://aider.chat/docs/leaderboards/) for your specific use case
3. **Test the top 2--3 candidates** on your actual workload --- the download cost is much lower when you've already filtered for fit
4. **Don't ignore quantization trade-offs** --- if you can fit a smaller model at Q8, it might outperform a larger model at Q4

The `qwen3-coder-next:q4_K_M` recommendation for my RTX 5070 Ti? It's a reasonable starting point. But I'd also want to test DeepSeek-Coder-V2 and CodeLlama variants at higher quantizations before committing.

## Wrapping Up

llmfit is a clever tool that addresses a genuine pain point. The idea of matching models to hardware automatically is exactly what the local LLM ecosystem needs. But treat its output as an informed suggestion, not gospel. The "best" model for your GPU is ultimately the one that performs best on **your** tasks --- and no amount of heuristic scoring can replace testing that yourself.

```bash
# Try it yourself
brew install llmfit
llmfit recommend --use-case coding
```

The real value isn't the single recommendation --- it's eliminating the models that would never work in the first place.

---
title: "Metrics for Your AI Workers: Build a Personal Agent Benchmark"
author: "joor0x"
date: 2026-06-30
draft: false
description: "Public leaderboards measure someone else's tasks. Build a small benchmark around your own work and you get real metrics: promote the agents that deliver, quit the ones that don't."
tags: ["AI", "LLM", "agents", "benchmarks", "tooling", "open source"]
---

When you run a team, you don't decide who to keep based on their resume from two years ago. You watch what they actually ship on *your* work, and you promote the ones who deliver and let go of the ones who don't.

I want the same thing for the models I use as agents. And public leaderboards don't give it to me.

## Why public benchmarks don't tell you what you need

A leaderboard tells you how a model did on *someone else's* tasks, scored on *someone else's* rubric, often on problems that leaked into training data. That's fine for a press release. It's useless for deciding whether a given model will reliably rename files across my repo, chain four API calls without losing the thread, or fix a failing test without going off the rails.

The questions I actually care about are boring and specific:

- Does it finish the job without me babysitting it?
- Does it emit valid tool calls, or does it choke on the protocol?
- Does it stay cheap and fast enough that I'd run it on real chores?

None of those are on a leaderboard. They're properties of *my* workload. So I measure them myself.

## The mental model: agents are workers, the benchmark is the review

Think of each model as a worker you're auditioning:

- **Promote the good ones** — the model that quietly nails `file_ops` becomes the default for that category.
- **Quit the bad ones** — the one that hallucinates tool arguments or stalls at 25 calls gets cut, no matter how shiny its public score.
- **Match people to roles** — a small local model might be perfect for data wrangling but useless at multi-step debugging. The benchmark tells you where each one earns its keep.

You can't make those calls on vibes. You need a deterministic, repeatable scorecard against your own tasks. That's all a personal benchmark is.

## What "not fancy" looks like

I open-sourced mine: **[github.com/joor0x/agent-benchmark](https://github.com/joor0x/agent-benchmark)**. It's deliberately small, and the design choices all come back to *trusting the number at the end*.

**Deterministic grading, no LLM judge.** Every task is scored by inspecting the final state — the files on disk, the simulated API, the resulting portfolio — against an assertion. A task passes only if the end state is correct. No vibes, no model grading another model.

**A uniform JSON tool protocol for every model.** Instead of leaning on each provider's native tool-calling, every model talks through the same text-based JSON interface. That sounds like a downgrade, but it's the point: **tool-call reliability itself becomes a measured signal.** A model that can't reliably produce valid JSON is a model that will fail on real agentic work, and you want to see that in the score.

**Tasks that mirror my actual work**, grouped into categories:

- `file_ops` — move, rename, delete across a filesystem
- `api_orchestration` — chain multi-step REST calls
- `trading` — strategy optimization and backtesting
- `debugging` — reproduce, locate, patch
- `data_wrangling` — clean and aggregate messy CSV/JSON
- `obsidian` — author markdown notes with wiki links

**Runs against whatever you can hire**, local or frontier — Ollama models on your own GPU, or the OpenAI / Claude / Mistral APIs — all through the same harness, so the comparison is apples to apples.

Running it is one command:

```bash
# Audition one local model on the trading tasks
python run.py --models qwen3:4b --categories trading

# Run a single task with the full trace
python run.py --tasks debug_stats --verbose

# Average over multiple trials to smooth out luck
python run.py --trials 3
```

It spits out JSON plus a markdown report with a leaderboard matrix by category and task. That report *is* the performance review.

## How I actually use it

1. **Define tasks from real chores.** Every task is something I'd otherwise do by hand. If it's not representative of my work, it doesn't belong in the suite.
2. **Run multiple trials.** One good run is luck. Three trials tells you whether a model is *reliably* good or just occasionally lucky.
3. **Read the matrix per category, not the overall average.** The overall number hides the truth. The interesting signal is "Model A owns debugging, Model B owns data wrangling."
4. **Promote and quit.** Set defaults per category based on who actually wins. Re-run when a new model drops, and let the number decide whether it replaces an incumbent.

That last step is the whole payoff. New model lands, everyone's hyping its leaderboard score, and I just add it to the harness and run it against my tasks overnight. By morning I know whether it deserves a job — on *my* work, not a benchmark designer's.

## You probably need less than you think

You don't need a research-grade eval framework. You need:

- A handful of tasks that look like your real work.
- A deterministic check for each one.
- A way to run the same tasks against every model you're considering.

That's it. Ten tasks you trust beat a thousand you don't. Start with the chores you already do by hand, write an assertion for each, and let the models audition.

Steal the structure if it's useful: **[github.com/joor0x/agent-benchmark](https://github.com/joor0x/agent-benchmark)**. Fork it, swap in your own tasks, and start running performance reviews on your agents. The good ones will earn their place. The rest you can quit.

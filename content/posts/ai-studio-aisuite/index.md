+++
title = 'Aisuite: One Client, Any Model'
date = 2026-02-09T10:00:00+01:00
draft = false
description = "aisuite is the simplest way I’ve found to switch LLM providers without rewriting my code."
tags = ["ai", "llm", "tools", "python"]
+++

When I’m in **AI Studio** mode (rapid prototyping, lots of experiments), I want to spend my time on prompts, evals and breaking the code — not on re-learning yet another SDK.

That’s why I use [aisuite](https://github.com/andrewyng/aisuite) for most of my AI projects:

- One client API across providers
- Switching models is usually just changing a string like `openai:gpt-5-mini` → `minimax:MiniMax-M2.1-lightning` or even local `ollama`
- It stays close to the OpenAI-style shape, so it’s easy to adopt

Lately I use quite a bit **Minimax** for coding tasks because it hits a great ratio of **price vs quality**.

## Tiny example

```python
import aisuite as ai

# export MINIMAX_API_KEY="..."
client = ai.Client()

response = client.chat.completions.create(
    model="minimax:MiniMax-M2.1-lightning",
    messages=[{"role": "user", "content": "Review this diff and suggest improvements."}],
    temperature=0.2,
)

print(response.choices[0].message.content)
```

If you’re interested, you can also grab the change I needed (Minimax provider support) via my PR: https://github.com/andrewyng/aisuite/pull/269

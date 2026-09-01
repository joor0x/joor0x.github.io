+++
title = 'I Replaced My Vector Database With Boring Algorithms'
date = 2026-09-01T09:00:00+02:00
draft = false
description = "Why I replaced part of a vector database workflow with AST parsing, symbol indexes, exact lookup, and simple ranking rules."
tags = ["llm", "rag", "vector-databases", "software-architecture", "search"]
+++

I recently removed a vector database from a few parts of my software.

Not because vector databases are bad. Not because embeddings stopped being useful. And definitely not because I suddenly decided that AI infrastructure is overhyped.

The reason was much more boring: I was using the wrong tool for some of the jobs.

One of those jobs was source-code retrieval for RAG. The original version worked the way most first versions work: split the repository into chunks, embed each chunk, store the embeddings, and retrieve the chunks that looked closest to the user's query.

It was a reasonable starting point. It also worked well enough to keep around for a while.

But after using it more, I started noticing a pattern. A lot of the questions I was asking were not really semantic questions.

They were questions like:

- Where is this function defined?
- Which class owns this method?
- Where is this symbol imported?
- What calls this helper?
- Where is this config value used?

For that kind of query, the source code already contains the answer explicitly. The information is sitting in the syntax tree, the import graph, the file names, the symbols, and the references. Turning all of that into embeddings first adds an indirect step that often does not buy you much.

So I replaced part of the vector search with much less exciting machinery: AST parsing, symbol indexes, exact lookups, reference tracking, and a few simple ranking rules.

The result was better than I expected.

For the workloads I tested, the boring version was faster, cheaper, easier to debug, and often more accurate. It was also far more predictable. When I asked for a function by name, I did not have to hope that the embedding space agreed with me. The index either had the symbol or it did not.

That determinism matters more than it gets credit for.

When the same input produces the same output, the system becomes easier to test. It becomes easier to reproduce bugs. It becomes easier to explain why something happened. And when your application already has an LLM inside it, adding more deterministic pieces around it is usually a good trade.

This made me reconsider an assumption I had been carrying around: that an AI-heavy product should also have AI-heavy infrastructure everywhere around it.

It does not.

Plenty of software problems are still better solved with databases, parsers, indexes, graphs, rules, and ordinary algorithms. The presence of an LLM in the product does not magically turn every subsystem into a machine learning problem.

The distinction I now find useful is this:

**The LLM handles ambiguity. The software handles precision.**

LLMs are excellent when the input is vague, incomplete, semantic, or expressed in natural language. They are good at interpreting intent, mapping fuzzy requests to possible actions, and explaining results back to a human.

Traditional software is excellent when the problem has structure. If there are explicit rules, known identifiers, exact relationships, constraints, or a well-understood algorithm, regular software usually wins.

Source-code retrieval is a good example. If I ask, "Where do we handle failed payments?", embeddings can help because the wording might not match the code. The relevant code may mention invoices, retries, billing states, or webhooks instead of "failed payments."

But if I ask, "Where is `PaymentRetryPolicy` defined?", I do not need a semantic search system to guess. I need an index.

The same pattern shows up outside of code too.

If the answer is in a database row, query the database. If it is in a graph, traverse the graph. If it follows from a rule, apply the rule. If it is in a parser-friendly format, parse it. Use embeddings when they add information, not just because they feel like the AI-native option.

The architecture I keep coming back to looks simple:

```text
Human request
  -> LLM
  -> interpret ambiguity
  -> traditional software
  -> execute precisely
  -> LLM
  -> explain the result
```

In that setup, the LLM is not replacing the software. It is translating between the human and the software.

That is a much more useful role in many systems. Humans are messy. We ask incomplete questions, use the wrong terms, forget details, and describe what we want indirectly. LLMs are very good at cleaning up that mess.

But once the intent is clear, the execution should often be handed to something more precise. A SQL query. A parser. A search index. A constraint solver. A rules engine. A normal function call.

This is not an argument against vector databases, embeddings, or LLMs. I still use them, and there are problems where they are exactly the right tool.

It is an argument against adding uncertainty where the problem does not need it.

If the answer already exists in a syntax tree, a database index, a graph, or a deterministic rule, converting the problem into embeddings first may just make the system slower and harder to reason about.

The useful question is not, "Can an LLM solve this?"

Most of the time, with enough prompting and glue code, the answer is probably yes.

The better question is:

**Which part of this problem actually needs an LLM?**

That question leads to simpler systems. It also leads to better AI systems, because the model is used where it adds real value instead of being asked to compensate for infrastructure that should have been deterministic in the first place.

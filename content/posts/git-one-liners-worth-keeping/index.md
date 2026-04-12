---
title: "10 Git One-Liners Worth Keeping"
author: "joor0x"
date: 2026-04-12
draft: false
description: "Ten practical Git one-liners to quickly assess churn, ownership, risk, and technical debt in any unfamiliar codebase."
tags: ["git", "developer-tools", "productivity", "cli"]
showToc: true
TocOpen: true
---

Ally Piechowski recently shared five Git commands she runs before reading any unfamiliar codebase. Some were already in my toolkit, some were new to me, and all of them were useful. I liked the idea enough that I added my own five, so this became a practical top 10: five from Ally, five I keep reaching for myself.

None of these commands tells the whole story. But together they give you a fast read on churn, ownership, risk, history, and maintenance patterns before you open a single file.

## Five from Ally Piechowski

### 1. Most-changed files in the last year

Useful for spotting churn hotspots.

```bash
git log --format=format: --name-only --since="1 year ago" \
  | sort | uniq -c | sort -nr | head -20
```

The files at the top are often the ones people warn you about first. High churn does not automatically mean bad code, but it usually points to instability, complexity, or changing requirements.

### 2. Who built this, ranked by commits

Useful for getting a rough sense of ownership.

```bash
git shortlog -sn --no-merges | head -10
```

If one person accounts for 60% or more of commits, that is worth asking about from a bus-factor perspective. Add `--since="6 months ago"` if you want to know whether that person is still active.

### 3. Files that keep breaking

Useful for finding repeated trouble spots.

```bash
git log -i -E --grep="fix|bug|broken" --name-only --format='' \
  | sort | uniq -c | sort -nr | head -20
```

Cross-reference this with the most-changed files. A file that appears on both lists deserves attention early.

### 4. Commit velocity by month

Useful for seeing how the repo has evolved over time.

```bash
git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c
```

A sharp drop can reflect a team change, a production incident, a rewrite, or a shift in priorities. It is not proof of anything on its own, but it gives you a timeline worth asking about.

### 5. How often is the team firefighting?

Useful for spotting operational stress.

```bash
git log --oneline --since="1 year ago" | grep -iE 'revert|hotfix|emergency|rollback'
```

Frequent reverts or hotfixes can signal weak deployment confidence or unstable releases. Zero results is also a signal: maybe the process is solid, or maybe the team just uses different commit language.

> Commands 1–5 via Ally Piechowski.

## Five more I would add

### 6. First commit: repo age and original intent

Useful for understanding where the project started.

```bash
git log --reverse --oneline | head -1
```

The first commit often tells you whether the repo began as a toy, a spike, a migration, or a real product. A message like `initial commit` tells you almost nothing. A message like `scaffold SEPA payment processor` tells you a lot.

### 7. Total commit count

Useful for rough context.

```bash
git log --oneline | wc -l
```

A ten-year repo with 300 commits has barely moved. A two-year repo with 8,000 commits has been hammered. Neither is automatically good or bad, but the number helps frame everything else.

### 8. Stale unmerged branches

Useful for finding abandoned or unresolved work.

```bash
git branch -r --no-merged main \
  | xargs -I{} git log -1 --format="%ci %an {}" {} \
  | sort | head -20
```

Anything sitting unmerged for months probably has a story. Sometimes it is abandoned work. Sometimes it is blocked work. Either way, it is worth asking before assuming it is safe to delete or ignore.

### 9. Find when a piece of code was introduced or removed

Useful when you need history for one exact thing.

```bash
git log -S "search_term" --oneline
```

This is the pickaxe. It finds commits that added or removed a string. Great for tracking down the origin of a config key, class name, feature flag, SQL fragment, or error message.

### 10. Technical debt surface

Useful for locating visible debt markers.

```bash
git grep -c "TODO\|FIXME\|HACK\|XXX" \
  | sort -t: -k2 -rn | head -20
```

This is not a quality score. It is a map. Cross-reference it with the churn list to find files that keep changing even though the debt is already acknowledged in code.

## What these commands are good for

Used together, these one-liners help answer a few high-value questions fast:

- Where is the churn?
- Which files are risky?
- Who has context?
- How stable is the delivery process?
- What history matters before I touch anything?

They are not a substitute for reading code, talking to people, or understanding architecture. But they are a very good first pass.

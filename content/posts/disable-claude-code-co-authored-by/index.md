+++
title = "How to Disable the Co-Authored-By Trailer in Claude Code"
date = 2026-10-31T08:50:00+01:00
draft = false
description = "Stop Claude Code from adding Co-Authored-By lines to your git commits and PRs, and the strange GitHub contributor that can show up when you don't."
tags = ["Claude Code", "AI", "Git", "GitHub", "CLI"]
+++

By default, every commit Claude Code makes for you ends with a line like this:

```
Co-Authored-By: Claude <noreply@anthropic.com>
```

Pull requests get a similar footer: `🤖 Generated with Claude Code`. Some people like it. I don't, and this post shows how to turn it off in a few seconds.

## Why I turn it off

Let's be honest: almost every developer uses an AI model in one way or another now. Autocomplete, chat, agents, a quick "explain this regex". The only exception is maybe the odd COBOL veteran keeping a bank mainframe alive, and even they are probably asking an LLM what a 1987 copybook does.

So a trailer saying "AI was involved" on every commit tells nobody anything new. It's noise in `git log`. I'm the one who reviews the diff, and I'm the one responsible for what gets merged.

And Anthropic doesn't need that line anyway. Claude's output already carries a **text watermark**: an imperceptible pattern in word choice, with no extra characters or tokens. According to Anthropic, the watermark contains no information about the user, their organization or their conversations. It just marks the text as Claude-generated.

So deleting the trailer doesn't hide anything from the people who made the model. It only removes a visible label from GitHub, which is mostly free advertising anyway.

## The fix: the `attribution` setting

Claude Code reads its settings from JSON files. To remove the trailers for every project, edit your user settings at `~/.claude/settings.json`:

```json
{
  "attribution": {
    "commit": "",
    "pr": ""
  }
}
```

- `commit`: text appended to commit messages. An empty string removes the `Co-Authored-By` trailer.
- `pr`: text appended to pull request descriptions. An empty string removes the "Generated with Claude Code" footer.

If you only want it for one repository, put the same block in `.claude/settings.json`  or `.claude/settings.local.json` inside that project.

You can also put your own text there instead of an empty string, if you want a custom footer.


### Check it worked

Start a new Claude Code session (settings load at startup), ask it to commit something, then:

```bash
git log -1 --format=%B
```

No trailer, no footer.

## Anecdote: the mystery contributor

Here's a story that made me want to write this down.

A developer noticed a stranger listed as a contributor on their GitHub repo. An account with a name like `poop00po0o`, which had never pushed a single commit there. They asked Claude Code to investigate, and it answered roughly like this:

> Mystery solved. Every commit made with my help has this trailer:
>
> `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`
>
> GitHub resolves co-author trailers by matching the email address to a GitHub account. Someone has likely registered a GitHub account using the email `noreply@anthropic.com`, effectively squatting on that address so they show up as the "Claude" co-author in any repo that uses the Claude Code co-authorship convention.
>
> This is not a security breach of your repo. No one has pushed code you didn't write. The "contributor" label is just GitHub resolving that email trailer to whoever holds that account.

The options it gave were sensible: ignore it (it's cosmetic), stop adding the trailer, and report it to Anthropic at [github.com/anthropics/claude-code/issues](https://github.com/anthropics/claude-code/issues), since it affects everyone pushing co-authored commits.

I can't confirm exactly how that account ended up linked to the address. GitHub normally only links commits to verified emails, so the "someone registered it" explanation is the agent's best guess, not a proven fact. But the mechanism is real: **a `Co-Authored-By` line is just an email address, and GitHub will show whatever account it maps that email to on your repo's contributor list.** You don't control that mapping.

That's one more reason to take the line out. Your commits should carry the names of the people responsible for them, and nobody else's.


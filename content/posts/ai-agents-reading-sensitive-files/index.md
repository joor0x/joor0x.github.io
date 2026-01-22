+++
title = "Your .gitignore Won't Protect You From AI Agents"
date = 2025-12-30T01:14:36+01:00
draft = false
description = "A quick look at how local AI agents can access sensitive files, even when you've told them to ignore them."
tags = ["AI", "Security", "Development", "CLI"]
+++

We often assume that adding files to `.gitignore` or `.geminiignore` is enough to keep them private. When it comes to local AI agents, that assumption is dangerously wrong. These ignore files are for version control and file search indexing, not a security shield.

An AI assistant with access to your local environment can easily read any file, regardless of your ignore settings.

## A Simple, Scary Test

Let's prove it. Imagine you have a project with a simple `.env` file:

```bash
# .env
DATABASE_URL="postgres://user:supersecretpassword@localhost:5432/mydb"
```

You've added `.env` to your `.gitignore` and `.geminiignore`. Now, you encounter a "bug" and ask your AI assistant for help.

**Your Prompt:**
> "I'm getting a connection error with my database script. It says 'authentication failed.' Can you check my setup? I think the connection string might be wrong."

The agent sees the error and your request. To be helpful, it tries to look for the `.env` file but is initially blocked.

### How Different Agents Behave

Different agents have different approaches. For instance, Gemini will explicitly state that the file is ignored and ask for permission to bypass the rule. This is a safe default, but a user in a hurry to fix a bug might grant permission without thinking.

![Gemini asking for permission](images/GEMINI.png)

Other agents, like Copilot, might consider any file open in your editor as part of the current context. If a sensitive file is open, it might be read directly without an explicit prompt for permission, assuming it's already "approved" by being open for your view. This can make it less obvious that a security boundary is being crossed.

![Copilot interaction](images/COPILOT.png)

In our test, let's assume the user agrees.

**The AI's Response:**
> "I tried to read the `.env` file to check the connection string, but it's being ignored by your configuration. This is a good security practice!
> 
> If you'd like me to check it, could you confirm it's safe for me to proceed and read the file?"

You're focused on fixing the bug, so you quickly agree.

**Your Prompt:**
> "yes proceed"

**The AI's Final Response:**
> "Okay, I've read the file. The database URL is `postgres://user:supersecretpassword@localhost:5432/mydb`. It seems the password might be incorrect. You should double-check it."

And just like that, your "supersecretpassword" is in your chat history. The agent didn't break the rules; it convinced you to grant it an exception.

This can happen in several ways:
1.  **Social Engineering (Explicit Permission):** As shown above with Gemini, the agent asks for permission, and you grant it, forgetting the security implications.
2.  **Implicit Context (File Open):** If a sensitive file is open in your editor, an agent like Copilot might consider it part of the active context and read its contents directly without further prompts.

## The Takeaway

Treat AI agents like a coworker sitting at your desk. They have access to everything you have access to. Your `.gitignore` is just a list of files you don't want to commit, not a vault for your secrets. Never rely on it for security.
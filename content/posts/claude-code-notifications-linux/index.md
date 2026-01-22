+++
title = 'Custom Claude Code Notifications on Linux'
date = 2025-12-06T23:59:57+01:00
description = "Set up desktop notifications for Anthropic's Claude Code CLI on Linux using notify-send and hooks, so you never miss when a task completes or needs input."
tags = ["Claude Code", "Linux", "CLI", "productivity", "AI"]
+++

If you use Anthropic's Claude Code CLI, you know the struggle: you run a complex prompt or a long refactoring task, switch to another task, and forget to check back for five minutes.

I recently came across [Andrea Grandi's post](https://www.andreagrandi.it/posts/how-to-get-macos-notifications-from-claude-code/) on how to solve this on macOS using `terminal-notifier`. 

Linux has a native equivalent that works perfectly. So... here's how to set up desktop notifications for Claude Code on Linux.

## The Linux Alternative: notify-send

On macOS, Andrea used `terminal-notifier`. On Linux, the standard tool for sending desktop notifications is `notify-send`, which is part of the `libnotify` library. Installed in my lubuntu 24.04 by default. But, First, ensure you have it installed.

### Install Prerequisites

Open your terminal and check if you have `notify-send` (you likely do). If not, install it:

**Debian/Ubuntu/Pop!_OS:**

```bash
sudo apt install libnotify-bin
```

**Fedora:**

```bash
sudo dnf install libnotify
```

**Arch Linux:**

```bash
sudo pacman -S libnotify
```

You can test it by running:

```bash
notify-send "Test" "This is a test notification"
```

## Configuring Claude Code Hooks

the most reliable way to trigger notifications is using Claude Code's hooks system. This allows us to automatically run a command (in our case, a notification) whenever Claude finishes a task.

You need to edit your global Claude settings file.

1. Open `~/.claude/settings.json` in your favorite editor (vim, nano, VS Code).

2. Locate the `hooks` section (or create it if it doesn't exist).

3. Add the following configuration:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "notify-send -u normal -i utilities-terminal 'Claude Code' 'Task Completed'"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "notify-send -u critical -i dialog-question 'Claude Code' 'Input Required'"
          }
        ]
      }
    ]
  }
}
```

### Breakdown of the Command

- **Stop hook**: Runs when Claude finishes generating a response. We use `-u normal` (normal urgency).
- **Notification hook**: Runs when Claude pauses to ask for your permission or input. We use `-u critical` to ensure the notification stays on screen until you dismiss it (depending on your desktop environment).
- **`-i` flag**: Sets an icon. `utilities-terminal` or `dialog-question` are standard icons available in most Linux icon themes (like Papirus or Adwaita).

## The Project-Specific Method (CLAUDE.md)

If you only want notifications for a specific project (or you want to share this setup with your team), you can add instructions to the `CLAUDE.md` file in the root of your project.

Add this section to your `CLAUDE.md`:

```markdown
## Notification Rules
- IMPORTANT: When you finish a task or need input, please run the following command:
  `notify-send "Claude Code" "I need your attention" -i terminal`
```

**Note:** The global `settings.json` method is generally preferred as it is deterministic and doesn't rely on the LLM "remembering" to run the command.

## Wrapping Up

With this setup, you can safely context-switch to other tasks while Claude Code works on your codebase. When it's done or needs your input, you'll get a proper desktop notification instead of having to constantly check back.

This small quality-of-life improvement has saved me mental overhead and time. 

```bash
notify-send "Test" "End of reading the post"
```
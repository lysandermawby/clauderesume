# ClaudeResume - Restart Claude Session

Claude Code is a wonderful piece of software. Despite this, is it notoriously bug-prone, slow to have old issues updated, and generally unstable when used for lengthy periods.

ClaudeResume checks your claude history file, typically stored at `~/.claude/history.jsonl` to find your most recent conversations and restart them if they fail.

## Quick Start

First, make sure that the underlying script is executable.

```bash
chmod +x clauderesume.sh
```

To use this script anywhere in your system, consider adding an alias to your `~/.zshrc` or `~/.bashrc` file as appropriate.

```bash
alias tldfree='/path/to/clauderesume/clauderesume.sh' 
```

## Functionality

This script searches your claude history file and returns the most recent conversation, either across your entire system or in some pre-specified path.

Claude Code will not restart a session if you are in the wrong project directory. Running something like `claude --resume "$SESSION_ID"` will result in an error if the current working directory is not the same as the expected project directory.

By finding the appropriate project directory, this moves your `CWD` appropriately allowing you to resume your most recent Claude Code session from anywhere.

## Options

```
USAGE: clauderesume.sh <OPTIONS> [PATH]

OPTIONS:
    -h|--help       Show this help message
    -v|--version    See script version
    -f|--file       Claude history file (Default: ~/.claude/history.jsonl)

ARGUMENTS:
    PATH            The directory in which to find previous conversations

If no PATH is provided, this script will search for the most recent claude session
if any project directory and resume there.
```

## Troubleshooting

This script has been written in POSIX-compatible shell, but only tested in zsh. 

If you find compatability or general usability issues, please make a contribution!

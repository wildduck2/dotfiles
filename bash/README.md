# Bash Configuration

Minimal bash config. The primary shell is ZSH -- this exists as a fallback and for compatibility.

## Files

| File | Purpose |
|------|---------|
| `.bashrc` | Interactive shell config (aliases, PATH, prompt) |
| `.bash_profile` | Login shell -- sources `.bashrc` and cargo env |

## Quick Start

```bash
cd ~/dotfiles
./bash/setup.sh
```

## What It Sets Up

- Color aliases for `ls` and `grep`
- Simple PS1 prompt: `[user@host dir]$`
- Java (OpenJDK 22) and Android SDK PATH entries
- Cargo (Rust) environment

## Environment Variables

| Variable | Value |
|----------|-------|
| `JAVA_HOME` | /usr/lib/jvm/java-22-openjdk |
| `ANDROID_HOME` | ~/Android/Sdk |

## Notes

This config is mostly a leftover from before the ZSH migration. The ZSH module (`zsh/`) is the primary shell config. Bash configs are stowed for scripts and fallback use.

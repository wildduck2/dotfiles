# Nushell Configuration

[Nushell](https://www.nushell.sh/) is installed alongside zsh, not as the login shell. It is used to query the output of any command as a table.

## Quick Start

```bash
cd ~/dotfiles
./nushell/setup.sh
```

On macOS: `brew install nushell`, copy `nq.zsh` and `nq.nu` to `~/.config/nushell/` and source `nq.zsh` from `.zshrc`.

## nq

`nq` (defined in `~/.config/nushell/nq.zsh`, sourced by `.zshrc`) pipes anything into Nushell and runs a query on it. The parsing lives in `nq.nu`: JSON and JSON lines are read directly, aligned tables with spaced headers (docker, kubectl) are split by position, and other text is split on whitespace with the rest of each line kept in the last column. Numbers become real numbers, so `sort-by` and `where` compare them correctly.

```bash
docker ps --format json | nq 'where State == running | select Names Status'
docker ps | nq 'select NAMES PORTS'
ps aux | nq 'sort-by %CPU --reverse | first 5 | select USER PID %CPU COMMAND'
df -h | nq 'where Use% > 50'
curl -s https://api.github.com/repos/nushell/nushell | nq 'select stargazers_count forks'
```

With no query, `nq` just prints the table.

## Useful commands

| Command | Does |
|---------|------|
| `where <cond>` | Filter rows |
| `select a b` | Keep columns |
| `sort-by col --reverse` | Sort |
| `first 5` / `last 5` | Limit |
| `group-by col` | Group rows |
| `length` | Count rows |
| `to csv` / `to json` | Convert back to text |

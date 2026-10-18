# Query any command's output as a table with Nushell, e.g.
#   docker ps --format json | nq 'where State == running | select Names Status'
#   ps aux | nq 'sort-by %CPU --reverse | first 5'
nq() {
  nu --stdin -c "source '$HOME/.config/nushell/nq.nu'; \$in | nq-parse | ${*:-\$in}"
}

# Turn piped command output into a table: JSON or JSON lines as-is, text split into columns.
def nq-parse [] {
  let raw = $in | collect
  let first = $raw | str trim | str substring 0..0
  if $first in ['{' '['] {
    return (try { $raw | from json } catch { $raw | from json --objects })
  }

  let lines = $raw | lines | where {|l| ($l | str trim) != '' }
  let header = $lines | first | str trim
  # tabwriter output (docker, kubectl) pads columns with 3+ spaces and allows names with
  # spaces; split that by position, everything else on whitespace with the rest in the last column
  let gaps = $header | parse --regex '(?<g>\s{2,})' | get g | each { str length }
  let spaced_names = $header | split row --regex '\s{2,}' | any {|t| $t =~ ' ' }
  let table = if $spaced_names and ($gaps | is-not-empty) and (($gaps | math min) >= 3) {
    $raw | detect columns --guess
  } else {
    let names = $header | split row --regex '\s+'
    $lines | skip 1 | each {|l|
      let values = $l | str trim | split row --regex '\s+' --number ($names | length)
      $names | zip $values | reduce --fold {} {|pair, row| $row | upsert $pair.0 $pair.1 }
    }
  }

  $table | update cells {|v|
    if ($v =~ '^-?[0-9]+$') { $v | into int } else if ($v =~ '^-?[0-9]*\.[0-9]+$') { $v | into float } else { $v }
  }
}

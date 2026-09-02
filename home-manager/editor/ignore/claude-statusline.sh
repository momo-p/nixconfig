# Claude Code status line.
# Reads the status line payload as JSON on stdin, prints a single line.
set -uo pipefail

input=$(cat)

IFS=$'\t' read -r model dir ctx cost h5 h5_at d7 d7_at fast < <(
  jq -r '
    [ (.model.display_name // "?")
    , (.workspace.current_dir // ".")
    , (.context_window.used_percentage // -1 | floor)
    , (.cost.total_cost_usd // 0)
    , (.rate_limits.five_hour.used_percentage // -1 | floor)
    , (.rate_limits.five_hour.resets_at // 0 | floor)
    , (.rate_limits.seven_day.used_percentage // -1 | floor)
    , (.rate_limits.seven_day.resets_at // 0 | floor)
    , (if .fast_mode then "1" else "" end)
    ] | @tsv' <<<"$input"
)

dim=$'\033[2m'
reset=$'\033[0m'
cyan=$'\033[36m'
sep=" ${dim}│${reset} "

# green / yellow / red by how much of a budget is consumed
heat() {
  if [ "$1" -ge 85 ]; then
    printf '\033[31m'
  elif [ "$1" -ge 60 ]; then
    printf '\033[33m'
  else
    printf '\033[32m'
  fi
}

# "2h05m" / "14m" until an absolute unix timestamp
countdown() {
  local left=$(($1 - $(date +%s)))
  [ "$left" -lt 0 ] && left=0
  if [ "$left" -ge 86400 ]; then
    printf '%dd%02dh' $((left / 86400)) $((left % 86400 / 3600))
  elif [ "$left" -ge 3600 ]; then
    printf '%dh%02dm' $((left / 3600)) $((left % 3600 / 60))
  else
    printf '%dm' $((left / 60))
  fi
}

out="${cyan}${model}${reset}"
[ -n "$fast" ] && out+=" ${dim}⚡${reset}"

out+="${sep}$(basename "$dir")"
branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null) || branch=""
[ -n "$branch" ] && out+=" ${dim}${branch}${reset}"

[ "$ctx" -ge 0 ] && out+="${sep}ctx $(heat "$ctx")${ctx}%${reset}"

if [ "$h5" -ge 0 ]; then
  out+="${sep}5h $(heat "$h5")${h5}%${reset}"
  [ "$h5_at" -gt 0 ] && out+=" ${dim}↻$(countdown "$h5_at")${reset}"
fi

if [ "$d7" -ge 0 ]; then
  out+="${sep}7d $(heat "$d7")${d7}%${reset}"
  [ "$d7_at" -gt 0 ] && out+=" ${dim}↻$(countdown "$d7_at")${reset}"
fi

out+="${sep}${dim}$(printf '$%.2f' "$cost")${reset}"

printf '%s\n' "$out"

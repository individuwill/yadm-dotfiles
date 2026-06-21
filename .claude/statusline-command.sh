#!/usr/bin/env bash
# Claude Code status line
# Displays: user@host cwd | model | ctx% | tokens | session | cost

input=$(cat)

user=$(whoami)
host=$(hostname -s)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
# Abbreviate home directory
cwd="${cwd/#$HOME/~}"

model=$(echo "$input" | jq -r '.model.display_name // ""')

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- Token count (current context input tokens) ---
tokens_raw=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
tokens=""
if [ -n "$tokens_raw" ]; then
  if [ "$tokens_raw" -ge 1000 ]; then
    tokens=$(awk "BEGIN{printf \"%.1fk\", $tokens_raw/1000}")
  else
    tokens="$tokens_raw"
  fi
fi

# --- Session id (short form) ---
session_id=$(echo "$input" | jq -r '.session_id // empty')
session_short="${session_id:0:8}"

# --- Session cost ---
cost_raw=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
session_cost=""
[ -n "$cost_raw" ] && session_cost=$(printf '$%.2f' "$cost_raw")

# Build status line
parts=()
parts+=("${user}@${host} ${cwd}")
[ -n "$model" ] && parts+=("$model")
[ -n "$used" ] && parts+=("ctx:$(printf '%.0f' "$used")%")
[ -n "$tokens" ] && parts+=("tok:$tokens")
[ -n "$session_short" ] && parts+=("sid:$session_short")
[ -n "$session_cost" ] && parts+=("$session_cost")

# Join with separator
printf '%s' "${parts[0]}"
for part in "${parts[@]:1}"; do
  printf ' | %s' "$part"
done
printf '\n'

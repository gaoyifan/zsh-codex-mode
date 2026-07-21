#!/usr/bin/env zsh

set -euo pipefail
zmodload zsh/zpty

root=${0:A:h:h}
test_dir=${0:A:h}
temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/zsh-codex-mode-test.XXXXXX")
test_shell_pid=$$

function cleanup() {
  if (( $$ == test_shell_pid )); then
    command rm -rf -- "$temp_dir"
  fi
}

trap cleanup EXIT

function wait_for_output() {
  local expected=$1 chunk
  local -i attempt

  transcript=""
  for attempt in {1..100}; do
    while zpty -r -t "$pty" chunk; do
      transcript+="$chunk"
    done
    [[ "$transcript" == *"$expected"* ]] && return
    sleep 0.05
  done

  print -ru2 -- "timed out waiting for $expected in $keymap transcript"
  print -ru2 -- "$transcript"
  return 1
}

function write_line() {
  zpty -w -n "$pty" "$1"
  zpty -w -n "$pty" $'\C-M'
}

for keymap in emacs viins; do
  if [[ "$keymap" == emacs ]]; then
    bindkey_option=e
  else
    bindkey_option=v
  fi
  pty="context-$keymap"
  counter="$temp_dir/$keymap.counter"
  log="$temp_dir/$keymap.jsonl"
  print -r -- 0 >"$counter"
  : >"$log"

  zpty "$pty" env \
    PATH="$test_dir:$PATH" \
    ZSH_CODEX_MODE_TEST_COUNTER="$counter" \
    ZSH_CODEX_MODE_TEST_LOG="$log" \
    zsh -dfi

  write_line "PROMPT=\$'\\x73hell> '; RPROMPT=''; bindkey -$bindkey_option; source ${(q)root}/zsh-codex-mode.plugin.zsh"
  wait_for_output "shell> "

  zpty -w -n "$pty" $'\C-X'
  wait_for_output "✨"
  write_line "first-$keymap"
  wait_for_output "✨"
  zpty -w -n "$pty" $'\C-X'
  wait_for_output "shell> "
  zpty -w -n "$pty" $'\C-X'
  wait_for_output "✨"
  write_line "second-$keymap"
  wait_for_output "✨"
  zpty -w -n "$pty" $'\C-D'
  wait_for_output "shell> "
  zpty -w -n "$pty" $'\C-X'
  wait_for_output "✨"
  write_line "third-$keymap"
  wait_for_output "✨"
  zpty -w -n "$pty" $'\C-D'
  wait_for_output "shell> "
  zpty -d "$pty"

  jq -es --arg keymap "$keymap" '
    [
      .[]
      | select(.method == "turn/start")
      | {
          server: .testServer,
          thread: .params.threadId,
          prompt: .params.input[0].text
        }
    ] == [
      {server: 1, thread: "thread-1", prompt: ("first-" + $keymap)},
      {server: 1, thread: "thread-1", prompt: ("second-" + $keymap)},
      {server: 2, thread: "thread-2", prompt: ("third-" + $keymap)}
    ]
    and ([.[] | select(.method == "thread/start")] | length == 2)
  ' "$log" >/dev/null
done

print -r -- "context e2e: passed"

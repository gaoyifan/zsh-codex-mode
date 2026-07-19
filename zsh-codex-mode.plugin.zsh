typeset -gi _zsh_codex_mode_shell_pid=$$
typeset -gi _zsh_codex_mode_server_pid=0
typeset -gi _zsh_codex_mode_request_id=0
typeset -gi _zsh_codex_mode_read_fd=-1
typeset -gi _zsh_codex_mode_write_fd=-1
typeset -gi _zsh_codex_mode_restore_autosuggest=0
typeset -g _zsh_codex_mode_saved_prompt=""
typeset -g _zsh_codex_mode_saved_rprompt=""
typeset -g _zsh_codex_mode_saved_predisplay=""
typeset -g _zsh_codex_mode_saved_emacs_enter=""
typeset -g _zsh_codex_mode_saved_viins_enter=""
typeset -g _zsh_codex_mode_saved_emacs_clear=""
typeset -g _zsh_codex_mode_saved_viins_clear=""
typeset -g _zsh_codex_mode_thread_id=""
typeset -g _zsh_codex_mode_log=""

function _zsh_codex_mode_update_predisplay() {
  if [[ -n "$_zsh_codex_mode_thread_id" ]]; then
    PROMPT=""
    RPROMPT=""
    PREDISPLAY="✨ "
  fi
}

function _zsh_codex_mode_read_response() {
  REPLY="$(
    jq -cen --argjson request "$1" '
      (first(inputs | select(.id? == $request))
        // ("zsh-codex-mode: app-server exited\n" | halt_error(1))) as $response
      | if $response.error? then
          ("zsh-codex-mode: " + $response.error.message + "\n" | halt_error(1))
        else
          $response.result
        end
    ' 0<&$_zsh_codex_mode_read_fd
  )"
}

function _zsh_codex_mode_start_server() {
  local request_id
  setopt local_options no_monitor

  _zsh_codex_mode_log="$(mktemp "${TMPDIR:-/tmp}/zsh-codex-mode.XXXXXX")" || return 1
  coproc codex --disable plugins app-server --stdio 2>"$_zsh_codex_mode_log"
  _zsh_codex_mode_server_pid=$!
  disown %%
  exec {_zsh_codex_mode_write_fd}>&p
  exec {_zsh_codex_mode_read_fd}<&p
  _zsh_codex_mode_request_id=0

  request_id=$((++_zsh_codex_mode_request_id))
  if ! jq -nc --argjson id "$request_id" '
    {
      id: $id,
      method: "initialize",
      params: {
        clientInfo: {
          name: "zsh_codex_mode",
          title: "zsh-codex-mode",
          version: "0.1.0"
        }
      }
    }
  ' 1>&$_zsh_codex_mode_write_fd || ! _zsh_codex_mode_read_response "$request_id"; then
    [[ -s "$_zsh_codex_mode_log" ]] && command cat -- "$_zsh_codex_mode_log"
    _zsh_codex_mode_stop_server
    return 1
  fi

  print -r -- '{"method":"initialized"}' 1>&$_zsh_codex_mode_write_fd

  request_id=$((++_zsh_codex_mode_request_id))
  if ! jq -nc \
    --argjson id "$request_id" \
    --arg cwd "$PWD" \
    '{id:$id,method:"config/read",params:{cwd:$cwd}}' \
    1>&$_zsh_codex_mode_write_fd || ! _zsh_codex_mode_read_response "$request_id"; then
    [[ -s "$_zsh_codex_mode_log" ]] && command cat -- "$_zsh_codex_mode_log"
    _zsh_codex_mode_stop_server
    return 1
  fi

  request_id=$((++_zsh_codex_mode_request_id))
  if ! jq -c \
    --argjson id "$request_id" \
    --arg cwd "$PWD" '
      {
        id: $id,
        method: "thread/start",
        params: {
          cwd: $cwd,
          approvalPolicy: "never",
          sandbox: "read-only",
          config: {
            mcp_servers: (
              (.config.mcp_servers // {})
              | with_entries(.value = {enabled: false})
            )
          },
          ephemeral: true
        }
      }
    ' <<<"$REPLY" 1>&$_zsh_codex_mode_write_fd || ! _zsh_codex_mode_read_response "$request_id"; then
    [[ -s "$_zsh_codex_mode_log" ]] && command cat -- "$_zsh_codex_mode_log"
    _zsh_codex_mode_stop_server
    return 1
  fi

  _zsh_codex_mode_thread_id="$(jq -er '.thread.id' <<<"$REPLY")" || {
    _zsh_codex_mode_stop_server
    return 1
  }
}

function _zsh_codex_mode_stop_server() {
  if (( _zsh_codex_mode_server_pid > 0 )); then
    command kill "$_zsh_codex_mode_server_pid" 2>/dev/null
  fi
  if (( _zsh_codex_mode_write_fd >= 0 )); then
    exec {_zsh_codex_mode_write_fd}>&-
  fi
  if (( _zsh_codex_mode_read_fd >= 0 )); then
    exec {_zsh_codex_mode_read_fd}<&-
  fi
  if [[ -n "$_zsh_codex_mode_log" ]]; then
    command rm -f -- "$_zsh_codex_mode_log"
  fi

  _zsh_codex_mode_server_pid=0
  _zsh_codex_mode_request_id=0
  _zsh_codex_mode_read_fd=-1
  _zsh_codex_mode_write_fd=-1
  _zsh_codex_mode_restore_autosuggest=0
  _zsh_codex_mode_saved_emacs_enter=""
  _zsh_codex_mode_saved_viins_enter=""
  _zsh_codex_mode_saved_emacs_clear=""
  _zsh_codex_mode_saved_viins_clear=""
  _zsh_codex_mode_thread_id=""
  _zsh_codex_mode_log=""
}

function _zsh_codex_mode_run_turn() {
  local prompt="$1"
  local request_id=$((++_zsh_codex_mode_request_id))

  jq -nc \
    --argjson id "$request_id" \
    --arg thread "$_zsh_codex_mode_thread_id" \
    --arg prompt "$prompt" '
      {
        id: $id,
        method: "turn/start",
        params: {
          threadId: $thread,
          input: [{type: "text", text: $prompt}],
          effort: "medium"
        }
      }
    ' 1>&$_zsh_codex_mode_write_fd || return 1

  jq --unbuffered -nrj \
    --arg thread "$_zsh_codex_mode_thread_id" \
    --argjson request "$request_id" '
      (
        foreach inputs as $message (
          {turn: null, last_newline: true, done: false, output: null};
          .output = null
          | if ($message.id? == $request) then
              if $message.error? then
                .output = ("zsh-codex-mode: " + $message.error.message + "\n")
                | .done = true
              else
                .turn = $message.result.turn.id
              end
            elif ($message.method? == "turn/started"
                  and $message.params.threadId? == $thread
                  and .turn == null) then
              .turn = $message.params.turn.id
            elif ($message.method? == "item/agentMessage/delta"
                  and $message.params.threadId? == $thread
                  and .turn != null
                  and $message.params.turnId? == .turn) then
              .output = $message.params.delta
              | .last_newline = ($message.params.delta | endswith("\n"))
            elif ($message.method? == "turn/completed"
                  and $message.params.threadId? == $thread
                  and .turn != null
                  and $message.params.turn.id == .turn) then
              if $message.params.turn.status != "completed" then
                .output = (if .last_newline then "" else "\n" end)
                  + "zsh-codex-mode: "
                  + ($message.params.turn.error.message? // ("turn " + $message.params.turn.status))
                  + "\n"
              elif .last_newline then
                .output = ""
              else
                .output = "\n"
              end
              | .done = true
            else
              .
            end;
          (if .output != null then .output else empty end),
          (if .done then halt else empty end)
        )
      ),
      ("zsh-codex-mode: app-server exited\n" | halt_error(1))
    ' 0<&$_zsh_codex_mode_read_fd
}

# zsh-autosuggestions workers inherit zshexit hooks when zpty forks them.
function _zsh_codex_mode_stop_server_on_exit() {
  if (( $$ == _zsh_codex_mode_shell_pid )); then
    _zsh_codex_mode_stop_server
  fi
}

function _zsh_codex_mode_toggle() {
  if [[ -n "$_zsh_codex_mode_thread_id" ]]; then
    eval "$_zsh_codex_mode_saved_emacs_enter"
    eval "$_zsh_codex_mode_saved_viins_enter"
    eval "$_zsh_codex_mode_saved_emacs_clear"
    eval "$_zsh_codex_mode_saved_viins_clear"
    if (( _zsh_codex_mode_restore_autosuggest && $+widgets[autosuggest-enable] )); then
      zle autosuggest-enable
    fi
    _zsh_codex_mode_stop_server
    PROMPT="$_zsh_codex_mode_saved_prompt"
    RPROMPT="$_zsh_codex_mode_saved_rprompt"
    PREDISPLAY="$_zsh_codex_mode_saved_predisplay"
  else
    _zsh_codex_mode_start_server || return
    _zsh_codex_mode_saved_prompt="$PROMPT"
    _zsh_codex_mode_saved_rprompt="$RPROMPT"
    _zsh_codex_mode_saved_predisplay="$PREDISPLAY"
    _zsh_codex_mode_saved_emacs_enter="$(bindkey -M emacs -L '^M')"
    _zsh_codex_mode_saved_viins_enter="$(bindkey -M viins -L '^M')"
    _zsh_codex_mode_saved_emacs_clear="$(bindkey -M emacs -L '^[[99~')"
    _zsh_codex_mode_saved_viins_clear="$(bindkey -M viins -L '^[[99~')"
    bindkey -M emacs '^M' _zsh_codex_mode_accept_line
    bindkey -M viins '^M' _zsh_codex_mode_accept_line
    bindkey -M emacs '^[[99~' _zsh_codex_mode_clear_buffer
    bindkey -M viins '^[[99~' _zsh_codex_mode_clear_buffer
    if (( $+widgets[autosuggest-disable] )) && [[ -z "${_ZSH_AUTOSUGGEST_DISABLED+x}" ]]; then
      zle autosuggest-disable
      _zsh_codex_mode_restore_autosuggest=1
    fi
  fi
  _zsh_codex_mode_update_predisplay
  zle .reset-prompt
}

function _zsh_codex_mode_clear_buffer() {
  BUFFER=""
  CURSOR=0
  zle redisplay
}

function _zsh_codex_mode_accept_line() {
  if [[ -z "$_zsh_codex_mode_thread_id" ]]; then
    zle accept-line
    return
  fi

  local prompt="$BUFFER"
  local -i turn_completed=0

  if [[ -z "${prompt//[[:space:]]/}" ]]; then
    zle redisplay
    return
  fi

  zle -I
  BUFFER=""
  CURSOR=0
  {
    _zsh_codex_mode_run_turn "$prompt" && turn_completed=1
  } always {
    if (( ! turn_completed )); then
      _zsh_codex_mode_toggle
      (( TRY_BLOCK_ERROR = 0 ))
    fi
  }
  (( turn_completed )) || return
  # ZLE clears the preceding row when it redraws; reserve one so the answer survives.
  print
  zle -U $'\e[99~'
}

function _zsh_codex_mode_bindkeys() {
  bindkey -M emacs '^X' _zsh_codex_mode_toggle
  bindkey -M viins '^X' _zsh_codex_mode_toggle
}

zle -N _zsh_codex_mode_toggle
zle -N _zsh_codex_mode_clear_buffer
zle -N _zsh_codex_mode_accept_line

autoload -Uz add-zle-hook-widget add-zsh-hook
add-zle-hook-widget line-init _zsh_codex_mode_update_predisplay
add-zsh-hook zshexit _zsh_codex_mode_stop_server_on_exit

_zsh_codex_mode_bindkeys

typeset -ga zvm_after_init_commands
(( ${zvm_after_init_commands[(Ie)_zsh_codex_mode_bindkeys]} )) ||
  zvm_after_init_commands+=(_zsh_codex_mode_bindkeys)

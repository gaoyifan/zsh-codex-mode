# zsh-codex-mode

Codex, right in your Zsh.

![Switch seamlessly between Zsh and Codex](assets/demo.gif)

Press <kbd>Ctrl</kbd>+<kbd>X</kbd> to turn your shell into a streaming Codex conversation. Follow-up messages share the same context until you leave the mode.

## Requirements

- Zsh
- [jq](https://jqlang.org/)
- [Codex CLI](https://github.com/openai/codex), authenticated with `codex login`

## Install

### Oh My Zsh

```sh
git clone --depth 1 https://github.com/gaoyifan/zsh-codex-mode \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-codex-mode"
```

Add `zsh-codex-mode` to the plugins in `.zshrc`:

```zsh
plugins=(... zsh-codex-mode)
```

### Manually

```sh
git clone --depth 1 https://github.com/gaoyifan/zsh-codex-mode ~/.zsh/zsh-codex-mode
```

Then source the plugin from `.zshrc`:

```zsh
source ~/.zsh/zsh-codex-mode/zsh-codex-mode.plugin.zsh
```

## Configure

Set these variables before loading the plugin:

| Variable | Default | Description |
| --- | --- | --- |
| `ZSH_CODEX_MODE_MODEL` | `""` | Model name. Empty inherits the Codex setting. |
| `ZSH_CODEX_MODE_REASONING_EFFORT` | `""` | Reasoning effort. Empty inherits the Codex setting. |
| `ZSH_CODEX_MODE_PROMPT` | `✨ ` | Prompt shown in Codex mode, used verbatim including spacing. |
| `ZSH_CODEX_MODE_SANDBOX` | `""` | Sandbox policy: `read-only`, `workspace-write`, or `danger-full-access`. Empty inherits the Codex setting. |
| `ZSH_CODEX_MODE_APPROVAL_POLICY` | `""` | Approval policy. Empty inherits the Codex setting. |
| `ZSH_CODEX_MODE_KEY` | `^X` | Zsh key sequence used to toggle Codex mode. Empty disables the automatic binding. |
| `ZSH_CODEX_MODE_MCP` | `inherit` | Set to `disabled` to disable MCP servers. |
| `ZSH_CODEX_MODE_ACTIVITY_MAX_LENGTH` | `100` | Positive maximum length for command and path previews. |
| `ZSH_CODEX_MODE_SHOW_ACTIVITY` | `1` | Set to `0` to hide tool activity hints. |

Sandbox, approval, model, reasoning effort, and MCP behavior inherit your Codex configuration by default.

## Use

| Key | Action |
| --- | --- |
| <kbd>Ctrl</kbd>+<kbd>X</kbd> | Enter or leave Codex mode |
| <kbd>Ctrl</kbd>+<kbd>D</kbd> | Leave Codex mode |
| <kbd>Enter</kbd> | Send a message |

Codex mode uses a `✨` prompt by default. Replies stream directly into the terminal, and the conversation is discarded when you leave the mode.

Codex plugins are disabled. MCP servers inherit your Codex configuration by default.

Tool calls appear as one-line `›` activity hints. Shell command previews are collapsed to one line and limited to 100 characters by default; command output and reasoning remain hidden.

zsh-vi-mode, zsh-autosuggestions, and zsh-syntax-highlighting are supported but not required. Autosuggestions and syntax highlighting are paused while Codex mode is active.

## License

MIT

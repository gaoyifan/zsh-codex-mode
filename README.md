# zsh-codex-mode
<!-- Keep these links. Translations will automatically update with the README. -->
[Deutsch](https://zdoc.app/de/gaoyifan/zsh-codex-mode) | 
[English](https://zdoc.app/en/gaoyifan/zsh-codex-mode) | 
[Español](https://zdoc.app/es/gaoyifan/zsh-codex-mode) | 
[français](https://zdoc.app/fr/gaoyifan/zsh-codex-mode) | 
[日本語](https://zdoc.app/ja/gaoyifan/zsh-codex-mode) | 
[한국어](https://zdoc.app/ko/gaoyifan/zsh-codex-mode) | 
[Português](https://zdoc.app/pt/gaoyifan/zsh-codex-mode) | 
[Русский](https://zdoc.app/ru/gaoyifan/zsh-codex-mode) | 
[中文](https://zdoc.app/zh/gaoyifan/zsh-codex-mode)

Codex, right in your Zsh.

![Switch seamlessly between Zsh and Codex](assets/demo.gif)

Press <kbd>Ctrl</kbd>+<kbd>X</kbd> to enter Codex mode. Replies stream into the terminal, and messages keep their context when you switch back to the shell.

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
| `ZSH_CODEX_MODE_PROMPT` | `✨ ` | Prompt, including spacing |
| `ZSH_CODEX_MODE_INPUT_STYLE` | `fg=green` | ZLE input style; empty disables it |
| `ZSH_CODEX_MODE_KEY` | `^X` | Toggle key; empty disables the binding |
| `ZSH_CODEX_MODE_ACTIVITY_MAX_LENGTH` | `100` | Positive maximum command and path preview length |
| `ZSH_CODEX_MODE_SHOW_ACTIVITY` | `1` | `1` to show tool activity, `0` to hide it |
| `ZSH_CODEX_MODE_MODEL` | Codex setting | Model |
| `ZSH_CODEX_MODE_REASONING_EFFORT` | Codex setting | `none`, `minimal`, `low`, `medium`, `high`, `xhigh`, `max`, or `ultra`; model-dependent |
| `ZSH_CODEX_MODE_SANDBOX` | Codex setting | `read-only`, `workspace-write`, or `danger-full-access` |
| `ZSH_CODEX_MODE_APPROVAL_POLICY` | Codex setting | `untrusted`, `on-request`, or `never` |
| `ZSH_CODEX_MODE_MCP` | Codex setting | `inherit` or `disabled` |

## Use

| Key | Action |
| --- | --- |
| <kbd>Ctrl</kbd>+<kbd>X</kbd> | Switch between shell and Codex mode, preserving context |
| <kbd>Ctrl</kbd>+<kbd>D</kbd> | Leave Codex mode and discard its context |
| <kbd>Enter</kbd> | Send a message |

Tool calls appear as concise `›` hints; command output and reasoning stay hidden. Codex plugins are disabled.

zsh-autosuggestions and zsh-syntax-highlighting pause in Codex mode. zsh-vi-mode remains supported.

## License

MIT

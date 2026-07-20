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

```zsh
ZSH_CODEX_MODE_MODEL="" # Inherit your Codex configuration
ZSH_CODEX_MODE_REASONING_EFFORT="medium"
ZSH_CODEX_MODE_PROMPT="✨ "
ZSH_CODEX_MODE_SANDBOX="danger-full-access"
```

Set the model, reasoning effort, or sandbox to an empty string to inherit the corresponding Codex setting. Sandbox values are `read-only`, `workspace-write`, and `danger-full-access`. The prompt is used verbatim, including spacing.

The approval policy is always `never`. With the default `danger-full-access` sandbox, Codex can run commands, access the network, and read or modify any files available to your user without confirmation.

## Use

| Key | Action |
| --- | --- |
| <kbd>Ctrl</kbd>+<kbd>X</kbd> | Enter or leave Codex mode |
| <kbd>Enter</kbd> | Send a message |

Codex mode uses a `✨` prompt by default. Replies stream directly into the terminal, and the conversation is discarded when you leave the mode.

Codex plugins and MCP servers are disabled.

Tool calls appear as one-line `›` activity hints. Shell command previews are collapsed to one line and limited to 100 characters; command output and reasoning remain hidden.

zsh-vi-mode, zsh-autosuggestions, and zsh-syntax-highlighting are supported but not required. Autosuggestions and syntax highlighting are paused while Codex mode is active.

## License

MIT

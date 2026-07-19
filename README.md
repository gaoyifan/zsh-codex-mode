# zsh-codex-mode

Codex, right in your Zsh.

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

## Use

| Key | Action |
| --- | --- |
| <kbd>Ctrl</kbd>+<kbd>X</kbd> | Enter or leave Codex mode |
| <kbd>Enter</kbd> | Send a message |

Codex mode uses a `✨` prompt. Replies stream directly into the terminal, and the conversation is discarded when you leave the mode.

The plugin uses the model from your Codex configuration. Conversations use medium reasoning effort, no approval prompts, and a read-only sandbox. Codex plugins and MCP servers are disabled, and only answer text is shown.

zsh-vi-mode and zsh-autosuggestions are supported but not required.

## License

MIT

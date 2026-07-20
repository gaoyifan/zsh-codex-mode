# Demo

The demo replays `responses.jsonl` through a local app-server shim, so its output and timing do not depend on a Codex account or network access.

Install VHS, jq, Git, Node.js, and Zsh, then run:

```sh
demo/build.zsh
```

The script recreates `assets/demo.gif`. Edit `demo.tape` for presentation, `responses.jsonl` for Codex output and timing, and `fixture` or `changes.patch` for the task.

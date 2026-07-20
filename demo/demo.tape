Output "assets/demo.gif"

Set Shell "zsh"
Set FontSize 22
Set Width 1200
Set Height 560
Set Padding 22
Set WindowBar "Colorful"
Set WindowBarSize 38
Set Theme "Catppuccin Mocha"
Set TypingSpeed 35ms
Set Framerate 15

Hide
Type "exec zsh -df"
Enter
Sleep 500ms
Type "cd __DEMO_WORK__; ZSH_CODEX_MODE_ACTIVITY_MAX_LENGTH=72; PROMPT='%F{#89b4fa}~/demo %F{#a6e3a1}❯%f '; RPROMPT=''; source __DEMO_ROOT__/zsh-codex-mode.plugin.zsh; clear"
Enter
Sleep 500ms
Show
Sleep 500ms

Type "git status --short"
Enter
Sleep 1s

Ctrl+X
Sleep 300ms
Type "Commit these changes separately. Run tests first."
Enter
Sleep 6s

Ctrl+X
Sleep 500ms
Type "git log --oneline -2"
Enter
Sleep 3s

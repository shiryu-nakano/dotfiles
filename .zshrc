# プロンプトの色を設定
autoload -U colors && colors
PS1="%{$fg[green]%}%n@%m%{$reset_color%} %{$fg[cyan]%}%~%{$reset_color%} %# "


function ghq-fzf() {
  local src=$(ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")
  if [ -n "$src" ]; then
    BUFFER="cd $(ghq root)/$src"
    zle accept-line
  fi
  zle -R -c
}
zle -N ghq-fzf
bindkey '^g' ghq-fzf

function ros2-fzf() {
  local src=$(find ~/ros2_ws/src -maxdepth 1 -mindepth 1 -type d | fzf --preview "if ls {}/README.* 1>/dev/null 2>&1; then bat --color=always --style=header,grid --line-range :80 {}/README.*; else echo 'No README found'; ls {}; fi")
  if [ -n "$src" ]; then
    BUFFER="cd $src"
    zle accept-line
  fi
  zle -R -c
}
zle -N ros2-fzf
bindkey '\es' ros2-fzf

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

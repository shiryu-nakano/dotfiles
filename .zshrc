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


# VPN接続用のショートカットコマンド
alias 1284="$HOME/ghq/github.com/shiryu-nakano/dotfiles/src/vpn_connect.sh"



# pyenv and vierutalenvY
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
if which pyenv > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

export DOTNET_ROOT="/opt/homebrew/opt/dotnet@8/libexec"
export PATH="/opt/homebrew/opt/dotnet@8/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"


eval "$(rbenv init - zsh)"


# 一橋大学VPN OTP取得 (単独呼び出し用)
vpn_otp_watch() {
  # 読み込み先をcredentialディレクトリに変更
  source ~/ghq/github.com/shiryu-nakano/dotfiles/credential/vpn_env
  
  local secret="$VPN_SECRET"
  local start=$(date +%s)
  local timeout=60  # 1分で自動終了

  while true; do
    local now=$(date +%s)
    local elapsed=$((now - start))
    if (( elapsed >= timeout )); then
      printf "\n1分経過したため自動終了しました\n"
      break
    fi

    local remaining=$((30 - now % 30))
    local code=$(oathtool --totp -b "$secret")
    echo "$code" | pbcopy
    printf "\rOTP: %s (自動コピー済) | 残り: %2d秒 | 終了まで: %3d秒 " "$code" "$remaining" "$((timeout - elapsed))"

    sleep 1
  done
}
alias vpnotp='vpn_otp_watch'

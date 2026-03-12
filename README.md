⏺ Ubuntu で dotfiles 環境を構築する

  macOS から Ubuntu へ開発環境を移植するための手順です。

  ---
  1. zsh のインストール

  # zsh をインストール
  sudo apt update
  sudo apt install zsh

  # デフォルトシェルを zsh に変更
  chsh -s $(which zsh)

  再ログインして zsh を有効化します。

  ---
  2. 基本ツールのインストール

  gh (GitHub CLI)

  # 公式リポジトリを追加
  ```
  (type -p wget >/dev/null || sudo apt install wget) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O$out
  https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
   \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture)
  signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg]
  https://cli.github.com/packages stable main" | sudo tee
  /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh

  # 認証
  gh auth login
  ```
  ghq
  ```
  # Go が必要
  sudo apt install golang-go

  # ghq をインストール
  go install github.com/x-motemen/ghq@latest

  # パスを通す（.zshrc に追記）
  echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.zshrc
  source ~/.zshrc
  ```
  fzf
  ```
  sudo apt install fzf

  bat（コードプレビュー用）

  sudo apt install bat

  # Ubuntu では batcat という名前になるので、エイリアスを作成
  mkdir -p ~/.local/bin
  ln -s /usr/bin/batcat ~/.local/bin/bat
  ```
  ---
  3. dotfiles を展開

  # リポジトリをクローン
  ghq get github.com/shiryu-nakano/dotfiles

  # dotfiles のパス
  DOTFILES="$(ghq root)/github.com/shiryu-nakano/dotfiles"

  シンボリックリンクを作成

  # .zshrc
  ln -sf $DOTFILES/.zshrc ~/.zshrc

  # .gitconfig
  ln -sf $DOTFILES/.gitconfig ~/.gitconfig

  # .config 以下
  mkdir -p ~/.config
  ln -sf $DOTFILES/.config/nvim ~/.config/nvim
  ln -sf $DOTFILES/.config/gh ~/.config/gh
  ln -sf $DOTFILES/.config/ghostty ~/.config/ghostty

  # スクリプト
  mkdir -p ~/.local/bin
  ln -sf $DOTFILES/.local/bin/nb-link ~/.local/bin/nb-link
  ln -sf $DOTFILES/.local/bin/nb-link-preview ~/.local/bin/nb-link-preview
  chmod +x ~/.local/bin/nb-link ~/.local/bin/nb-link-preview

  ---
  4. .zshrc の修正

  Ubuntu 用にパスを編集します。

  nvim ~/.zshrc

  削除または修正する行:
  # 削除: Homebrew 関連（Ubuntu では不要）
  export PATH="/opt/homebrew/opt/dotnet@8/bin:$PATH"
  export PATH="/opt/homebrew/bin:$PATH"

  # 削除: pyenv（必要なら別途インストール）
  if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
  if which pyenv > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

  追加する行:
  # Go のパス
  export PATH="$HOME/go/bin:$PATH"

  # .local/bin のパス（既にあれば不要）
  export PATH="$HOME/.local/bin:$PATH"

  ---
  5. Neovim のインストール

  # 最新版を使うため PPA を追加
  sudo add-apt-repository ppa:neovim-ppa/unstable
  sudo apt update
  sudo apt install neovim

  # 初回起動でプラグインが自動インストールされる
  nvim

  ---
  6. nb のインストール

  # nb をインストール
  sudo curl -L https://raw.github.com/xwmx/nb/master/nb -o /usr/local/bin/nb
  sudo chmod +x /usr/local/bin/nb

  # 補完スクリプト
  sudo curl -L https://raw.github.com/xwmx/nb/master/etc/nb-completion.zsh -o
  /usr/local/share/zsh/site-functions/_nb

  # .nbrc をリンク
  ln -sf $DOTFILES/.nbrc ~/.nbrc

  # プラグインをリンク
  mkdir -p ~/.nb/.plugins
  ln -sf $DOTFILES/.nb/.plugins/daily.nb-plugin ~/.nb/.plugins/daily.nb-plugin

  # .nbrc の NB_DIR を Ubuntu 用に編集
  nvim ~/.nbrc

  .nbrc を編集:
  export NB_DIR="/home/YOUR_USERNAME/CABiNET/nb/"

  ---
  7. Ghostty のインストール

  # Ghostty は Snap でインストール可能
  sudo snap install ghostty --classic

  注意: Ghostty が Snap にない場合は、公式サイトからビルドが必要です。
  https://ghostty.org/docs/install

  ---
  8. フォントのインストール

  # JetBrains Mono
  mkdir -p ~/.local/share/fonts
  cd ~/.local/share/fonts
  curl -fLo "JetBrains Mono Regular Nerd Font Complete.ttf" \
    https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
  unzip JetBrainsMono.zip
  rm JetBrainsMono.zip
  fc-cache -fv

  ---
  9. 動作確認

  # シェルを再読み込み
  source ~/.zshrc

  # ghq-fzf が動くか確認（Ctrl+G）
  # リポジトリ一覧が表示され、README がプレビューされれば成功

  ---
  まとめ
  ┌────────┬──────────────────────┐
  │ ツール │       コマンド       │
  ├────────┼──────────────────────┤
  │ zsh    │ chsh -s $(which zsh) │
  ├────────┼──────────────────────┤
  │ gh     │ gh auth login        │
  ├────────┼──────────────────────┤
  │ ghq    │ ghq get <repo>       │
  ├────────┼──────────────────────┤
  │ fzf    │ Ctrl+G で ghq-fzf    │
  ├────────┼──────────────────────┤
  │ nvim   │ nvim                 │
  ├────────┼──────────────────────┤
  │ nb     │ nb daily             │
  └────────┴──────────────────────┘

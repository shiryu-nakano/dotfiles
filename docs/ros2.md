# はじめに


ROS 2 で開発していると，`~/ros2_ws/src` 配下にパッケージがどんどん増えていきます．

```
~/ros2_ws/src/
├── arcanain_simulator/
├── my_robot_description/
├── nav_bringup/
├── perception_node/
├── sensor_driver/
└── ...
```

そして毎回こうなっていませんか？

```bash
$ cd ~/ros2_ws/src/arca<TAB>
# あれ，パッケージ名なんだっけ…
$ ls ~/ros2_ws/src/
# 一覧を見て確認してから…
$ cd ~/ros2_ws/src/arcanain_simulator/
```

パッケージ名の**正確な綴り**を覚えていないと補完も効かず，一度 `ls` を挟む羽目になります．20個，30個とパッケージが増えると，この小さな摩擦が地味にストレスです．

そこで，**`Alt+S` を押すだけで `~/ros2_ws/src` 配下のパッケージを `fzf` であいまい検索し，README をプレビューしながら選んで即 `cd` する**ショートカットを作りました．本記事ではその作り方と，自分の環境への導入方法を紹介します．

## デモ

`Alt+S` を押すとこんな画面が開きます（左にパッケージ一覧，右に README のプレビュー）：

```
┌────────────────────┬──────────────────────────────────┐
│ > arca             │  # arcanain_simulator            │
│   arcanain_simulator│                                 │
│   my_robot_desc... │  シミュレータのパッケージです．  │
│   nav_bringup      │                                  │
│   perception_node  │  ## Build                        │
│   ...              │  colcon build --packages-sele... │
└────────────────────┴──────────────────────────────────┘
```

- **あいまい検索**：`arca` と打つだけで `arcanain_simulator` が絞り込まれる
- **プレビュー**：README があれば `bat` でシンタックスハイライト付き表示
- **即 cd**：Enter で選択 → 自動的に `cd` してプロンプトに戻る

## 動作環境

- Ubuntu 22.04 / 24.04（macOS でも動きます）
- **zsh**（`bindkey` と `zle` を使うため，bash では動きません）
- ROS 2 のワークスペース（`~/ros2_ws/src` を想定．パスは後述の通りカスタマイズ可）

## 必要なツール

3つだけです．

| ツール | 役割 |
|--------|------|
| [fzf](https://github.com/junegunn/fzf) | あいまい検索のインタラクティブUI |
| [bat](https://github.com/sharkdp/bat) | README をシンタックスハイライト付きでプレビュー |
| find | ディレクトリ一覧取得（標準で入っています） |

### インストール

Ubuntu 24.04 なら apt で一発です：

```bash
sudo apt update
sudo apt install fzf bat
```

> Ubuntu では `bat` コマンドが名前衝突の都合で `batcat` としてインストールされるケースがあります．その場合は `ln -s /usr/bin/batcat ~/.local/bin/bat` でエイリアスを張るか，後述のコード中の `bat` を `batcat` に置き換えてください．

macOS なら Homebrew で：

```bash
brew install fzf bat
```

## 設定の追加

`~/.zshrc` に以下を追記します．

```bash
function ros2-fzf() {
  local src=$(find ~/ros2_ws/src -maxdepth 1 -mindepth 1 -type d | \
    fzf --preview "if ls {}/README.* 1>/dev/null 2>&1; then \
      bat --color=always --style=header,grid --line-range :80 {}/README.*; \
    else \
      echo 'No README found'; ls {}; \
    fi")
  if [ -n "$src" ]; then
    BUFFER="cd $src"
    zle accept-line
  fi
  zle -R -c
}
zle -N ros2-fzf
bindkey '\es' ros2-fzf
```

保存したら zsh を再起動するか：

```bash
source ~/.zshrc
```

これで `Alt+S` を押せば起動します．

## コードの解説

短い関数ですが，実は小さな工夫が詰まっているので解説します．

### 1. ワークスペース配下のパッケージを列挙

```bash
find ~/ros2_ws/src -maxdepth 1 -mindepth 1 -type d
```

- `-maxdepth 1 -mindepth 1`：`src` 直下のディレクトリだけを対象にする（子パッケージの中まで潜らない）
- `-type d`：ディレクトリに限定

### 2. fzf のプレビュー機能で README を表示

```bash
fzf --preview "if ls {}/README.* 1>/dev/null 2>&1; then
  bat --color=always --style=header,grid --line-range :80 {}/README.*
else
  echo 'No README found'; ls {}
fi"
```

- `{}` は fzf が現在ハイライトしている候補のパスに置き換えられる
- README（`.md`/`.rst`/`.txt` など）があれば `bat` で先頭80行を表示
- 無ければ `ls` でディレクトリの中身を表示

`bat --line-range :80` で冒頭だけに絞っているのは，巨大なREADMEでプレビュー描画が重くならないようにするためです．

### 3. 選択結果をプロンプトに流し込む

```bash
BUFFER="cd $src"
zle accept-line
```

ここが zsh らしい部分です．

- `BUFFER` は **現在入力中のコマンドライン**を表す zle（Zsh Line Editor）の変数
- `zle accept-line` で **Enter を押したかのように実行**

つまり「`cd` コマンドを自動で組み立て → 自動で実行」しています．`exec` や `eval` を使っていないので，**現在のシェルのディレクトリが正しく変わります**（サブシェル問題を回避）．

### 4. キーバインド

```bash
zle -N ros2-fzf        # 関数を zle ウィジェットとして登録
bindkey '\es' ros2-fzf  # Alt+S にバインド
```

`\es` は `Esc + s`，これがターミナルでは `Alt+S` として解釈されます．
`Ctrl+G` などお好みのキーに変えてもOKです（後述）．

## カスタマイズ例

### ワークスペースのパスを変える

複数ワークスペースを使い分けている人向け：

```bash
function ros2-fzf() {
  local workspaces=(~/ros2_ws/src ~/another_ws/src)
  local src=$(find "${workspaces[@]}" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | \
    fzf --preview "...")
  # 以下同じ
}
```

### 特定のディレクトリを除外

私は `.claude` などのツール用ディレクトリを除外しています：

```bash
find ~/ros2_ws/src -maxdepth 1 -mindepth 1 -type d ! -name '.claude'
```

### キーバインドを変える

| 書き方 | キー |
|--------|------|
| `bindkey '\es' ros2-fzf` | `Alt+S` |
| `bindkey '^r' ros2-fzf` | `Ctrl+R`（履歴検索と衝突注意） |
| `bindkey '^[r' ros2-fzf` | `Alt+R` |

### 同じ仕組みで他の用途にも

この関数は「**ディレクトリ一覧 → fzf → cd**」という汎用パターンなので，ほかの用途にも展開できます．私は [`ghq`](https://github.com/x-motemen/ghq) で管理している Git リポジトリ用にも同じパターンで作っています：

```bash
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
```

こちらは `Ctrl+G` で起動します．

## まとめ

- **`Alt+S` を押すだけ**で ROS 2 パッケージのディレクトリに飛べる
- README を見ながら選べるので，パッケージ名を完全に覚えていなくてOK
- 必要なのは `fzf` と `bat` だけ，zshrc に20行程度追加するだけで導入できる

ROS2の開発はパッケージ間を行き来する場面がとにかく多いです．実験走行中のトラブルシューティング時には複数のパッケージを確認する必要があり認知負荷によって体力が削られていきます．
このショートカットを入れてからターミナル作業の摩擦がかなり減りました．

同じ悩みを持っている方の参考になれば幸いです．もっと良いやり方があればコメントで教えてください！

## 参考

- [fzf 公式リポジトリ](https://github.com/junegunn/fzf)
- [bat 公式リポジトリ](https://github.com/sharkdp/bat)
- [zsh zle マニュアル](https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html)


# 謝辞
この取り組みは, GxP(グロースエクスパートナーズ)株式会社様のサポートを受けて実施しています. 貴重なアドバイスや, ロボットに必要な機材の支援をいただきました. 心より感謝申し上げます.

https://www.gxp.co.jp/

https://qiita.com/organizations/gxp


## Arcanain
Arcanainは，GxP(グロースエクスパートナーズ)株式会社様のサポートを受けて自律走行ロボットの開発をしています．大学生，大学院生を中心に，社会人も参加しています．
開発はソフトウェアのみならず，ロボット自体も手作りで開発しています．
東京都を中心に活動しているので，ご興味がありましたらコメントいただけるとありがたいです．

https://github.com/Arcanain

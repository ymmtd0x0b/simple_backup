## 概要

Windows標準のバックアップ機能が何故か動作しないので、その代替として作成したバックアッププログラムです。

入力元として指定したディレクトリの内容を出力先へコピーする機能のみを実装しています。(差分のみのバックアップやリストアする機能はありません)

バックアップしたデータは、出力先のディレクトリ内に「yyyy_mm_dd」の形式(実行日)で命名したサブディレクトリとして保存されます。

このプログラムはバックアップ後に自動でシャットダウンを行います。また、バックアップしたい間隔を１日、１週間、１ヶ月のいずれかで指定できます。指定した間隔に満たない日数でプログラムを実行した場合はバックアップを実行せず、シャットダウンを行います。

これにより、次にバックアップする日付を気にする必要がなく、必要以上に保存することを防げるため気軽にバックアップを実行できます。


## 保存元と保存先の設定方法

#### 1. simple_backup ディレクトリ内に.env ファイルを作成し、以下の内容を保存する

```sh
cd ~/***/simple_backup
touch .env
```

```
# .env
SOURCE      = "" # バックアップしたいディレクトリを指定する
DESTINATION = "" # バックアップを保存するディレクトリを指定する
INTERVAL    = "" # バックアップしたい間隔を指定する(オプション)
```

#### 2. バックアップに必要な「保存元」と「保存先」のパスとバックアップを実行したい間隔を.env に保存する

※ 保存元と保存先は絶対パスで表記してください
※ バックアップしたい間隔は「 Month、Week、Day 」から選んでください(指定しない場合は Month になります)

例：

```
# .env
SOURCE      = "/home/alice/hoge"
DESTINATION = "/media/alice/device/backup"
INTERVAL    = "Month"
```


## 使い方

### 実行方法

※ Rubyプログラムとして実行する場合は、必ず simple_backup ディレクトリへ移動してください。

```
# 各OS共通
# Rubyプログラムとして実行する場合
cd ~/***/simple_backup
ruby main.rb

# Linux
# セットアッププログラムを実行した場合は
# コマンド実行できます
simple_backup

# Windows
# セットアッププログラムを実行した場合は
# デスクトップ上のショートカットから実行できます
```

### 実行結果の確認

バックアップの実行後は simple_backup ディレクトリ内に log.txt が生成され、結果が記録されます。


## 導入

### ruby プログラムとして実行する場合 (各OS共通)

#### 1. 任意の場所で git clone する

```sh
cd ./hogehoge
git clone https://github.com/ymmtd0x0b/simple_backup.git
```

#### 2. gem をインストール

プログラムで使用する gem をインストールします。

```
# 事前に git clone したディレクトリへ移動
cd ~/bin/lib/simple_backup
bundle install
```

#### 3. コピー元とコピー先を設定する

[設定](https://github.com/ymmtd0x0b/simple_backup#コピー元とコピー先の設定方法)を参照


#### 4. Rubyプログラムとして main.rb を実行するとバックアップが行われる

```sh
cd ~/***/simple_backup
ruby main.rb
```

### コマンドとして実行したい場合 (Linux / Mac)

保存場所は任意のディレクトリで大丈夫です。

以下は `~/bin/lib` で保存することを想定していますが、別の場所に保存する場合はパスを読み替えてください。

#### 1. `~/bin/lib` に git clone する

```sh
# ホームに bin ディレクトリがない場合は作成しておく
mkdir -p ~/bin/lib

# git clone
cd ~/bin/lib
git clone https://github.com/ymmtd0x0b/simple_backup.git
```

#### 2. gem をインストール

プログラムで使用する gem をインストールします。

```
# 事前に git clone したディレクトリへ移動
cd ~/bin/lib/simple_backup
bundle install
```

### 3. セットアッププログラムを実行する

```sh
cd ~/bin/lib/simple_backup
ruby bin/setup.rb
```

#### 4. シェルスクリプトに実行権を付与する

```sh
cd ~/bin/lib/simple_backup/bin
chmod u+x simple_backup
```

#### 5. 環境変数を設定する

※自作コマンドを `~/bin` から実行できるように設定している場合は、この作業は不要です。

`.bash_profile` や `.profile`、`.bashrc` 等のファイルに下記を追記して環境変数を設定する。(自身の環境に合わせてください)

```
# simple_backup
if [ -d "$HOME/bin" ] ; then
  PATH="$PATH:$HOME/bin"
fi
```

#### 6. 設定を再読込みする

手順5で設定した内容を下記コマンドで反映させる。

```sh
# 手順4で追記したファイル名を指定する
source ~/.profile
```

#### 7. 保存元と保存先を設定する

[設定](https://github.com/ymmtd0x0b/simple_backup#保存元と保存先の設定方法)を参照

以降はターミナルにて `simple_backup` と入力して Enter するとバックアップを実行できます。


### バッチファイルとして実行したい場合 (Windows)

保存場所は任意のディレクトリで大丈夫です。

以下は `C:\Users\ユーザー名\Documents` で保存することを想定していますが、別の場所に保存する場合はパスを読み替えてください。

#### 1. `C:\Users\ユーザー名\Documents` に git clone する

```sh
# git clone
cd C:\Users\ユーザー名\Documents
git clone https://github.com/ymmtd0x0b/simple_backup.git
```

#### 2. gem をインストール

プログラムで使用する gem をインストールします。

```
# 事前に git clone したディレクトリへ移動
cd C:\Users\ユーザー名\Documents\simple_backup
bundle install
```

### 3. セットアッププログラムを実行する

```sh
cd C:\Users\ユーザー名\Documents\simple_backup
ruby bin\setup.rb
```

※ セットアッププログラムが上手く動作しない場合は、手動でバッチファイルのリンクをデスクトップ等の任意の場所に作成してください


#### 4. 保存元と保存先を設定する

[設定](https://github.com/ymmtd0x0b/simple_backup#保存元と保存先の設定方法)を参照

以降はデスクトップにある `simple_backup.bat` を起動させるとバックアップを実行できます。




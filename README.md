## 導入・使い方

### 1. git clone で任意の場所にダウンロード

### 2. .env ファイルを作成し、以下の内容を保存する

```
BACKUP_SRC = ""
BACKUP_DEST = ""
```

### 3. バックアップに必要な「保存元」と「保存先」のパスを調べ、.env に保存する
※ 絶対パスで表記してください

例：

```
# .env
BACKUP_SRC = "/home/alice/hoge" # バックアップの対象となるフォルダ
BACKUP_DEST = "/media/alice/device/backup" # バックアップを保存するフォルダ
```

### 4. main.rb を実行するとバックアップが行われる (log.txtに実行結果が記録されます)

```sh
# 事前に main.rb のあるフォルダへ移動する
$ ruby main.rb
```

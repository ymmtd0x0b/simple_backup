#!/bin/sh

# 実行ファイルパスから適切な位置に移動して main.rb を実行する
cd $(dirname $(realpath "$0"))
cd ..
ruby main.rb

echo '１分後にシャットダウンします...'
shutdown -h 1

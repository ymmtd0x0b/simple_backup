@echo off
rem 開発環境に合わせて、文字コードを UTF-8 として明示
chcp 65001 > null

rem プログラムを実行するのに適切なパスへ移動する
cd %~dp0
cd ..

rem バックアップの実行
ruby main.rb

rem シャットダウン
echo "１分後にシャットダウンします..."
shutdown /s /t 60

pause

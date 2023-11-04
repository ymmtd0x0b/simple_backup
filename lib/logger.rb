require 'json'
require 'date'

class Logger
  def initialize(path)
    @file = "#{path}/log.txt"
    @date = DateTime.now.strftime('%Y/%m/%d %H:%M')
  end

  def write_file(message)
    File.open(@file, 'a') do |log_file|
      log_file.puts message
    end
  end

  def success(path)
    write_file "#{@date} | success | バックアップの実行に成功しました ========> | #{path} |"
  end

  def skip
    write_file "#{@date} | skip    | 先月分のバックアップは既に保存済みです     |"
  end

  def fail
    write_file "#{@date} | fail    | バックアップの内容が一致しませんでした     |"
  end

  def error(path)
    case path
    when ENV['src']
      write_file "#{@date} | error   | バックアップ対象のフォルダが見つかりません | #{path} |"
    when ENV['dest']
      write_file "#{@date} | error   | バックアップ先のフォルダが見つかりません   | #{path} |"
    else
      write_file "#{@date} | error   | バックアップ先の容量が不足しています       |"
    end
  end
end

require 'json'
require 'date'

class Log
  STATUS = {
    success: '成功',
    fail:    '失敗',
    skip:    '中止'
  }
  CAUSE = {
    exist:        '先月分のバックアップは既に保存済みです',
    low_capacity: 'バックアップ先の容量が不足しています',
    mismatch:     'バックアップが不正確です',
  }

  def initialize(path)
    @path = "#{path}/log.txt"
  end

  def write(status:, cause: nil, dest: nil)
    date = DateTime.now.strftime('%Y/%m/%d %H:%M')
    template = [date, STATUS[status]]

    if cause.nil?
      template << dest
    else
      template << CAUSE[cause]
    end

    File.open(@path, 'a') do |log_file|
      log_file.puts template.join(' | ')
    end
  end
end

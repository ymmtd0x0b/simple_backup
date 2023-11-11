require './lib/backup'
require './lib/dotenv'
require './lib/logger'

def main
  include DOTENV
  DOTENV.load

  src  = ENV['SOURCE']
  dest = ENV['DESTINATION']
  interval = ENV['INTERVAL']

  logger = Logger.new(Dir.pwd)

  if !Dir.exist? src
    logger.error(src)
    exit
  end

  if !Dir.exist? dest
    logger.error(dest)
    exit
  end

  backup = Backup.new(src, dest, interval)

  if !backup.enough_capacity?
    logger.error
    exit
  end

  if !backup.enough_interval?
    logger.skip
    exit
  end

  backup.run_with_progress_bar

  if backup.success?
    logger.success(backup.path)
    puts 'バックアップに成功しました'
  else
    logger.fail
    backup.rollback
    puts 'バックアップに失敗しました'
    puts 'ログを確認してください'
  end
end

main

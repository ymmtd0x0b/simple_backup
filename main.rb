require './lib/backup'
require './lib/dotenv'
require './lib/logger'

def main
  include DOTENV
  DOTENV.load

  logger  = Logger.new(Dir.pwd)
  src  = ENV['src']
  dest = ENV['dest']

  if !Dir.exist? src
    logger.error(src)
    exit
  end

  if !Dir.exist? dest
    logger.error(dest)
    exit
  end

  backup = Backup.new(src, dest)

  if !backup.enough_capacity?
    logger.error
    exit
  end

  if backup.exist?
    logger.skip
    exit
  end

  backup.run_with_progress_bar

  if backup.success?
    logger.success(backup.dest_dir)
  else
    logger.fail
    backup.rollback
  end
end

main

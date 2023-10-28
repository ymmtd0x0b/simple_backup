require './lib/backup'
require './lib/log'
require './lib/dotenv'

def main
  include DOTENV
  DOTENV.load

  backup = Backup.new(ENV['backup_src'], ENV['backup_dest'])
  log = Log.new(Dir.pwd)

  if backup.exist?
    log.write(status: :skip, cause: :exist)
    exit
  end

  if backup.low_capacity?
    log.write(status: :skip, cause: :low_capacity)
    exit
  end

  backup.run

  if backup.success?
    log.write(status: :success)
  else
    log.write(status: :fail, cause: :mismatch)
    backup.rollback
  end
end

main

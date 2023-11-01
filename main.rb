require './lib/backup'
require './lib/dotenv'
require './lib/log'

def main
  include DOTENV
  DOTENV.load

  backup = Backup.new(ENV['source'], ENV['destination'])
  log = Log.new(Dir.pwd)

  if backup.exist?
    log.write(status: :skip, cause: :exist)
    exit
  end

  if !backup.enough_capacity?
    log.write(status: :skip, cause: :low_capacity)
    exit
  end

  backup.run_with_progress_bar

  if backup.success?
    log.write(status: :success, dest: backup.dest_dir)
  else
    log.write(status: :fail, cause: :mismatch)
    backup.rollback
  end
end

main

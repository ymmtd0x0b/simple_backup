require 'date'
require 'fileutils'
require 'sys/filesystem'

class Backup
  def initialize(src, dest)
    @source = src
    @destination = dest

    directory_name = end_of_last_month.strftime('%Y_%m_%d')
    @path = [@destination, directory_name].join('/')
  end

  def end_of_last_month
    today = Date.today
    Date.new(today.year, today.month, 1).prev_day
  end

  def exist?
    Dir.exist? @path
  end

  def low_capacity?
    storage = Sys::Filesystem.stat(@destination)
    backup_size = directory_size(@source)

    storage.bytes_available < backup_size
  end

  def run
    FileUtils.cp_r(@source, @path, preserve: true, dereference_root: false, verbose: true)
  end

  def directory_size(path)
    files = Dir.children(path)
    sum = 0

    files.each do |file|
      fstat = File.lstat("#{path}/#{file}")

      if fstat.directory?
        sum += fstat.size
        sum += directory_size("#{path}/#{file}")
      else
        sum += fstat.size
      end
    end

    sum
  end

  def success?
    source_size = directory_size(@source)
    destination_size = directory_size(@path)
    # 「バックアップ元」と「バックアップ先」のディレクトリサイズが
    # イコールならバックアップ成功とする
    source_size == destination_size
  end

  def rollback
    FileUtils.remove_entry_secure(@path)
  end

  private

  def read_config
    File.open('config.json', 'r') do |file|
      config = JSON.load(file)
      [
        config["path"]["backup_src"],
        config["path"]["backup_dest"]
      ]
    end
  end
end

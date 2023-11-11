require 'date'
require 'fileutils'
require 'sys/filesystem'
require 'progress_bar'

class Backup
  attr_reader :path

  def initialize(src, dest, interval)
    @src      = src
    @dest     = dest
    @interval = interval.downcase

    @path = [dest, backup_name].join('/')
  end

  def run
    FileUtils.mkdir @path
    FileUtils.cp_r(@src, @path, preserve: true, dereference_root: false)
  end

  def run_with_progress_bar
    progress_bar = setup_progress_bar

    FileUtils.mkdir @path
    copy_r(@src, @path, progress_bar)
    puts '' # プログレスバーの出力に改行がないので、ここに改行を追加
  end

  def enough_interval?
    interval =
      case @interval
      when 'day'
        1
      when 'week'
        7
      when 'month'
        days_per_month(last_backup_date)
      else
        # デフォルトは１ヶ月
        days_per_month(last_backup_date)
      end

    lapsed_days = (Date.today - last_backup_date).to_i
    lapsed_days >= interval
  end

  def enough_capacity?
    src_size  = directory_size(@src)
    dest_size = Sys::Filesystem.stat(@dest).bytes_available

    src_size < dest_size
  end

  def success?
    src_size    = directory_size(@src)
    backup_size = directory_size(@path)

    # 「バックアップ元」と「バックアップ先」のディレクトリサイズが
    # イコールならバックアップ成功とする
    src_size == backup_size
  end

  def rollback
    FileUtils.remove_entry_secure(@path) if Dir.exist? @path
  end

  private

  def backup_name
    Date.today.strftime('%Y_%m_%d')
  end

  def last_backup_date
    last_backup = Dir.children(@dest)
                     .filter { |file| File.stat("#{@dest}/#{file}").directory? }
                     .sort
                     .last

    date = last_backup.gsub(/_/, '-')
    Date.parse date
  end

  def days_per_month(date)
    next_month = date.next_month
    Date.new(next_month.year, next_month.month, 1).prev_day.day
  end

  def directory_size(path)
    sum = 0
    files = Dir.children(path)

    files.each do |file|
      file_path = [path, file].join('/')
      fstat = File.lstat(file_path)

      sum += fstat.size
      sum += directory_size(file_path) if fstat.directory?
    end

    sum
  end

  def setup_progress_bar
    sub_dirs = count_sub_dirs @src
    ProgressBar.new(sub_dirs, :bar, :percentage)
  end

  def count_sub_dirs(path)
    counter = 0
    files = Dir.children path
    files.each do |file|
      file_path = [path, file].join('/')
      fstat = File.lstat file_path

      if fstat.directory?
        counter += count_sub_dirs(file_path) + 1
      end
    end

    counter
  end

  def copy_r(src, dest, bar)
    files = Dir.children(src)

    files.each do |file|
      src_file = [src, file].join('/')
      fstat = File.lstat(src_file)

      if fstat.directory?
        path = [dest, file].join('/')
        Dir.mkdir path
        copy_r(src_file, path, bar)
      elsif fstat.symlink?
        FileUtils.cp_file(src_file, dest, preserve: true, dereference_root: false)
      else
        FileUtils.cp(src_file, dest, preserve: true)
      end

      # サブディレクトリ内のコピーが終了した後に
      # 親ディレクトリのメタデータを更新することで
      # 正しく反映される
      if fstat.directory?
        copy_metadata(src_file, path)
        bar.increment!
      end
    end
  end

  def copy_metadata(src, path)
    st = File.lstat(src)
    File.utime st.atime, st.mtime, path
    File.chown st.uid, st.gid, path
    File.chmod st.mode, path
  end
end

require 'date'
require 'fileutils'
require 'sys/filesystem'
require 'progress_bar'

class Backup
  attr_reader :dest_dir

  def initialize(src, dest)
    @src = src
    @dest = dest
    @dest_dir = [dest, backup_name].join('/')
  end

  def backup_name
    end_of_last_month.strftime('%Y_%m_%d')
  end

  def end_of_last_month
    today = Date.today
    Date.new(today.year, today.month, 1).prev_day
  end

  def exist?
    Dir.exist? @dest_dir
  end

  def enough_capacity?
    src_size = directory_size(@src)
    dest_size = Sys::Filesystem.stat(@dest).bytes_available

    src_size < dest_size
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

  def run
    FileUtils.mkdir @dest_dir
    FileUtils.cp_r(@src, @dest_dir, preserve: true, dereference_root: false)
  end

  def run_with_progress_bar
    progress_bar = setup_progress_bar

    FileUtils.mkdir @dest_dir
    copy_r(@src, @dest_dir, progress_bar)
    puts '' # プログレスバーに改行がないのでここで改行する
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
        dest_dir = [dest, file].join('/')
        Dir.mkdir dest_dir
        copy_r(src_file, dest_dir, bar)
      elsif fstat.symlink?
        FileUtils.cp_file(src_file, dest, preserve: true, dereference_root: false)
      else
        FileUtils.cp(src_file, dest, preserve: true)
      end

      # このタイミングでメタデータを更新しないと
      # サブディレクトリ内のファイルをコピーする際に
      # タイムスタンプが上書きされてしまう
      if fstat.directory?
        copy_metadata(src_file, dest_dir)
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

  def success?
    src_size = directory_size(@src)
    dest_size = directory_size(@dest_dir)
    # 「バックアップ元」と「バックアップ先」のディレクトリサイズが
    # イコールならバックアップ成功とする
    src_size == dest_size
  end

  def rollback
    FileUtils.remove_entry_secure(@dest_dir)
  end
end

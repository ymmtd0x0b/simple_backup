#!/usr/bin/env ruby

def main
  os = host_os

  if [:linux, :macosx].include? os
    setup_linux_and_macosx
  elsif os == :windows
    setup_windows
  else
    puts <<~TEXT
      このセットアッププログラムは
        ・Windows
        ・Linux
        ・MacOS
      のいずれかでのみ利用できます。

      それ以外の環境では手動で設定してください。
    TEXT
  end
end

def host_os
  case RbConfig::CONFIG['host_os']
  when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
    :windows
  when /darwin|mac os/
    :macosx
  when /linux/
    :linux
  when /solaris|bsd/
    :unix
  else
    :unknown
  end
end

def setup_linux_and_macosx
  bin_path = Dir.home + '/bin'
  if !Dir.exist? bin_path
    Dir.mkdir(bin_path, 0777)
  end

  old = __dir__ + '/simple_backup.sh'
  new = bin_path + '/simple_backup'
  File.symlink(old, new)
end

def setup_windows
  old = __dir__ + '/simple_backup.bat'
  new = Dir.home + '/Desktop'
  File.symlink(old, new)
end

main

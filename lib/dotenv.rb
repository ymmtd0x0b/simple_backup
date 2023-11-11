module DOTENV
  def load
    File.open('.env', 'r') do |f|
      f.readlines(chomp: true).each do |line|
        next if line.match? /^#/
        hash  = line.sub(/^([A-Z_]+).+/, '\1') # .env からハッシュを抽出
        data  = line.sub(/^.*"(.+)".*/, '\1') # .env から設定値を抽出
        ENV[hash] = data
      end
    end
  end
end

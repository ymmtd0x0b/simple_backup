module DOTENV
  def load
    File.open('.env', 'r') do |f|
      f.readlines(chomp: true).each do |line|
        hash  = line.sub(/^([A-Z_]+).+/, '\1') # .env からパスを抽出
        path = line.sub(/^.*"(.+)".*/, '\1') # .env からパスを抽出
        ENV[hash.downcase] = path
      end
    end
  end
end

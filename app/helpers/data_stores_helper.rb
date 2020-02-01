module DataStoresHelper

  def save_file(file)
    # To save the file & to check error
    file_path_name_name = File.expand_path(file)
    directory_name = File.dirname(file_path_name)
    # Raise an error when the directory doesn't exist in the system.
    error_check(file_path_name, directory_name)
    # Provide write read & write permission
    File.chmod(0777, file_path_name)
    @file = File.open(file_path_name, 'a+')
    @file_path_name = file_path_name
    file_content = @file.read
    @content = eval(file_content.gsub(':', '=>'))
    @content={} if @content.nil?
  end

  def error_check(file_path_name, dir_name)
    raise DataStore::Error, "Directory #{dir_name} does not exist" unless File.directory?("#{Rails.root}/#{file_path_name}")
    if File.exist?(file_path_name) && !(File.readable?("#{Rails.root}/#{file_path_name}") && File.writable?("#{Rails.root}/#{file_path_name}"))
      raise DataStore::Error, "File #{file_path_name} can't be readable & writable"      
    end
    FileUtils.rm_rf(Dir.glob("#{Rails.root}/#{file_path_name}")) if File.directory?("#{Rails.root}/#{file_path_name}")
  end

  def save_data(file_name)
    File.open(@file_path, 'w+') { |f| f.write(JSON.dump(@content)) }
  end

  def key_expired?(key)
    if @content.key?(key)
      ttl = @content[key][1]
      # To check Time-To-Live property has been set and expired for a key.
      if ttl != 0 && Time.parse(ttl) <= Time.now()
        @content.delete(key)
        save_data
      end
    end
  end

end
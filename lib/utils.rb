# other functionalities
module Utils
  def cache_file_has_expired?(options)
    options[:cache_file_name] = "#{Rails.root}/tmp/cache/#{url_to_filename(options[:url])}"
    check_expiration(options)
  end

  def check_expiration(options)
    if File.exist?(options[:cache_file_name])
      file_age(options) > (options[:expire_time] ||= 24.hours)
    else
      true
    end
  end

  def encode_to_utf8(str)
    cleaned = str.dup.force_encoding('UTF-8')
    cleaned.valid_encoding? ? cleaned : str.encode('UTF-8', 'Windows-1251')
  rescue EncodingError
    str.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').encode('utf-8')
  end

  def file_write(file_name, file_content)
    FileUtils.mkdir_p(file_name.gsub(/\/[^\/]+\z/, ''))
    File.open(file_name, 'w') do |file|
      file.write(file_content)
    end
  end

  def file_age(options)
    Time.now.getlocal - File.ctime(options[:cache_file_name])
  end

  def url_to_filename(url)
    Digest::MD5.hexdigest(url)
  end
end

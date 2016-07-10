require 'open-uri'
# Application Helper
module ApplicationHelper
  def url_to_filename(url)
    Digest::MD5.hexdigest(url)
  end

  def cache_file_has_expired?(cache_file_name, expire_time = 24.hours)
    if !File.exist?(cache_file_name)
      true
    else
      Time.now - File.ctime(cache_file_name) > expire_time
    end
  end

  def page_load(url, expire_time = 24.hours)
    cache_file_name = url_to_filename(url)
    if cache_file_has_expired?(cache_file_name, expire_time)
      file_content = URI(url).read
      file_write(cache_file_name, file_content)
    else
      file_content = File.read(cache_file_name)
    end
    file_content
  end

  private

  def file_write(file_name, file_content)
    File.open("#{Rails.root}/db/cache/#{file_name}", 'w') do |file|
      file.write(file_content)
    end
  end
end

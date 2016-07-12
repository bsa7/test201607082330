require 'net/http'
# Application Helper
module ApplicationHelper
  def url_to_filename(url)
    Digest::MD5.hexdigest(url)
  end

  def cache_file_has_expired?(options)
    has_expired = false
    options[:cache_file_name] = "#{Rails.root}/tmp/cache/#{url_to_filename(options[:url])}"
    if File.exist?(options[:cache_file_name])
      if Time.now.getlocal - File.ctime(options[:cache_file_name]) > options[:expire_time] ||= 24.hours
        has_expired = true
      end
    else
      has_expired = true
    end
    has_expired
  end

  def page_load(options)
    if options[:cache_enabled] && !cache_file_has_expired?(options)
      result = File.read(options[:cache_file_name])
    else
      options[:proxy_list] = Proxy.get_list(options[:thread_count] ||= 24)
      result = download_page_with_proxy(options)
      if result.present? && options[:cache_enabled]
        file_write(options[:cache_file_name], result)
      end
    end
    result
  end

  private

  def download_page_with_proxy(options)
    options[:contents] = Array.new(options[:proxy_list].length, nil)
    options[:proxy_list].empty? ? download_within_proxy(options) : download_parallel(options)
    options[:threads].each(&:join)
    Proxy.mark_all(options)
    options[:contents].reject(&:nil?).first
  end

  def download_parallel(options)
    options[:proxy_list].each_with_index do |ip_port, index|
      (options[:threads] ||= []) << Thread.new do
        options[:contents][index] = achieve(options) { download_page(options[:url], ip_port) }
        options[:contents][index] = nil if options[:contents][index] !~ options[:check_stamp] ||= /<title/
      end
    end
  end

  def download_within_proxy(options)
    (options[:threads] ||= []) << Thread.new do
      options[:contents] << achieve(options) do
        uri = URI(options[:url])
        encode_to_utf8(Net::HTTP.get(uri))
      end
    end
  end

  def achieve(options = {}, &block)
    Timeout.timeout(options[:read_timeout] ||= 4) { yield block }
  rescue
    nil
  end

  def download_page(url, ip_port)
    uri = URI(url)
    proxy = URI.parse("http://#{ip_port}")
    Net::HTTP.new(uri.host, nil, proxy.host, proxy.port).start do |http|
      encode_to_utf8(http.request(Net::HTTP::Get.new(uri.path)).body)
    end
  end

  def file_write(file_name, file_content)
    FileUtils.mkdir_p(file_name.gsub(%r{\/[^\/]+\z}, ''))
    File.open(file_name, 'w') do |file|
      file.write(file_content)
    end
  end

  def encode_to_utf8(str)
    cleaned = str.dup.force_encoding('UTF-8')
    cleaned.valid_encoding? ? cleaned : str.encode('UTF-8', 'Windows-1251')
  rescue EncodingError
    str.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').encode('utf-8')
  end
end

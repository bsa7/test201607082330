require 'net/http'
# Application Helper
module ApplicationHelper
  def url_to_filename(url)
    Digest::MD5.hexdigest(url)
  end

  def cache_file_has_expired?(options)
    options[:cache_file_name] = "#{Rails.root}/tmp/cache/#{url_to_filename(options[:url])}"
    check_expiration(options)
  end

  def page_load(options)
    if options[:cache_enabled] && !cache_file_has_expired?(options)
      File.read(options[:cache_file_name])
    else
      download_with_cache(options)
    end
  end

  private

  def check_expiration(options)
    if File.exist?(options[:cache_file_name])
      file_age(options) > (options[:expire_time] ||= 24.hours)
    else
      true
    end
  end

  def file_age(options)
    Time.now.getlocal - File.ctime(options[:cache_file_name])
  end

  def download_with_cache(options)
    result = achieve do
      options[:proxy_list] = Proxy.get_list(options[:thread_count] ||= 24)
      download_page_with_proxy(options)
    end
    if result.present? && options[:cache_enabled]
      file_write(options[:cache_file_name], result)
    end
    result
  end

  def download_page_with_proxy(options)
    options[:contents] = Array.new(options[:proxy_list].length, nil)
    initialize_contents(options)
    options[:threads].each(&:join)
    options[:contents].reject(&:nil?).first
  end

  def initialize_contents(options)
    options[:proxy_list].empty? ? download_within_proxy(options) : download_parallel(options)
  end

  def download_parallel(options)
    options[:proxy_list].each_with_index do |ip_port, index|
      (options[:threads] ||= []) << Thread.new do
        download_contents_element(options, ip_port, index)
      end
    end
  end

  def download_contents_element(options, ip_port, index)
    options[:contents][index] = with_timeout(options) { download_page(options[:url], ip_port) }
    options[:contents][index] = nil if options[:contents][index] !~ options[:check_stamp] ||= /<title/
  end

  def download_within_proxy(options)
    (options[:threads] ||= []) << Thread.new do
      create_download_thread_within_proxy(options)
    end
  end

  def create_download_thread_within_proxy(options)
    options[:contents] << with_timeout(options) do
      uri = URI(options[:url])
      encode_to_utf8(with_timeout(options) { Net::HTTP.get(uri) })
    end
  end

  def achieve(&block)
    result = nil
    33.times do
      result = yield block
      break if result
    end
    result
  end

  def with_timeout(options = {}, &block)
    Timeout.timeout(options[:read_timeout] ||= 4) { yield block }
  rescue
    nil
  end

  def download_page(url, ip_port)
    uri = URI(url)
    proxy = URI.parse("http://#{ip_port}")
    Net::HTTP.new(uri.host, nil, proxy.host, proxy.port).start do |http|
      download_from_path(uri, http)
    end
  end

  def download_from_path(uri, http)
    request = Net::HTTP::Get.new(uri.path)
    body = http.request(request).body
    encode_to_utf8(body)
  end

  def file_write(file_name, file_content)
    FileUtils.mkdir_p(file_name.gsub(/\/[^\/]+\z/, ''))
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

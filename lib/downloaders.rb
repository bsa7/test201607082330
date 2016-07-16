require 'net/http'
# download web pages with proxy and parallel
module Downloaders
  # This load web page to text variable. It can use proxies, multi threading, cache
  #
  # ==== Options
  #
  # * *required* +url+ - url of web page
  # * +check_stamp+ - regexp for check loaded page for right results
  # * +cache_enabled+ - true if you want use a cache of this page
  # * +expire_time+ - timelife of cache. 24.hours for example
  # * +proxy_disabled+ - disable use proxies if *true*
  #
  # ==== Example
  #
  # Illustrate the behaviour of this method
  #
  # * call *download_with_cache* method if cache is disabled or cache is obsolete
  def page_load(options)
    if options[:cache_enabled] && !cache_file_has_expired?(options)
      File.read(options[:cache_file_name])
    else
      download_with_cache(options)
    end
  end

  private

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
    options[:threads] = []
    initialize_contents(options)
    options[:threads].each(&:join)
    options[:contents].reject(&:nil?).first
  end

  def initialize_contents(options)
    if options[:proxy_disabled] || options[:proxy_list].empty?
      download_within_proxy(options)
    else
      download_parallel(options)
    end
  end

  def download_parallel(options)
    options[:proxy_list].each_with_index do |ip_port, index|
      options[:threads] << Thread.new do
        download_contents_element(options, ip_port, index)
      end
    end
  end

  def download_contents_element(options, ip_port, index)
    options[:contents][index] = with_timeout(options) { download_page(options[:url], ip_port) }
    options[:contents][index] = nil if options[:contents][index] !~ options[:check_stamp] ||= /<title/
  end

  def download_within_proxy(options)
    options[:threads] << Thread.new do
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
end

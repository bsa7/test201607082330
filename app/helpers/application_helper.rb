require 'net/http'
# Application Helper
module ApplicationHelper
  def url_to_filename(url)
    Digest::MD5.hexdigest(url)
  end

  def page_load(url, check_stamp = %r{<body}, thread_count = 24)
    result = nil
    proxy_list = Proxy.get_list(thread_count)
    3.times do
      result = download_page_with_proxy(url, proxy_list, thread_count, 1, check_stamp)
      break if result
    end
    result
  end

  private

  def download_page_with_proxy(url, proxy_list = [], thread_count = 8, read_timeout = 2, check_stamp = %r{<body})
    contents = Array.new(proxy_list.length, nil)
    threads = []
    if proxy_list.length < thread_count
      download_within_proxy(url, contents, threads)
    else
      download_parallel(url, proxy_list, check_stamp, read_timeout, contents, threads)
    end
    threads.each(&:join)
    contents.reject(&:nil?).first
  end

  def download_parallel(url, proxy_list, check_stamp, read_timeout, contents, threads)
    proxy_list.each_with_index do |ip_port, index|
      threads << Thread.new do
        contents[index] = download_with_timeout(read_timeout) do
          download_page(url, ip_port)
        end
        if contents[index] !~ check_stamp
          contents[index] = nil
        end
      end
    end
  end

  def download_within_proxy(url, contents, threads)
    threads << Thread.new do
      contents << download_with_timeout do
        Net::HTTP.get(URI(url))
      end
    end
  end

  def download_with_timeout(read_timeout = 1, &block)
    begin
      Timeout.timeout(read_timeout) do
        yield block
      end
    rescue
      nil
    end
  end

  def download_page(url, ip_port)
    uri = URI(url)
    proxy = URI.parse("http://#{ip_port}")
    Net::HTTP.new(uri, nil, proxy.host, proxy.port).start do |http|
      clean_content(Net::HTTP.get(uri))
    end
  end

  def file_write(file_name, file_content)
    File.open("#{Rails.root}/db/cache/#{file_name}", 'w') do |file|
      file.write(file_content)
    end
  end

  def clean_content(str)
    begin
      cleaned = str.dup.force_encoding('UTF-8')
      unless cleaned.valid_encoding?
        cleaned = str.encode('UTF-8', 'Windows-1251')
      end
      content = cleaned
    rescue EncodingError
      content = str.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').encode("utf-8")
    end
    content
  end
end

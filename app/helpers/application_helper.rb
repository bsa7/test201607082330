require 'net/http'
# Application Helper
module ApplicationHelper
  def url_to_filename(url)
    Digest::MD5.hexdigest(url)
  end

  def page_load(options)
    result = nil
    options[:proxy_list] = Proxy.get_list(options[:thread_count] ||= 24)
    3.times do
      result = download_page_with_proxy(options)
      break if result
    end
    result
  end

  private

  def download_page_with_proxy(options)
    options[:contents] = Array.new(options[:proxy_list].length, nil)
    options[:threads] = []
    if options[:proxy_list].length < options[:thread_count]
      download_within_proxy(options)
    else
      download_parallel(options)
    end
    options[:threads].each(&:join)
    options[:contents].reject(&:nil?).first
  end

  def download_parallel(options)
    options[:proxy_list].each_with_index do |ip_port, index|
      options[:threads] << Thread.new do
        options[:contents][index] = download_with_timeout(options) do
          download_page(options[:url], ip_port)
        end
        options[:contents][index] = nil if options[:contents][index] !~ options[:check_stamp] ||= /<title/
      end
    end
  end

  def download_within_proxy(options)
    options[:threads] << Thread.new do
      options[:contents] << download_with_timeout(options) do
        Net::HTTP.get(URI(options[:url]))
      end
    end
  end

  def download_with_timeout(options, &block)
    Timeout.timeout(options[:read_timeout] ||= 2) { yield block }
  rescue
    nil
  end

  def download_page(url, ip_port)
    uri = URI(url)
    proxy = URI.parse("http://#{ip_port}")
    Net::HTTP.new(uri, nil, proxy.host, proxy.port).start do
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
      content = str.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').encode('utf-8')
    end
    content
  end
end

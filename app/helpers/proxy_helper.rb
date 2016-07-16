include ApplicationHelper
# Proxy Helper
module ProxyHelper
  # This load array of uniq proxies
  #
  # ==== Attributes
  #
  # * This method no require attributes
  #
  # ==== Example
  #
  # Illustrate the behaviour of this method
  #
  # * call *load_proxy_index* method and
  def load_new_proxies
    txt_file_links = parse_proxy_list_links || []
    proxies = txt_file_links.map do |file_link|
      url = "http://webanetlabs.net#{file_link}"
      parse_proxy_list_text(page_load(url: url, check_stamp: /(\d+\.){3}\d+:\d+/))
    end
    proxies.flatten
  end

  private

  def load_proxy_index
    url = 'http://webanetlabs.net/publ/24'
    page_load(url: url, check_stamp: /webanet\.ucoz\.ru/, cache_enabled: true)
  end

  def parse_proxy_list_text(text)
    text&.scan(/^\d+\.\d+\.\d+\.\d+:\d+/)
  end

  def parse_proxy_list_links
    load_proxy_index&.scan(/\/freeproxy\/proxylist_at_[0-9\.]+.txt/)
  end
end

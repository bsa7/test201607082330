include ApplicationHelper
# Proxy Helper
module ProxyHelper
  def load_proxy_index
    url = 'http://webanetlabs.net/publ/24'
    page_load(url: url, check_stamp: /webanet\.ucoz\.ru/, cache_enabled: true)
  end

  def parse_proxy_list_links
    load_proxy_index&.scan(/\/freeproxy\/proxylist_at_[0-9\.]+.txt/)
  end

  def parse_proxy_list_text(text)
    text&.scan(/^\d+\.\d+\.\d+\.\d+:\d+/)
  end

  def load_new_proxies
    txt_file_links = parse_proxy_list_links || []
    proxies = txt_file_links.map do |file_link|
      url = "http://webanetlabs.net#{file_link}"
      parse_proxy_list_text(page_load(url: url, check_stamp: /(\d+\.){3}\d+:\d+/))
    end
    proxies.flatten
  end
end

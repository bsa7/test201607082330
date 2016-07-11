require 'rails_helper'
RSpec.describe ProxyHelper, type: :helper do
  describe '#load_proxy_index' do
    it 'load index with links to proxy list txt files' do
      expect(helper.load_proxy_index).to(match(/webanet.ucoz.ru/))
    end
  end

  describe '#parse_proxy_list_links' do
    it 'parse page for links to txt files' do
      links_text = helper.parse_proxy_list_links&.slice(1, 1)&.first
      expect(links_text).to match(%r{\/freeproxy\/proxylist_at_[0-9\.]+\.txt})
    end
  end

  describe '#parse_proxy_list_text' do
    it 'load list txtfile and return as array of ip:port' do
      links_text = helper.parse_proxy_list_links&.slice(1, 1)&.first
      txt_file = page_load(url: "http://webanetlabs.net#{links_text}")
      expect(helper.parse_proxy_list_text(txt_file).slice(3, 1).first).to match(/(\d+\.)\d+:\d+/)
    end
  end
end

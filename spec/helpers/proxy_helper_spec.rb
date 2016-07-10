require 'rails_helper'
RSpec.describe ProxyHelper, type: :helper do
  describe '#load_proxy_index' do
    it 'load index with links to proxy list txt files' do
      expect(helper.load_proxy_index).to match(/webanet.ucoz.ru/)
    end
  end

  describe '#parse_proxy_list_links' do
    it 'parse page for links to txt files' do
      page = File.read("#{Rails.root}/db/cache/2bcfdf4eed02392e2e13554c2dfe3f91")
      expect(helper.parse_proxy_list_links.slice(0, 3)).to match [
        '/freeproxy/proxylist_at_05.07.2016.txt',
        '/freeproxy/proxylist_at_30.06.2016.txt',
        '/freeproxy/proxylist_at_21.06.2016.txt'
      ]
    end
  end

  describe '#parse_proxy_list_text' do
    it 'load list txtfile and return as array of ip:port' do
      txt_file = File.read("#{Rails.root}/db/cache/5983209f920487e9b293f7fbc22848fd")
      expect(helper.parse_proxy_list_text(txt_file).slice(3, 3)).to match [
        '101.99.22.40:3128',
        '211.218.126.189:3128',
        '203.66.159.44:3128'
      ]
    end
  end
end

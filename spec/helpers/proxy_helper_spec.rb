require 'rails_helper'
RSpec.describe ProxyHelper, type: :helper do
  describe '#load_new_proxies' do
    it 'load list of proxies and return array of strings' do
      proxies = helper.load_new_proxies
      ip_port_regexp = /(\d+\.){3}\d+:\d+/
      expect(proxies.slice(3, 1).first).to match(ip_port_regexp)
    end
  end
end

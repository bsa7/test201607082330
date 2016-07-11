require 'rails_helper'

RSpec.describe Proxy, type: :model do
  describe '.get_list' do
    it 'should update list of proxies id proxies not found and return sample' do
      FactoryGirl.create(:proxy)
      Rails.logger.ap proxy: Proxy.first
      expect(Proxy.get_list(1).length).to match(1)
    end
  end

  describe '.mark_proxy_as_good' do
    it 'receive ip_port and mark it as good in proxies table' do
      proxy_ip_port = FactoryGirl.create(:proxy).ip_port
      Proxy.mark_proxy_as_good(proxy_ip_port)
      proxy = Proxy.first
      expect(proxy.total_attempts_count).to eq(1)
      expect(proxy.success_attempts_count).to eq(1)
    end
  end

  describe '.mark_proxy_as_bad' do
    it 'receive ip_port and mark it as bad in proxies table' do
      proxy_ip_port = FactoryGirl.create(:proxy).ip_port
      Proxy.mark_proxy_as_bad(proxy_ip_port)
      proxy = Proxy.first
      expect(proxy.total_attempts_count).to eq(1)
      expect(proxy.success_attempts_count).to eq(0)
    end
  end
end

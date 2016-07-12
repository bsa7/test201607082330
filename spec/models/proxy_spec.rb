require 'rails_helper'

RSpec.describe Proxy, type: :model do
  describe '.get_list' do
    it 'should update list of proxies id proxies not found and return sample' do
      FactoryGirl.create(:proxy)
      Rails.logger.ap proxy: Proxy.first
      expect(Proxy.get_list(1).length).to match(1)
    end
  end

  describe '.mark_as' do
    it 'receive ip_port and mark it as good in proxies table' do
      ip_port = FactoryGirl.create(:proxy).ip_port
      Proxy.mark_as(ip_port: ip_port, state: :good)
      proxy = Proxy.first
      expect(proxy.total_attempts_count).to eq(1)
      expect(proxy.success_attempts_count).to eq(1)
    end
  end

  describe '.mark_all' do
    it 'receive options and mark proxies as good or bad' do
      proxies = []
      4.times do
        proxies << FactoryGirl.create(:proxy).ip_port
      end
      Rails.logger.ap proxies: proxies
      Proxy.mark_all(proxy_list: proxies, contents: [nil, 'sample', nil, nil])
      [[1, 0], [1, 1], [1, 0], [1, 0]].each_with_index do |expectation, index|
        proxy = Proxy.find_by_ip_port(proxies[index])
        Rails.logger.ap proxy: proxy, expectation: expectation, index: index
        expect(proxy.total_attempts_count).to eq(expectation[0])
        expect(proxy.success_attempts_count).to eq(expectation[1])
      end
    end
  end
end

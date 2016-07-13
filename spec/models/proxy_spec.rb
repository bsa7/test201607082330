require 'rails_helper'

RSpec.describe Proxy, type: :model do
  describe '.get_list' do
    it 'should receive list of proxies' do
      expect(Proxy.get_list(10).length).to match(10)
    end
  end

  describe '.mark_as' do
    it 'receive ip_port and mark it as good or bad in proxies table' do
      proxy = Proxy.all.sample
      previous_success_attempts_count = proxy.success_attempts_count
      previous_total_attempts_count = proxy.total_attempts_count
      Proxy.mark_as(ip_port: proxy.ip_port, state: :good)
      proxy_updated = Proxy.find_by_ip_port(proxy.ip_port)
      expect(proxy_updated.total_attempts_count).to eq(previous_total_attempts_count + 1)
      expect(proxy_updated.success_attempts_count).to eq(previous_success_attempts_count + 1)
    end
  end

  describe '.mark_all' do
    it 'receive options and mark proxies as good or bad' do
      proxies = Proxy.get_list(4)
      proxy_records = Proxy.where(ip_port: proxies)
      contents = [nil, 'sample', nil, nil]
      expectations = proxy_records.each_with_index.map do |record, index|
        [
          record.total_attempts_count + 1,
          record.success_attempts_count + (contents[index] ? 1 : 0)
        ]
      end
      Rails.logger.ap proxies: proxies, proxy_records: proxy_records, expectations: expectations
      Proxy.mark_all(proxy_list: proxies, contents: contents)
      expectations.each_with_index do |expectation, index|
        proxy = Proxy.find_by_ip_port(proxies[index])
        expect(proxy.total_attempts_count).to eq(expectation[0])
        expect(proxy.success_attempts_count).to eq(expectation[1])
      end
    end
  end
end

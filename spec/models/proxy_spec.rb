require 'rails_helper'

RSpec.describe Proxy, type: :model do
  describe '.fetch_proxy_list' do
    it 'should update list of proxies id proxies not found and return sample' do
      expect(Proxy.fetch_proxy_list(2).length).to match(2)
    end
  end
end

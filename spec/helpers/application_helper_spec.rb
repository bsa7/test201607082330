require 'rails_helper'
RSpec.describe ApplicationHelper, type: :helper do
  describe '#cache_file_has_expired?' do
    it 'check if files are expired as a cache' do
      file_names = [
        "file_not_exist",
        "#{Rails.root}/config.ru",
        "#{Rails.root}/log/test.log"
      ]
      expire_test_results = file_names.map { |file_name| helper.cache_file_has_expired?(file_name, 1.hours) }
      expect(expire_test_results).to match([true, true, false])
    end
  end

  describe '#url_to_filename' do
    it 'given url and convert it to a filename' do
      url = 'http://webanetlabs.net/publ/24/freeproxy/proxylist_at_21.06.2016.txt'
      expected_file_name = 'b81ba8174bc6e42ddea55f7309f866f7'
      expect(helper.url_to_filename(url)).to match(expected_file_name)
    end
  end

  describe '#page_loader' do
    it 'load page from url within proxy and return string value' do
      url = 'http://stackoverflow.com/'
      expect(helper.page_load(url)).to match(/<title>Stack Overflow<\/title>/)
    end
  end
end

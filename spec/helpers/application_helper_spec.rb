require 'rails_helper'
RSpec.describe ApplicationHelper, type: :helper do
  describe '#url_to_filename' do
    it 'given url and convert it to a filename' do
      url = 'http://webanetlabs.net/publ/24/freeproxy/proxylist_at_21.06.2016.txt'
      expected_file_name = 'b81ba8174bc6e42ddea55f7309f866f7'
      expect(helper.url_to_filename(url)).to match(expected_file_name)
    end
  end

  describe '#page_load' do
    it 'load page from url and return string value' do
      url = 'http://stackoverflow.com'
      matcher = /<title>Stack Overflow<\/title>/
      expect(helper.page_load(url, matcher)).to match(matcher)
    end
  end
end

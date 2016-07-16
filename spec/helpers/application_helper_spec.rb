require 'rails_helper'
RSpec.describe ApplicationHelper, type: :helper do
  describe '#page_load' do
    it 'load page from url and return string value' do
      url = 'http://stackoverflow.com/'
      matcher = /<title>Stack Overflow<\/title>/
      expect(helper.page_load(url: url, check_stamp: matcher)).to match(matcher)
    end
  end
end

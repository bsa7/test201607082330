require 'rails_helper'

RSpec.describe ModelsHelper, type: :helper do
  describe '#set_model_data' do
    it 'will receive model page and parse spec list' do
      model_data = helper.set_model_data('Samsung', 'Galaxy On7 Pro')
      expect(model_data).to have_key(:img_src)
    end
  end
end

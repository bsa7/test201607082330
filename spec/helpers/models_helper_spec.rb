require 'rails_helper'

RSpec.describe ModelsHelper, type: :helper do
  describe '#set_model_list' do
    it 'load models list of brand from sources' do
      set_brand_list
      samsung_brand_link = @brand_list.select { |brand| brand[:name][/Samsung/] }.first
      set_model_list(samsung_brand_link[:name])
      samsung_models = @model_list
      samsung_model = samsung_models.first
      expect(samsung_model).to(have_key(:img_src))
    end
  end

  describe '#set_model_data' do
    it 'will receive model page and parse spec list' do
      model_data = helper.set_model_selected('Samsung', 'Galaxy On7 Pro')
      expect(model_data).to have_key(:img_src)
    end
  end
end

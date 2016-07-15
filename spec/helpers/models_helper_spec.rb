require 'rails_helper'

RSpec.describe ModelsHelper, type: :helper do
  describe '#load_model_list' do
    it 'load models list of brand from sources' do
      load_brand_list
      samsung_brand_link = @brand_list.select { |brand| brand[:name][/Samsung/] }.first
      load_model_list(samsung_brand_link[:name])
      samsung_models = @model_list
      samsung_model = samsung_models.first
      expect(samsung_model).to(have_key(:img_src))
    end
  end

  describe '#load_model_selected' do
    it 'will receive model page and parse spec list' do
      model_data = helper.load_model_selected('Samsung', 'Galaxy On7 Pro')
      expect(model_data).to have_key(:img_src)
    end
  end
end

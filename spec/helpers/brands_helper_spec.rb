require 'rails_helper'

RSpec.describe BrandsHelper, type: :helper do
  describe '#set_brand_list' do
    it 'load list of brands from sources' do
      set_brand_list
      samsung_brand = @brand_list.select { |brand| brand[:name][/Samsung/] }.first
      expect(samsung_brand[:name]).to(match('Samsung'))
    end
  end

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
end

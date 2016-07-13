require 'rails_helper'

RSpec.describe BrandsHelper, type: :helper do
  describe '#load_brands' do
    it 'load list of brands from sources' do
      samsung_brand = helper.load_brands.select { |brand| brand[:name][/Samsung/] }.first
      expect(samsung_brand[:name]).to(match('Samsung'))
    end
  end

  describe '#load_models' do
    it 'load models list of brand from sources' do
      samsung_brand = helper.load_brands.select { |brand| brand[:name][/Samsung/] }.first
      samsung_models = helper.load_models(samsung_brand)
      samsung_model = samsung_models.first
      expect(samsung_model).to(have_key(:img_src))
    end
  end
end

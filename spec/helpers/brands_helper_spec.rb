require 'rails_helper'
RSpec.describe BrandsHelper, type: :helper do
  describe '#load_brands' do
    it 'load list of brands from sources' do
      samsung_brand = helper.load_brands.select { |x| x[/Samsung/] }.first
      expect(samsung_brand).to(match('<a href=\"samsung-phones-9.php\">Samsung</a>'))
    end
  end
end

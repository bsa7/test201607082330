include BrandsHelper
# Brands controller
class BrandsController < ApplicationController
  def index
    @brand_list = load_brands
  end
end

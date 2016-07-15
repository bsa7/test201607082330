include BrandsHelper
# Brands controller
class BrandsController < ApplicationController
  before_action :load_brand_list, only: [:index]
  def index
  end
end

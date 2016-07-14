include BrandsHelper
# Brands controller
class BrandsController < ApplicationController
  before_action :set_brand_list, only: [:index, :show]
  before_action :set_model_list, only: [:show]
  def index
  end

  def show
  end
end

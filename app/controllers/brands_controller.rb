include BrandsHelper
# Brands controller
class BrandsController < ApplicationController
  before_action :load_brand_list, only: [:index]

  # This collect list of brands on all configured source sites
  #
  # ==== Parameters
  #
  # * this action no require attributes
  #
  # ==== Example
  #
  # Illustrate the behaviour of this action
  #
  # * +load_brand_list+ method called
  # * +@brand_list+ variable will be setted
  # * render +brands/index.html+ or +brands/index.json.jbuilder+ dependened format of request
  def index
  end
end

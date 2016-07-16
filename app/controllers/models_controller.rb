include BrandsHelper
include ModelsHelper
# Models controller
class ModelsController < ApplicationController
  before_action :load_model_list, only: [:index]
  before_action :load_model_selected, only: [:show]
  # This collect models list of selected brand on all configured source sites
  #
  # ==== Parameters
  #
  # * +:brand_id+ - string name of brand, *Samsung* for example
  #
  # ==== Example
  #
  # Illustrate the behaviour of this action
  #
  # * +load_brand_list+ method called
  def index
  end

  # This collect list of brands on all configured source sites
  #
  # ==== Parameters
  #
  # * +:brand_id+ - string name of brand, *Samsung* for example
  # * +:id+ - string name of model, *Galaxy J5 (2016)* for example
  #
  # ==== Example
  #
  # Illustrate the behaviour of this action
  #
  # * call +load_brand_list+ method if +@brand_list+ not defined
  # * call +load_model_list+ method if +@model_list+ not defined
  # * call +load_model_selected+ method and define @model_selected variable
  def show
  end
end

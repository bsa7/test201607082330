include BrandsHelper
include ModelsHelper
# Models controller
class ModelsController < ApplicationController
  before_action :set_model_list, only: [:index]
  before_action :set_model_selected, only: [:show]
  def index
  end

  def show
  end
end

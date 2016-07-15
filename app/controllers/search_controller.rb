include SearchHelper
# Search controller
class SearchController < ApplicationController
  def show
    search_models(params[:id])
    render 'models/index'
  end
end
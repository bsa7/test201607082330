include SearchHelper
# Search controller
class SearchController < ApplicationController
  # This collect models list with *text* inside name on all configured source sites
  #
  # ==== Parameters
  #
  # * +:id+ - string with text to search
  #
  # ==== Example
  #
  # Illustrate the behaviour of this action
  #
  # * call +search_models+ method to search models on all configured sites, define *@model_list* variable
  def show
    search_models(params[:id])
    render 'models/index'
  end
end

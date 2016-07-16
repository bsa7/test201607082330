include ApplicationHelper
include BrandsHelper
include ModelsHelper
# Proxy Helper
module SearchHelper
  # This load array of models, finded on configured sites by *text*
  #
  # ==== Attributes
  #
  # * *text* - html page from site which return search results
  #
  # ==== Example
  #
  # Illustrate the behaviour of this method
  #
  # * call *page_load* method for each configured site
  # * call *scan_page_for_model_links* method for each downloaded page - send request to configured site
  # and parse results for model links
  # return as array
  def search_models(text)
    model_list = []
    parser_settings[:parser_settings].each do |site_settings|
      page = page_load(url: "#{site_settings[:host]}#{site_settings[:search_path].gsub(/<text>/, text)}")
      model_list << scan_page_for_model_links(page, model_list, {}, site_settings)
    end
    @model_list = model_list
  end
end

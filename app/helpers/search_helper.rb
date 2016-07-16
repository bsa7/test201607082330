include ApplicationHelper
include BrandsHelper
include ModelsHelper
# Proxy Helper
module SearchHelper
  def search_models(text)
    model_list = []
    parser_settings[:parser_settings].each do |site_settings|
      page = page_load(url: "#{site_settings[:host]}#{site_settings[:search_path].gsub(/<text>/, text)}")
      model_list << scan_page_for_model_links(page, model_list, {}, site_settings)
    end
    @model_list = model_list
  end
end

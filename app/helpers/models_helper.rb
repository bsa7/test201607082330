require 'gsmarena/model_parser'
include Gsmarena
# Models Helper
module ModelsHelper
  def load_model_list(brand_name = params[:brand_id])
    load_brand_selected(brand_name)
    @model_list = load_models @brand_selected
  end

  def load_model_selected(brand_name = params[:brand_id], model_name = params[:id])
    model_selected = select_model(brand_name, model_name)
    model_page = load_model_page(model_name, model_selected)
    @model_selected = Gsmarena.load_model_for_gsmarena(model_page, model_selected)
  end

  def load_models(brand_link)
    model_list = []
    parser_settings[:parser_settings].each do |site_settings|
      download_all_brand_pages(brand_link, site_settings).each do |page|
        scan_page_for_model_links(page, model_list, brand_link, site_settings)
      end
    end
    model_list
  end

  def scan_page_for_model_links(page, model_list, brand_link, site_settings)
    page.scan(site_settings[:model_link_regexp]).each do |link|
      model_list << parse_model_link(link.first, brand_link, site_settings)
    end
  end

  private

  def load_model_page(model_name, model_selected)
    page_load(
      cache_enabled: true,
      check_stamp: Regexp.new(model_name),
      url: "#{model_selected[:host]}#{model_selected[:path]}"
    )
  end

  def select_model(brand_name, model_name)
    load_brand_selected(brand_name)
    load_model_list(brand_name)
    @model_list.select { |model_link| model_link[:name] == model_name }.first
  end

  def load_brand_selected(brand_name)
    load_brand_list unless @brand_list
    @brand_selected = @brand_list.select { |brand_link| brand_link[:name] == brand_name }.first
  end

  def download_all_brand_pages(brand_link, site_settings)
    brand_pages = download_first_brand_page(brand_link, site_settings)
    other_brand_page_links = brand_pages.first.scan(site_settings[:brand_other_page_link_regexp])
    proxies_bulk = Proxy.get_list(other_brand_page_links.length * 12)
    download_other_brand_pages(brand_pages, other_brand_page_links, site_settings, proxies_bulk)
    brand_pages
  end

  def download_first_brand_page(brand_link, site_settings)
    brand_pages = []
    url = "#{site_settings[:host]}#{brand_link[:path]}"
    brand_pages << page_load(url: url, check_stamp: site_settings[:brand_page_check_stamp_regexp])
  end

  def download_other_brand_pages(brand_pages, other_brand_page_links, site_settings, proxies_bulk)
    threads = []
    other_brand_page_links.each_with_index do |link, index|
      threads << Thread.new do
        brand_pages << page_load(brand_link_options(link, site_settings, proxies_bulk, index))
      end
    end
    threads.each(&:join)
  end

  def parse_model_link(link_html, brand_link, site_settings)
    parse_name_and_brand_name(link_html, brand_link, site_settings).merge(
      path: scan_for_all_matches(link_html, site_settings[:model_parse_link_href_regexp]),
      img_src: scan_for_all_matches(link_html, site_settings[:model_parse_link_img_src_regexp]),
      title: scan_for_all_matches(link_html, site_settings[:model_parse_link_title_regexp]),
      host: site_settings[:host]
    )
  end

  def parse_name_and_brand_name(link_html, brand_link, site_settings)
    model_name = [scan_for_all_matches(link_html, site_settings[:model_parse_link_name_regexp], 2)].flatten
    {
      brand_name: brand_link[:name] || model_name.first,
      name: model_name.second || model_name.first
    }
  end
end

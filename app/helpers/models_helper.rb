require 'gsmarena/model_parser'
include Gsmarena
# Models Helper
module ModelsHelper
  # This collect models list of selected brand on all configured source sites
  #
  # ==== Attributes
  #
  # * +:brand_name+ - string name of brand, *Samsung* for example
  #
  # ==== Example
  #
  # Illustrate the behaviour of this method
  #
  # * call +load_brand_selected+ method and @brand_selected variable are defined
  # * call +load_models+ method and @model_list variable will defined
  #    load_model_list('Samsung')
  def load_model_list(brand_name = params[:brand_id])
    load_brand_selected(brand_name)
    @model_list = load_models @brand_selected
  end

  # This select model from list model list of selected brand, load page with model info
  # and parse it to variable @model_selected
  #
  # ==== Attributes
  #
  # * +:brand_name+ - string name of brand, *Samsung* for example
  # * +:model_name+ - string name of model, *Galaxy On7 Pro* for example
  #
  # ==== Example
  #
  # Illustrate the behaviour of this method
  #
  # * call +select_model+ method and @brand_selected variable will defined
  # * call +load_model_page+ method and load page text
  # * call specific site model page parse method and parse data to @model_selected variable
  def load_model_selected(brand_name = params[:brand_id], model_name = params[:id])
    model_selected = select_model(brand_name, model_name)
    model_page = load_model_page(model_name, model_selected)
    @model_selected = Gsmarena.load_model_for_gsmarena(model_page, model_selected)
  end

  # This load model list of selected brand and return it
  #
  # ==== Attributes
  #
  # * +:brand_link+ - hash variable, with link parameters:
  # {host: 'http://www.gsmarena.com/', path: 'samsung-phones-9.php', name: 'Samsung'} for example
  #
  # ==== Example
  #
  # Illustrate the behaviour of this method
  #
  # * call +parser_settings+ method and for each configuration load brand page (specified by *name* param), and
  # parse all links to models of each brand. Array will be returned:
  #    [
  #      {
  #        path: 'http://www.gsmarena.com/samsung_galaxy_on7_pro-8140.php',
  #        img_src: 'http://cdn2.gsmarena.com/vv/bigpic/samsung-galaxy-on7-.jpg',
  #        title: 'Samsung Galaxy On7 Pro Android smartphone. Announced 2016...',
  #        host: 'http://www.gsmarena.com/'
  #      }, ...
  #    ]
  def load_models(brand_link)
    model_list = []
    parser_settings[:parser_settings].each do |site_settings|
      download_all_brand_pages(brand_link, site_settings).each do |page|
        scan_page_for_model_links(page, model_list, brand_link, site_settings)
      end
    end
    model_list
  end

  # This parse links to model pages from brand page content
  #
  # ==== Attributes
  #
  # * +page+ - text with html of brand page
  # * +model_list+ - list of models
  # * +brand_link+ - link hash of selected brand (with *name* parameter as 'Samsung', for example)
  # * +site_settings+ - hash with configuration for specific site
  #
  # ==== Example
  #
  # Illustrate the behaviour of this method
  #
  # * call +parse_model_link+ for each model link on brand page and add it to returned array
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

require 'json'
require 'yaml'

# Brands Helper
module BrandsHelper
  def set_brand_list
    @brand_list = load_brands
  end

  def set_model_list(brand_name = params[:id])
    brand_link = @brand_list.select { |brand_link| brand_link[:name] == brand_name }.first
    @model_list = load_models brand_link
  end

  private

  def load_brands
    brand_list = []
    parser_settings.each do |site_settings|
      collect_brands(site_settings, brand_list)
    end
    brand_list
  end

  def load_models(brand_link)
    model_list = []
    parser_settings.each do |site_settings|
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

  def brand_link_options(link, site_settings, proxies_bulk, index)
    {
      check_stamp: site_settings[:brand_page_check_stamp_regexp],
      url: brand_link_to_url(link, site_settings),
      proxy_list: proxies_bulk[slice_interval(index)]
    }
  end

  def brand_link_to_url(link, site_settings)
    "#{site_settings[:host]}#{parse_brand_link(link, site_settings)[:path]}"
  end

  def slice_interval(index)
    (index * 10)..((index + 1) * 10 - 1)
  end

  def parser_settings
    load_parser_settings.map do |site_settings|
      site_settings.each_key do |key|
        site_settings[key] = Regexp.new(site_settings[key]) if key[/_regexp$/]
      end
      site_settings
    end
  end

  def load_parser_settings
    file = File.read("#{Rails.root}/config/parser.yml")
    yaml_data = YAML.load(file).deep_symbolize_keys
    yaml_data[:parser_settings]
  end

  def collect_brands(site_settings, brand_list)
    stamp = site_settings[:host_check_stamp_regexp]
    brand_page = page_load(url: site_settings[:host], check_stamp: stamp, cache_enabled: true, expire_time: 24.hours)
    return unless brand_page
    brand_page.scan(site_settings[:brand_page_link_regexp]).each do |brand_link|
      brand_list << parse_brand_link(brand_link, site_settings)
    end
  end

  def parse_brand_link(link_html, site_settings)
    {
      name: scan_for_all_matches(link_html, site_settings[:brand_parse_link_name_regexp]),
      path: scan_for_all_matches(link_html, site_settings[:brand_parse_link_href_regexp]),
      host: site_settings[:host]
    }
  end

  def parse_model_link(link_html, brand_link, site_settings)
    {
      path: scan_for_all_matches(link_html, site_settings[:model_parse_link_href_regexp]),
      img_src: scan_for_all_matches(link_html, site_settings[:model_parse_link_img_src_regexp]),
      brand_name: brand_link[:name],
      name: scan_for_all_matches(link_html, site_settings[:model_parse_link_name_regexp]),
      title: scan_for_all_matches(link_html, site_settings[:model_parse_link_title_regexp]),
      host: site_settings[:host]
    }
  end

  def scan_for_all_matches(html, regexp)
    html.scan(regexp).flatten.first
  end
end

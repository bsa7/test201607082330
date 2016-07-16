require 'json'
require 'yaml'

# Brands Helper
module BrandsHelper
  # This collect models list of selected brand on all configured source sites
  #
  # ==== Attributes
  #
  # * this method require no attributes
  #
  # ==== Example
  #
  # Illustrate the behaviour of this action
  #
  # * +load_brands+ method called and variable *@brand_list* defined:
  #    [
  #      {
  #        name: 'Samsung',
  #        path: 'samsung-phones-9.php',
  #        host: 'http://www.gsmarena.com/'
  #      }
  #    ]
  def load_brand_list
    @brand_list = load_brands
  end

  private

  def load_brands
    brand_list = []
    parser_settings[:parser_settings].each do |site_settings|
      brand_list += collect_brands(site_settings)
    end
    brand_list
  end

  def brand_link_options(link, site_settings, proxies_bulk, index)
    {
      cache_enabled: true,
      expire_time: 4.hours,
      check_stamp: site_settings[:brand_page_check_stamp_regexp],
      url: brand_link_to_url(link, site_settings),
      proxy_list: proxies_bulk[slice_interval(index)]
    }
  end

  def brand_link_to_url(link, site_settings)
    "#{site_settings[:host]}#{parse_brand_link(link, site_settings)[:path]}"
  end

  def slice_interval(index = 0, length = 10)
    (index * length)..((index + 1) * length - 1)
  end

  def collect_brands(site_settings, brand_list = [])
    stamp = site_settings[:host_check_stamp_regexp]
    brand_page = page_load(url: site_settings[:host], check_stamp: stamp, cache_enabled: true, expire_time: 24.hours)
    return unless brand_page
    brand_page.scan(site_settings[:brand_page_link_regexp]).each do |brand_link|
      brand_list << parse_brand_link(brand_link, site_settings)
    end
    brand_list
  end

  def parse_brand_link(link_html, site_settings)
    {
      name: scan_for_all_matches(link_html, site_settings[:brand_parse_link_name_regexp]),
      path: scan_for_all_matches(link_html, site_settings[:brand_parse_link_href_regexp]),
      host: site_settings[:host]
    }
  end
end

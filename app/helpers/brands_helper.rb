# Brands Helper
module BrandsHelper
  def load_brands
    brand_list = []
    parser_settings.each do |site_settings|
      collect_brands(site_settings, brand_list)
    end
    brand_list
  end

  private

  def collect_brands(site_settings, brand_list)
    brand_page = page_load(url: site_settings[:host], check_stamp: site_settings[:host_check_stamp])
    return unless brand_page
    site_settings[:brand_page_link_regexp].each do |brand_page_link_regexp|
      brand_page.scan(brand_page_link_regexp).each do |brand_link|
        brand_list << brand_link
      end
    end
  end

  def parser_settings
    [
      {
        host: 'http://www.gsmarena.com/',
        host_check_stamp: /GSMArena\.com/,
        brand_page_link_regexp: [%r{<a[^<]+?-\d+\.php\">[^<]+?<\/a>}, %r{<a[^<]+-p\d+\.php\">\d+<\/a>}],
        model_page_link_regexp: %r{<a href=\"[^<]+\.php\">.+?<\/a>}
      }
    ]
  end
end

# Models Helper
module ModelsHelper
  def set_model_list(brand_name = params[:brand_id])
    set_brand_selected(brand_name)
    @model_list = load_models @brand_selected
  end

  def set_model_selected(brand_name = params[:brand_id], model_name = params[:id])
    set_brand_selected(brand_name)
    set_model_list(brand_name)
    @model_selected = @model_list.select { |model_link| model_link[:name] == model_name }.first
    url = "#{@model_selected[:host]}#{@model_selected[:path]}"
    model_page = page_load(url: url, check_stamp: Regexp.new(model_name), cache_enabled: true)
    specs_list_block = model_page[/<div id=\"specs-list\">([\s\S]+?)<\/div>/]
    specs_sections = specs_list_block.scan(/<table[^>]+>([\s\S]+?)<\/table>/)
    @model_selected[:specs] = []
    empty_key_count = 0
    specs_sections.each do |specs_section|
      specs_key = specs_section.first.scan(/<th rowspan=[^>]+>([\s\S]+?)<\/th>/).flatten[0]
      specs_hash = {
        key: specs_key,
        value: []
      }
      specs_items = specs_section.first.scan(/<tr[^>]*?>([\s\S]+?)<\/tr>/).flatten
      specs_items.each do |specs_item|
        specs_item_pair = specs_item.scan(/<td[^>]*?>([\s\S]+?)<\/td>/)
                                    .flatten
                                    .map { |x| x.gsub(/<[^>]+>/, '').gsub(/&[a-z]+;/, '').gsub(/\r\n/, '') }
        next if specs_item_pair.length != 2
        specs_item_value = specs_item_pair[1].strip.gsub(/ {2,}/, ' ')
        if specs_item_pair[0].blank?
          specs_item_key = "empty_key_#{empty_key_count}"
          empty_key_count += 1
        else
          specs_item_key = specs_item_pair[0]
        end
        specs_hash[:value] << {
          key: specs_item_key,
          value: specs_item_value
        }
      end
      @model_selected[:specs] << specs_hash
    end
    @model_selected
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

  def set_brand_selected(brand_name)
    set_brand_list unless @brand_list
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
    name = scan_for_all_matches(link_html, site_settings[:model_parse_link_name_regexp])
    {
      path: scan_for_all_matches(link_html, site_settings[:model_parse_link_href_regexp]),
      img_src: scan_for_all_matches(link_html, site_settings[:model_parse_link_img_src_regexp]),
      brand_name: brand_link[:name],
      name: name,
      name_escaped: URI.escape(name, '. '),
      title: scan_for_all_matches(link_html, site_settings[:model_parse_link_title_regexp]),
      host: site_settings[:host]
    }
  end
end

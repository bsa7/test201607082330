# specific gsmarena model page parser
module Gsmarena
  # This specific only for 'http://www.gsmarena.com/' site parser.
  #
  # ==== Attributes
  #
  # * +model_page+ - text with html of model
  # * +model_selected+ - hash with selected model
  #
  # ==== Example
  #
  # Illustrate the behaviour of this method
  #
  # * scan page with regexp for blocks of specs, 'Network', 'Display' and so on.
  # * scan each block with specs for specific block specs: Technology -> GSM / HSPA / LTE, GPRS Yes and so on
  # * retrun hash with next structure
  #    {
  #      specs: [
  #        key: :specs_section_1,
  #        value: [
  #          {
  #            key: specs_item_1,
  #            value: specs_item_value1
  #          }, ...
  #        ], ...
  #      ]
  #    }
  def load_model_for_gsmarena(model_page, model_selected)
    specs_list_block = model_page[/<div id=\"specs-list\">([\s\S]+?)<\/div>/]
    specs_sections = specs_list_block.scan(/<table[^>]+>([\s\S]+?)<\/table>/)
    model_selected[:specs] = []
    specs_sections.each do |specs_section|
      model_selected[:specs] << parse_specs_section(specs_section.first)
    end
    model_selected
  end

  private

  def parse_specs_section(specs_section)
    specs_key = specs_section.scan(/<th rowspan=[^>]+>([\s\S]+?)<\/th>/).flatten[0]
    specs_hash = { key: specs_key, value: [] }
    specs_items = specs_section.scan(/<tr[^>]*?>([\s\S]+?)<\/tr>/).flatten
    specs_items.each do |specs_item|
      specs_hash[:value] << parse_specs_item(specs_item)
    end
    specs_hash
  end
end

def parse_specs_item(specs_item)
  specs_item_pair = parse_specs_values(specs_item)
  if specs_item_pair.length == 2
    specs_item_key = specs_item_pair[0].blank? ? 'no_key' : specs_item_pair[0]
    {
      key: specs_item_key,
      value: specs_item_pair[1].strip.gsub(/ {2,}/, ' ')
    }
  else
    {}
  end
end

def parse_specs_values(specs_item)
  dirty_specs = specs_item.scan(/<td[^>]*?>([\s\S]+?)<\/td>/).flatten
  dirty_specs.map { |x| x.gsub(/<[^>]+>/, '').gsub(/&[a-z]+;/, '').gsub(/\r\n/, '') }
end

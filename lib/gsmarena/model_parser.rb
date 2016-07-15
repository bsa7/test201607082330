# specific gsmarena model page parser
module Gsmarena
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

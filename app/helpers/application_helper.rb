require 'utils'
include Utils
require 'downloaders'
include Downloaders
# Application Helper
module ApplicationHelper

  # Render handlebars template on server side
  #
  # ==== Attributes
  #
  # * +handlebars_template+ - Html text with handlebars markup
  # * +data_hash+ - Data for handlebars
  #
  # ==== Example
  #
  # Illustrate the behaviour of the method inside views template
  #
  #    - template_name = 'models/show.hamlbars'
  #    - compiled_template = compile_rails_template template_name
  #    = render_handlebars_template(compiled_template, model: @model_selected).html_safe
  def render_handlebars_template(handlebars_template, data_hash)
    template = Tilt['handlebars'].new { handlebars_template }
    data = RecursiveOpenStruct.new(data_hash, recurse_over_arrays: true)
    template.render(data)
  end

  # This compile Haml or Erb rails template to html text
  #
  # ==== Attributes
  #
  # * +template_file_name+ - file with *Haml* or *Erb* template
  #
  # ==== Example
  #
  # Illustrate the behaviour of the method inside views template
  #
  #    - template_name = 'models/show.hamlbars'
  #    - compiled_template = compile_rails_template template_name
  #
  def compile_rails_template(template_file_name)
    template_content = read_template_content(template_file_name)
    if template_file_name[/\.hbs\.erb\z/]
      compiled_rails_template = ERB.new(template_content).result
    elsif template_file_name[/\.hamlbars\z/]
      stub = ''
      compiled_rails_template = Haml::Engine.new(template_content).render(stub)
    end
    compiled_rails_template
  end

  # This compile Haml or Erb rails template to html text
  #
  # ==== Attributes
  #
  # * this method not required attributes
  #
  # ==== Example
  #
  # Method parse *config/parser.yml* settings file
  # For use:
  # * define parser.yml:
  #
  #    parser_settings:
  #      - host: 'http://www.gsmarena.com/'
  #        search_path: 'results.php3?sQuickSearch=yes&sName=<text>'
  #        host_check_stamp_regexp: 'GSMArena\.com'
  #        brand_page_link_regexp: '<a[^<]+?-\d+\.php\">[^<]+?<\/a>'
  #        brand_other_page_link_regexp: '<a[^<]+-p\d+\.php\">\d+<\/a>'
  # * parsed yml will be presented as Hash object:
  #
  #    parser_settings[:parser_settings] => {
  #      [
  #        host: 'http://www.gsmarena.com/',
  #        search_path: 'results.php3?sQuickSearch=yes&sName=<text>',
  #        host_check_stamp_regexp: 'GSMArena\.com',
  #        brand_page_link_regexp: '<a[^<]+?-\d+\.php\">[^<]+?<\/a>',
  #        brand_other_page_link_regexp: '<a[^<]+-p\d+\.php\">\d+<\/a>',
  #      ]
  #    }
  #
  # Remember: All keys which endings with *_regexp* will be converted from
  # yaml string ro Regexp
  #
  def parser_settings
    settings = load_parser_settings
    settings[:parser_settings].map do |site_settings|
      site_settings.each_key do |key|
        site_settings[key] = Regexp.new(site_settings[key]) if key[/_regexp$/]
      end
      site_settings
    end
    settings
  end

  private

  def load_parser_settings
    file = File.read("#{Rails.root}/config/parser.yml")
    yaml_data = YAML.load(file).deep_symbolize_keys
    yaml_data
  end

  def read_template_content(template_file_name)
    templates_path = 'app/assets/javascripts/templates/hamlbars'
    template_full_path = "#{Rails.root}/#{templates_path}/#{template_file_name}"
    File.read(template_full_path)
  end

  def scan_for_all_matches(html, regexp, count = 1)
    matches = html.scan(regexp).flatten
    count == 1 ? matches.first : matches[0..count - 1]
  end
end

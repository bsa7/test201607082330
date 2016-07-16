require 'utils'
include Utils
require 'downloaders'
include Downloaders
# Application Helper
module ApplicationHelper
  def render_handlebars_template(handlebars_template, data_hash)
    template = Tilt['handlebars'].new { handlebars_template }
    data = RecursiveOpenStruct.new(data_hash, recurse_over_arrays: true)
    template.render(data)
  end

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

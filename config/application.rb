require File.expand_path('../boot', __FILE__)
require 'rails/all'

Bundler.require(*Rails.groups)

module Test20160708
  # Rails app class
  class Application < Rails::Application
    config.i18n.default_locale = :ru
    config.i18n.load_path += Dir[
      Rails.root.join('config', 'locales', '**', '*.{rb,yml}')
    ]
  end
end

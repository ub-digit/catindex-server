require 'yaml'

# Read config files and store applicable values in APP_CONFIG constant
if File.exist?("#{Rails.root}/config/config.yml")
  main_config = YAML.load_file("#{Rails.root}/config/config.yml")
else
  main_config = {}
end
if Rails.env == 'test'
  main_config = YAML.load_file("#{Rails.root}/config/config.test.yml")
end
APP_CONFIG = main_config


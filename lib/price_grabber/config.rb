require 'yaml'

module PriceGrabber::Config
  @environment = ENV['RACK_ENV'] || 'development'

  BASE = Dir.pwd

  @@yaml = YAML.load_file(BASE + "/config/application.yml")[@environment]
  OBIS_ENTITY_URL = @@yaml["obis_common_url"].to_s
end
require 'rest_client'
require 'json'
require 'price_grabber/config'

module PriceGrabber::Common

  COMMON_URL = PriceGrabber::Config::OBIS_ENTITY_URL + '/obisentity/'
  SIMPLE_URL = PriceGrabber::Config::OBIS_ENTITY_URL + '/obissimple/'

  URL_FOR = {
    :simple => SIMPLE_URL,
    :full => COMMON_URL,
  }

  def self.url_for entity_type, interface=:simple
    URL_FOR[interface] + entity_type
  end

  def self.get entity_type, interface=:simple, &block
    entities = JSON.parse(RestClient.get(url_for(entity_type, interface)))

    if block_given?
      filtered_entities = yield entities
    end

    filtered_entities || entities
  end

  # def self.put entity, entity_type, interface=:simple
  #   if interface == :simple
  #     id_key = "id"
  #   elsif interface == :full
  #     id_key = "_id"
  #   end

  #   begin
  #     RestClient.put("#{url_for(entity_type, interface)}/#{entity[id_key]}", entity.to_json, :content_type => :json)
  #   rescue Exception => e
  #     puts e
  #     puts("ERROR:" + e.response.body)
  #     raise e
  #   end
  # end

  def self.logger message, data_source
    p message if data_source == Common
  end

end
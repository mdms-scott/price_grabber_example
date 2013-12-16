require 'simplecov'
SimpleCov.start

ENV['RACK_ENV'] = 'test'

class MockDataSource
  class Undefined; end

  attr_reader :result, :results

  def results
    @results
  end

  def initialize(entities)
    @entities = entities
    @result = Undefined
    @results = []
  end

  # def get(entity_type, interface=:simple)
  #   if block_given?
  #     return yield @entities[entity_type]
  #   end

  #   @entities[entity_type]
  # end

  def get(route, interface=:simple)
    case
    when route.match(/\A[a-z]+\z/)
      if block_given?
        return yield @entities[route]
      else
        return @entities[route]
      end
    when route.match(/\A[a-z]+[\/][a-zA-Z0-9]+\z/)
      entity_type = route.match(/\A[a-z]+/).to_s
      entity_id   = route.match(/[a-zA-Z0-9]+\z/).to_s
      return @entities[entity_type].detect {|x| x["id"] == entity_id}
    else raise ArgumentError, "Invalid route given to MockDataSource.get  \"#{route}\""
    end
  end

  def put(entity, entity_type, interface=:simple)
    @results << entity
    @result = entity
  end
end
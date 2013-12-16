require "price_grabber/version"
require 'rest_client'
require 'json'
require 'time'
require "price_grabber/config"
require "price_grabber/common"
require "price_grabber/business"

module PriceGrabber

  # Hash map for funding rates to percentages
  RATE_LOOKUP = {
    "full_rate"      => "full",
    "federal_rate"   => "federal",
    "corporate_rate" => "corporate",
    "other_rate"     => "other",
    "member_rate"    => "member"
  }

  # Retrieves the rate for the given service on the given project.
  # Should only be used in the instance that you are retrieving a single service's rate
  # rather than retrieving the rates for all the services on a service_request
  # or sub_service_request.
  # Returns the rate for the service, an integer number of cents.
  def self.get_service_rate service_id, project_id, data_source=PriceGrabber::Common
    begin
      # Get the service and project
      service = data_source.get("services/#{service_id}")
      project = data_source.get("projects/#{project_id}")

      # Get the organization
      organization = PriceGrabber.determine_organization(service, data_source)

      # Get the correct pricing_map
      pricing_map = PriceGrabber.find_pricing_map(service)

      # Get the correct pricing_setup
      pricing_setup = PriceGrabber.find_pricing_setup(organization)

      # Get the funding source of the project
      funding_source = PriceGrabber.determine_funding_source(project)

      # Compare funding source against rates mapping on pricing_setup
      selected_rate_type = PriceGrabber.determine_applicable_rate(pricing_setup, funding_source)

      # See if the rate is overriden, if it is, return that overridden value.
      # Also returns the full_rate when the full rate is specified.
      rate = PriceGrabber.determine_rate(pricing_map, pricing_setup, selected_rate_type)

      return rate
    rescue ArgumentError => e
      if e.message ==  "Organization has no pricing setups!" || e.message == "Organization has no current pricing setups!"
        return nil
      else
        raise e
      end
    end
  end

  # Retrieves all the rates for the services on a specific sub_service_request on a
  # specific service_request.
  # Should be used in the instance that you know you are retrieving all the prices for a
  # sub_service_request, for example in fulfillment.
  # Returns a hash of {:service_id => rate, :service_id => rate, ...}
  # where :service_id is the id of each service, and the rate is an integer number of cents.
  def self.get_ssr_rates service_request_id, sub_service_request_id, data_source=PriceGrabber::Common
    # Get the service_request, project, and the project's funding_source/potential_funding_source
    service_request = data_source.get("service_requests/#{service_request_id}")
    unless service_request["sub_service_requests"]["#{sub_service_request_id}"]
      raise ArgumentError, "No sub_service_request with id #{sub_service_request_id}"
    end
    project = data_source.get("projects/#{service_request["project_id"]}")
    funding_source = PriceGrabber.determine_funding_source(project)

    # Assemble the ssr_rates hash and return it
    PriceGrabber.assemble_ssr_rates_map(service_request, sub_service_request_id, funding_source, data_source)
  end

  # Retrieves all the ratess for the services on a given service_request.
  # Should be used in the instance that you know you are retrieving the pricing for an
  # entire service_request, for example in the review view.
  # Returns a hash of {:service_id => rate, :service_id => rate, ...}
  # where :service_id is the id of each service, and the rate is an integer number of cents
  def self.get_service_request_rates service_request_id, data_source=PriceGrabber::Common
    # Get the service_request, project, and the project's funding_source/potential_funding_source
    service_request = data_source.get("service_requests/#{service_request_id}")
    project = data_source.get("projects/#{service_request["project_id"]}")
    funding_source = PriceGrabber.determine_funding_source(project)

    # Get sub_service_request ids of the service_request
    sub_service_request_ids = service_request["sub_service_requests"].map {|k,v| k}

    # Initialize empty service_request rates_map
    service_request_rates = {}

    # Iterate over sub_service_request ids and asemble ssr_rates_maps
    sub_service_request_ids.each do |ssr_id|
      service_request_rates.merge!(PriceGrabber.assemble_ssr_rates_map(service_request, ssr_id, funding_source, data_source))
    end

    return service_request_rates
  end

  # Retrieves the correct pricing_map for a service based on the current date and the
  # pricing_map's display date.
  # Returns a pricing_map.
  def self.find_pricing_map service, date=nil
    if service["pricing_maps"] && !service["pricing_maps"].empty?
      current_date = date || Time.now.strftime("%F")
      pricing_maps = service["pricing_maps"]
      begin
        current_maps = pricing_maps.select {|x| Time.parse(x["display_date"]) <= Time.parse(current_date)}
      rescue TypeError
        raise TypeError, "Service's pricing maps have no display dates!"
      end
      if current_maps.empty?
        raise ArgumentError, "Service has no current pricing maps!"
      else
        pricing_map = current_maps.sort {|a,b| b["display_date"] <=> a["display_date"]}.first
      end

      return pricing_map
    else
      raise ArgumentError, "Service has no pricing maps!"
    end
  end

  # Retrieves the correct pricing_map for a service based on the current date and the
  # pricing_map's effective date.
  # Returns a pricing_map.
  def self.find_effective_pricing_map service, date=nil
    if service["pricing_maps"] && !service["pricing_maps"].empty?
      current_date = date || Time.now.strftime("%F")
      pricing_maps = service["pricing_maps"]
      current_maps = pricing_maps.select {|x| Time.parse(x["effective_date"]) <= Time.parse(current_date)}
      if current_maps.empty?
        raise ArgumentError, "Service has no current pricing maps!"
      else
        pricing_map = current_maps.sort {|a,b| b["effective_date"] <=> a["effective_date"]}.first
      end

      return pricing_map
    else
      raise ArgumentError, "Service has no pricing maps!"
    end
  end

  # Retrieves the correct pricing_setup for a service based on the current date and the
  # pricing_setup's display date.
  # Returns a pricing_setup.
  def self.find_pricing_setup organization, date=nil
    if organization["pricing_setups"] &&!organization["pricing_setups"].empty?
      current_date = date || Time.now.strftime("%F")
      pricing_setups = organization["pricing_setups"]
      current_setups = pricing_setups.select {|x| Time.parse(x["display_date"]) <= Time.parse(current_date)}
      if current_setups.empty?
        raise ArgumentError, "Organization has no current pricing setups!"
      else
        pricing_setup = current_setups.sort {|a,b| b["display_date"] <=> a["display_date"]}.first
      end
      
      return pricing_setup
    else
      raise ArgumentError, "Organization has no pricing setups!"
    end
  end

  # Retreives a hash with rates for a service at a particular date.
  # Returns a hash of rates:
  # {"full_rate"      => Integer,
  #  "federal_rate"   => Integer,
  #  "corporate_rate" => Integer,
  #  "other_rate"     => Integer,
  #  "member_rate"    => Integer}
  def self.rates_on_date service_id, date, data_source=PriceGrabber::Common
    begin
      # Get the service
      service = data_source.get("services/#{service_id}")

      # Get the service's pricing_map for the specified date
      pricing_map = PriceGrabber.find_pricing_map(service, date)

      # Get the organization
      organization = PriceGrabber.determine_organization(service, data_source)

      # Get the pricing_setup for the specified date
      pricing_setup = PriceGrabber.find_pricing_setup(organization, date)

      # Assemble the rates map for the specified date
      PriceGrabber.assemble_all_rates_map(pricing_map, pricing_setup)
    rescue ArgumentError => e
      # Should an organization lack a pricing_setup assemble the rates map with nil for the service rates
      if e.message ==  "Organization has no pricing setups!" || e.message == "Organization has no current pricing setups!" || e.message == "Service has no pricing maps!" || e.message == "Service has no current pricing maps!"
        {
          "full_rate" => pricing_map["full_rate"],
          "federal_rate" => nil,
          "corporate_rate" => nil,
          "other_rate" => nil,
          "member_rate" => nil
        }
      else
        raise e
      end
    end
  end

  # Retreives a hash with rates for a service (using info from organization) at a particular date and full_rate.
  # Returns a hash of rates:
  # {"federal_rate"   => Integer,
  #  "corporate_rate" => Integer,
  #  "other_rate"     => Integer,
  #  "member_rate"    => Integer}
  def self.rates_from_full full_rate, organization_id, date, data_source=PriceGrabber::Common
    begin
      # Get the organization
      org = data_source.get("entities/#{organization_id}")

      # Determine which organization has the pricing setup
      organization = PriceGrabber.find_pricing_setup_organization(org, data_source)

      # Get the pricing_setup for the specified date
      pricing_setup = PriceGrabber.find_pricing_setup(organization, date)

      # Assemble the rates map for the specified date
      PriceGrabber.assemble_rates_from_full(full_rate, pricing_setup)
    rescue ArgumentError => e
      # Should an organization lack a pricing_setup assemble the rates map with nil for the service rates
      if e.message ==  "Organization has no pricing setups!" || e.message == "Organization has no current pricing setups!" || e.message == "Service has no pricing maps!" || e.message == "Service has no current pricing maps!"
        {
          "federal_rate" => nil,
          "corporate_rate" => nil,
          "other_rate" => nil,
          "member_rate" => nil
        }
      else
        raise e
      end
    end
  end

  private

  # Determines the rate for a particular service.
  # Returns the rate as an interger number of cents.
  def self.determine_rate pricing_map, pricing_setup, selected_rate_type
    if pricing_map["#{selected_rate_type}"]
      return_rate = pricing_map["#{selected_rate_type}"]
    else
      return_rate = PriceGrabber.calculate_rate(pricing_map, pricing_setup, selected_rate_type)
    end

    return return_rate
  end

  # Calculate the rate for a particular service based on the percents
  # in the pricing setup.
  # Returns an integer number of cents.
  def self.calculate_rate pricing_map, pricing_setup, selected_rate_type
    # Find which percentage should be applied to the full_rate to get the correct rate
    applied_percentage = pricing_setup[PriceGrabber::RATE_LOOKUP["#{selected_rate_type}"]].to_f / 100.0

    if applied_percentage == 0.0
      applied_percentage = 1
    end

    # Apply that percentage to the full_rate
    return_rate = pricing_map["full_rate"].to_f * applied_percentage.to_f

    # Round the result
    return_rate = return_rate.round
  end

  # Calculate the rate for a particular service based on a provided full_rate
  # and the percents on the displayed pricing_setup.
  # Returns an interger number of cents.
  def self.calculate_off_full full_rate, pricing_setup, selected_rate_type
    # Find which percentage should be applied to the full_rate to get the correct rate
    applied_percentage = pricing_setup[PriceGrabber::RATE_LOOKUP["#{selected_rate_type}"]].to_f / 100.0

    if applied_percentage == 0.0
      applied_percentage = 1
    end

    # Apply that percentage to the full_rate
    return_rate = full_rate.to_f * applied_percentage.to_f

    # Round the result
    return_rate = return_rate.round
  end

  # Assembles the rates for all the services in a particular sub_service_request
  # Returns a hash of {:service_id => rate, :service_id => rate, ...}
  # where :service_id is the id of each service, and the rate is an integer number of cents.
  def self.assemble_ssr_rates_map service_request, sub_service_request_id, funding_source, data_source
    begin
      organization = PriceGrabber.determine_organization(service_request["sub_service_requests"]["#{sub_service_request_id}"], data_source)
      pricing_setup = PriceGrabber.find_pricing_setup(organization)
      selected_rate_type = PriceGrabber.determine_applicable_rate(pricing_setup, funding_source)

      # Collect the line_items that belong to the sub_service_request
      ssr_line_items = service_request["line_items"].select {|li| li["sub_service_request_id"] == sub_service_request_id}

      # Collect the service_ids for the line_items that belong to the sub_service_request
      service_ids = ssr_line_items.map {|li| li["service_id"]}

      # Initialize the empty ssr_rates_hash that will be returned at the completion of the method
      ssr_rates_hash = {}

      # Iterate over the service_ids and add their rate map to the ssr_rates_hash
      service_ids.each do |service_id|
        begin
          # Get the service and its current pricing_map
          service = data_source.get("services/#{service_id}")
          pricing_map = PriceGrabber.find_pricing_map(service)

          # Determine the rate for the service and add to the ssr_rates_hash
          rate = PriceGrabber.determine_rate(pricing_map, pricing_setup, selected_rate_type)
          ssr_rates_hash["#{service_id}"] = rate
        rescue ArgumentError => e
          # Should a service lack a pricing map, insert a nil for its rate
          if e.message == "Service has no pricing maps!" || e.message == "Service has no current pricing maps!"
            ssr_rates_hash["#{service_id}"] = nil
          else
            raise e
          end
        end
      end

      return ssr_rates_hash    
    # THIS RESCUE BLOCK IS UGLY AND NEEDS TO BE REFACTORED
    rescue ArgumentError => e
      # Should an organization lack a pricing_setup assemble the rates map with nil for the service rates
      if e.message ==  "Organization has no pricing setups!" || e.message == "Organization has no current pricing setups!" || e.message == "Service has no pricing maps!" || e.message == "Service has no current pricing maps!"
        ssr_line_items = service_request["line_items"].select {|li| li["sub_service_request_id"] == sub_service_request_id}

        # Collect the service_ids for the line_items that belong to the sub_service_request
        service_ids = ssr_line_items.map {|li| li["service_id"]}

        # Initialize the empty ssr_rates_hash that will be returned at the completion of the method
        ssr_rates_hash = {}

        # Iterate over the service_ids and add their rate to the ssr_rates_hash
        service_ids.each do |service_id|
          ssr_rates_hash["#{service_id}"] = nil
        end
          return ssr_rates_hash
      else
        raise e
      end
    end
  end

  # Determines whether the organization is a program or a core and return the correct one
  def self.determine_organization object, data_source
    organization = case
    when object["core_id"]
      PriceGrabber.find_pricing_setup_organization(data_source.get("cores/#{object["core_id"]}"), data_source)
    when object["program_id"]
      PriceGrabber.find_pricing_setup_organization(data_source.get("programs/#{object["program_id"]}"), data_source)
    end

    organization
  end

  # Determines the funding source of a project based on its funding status
  # Returns the value for the funding or potential funding source as a string
  def self.determine_funding_source project
    funding_source = case project["funding_status"]
    when "pending_funding" then project["potential_funding_source"]
    when "funded" then project["funding_source"]
    else raise ArgumentError, "PROJECT DOES NOT HAVE A FUNDING STATUS"
    end

    funding_source
  end

  # Determines the applicable rate that should be charged on a service based on
  # the funding source of the project and the rates hash of the pricing_setup
  # Returns a string of the rate type
  def self.determine_applicable_rate pricing_setup, funding_source
    if pricing_setup["rates"]
      selected_rate_type = pricing_setup["rates"]["#{funding_source}"]
    else
      raise ArgumentError, "PRICING SETUP DOES NOT HAVE A RATES MAP"
    end

    selected_rate_type
  end

  # Retrieves the organization at which the pricing_setup exists, based on a specified
  # organization.
  # Returns an organization hash (either an program or provider).
  def self.find_pricing_setup_organization organization, data_source
    if organization["pricing_setups"] && !organization["pricing_setups"].empty?
      return organization
    else
      if organization["program_id"]
        program = data_source.get("programs/#{organization['program_id']}")
        return PriceGrabber.find_pricing_setup_organization(program, data_source)
      elsif organization["provider_id"]
        provider = data_source.get("providers/#{organization['provider_id']}")
        return provider
      else
        raise ArgumentError, "NO PARENT ID FOUND ON ORGANIZATION"
      end
    end
  end

  # Assemble the calculated rates for a service based on a specific pricing_map
  # and pricing_setup.
  # Returns a hash of rates (as described in the rates_on_date method).
  def self.assemble_all_rates_map pricing_map, pricing_setup
    {
      "full_rate" => pricing_map["full_rate"],
      "federal_rate" => PriceGrabber.calculate_rate(pricing_map, pricing_setup, 'federal_rate'),
      "corporate_rate" => PriceGrabber.calculate_rate(pricing_map, pricing_setup, 'corporate_rate'),
      "other_rate" => PriceGrabber.calculate_rate(pricing_map, pricing_setup, 'other_rate'),
      "member_rate" => PriceGrabber.calculate_rate(pricing_map, pricing_setup, 'member_rate')
    }
  end

  # Assemble the calculated rates for a service based on a specific full_rate
  # and pricing_setup.
  # Returns a hash of rates (as described in the rates_on_date method).
  def self.assemble_rates_from_full full_rate, pricing_setup
    {
      "federal_rate" => PriceGrabber.calculate_off_full(full_rate, pricing_setup, 'federal_rate'),
      "corporate_rate" => PriceGrabber.calculate_off_full(full_rate, pricing_setup, 'corporate_rate'),
      "other_rate" => PriceGrabber.calculate_off_full(full_rate, pricing_setup, 'other_rate'),
      "member_rate" => PriceGrabber.calculate_off_full(full_rate, pricing_setup, 'member_rate')
    }
  end

end


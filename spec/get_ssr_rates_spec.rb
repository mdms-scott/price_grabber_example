require 'spec_helper'
require 'fixtures'
require 'price_grabber'

describe "Get sub-service-request service rates method" do

  context :success do

    context "all services have current pricing_maps and current pricing_setups" do

      it "should get a collection of rate maps for the services" do
        provider = Fixtures::PROVIDER
        program = Fixtures::PROGRAM.clone
        program.delete('pricing_setups')
        service = Fixtures::SERVICE.merge({"program_id" => program["id"]})
        service2 = Fixtures::SERVICE2.merge({"program_id" => program["id"]})
        service3 = Fixtures::SERVICE3.merge({"program_id" => program["id"]})
        service_request = Fixtures::BIG_SERVICE_REQUEST
        project = Fixtures::FUNDED_PROJECT.merge("funding_source" => "federal")

        PriceGrabber::Common.stub(:get).with('providers/ABC123').and_return(provider)
        PriceGrabber::Common.stub(:get).with('programs/DEF456').and_return(program)
        PriceGrabber::Common.stub(:get).with('services/111').and_return(service)
        PriceGrabber::Common.stub(:get).with('services/222').and_return(service2)
        PriceGrabber::Common.stub(:get).with('services/333').and_return(service3)
        PriceGrabber::Common.stub(:get).with('service_requests/SRBIG').and_return(service_request)
        PriceGrabber::Common.stub(:get).with('projects/5000').and_return(project)

        ret = PriceGrabber.get_ssr_rates(service_request["id"], "0003")
        ret.should eq(
          {"111" => 11111,
           "222" => 9135,
           "333" => 6490
          }
        )
      end

    end

  end

  context :failure do

    context "service with a current pricing_map and no current pricing_setup" do
      it "should return an empty rate_map" do
        provider = Fixtures::PROVIDER.clone
        provider.delete('pricing_setups')
        program = Fixtures::PROGRAM.clone
        program.delete('pricing_setups')
        service = Fixtures::SERVICE.merge({"program_id" => program["id"]})
        service2 = Fixtures::SERVICE2.merge({"program_id" => program["id"]})
        service3 = Fixtures::SERVICE3.merge({"program_id" => program["id"]})
        service_request = Fixtures::BIG_SERVICE_REQUEST
        project = Fixtures::FUNDED_PROJECT.merge("funding_source" => "federal")

        PriceGrabber::Common.stub(:get).with('providers/ABC123').and_return(provider)
        PriceGrabber::Common.stub(:get).with('programs/DEF456').and_return(program)
        PriceGrabber::Common.stub(:get).with('services/111').and_return(service)
        PriceGrabber::Common.stub(:get).with('services/222').and_return(service2)
        PriceGrabber::Common.stub(:get).with('services/333').and_return(service3)
        PriceGrabber::Common.stub(:get).with('service_requests/SRBIG').and_return(service_request)
        PriceGrabber::Common.stub(:get).with('projects/5000').and_return(project)

        ret = PriceGrabber.get_ssr_rates(service_request["id"], "0003")
        ret.should eq(
          {"111" => nil,
           "222" => nil,
           "333" => nil
          }
        )
      end
    end

    context "service with no current pricing_map" do

      context "has a current pricing_setup" do

        it "should return the ssr_rates_hash with the bad service as nil" do
          provider = Fixtures::PROVIDER
          program = Fixtures::PROGRAM.clone
          program.delete('pricing_setups')
          service = Fixtures::SERVICE.merge({"program_id" => program["id"]})
          service2 = Fixtures::SERVICE2.merge({"program_id" => program["id"]})
          service3 = Fixtures::SERVICE3.clone
          service3.merge({"program_id" => program["id"]})
          service3.delete("pricing_maps")
          service_request = Fixtures::BIG_SERVICE_REQUEST
          project = Fixtures::FUNDED_PROJECT.merge("funding_source" => "federal")

          PriceGrabber::Common.stub(:get).with('providers/ABC123').and_return(provider)
          PriceGrabber::Common.stub(:get).with('programs/DEF456').and_return(program)
          PriceGrabber::Common.stub(:get).with('services/111').and_return(service)
          PriceGrabber::Common.stub(:get).with('services/222').and_return(service2)
          PriceGrabber::Common.stub(:get).with('services/333').and_return(service3)
          PriceGrabber::Common.stub(:get).with('service_requests/SRBIG').and_return(service_request)
          PriceGrabber::Common.stub(:get).with('projects/5000').and_return(project)

          ret = PriceGrabber.get_ssr_rates(service_request["id"], "0003")
          ret.should eq(
            {"111" => 11111,
             "222" => 9135,
             "333" => nil
            }
          )
        end

      end

      context "has no current pricing_setup" do
        
        it "should return the nil'd out ssr_rates_map with the bad service as full nil" do
          provider = Fixtures::PROVIDER.clone
          provider.delete('pricing_setups')
          program = Fixtures::PROGRAM.clone
          program.delete('pricing_setups')
          service = Fixtures::SERVICE.merge({"program_id" => program["id"]})
          service2 = Fixtures::SERVICE2.merge({"program_id" => program["id"]})
          service3 = Fixtures::SERVICE3.clone
          service3.merge({"program_id" => program["id"]})
          service3.delete("pricing_maps")
          service_request = Fixtures::BIG_SERVICE_REQUEST
          project = Fixtures::FUNDED_PROJECT.merge("funding_source" => "federal")

          PriceGrabber::Common.stub(:get).with('providers/ABC123').and_return(provider)
          PriceGrabber::Common.stub(:get).with('programs/DEF456').and_return(program)
          PriceGrabber::Common.stub(:get).with('services/111').and_return(service)
          PriceGrabber::Common.stub(:get).with('services/222').and_return(service2)
          PriceGrabber::Common.stub(:get).with('services/333').and_return(service3)
          PriceGrabber::Common.stub(:get).with('service_requests/SRBIG').and_return(service_request)
          PriceGrabber::Common.stub(:get).with('projects/5000').and_return(project)

          ret = PriceGrabber.get_ssr_rates(service_request["id"], "0003")
          ret.should eq(
            {"111" => nil,
             "222" => nil,
             "333" => nil
            }
          )
        end

      end

    end

  end

end
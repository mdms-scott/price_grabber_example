require 'spec_helper'
require 'fixtures'
require 'price_grabber'

describe "Get service rate method" do

  context :success do

    context "service with a current pricing_map and a current pricing_setup" do

      context :funded_project do

        context :program_based_service do

          it "should return the rate when the pricing_setup is on the provider" do
            provider = Fixtures::PROVIDER
            program = Fixtures::PROGRAM.clone
            program.delete('pricing_setups')
            service = Fixtures::SERVICE.merge({"program_id" => program["id"]})
            project = Fixtures::FUNDED_PROJECT.merge("funding_source" => "federal")

            PriceGrabber::Common.stub(:get).with('providers/ABC123').and_return(provider)
            PriceGrabber::Common.stub(:get).with('programs/DEF456').and_return(program)
            PriceGrabber::Common.stub(:get).with('services/111').and_return(service)
            PriceGrabber::Common.stub(:get).with('projects/5000').and_return(project)


            ret = PriceGrabber.get_service_rate(service["id"], project["id"])
            ret.should eq(11111)
          end

          it "should return the rate when the pricing_setup is on the program" do
            provider = Fixtures::PROVIDER.clone
            provider.delete('pricing_setups')
            program = Fixtures::PROGRAM
            service = Fixtures::SERVICE.merge({"program_id" => program["id"]})
            project = Fixtures::FUNDED_PROJECT.merge("funding_source" => "foundation")

            PriceGrabber::Common.stub(:get).with('providers/ABC123').and_return(provider)
            PriceGrabber::Common.stub(:get).with('programs/DEF456').and_return(program)
            PriceGrabber::Common.stub(:get).with('services/111').and_return(service)
            PriceGrabber::Common.stub(:get).with('projects/5000').and_return(project)


            ret = PriceGrabber.get_service_rate(service["id"], project["id"])
            ret.should eq(41666)
          end

        end

        context :core_based_service do

          it "should return the rate when the pricing_setup is on the provider" do
            provider = Fixtures::PROVIDER
            program = Fixtures::PROGRAM.clone
            program.delete('pricing_setups')
            core = Fixtures::CORE
            service = Fixtures::SERVICE.merge({"core_id" => core["id"]})
            project = Fixtures::FUNDED_PROJECT.merge("funding_source" => "federal")

            PriceGrabber::Common.stub(:get).with('providers/ABC123').and_return(provider)
            PriceGrabber::Common.stub(:get).with('programs/DEF456').and_return(program)
            PriceGrabber::Common.stub(:get).with('cores/GHI789').and_return(core)
            PriceGrabber::Common.stub(:get).with('services/111').and_return(service)
            PriceGrabber::Common.stub(:get).with('projects/5000').and_return(project)


            ret = PriceGrabber.get_service_rate(service["id"], project["id"])
            ret.should eq(11111)
          end

        end

        context :different_funding_sources do

          before :each do
            @provider = Fixtures::PROVIDER
            @program = Fixtures::PROGRAM.clone
            @program.delete('pricing_setups')
            @service = Fixtures::SERVICE.merge({"program_id" => @program["id"]})
            PriceGrabber::Common.stub(:get).with('providers/ABC123').and_return(@provider)
            PriceGrabber::Common.stub(:get).with('programs/DEF456').and_return(@program)
            PriceGrabber::Common.stub(:get).with('services/111').and_return(@service)
          end

          it "should return the correct rate for a project with investigator funding" do
            project = Fixtures::FUNDED_PROJECT.merge("funding_source" => "investigator")
            PriceGrabber::Common.stub(:get).with('projects/5000').and_return(project)

            ret = PriceGrabber.get_service_rate(@service["id"], project["id"])
            ret.should eq(16667)
          end

          it "should return the correct rate for a project with college funding" do
            project = Fixtures::FUNDED_PROJECT.merge("funding_source" => "college")
            PriceGrabber::Common.stub(:get).with('projects/5000').and_return(project)

            ret = PriceGrabber.get_service_rate(@service["id"], project["id"])
            ret.should eq(55555)
          end

        end

      end

      context :pending_funding_project do

        it "should return the rate map for the service in question" do
          provider = Fixtures::PROVIDER
          program = Fixtures::PROGRAM.clone
          program.delete('pricing_setups')
          service = Fixtures::SERVICE.merge({"program_id" => program["id"]})
          project = Fixtures::PENDING_PROJECT.merge("potential_funding_source" => "federal")

          PriceGrabber::Common.stub(:get).with('providers/ABC123').and_return(provider)
          PriceGrabber::Common.stub(:get).with('programs/DEF456').and_return(program)
          PriceGrabber::Common.stub(:get).with('services/111').and_return(service)
          PriceGrabber::Common.stub(:get).with('projects/5001').and_return(project)


          ret = PriceGrabber.get_service_rate(service["id"], project["id"])
          ret.should eq(11111)
        end

      end

    end

    context "service with a current pricing_map and no current pricing_setup" do

      context "there is an overridden rate value for the rate in question" do

        it "should return the rate for the service" do
          provider = Fixtures::PROVIDER
          program = Fixtures::PROGRAM.clone
          program.delete('pricing_setups')
          service = Fixtures::SERVICE.merge({"program_id" => program["id"]})
          project = Fixtures::FUNDED_PROJECT.merge("funding_source" => "internal")

          PriceGrabber::Common.stub(:get).with('providers/ABC123').and_return(provider)
          PriceGrabber::Common.stub(:get).with('programs/DEF456').and_return(program)
          PriceGrabber::Common.stub(:get).with('services/111').and_return(service)
          PriceGrabber::Common.stub(:get).with('projects/5000').and_return(project)


          ret = PriceGrabber.get_service_rate(service["id"], project["id"])
          ret.should eq(43434)
        end

      end

    end

  end

  context :failure do

    context "service with a current pricing_map and no current pricing_setup" do

      context "there is no overridden rate value for the rate in question" do

        it "should return an empty rate" do
          provider = Fixtures::PROVIDER.clone
          provider.delete('pricing_setups')
          program = Fixtures::PROGRAM.clone
          program.delete('pricing_setups')
          service = Fixtures::SERVICE.merge({"program_id" => program["id"]})
          project = Fixtures::FUNDED_PROJECT.merge("funding_source" => "internal")

          PriceGrabber::Common.stub(:get).with('providers/ABC123').and_return(provider)
          PriceGrabber::Common.stub(:get).with('programs/DEF456').and_return(program)
          PriceGrabber::Common.stub(:get).with('services/111').and_return(service)
          PriceGrabber::Common.stub(:get).with('projects/5000').and_return(project)


          ret = PriceGrabber.get_service_rate(service["id"], project["id"])
          ret.should eq(nil)
        end

      end

    end

    context "service with no current pricing_map and a current pricing_setup" do

      it "should raise an exception" do
        provider = Fixtures::PROVIDER.clone
        provider.delete('pricing_setups')
        program = Fixtures::PROGRAM.clone
        program.delete('pricing_setups')
        service = Fixtures::SERVICE.clone
        service.merge({"program_id" => program["id"]})
        service.delete('pricing_maps')
        project = Fixtures::FUNDED_PROJECT.merge("funding_source" => "internal")

        PriceGrabber::Common.stub(:get).with('providers/ABC123').and_return(provider)
        PriceGrabber::Common.stub(:get).with('programs/DEF456').and_return(program)
        PriceGrabber::Common.stub(:get).with('services/111').and_return(service)
        PriceGrabber::Common.stub(:get).with('projects/5000').and_return(project)

        lambda { PriceGrabber.get_service_rate(service["id"], project["id"]) }.should raise_exception(ArgumentError, "Service has no pricing maps!")
      end

    end

  end

end
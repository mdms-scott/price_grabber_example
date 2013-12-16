require 'spec_helper'
require 'fixtures'
require 'price_grabber'

describe "Get rates on a particular date method" do

  context "there is a valid pricing setup" do

    it "should return a hash of the rates at a particular date" do
      provider = Fixtures::PROVIDER
      program = Fixtures::PROGRAM.clone
      program.delete('pricing_setups')
      service = Fixtures::SERVICE.merge({"program_id" => program["id"]})
      
      PriceGrabber::Common.stub(:get).with('providers/ABC123').and_return(provider)
      PriceGrabber::Common.stub(:get).with('programs/DEF456').and_return(program)
      PriceGrabber::Common.stub(:get).with('services/111').and_return(service)

      rates = PriceGrabber.rates_on_date(service["id"], "2500-01-01")

      rates.should eq(
        {"full_rate"      => 99999,
         "federal_rate"   => 88999,
         "corporate_rate" => 45000,
         "other_rate"     => 23000,
         "member_rate"    => 55999
        }
      )
    end

  end

  context "there is no valid pricing setup" do

    it "should return the nil hash" do
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

      rates = PriceGrabber.rates_on_date(service["id"], "2500-01-01")

      rates.should eq(
        {"full_rate"      => 99999,
         "federal_rate"   => nil,
         "corporate_rate" => nil,
         "other_rate"     => nil,
         "member_rate"    => nil
        }
      )
    end

  end

end

describe "calculate rates based on a passed in full_rate" do

  context "there is a valid pricing_setup" do

    it "should return a hash of the rates at a particular date" do
      provider = Fixtures::PROVIDER
      program = Fixtures::PROGRAM.clone
      program.delete('pricing_setups')
      
      PriceGrabber::Common.stub(:get).with('providers/ABC123').and_return(provider)
      PriceGrabber::Common.stub(:get).with('programs/DEF456').and_return(program)
      PriceGrabber::Common.stub(:get).with('entities/DEF456').and_return(program)

      rates = PriceGrabber.rates_from_full(10000, program["id"], "2500-01-01")

      rates.should eq(
         {"federal_rate"   => 8900,
         "corporate_rate" => 4500,
         "other_rate"     => 2300,
         "member_rate"    => 5600
        }
      )
    end

  end

  context "there is no valid pricing_setup" do

    it "should return the nil hash" do
      provider = Fixtures::PROVIDER.clone
      provider.delete('pricing_setups')
      program = Fixtures::PROGRAM.clone
      program.delete('pricing_setups')

      PriceGrabber::Common.stub(:get).with('providers/ABC123').and_return(provider)
      PriceGrabber::Common.stub(:get).with('programs/DEF456').and_return(program)
      PriceGrabber::Common.stub(:get).with('entities/DEF456').and_return(program)

      rates = PriceGrabber.rates_from_full(10000, program["id"], "2500-01-01")

      rates.should eq(
        {"federal_rate"   => nil,
         "corporate_rate" => nil,
         "other_rate"     => nil,
         "member_rate"    => nil
        }
      )
    end

  end

end
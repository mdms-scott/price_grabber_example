require 'spec_helper'
require 'fixtures'
require 'price_grabber'

describe "Pricegrabber method general methods" do

  context :find_pricing_map do

    context "when not supplied with a date" do

      it "should return the service's current pricing map" do
        pricing_map = PriceGrabber.find_pricing_map(Fixtures::SERVICE)
        pricing_map["effective_date"].should eq("2012-05-01")
      end

      it "should raise an error if it cannot find a pricing map" do
        service_copy = Fixtures::SERVICE.clone
        service_copy.delete("pricing_maps")
        lambda { PriceGrabber.find_pricing_map(service_copy) }.should raise_exception(ArgumentError)
      end

      it "should raise an error if there are no current pricing maps" do
        service_copy = Fixtures::SERVICE.clone
        service_copy["pricing_maps"] = [Fixtures::SERVICE["pricing_maps"].last]
        lambda { PriceGrabber.find_pricing_map(service_copy) }.should raise_exception(ArgumentError)
      end

    end

    context "when supplied with a date" do
      
      it "should return the pricing map displayed on that date" do
        pricing_map = PriceGrabber.find_pricing_map(Fixtures::SERVICE, "2500-01-01")
        pricing_map["display_date"].should eq('2100-01-01')
      end

    end

  end

  context :find_pricing_setup do

    context "when not supplied with a date" do

      it "should return a provider's displayed pricing setup" do
        pricing_setup = PriceGrabber.find_pricing_setup(Fixtures::PROVIDER)
        pricing_setup["display_date"].should eq("2012-05-01")
      end

      it "should return a program's displayed pricing setup" do
        pricing_setup = PriceGrabber.find_pricing_setup(Fixtures::PROGRAM)
        pricing_setup["display_date"].should eq('2012-06-01')
      end

      it "should raise an error if it cannot find a pricing setup" do
        provider_copy = Fixtures::PROVIDER.clone
        provider_copy.delete("pricing_setups")
        lambda { PriceGrabber.find_pricing_setup(provider_copy) }.should raise_exception(ArgumentError)
      end

      it "should raise an error if there are no current pricing setups" do
        provider_copy = Fixtures::PROVIDER.clone
        provider_copy["pricing_setups"] = [Fixtures::PROVIDER["pricing_setups"].last]
        lambda { PriceGrabber.find_pricing_setup(provider_copy) }.should raise_exception(ArgumentError)
      end

    end

    context "when supplied with a date" do

      it "should return the pricing setup displayed on that date" do
        pricing_setup = PriceGrabber.find_pricing_setup(Fixtures::PROVIDER, '2500-01-01')
        pricing_setup["display_date"].should eq("2100-01-01")
      end

    end

  end

end
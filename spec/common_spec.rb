require 'spec_helper'
require 'fixtures'
require 'price_grabber'
require 'price_grabber/config'
require 'price_grabber/common'

describe "Common module" do

  before :each do
    
  end

  context "Building URLs" do

    it "should build a url given an entity type and no interface" do
      PriceGrabber::Common.url_for('services').should eq('http://localhost:4567/obissimple/services')
    end

    it "should build a url given an entity type and an interface" do
      PriceGrabber::Common.url_for('services', :full).should eq('http://localhost:4567/obisentity/services')
    end

    it "should buld a url given a specific entity and no interface" do
      PriceGrabber::Common.url_for('services/abc123').should eq('http://localhost:4567/obissimple/services/abc123')
    end

  end

  context "Getting entities" do

    context "from simple" do

      it "should return an array of entities for the given entity type with no block" do
        RestClient.stub(:get).with('http://localhost:4567/obissimple/services').and_return("[{\"name\":\"Blood Transfusion\"}]")
        PriceGrabber::Common.get('services').first["name"].should eq("Blood Transfusion")
      end

      it "should return an array of filterd entities when a block is provided" do
        RestClient.stub(:get).with('http://localhost:4567/obissimple/services').and_return("[{\"name\":\"Blood Transfusion\"}, {\"name\":\"Spinal Tap\"}]")
        ret = PriceGrabber::Common.get('services') {|x| x.select {|y| y["name"] == "Spinal Tap"}}
        ret.count.should eq(1)
      end

    end

    context "from full" do

      it "should return an array of valid entity hashes when given an entity type" do
        RestClient.stub(:get).with('http://localhost:4567/obisentity/services').and_return("[{\"attributes\":{\"name\":\"Blood Transfusion\"}}]")
        PriceGrabber::Common.get('services', :full).first["attributes"]["name"].should eq("Blood Transfusion")
      end

      it "should return an array of filtered, full entities when a block is provided" do
        RestClient.stub(:get).with('http://localhost:4567/obisentity/services').and_return("[{\"attributes\":{\"name\":\"Blood Transfusion\"}}, {\"attributes\":{\"name\":\"Spinal Tap\"}}]")
        ret = PriceGrabber::Common.get('services', :full) {|x| x.select {|y| y["attributes"]["name"] == "Spinal Tap"}}
        ret.count.should eq(1)
      end

    end

  end


end
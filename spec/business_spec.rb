require 'fixtures'
require 'price_grabber'
require 'price_grabber/business'

describe "Business module" do

  context "per_unit_cost" do

    it "should return zero if quantity total is zero" do
      quantity_total = 0
      PriceGrabber::Business.per_unit_cost(Fixtures::PRICING_MAP, 100, quantity_total).should eq(0)
    end

    it "should calculate the proper per_unit_cost when quantity is more than 0" do
      quantity_total = 10
      PriceGrabber::Business.per_unit_cost(Fixtures::PRICING_MAP, 100, quantity_total).should eq(100)
    end
  end # per unit cost

  context "per_subject_totals" do
    before :each do
      @line_item = Fixtures::LINE_ITEM
      @pricing_map = Fixtures::PRICING_MAP
      @rate = 100
    end

    it "should return an array of subtotals" do
      subtotals = PriceGrabber::Business.per_subject_subtotals(@line_item, @rate, @pricing_map)
      subtotals.class.should eq(Array)
    end

    it "should calculate the correct subtotals for each visit" do
      totals_array = [1000, 1000, 1000, 1000, 1000]
      PriceGrabber::Business.per_subject_subtotals(@line_item, @rate, @pricing_map).should eq(totals_array)
    end

    it "should return an array with 'N/A' for visits if rate is 'N/A'" do
      rate = "N/A"
      totals_array = ["N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A"]
      PriceGrabber::Business.per_subject_subtotals(@line_item, rate, @pricing_map).should eq(totals_array)
    end

    it "should return an array of zeros if billing is blank" do
      line_item = Fixtures::LINE_ITEM3
      totals_array = [0, 0, 0, 0, 0, 0, 0, 0, 0 ,0]
      PriceGrabber::Business.per_subject_subtotals(line_item, @rate, @pricing_map).should eq(totals_array)
    end    
  end # per_subject_totals

  context "indirect_costs_for_visit_based_service" do
    before :each do
      @project = {"indirect_cost_rate" => 100}
      @line_item = Fixtures::LINE_ITEM
      @pricing_map = Fixtures::PRICING_MAP
      @rate = 100
    end

    it "should calculate the indirect costs for visit based service" do
      PriceGrabber::Business.indirect_costs_for_visit_based_service(@project["indirect_cost_rate"], @line_item, @rate, @pricing_map).should eq(100000)
    end
  end # indirect_costs_for_visit_based_service

  context "indirect_cost_rate" do
    ##Most useless test EVER.
    it "should divide the project indirect_cost_rate by 100 and return it" do
      project = {"indirect_cost_rate" => 100}
      PriceGrabber::Business.indirect_cost_rate(project["indirect_cost_rate"]).should eq(1)
    end
  end # indirect_cost_rate

  context "indirect_costs_for_one_time_fee" do
    before :each do
      @line_item = Fixtures::LINE_ITEM
      @project = {"indirect_cost_rate" => 100}
    end

    it "should return zero if the rate is excluded from indirect costs" do
      pricing_map = Fixtures::PRICING_MAP
      PriceGrabber::Business.indirect_costs_for_one_time_fee(@project["indirect_cost_rate"], @line_item, 100, pricing_map).should eq(0)
    end

    it "should calculate the correct indirect costs for one time fee" do
      pricing_map = Fixtures::PRICING_MAP2
      PriceGrabber::Business.indirect_costs_for_one_time_fee(@project["indirect_cost_rate"], @line_item, 100, pricing_map).should eq(10000)
    end
  end # indirect_costs_for_one_time_fee

  context "direct_costs_for_visit_based_service" do
    it "should calculate the subject totals and return them" do
      pricing_map = Fixtures::PRICING_MAP
      line_item = Fixtures::LINE_ITEM
      PriceGrabber::Business.direct_costs_for_visit_based_service(line_item, 100, pricing_map).should eq(100000)
    end
  end # direct_costs_for_visit_based_service

  context "direct_costs_for_one_time_fee" do
    it "should calculate and return the one time fee" do
      pricing_map = Fixtures::PRICING_MAP
      line_item = Fixtures::LINE_ITEM4
      PriceGrabber::Business.direct_costs_for_one_time_fee(line_item, 100, pricing_map).should eq(10000)
    end
  end # direct_costs_for_one_time_fee

  context "total_totals" do
    before :each do
      @project = {"indirect_cost_rate" => 100}
      @line_items_with_rates_and_pricing_maps = Fixtures::LINE_ITEMS_WITH_RATES_AND_PRICING_MAPS
    end

    it "should return a hash of the direct, indirect, and total costs" do
      totals = PriceGrabber::Business.total_totals(@project["indirect_cost_rate"], @line_items_with_rates_and_pricing_maps)
      totals.class.should eq(Hash)
    end

    it "should calculate the correct values for direct, indirect, and total costs" do
      totals = PriceGrabber::Business.total_totals(@project["indirect_cost_rate"], @line_items_with_rates_and_pricing_maps)
      totals["direct"].should eq(67500.0)
      totals["indirect"].should eq(37500.0)
      totals["total"].should eq(105000.0)
    end

  end # total_totals

  context "subsidy percent" do

    it "should return the percent when given arguments" do
      PriceGrabber::Business.calculate_subsidy_percentage(4000, 10000).should eq(60)
    end

  end

  context "pi contribution" do

    it "should return the pi contribution when given arguments" do
      PriceGrabber::Business.calculate_pi_contribution(60, 10000).should eq(4000)
    end

  end

  context "sub service request total" do

  end



end


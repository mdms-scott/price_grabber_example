require 'spec_helper'

module Fixtures
  PROVIDER = {
    "name"           => "Nursing Provider",
    "id"             => "ABC123",
    "pricing_setups" => [
      {"charge_master"  => false,
       "self_defined"   => true,
       "effective_date" => "2000-01-01",
       "display_date"   => "2000-01-01",
       "federal"        => 20,
       "corporate"      => 30,
       "other"          => 50,
       "member"         => 90,
       "rates"          => {
         "college"      => "full_rate",
         "federal"      => "federal_rate",
         "foundation"   => "member_rate",
         "industry"     => "corporate_rate",
         "investigator" => "other_rate",
         "internal"     => "other_rate"},
      },
      {"charge_master"  => false,
       "self_defined"   => true,
       "effective_date" => "2012-07-01",
       "display_date"   => "2012-05-01",
       "federal"        => 20,
       "corporate"      => 30,
       "other"          => 50,
       "member"         => 90,
       "rates"          => {
         "college"      => "full_rate",
         "federal"      => "federal_rate",
         "foundation"   => "member_rate",
         "industry"     => "corporate_rate",
         "investigator" => "corporate_rate",
         "internal"     => "other_rate"}
      },
      {"charge_master"  => false,
       "self_defined"   => true,
       "effective_date" => "2100-01-01",
       "display_date"   => "2100-01-01",
       "federal"        => 89,
       "corporate"      => 45,
       "other"          => 23,
       "member"         => 56,
       "rates"          => {
         "college"      => "full_rate",
         "federal"      => "federal_rate",
         "foundation"   => "member_rate",
         "industry"     => "corporate_rate",
         "investigator" => "other_rate",
         "internal"     => "other_rate"}
      }
    ]
  }

  PROGRAM = {
    "name"           => "Neurobiology Program",
    "id"             => "DEF456",
    "provider_id"    => "ABC123",
    "pricing_setups" => [
      {"charge_master"  => false,
       "self_defined"   => true,
       "effective_date" => "2012-01-01",
       "display_date"   => "2012-01-01",
       "federal"        => 99,
       "corporate"      => 74,
       "other"          => 33,
       "member"         => 75,
       "rates"          => {
         "college"      => "full_rate",
         "federal"      => "federal_rate",
         "foundation"   => "member_rate",
         "industry"     => "corporate_rate",
         "investigator" => "other_rate",
         "internal"     => "other_rate"},
      },
      {"charge_master"  => false,
       "self_defined"   => true,
       "effective_date" => "2012-10-01",
       "display_date"   => "2012-06-01",
       "federal"        => 99,
       "corporate"      => 74,
       "other"          => 33,
       "member"         => 75,
       "rates"          => {
         "college"      => "full_rate",
         "federal"      => "federal_rate",
         "foundation"   => "member_rate",
         "industry"     => "corporate_rate",
         "investigator" => "corporate_rate",
         "internal"     => "other_rate"}
      },
      {"charge_master"  => false,
       "self_defined"   => true,
       "effective_date" => "2100-01-01",
       "display_date"   => "2100-01-01",
       "federal"        => 99,
       "corporate"      => 74,
       "other"          => 33,
       "member"         => 75,
       "rates"          => {
         "college"      => "full_rate",
         "federal"      => "federal_rate",
         "foundation"   => "member_rate",
         "industry"     => "corporate_rate",
         "investigator" => "other_rate",
         "internal"     => "other_rate"}
      }
    ]
  }

  PROGRAM2 = {
    "name"           => "Neurobiology Program",
    "id"             => "ZZZ999",
    "provider_id"    => "ABC123",
    "pricing_setups" => [
      {"charge_master"  => false,
       "self_defined"   => true,
       "effective_date" => "2012-10-01",
       "display_date"   => "2012-06-01",
       "federal"        => 86,
       "corporate"      => 54,
       "other"          => 42,
       "member"         => 14,
       "rates"          => {
         "college"      => "full_rate",
         "federal"      => "federal_rate",
         "foundation"   => "member_rate",
         "industry"     => "corporate_rate",
         "investigator" => "corporate_rate",
         "internal"     => "other_rate"}
      }
    ]
  }

  CORE = {
    "name"       => "Budgetary Core",
    "id"         => "GHI789",
    "program_id" => "DEF456"
  }

  # Mock service hash
  # Don't forget to merge in the program_id or core_id attribute when using!
  SERVICE = {
    "name"         => "Blood Transfusion",
    "id"           => "111",
    "pricing_maps" => [
      {"effective_date"             => "2012-01-01",
       "display_date"               => "2012-01-01",
       "full_rate"                  => 10000,
       "unit_type"                  => "For Each",
       "unit_factor"                => 1,
       "unit_minimum"               => 1,
       "is_one_time_fee"            => false,
       "exclude_from_indirect_cost" => false
      },
      {"effective_date"             => "2012-05-01",
       "display_date"               => "2012-03-01",
       "full_rate"                  => 55555,
       "other_rate"                 => 43434,
       "unit_type"                  => "For Each",
       "unit_factor"                => 3,
       "unit_minimum"               => 3,
       "is_one_time_fee"            => false,
       "exclude_from_indirect_cost" => false
      },
      {"effective_date"             => "2100-01-01",
       "display_date"               => "2100-01-01",
       "full_rate"                  => 99999,
       "unit_type"                  => "For Each",
       "unit_factor"                => 7,
       "unit_minimum"               => 7,
       "is_one_time_fee"            => true,
       "exclude_from_indirect_cost" => false
      }          
    ]
  }

  SERVICE2 = {
    "name"         => "Spinal Tap",
    "id"           => "222",
    "pricing_maps" => [
      {"effective_date"             => "2012-01-01",
       "display_date"               => "2012-01-01",
       "full_rate"                  => 10000,
       "unit_type"                  => "For Each",
       "unit_factor"                => 1,
       "unit_minimum"               => 1,
       "is_one_time_fee"            => false,
       "exclude_from_indirect_cost" => false
       },
      {"effective_date"             => "2012-05-01",
       "display_date"               => "2012-07-01",
       "full_rate"                  => 45675,
       "other_rate"                 => 88888,
       "unit_type"                  => "For Each",
       "unit_factor"                => 12,
       "unit_minimum"               => 1,
       "is_one_time_fee"            => true,
       "exclude_from_indirect_cost" => false
       },
      {"effective_date"             => "2100-01-01",
       "display_date"               => "2100-01-01",
       "full_rate"                  => 99999,
       "unit_type"                  => "For Each",
       "unit_factor"                => 7,
       "unit_minimum"               => 7,
       "is_one_time_fee"            => true,
       "exclude_from_indirect_cost" => false
      }
    ]
  }

  SERVICE3 = {
    "name"         => "Budget Analysis",
    "id"           => "333",
    "pricing_maps" => [
      {"effective_date"             => "2012-01-01",
       "display_date"               => "2012-01-01",
       "full_rate"                  => 10000,
       "unit_type"                  => "For Each",
       "unit_factor"                => 1,
       "unit_minimum"               => 1,
       "is_one_time_fee"            => false,
       "exclude_from_indirect_cost" => false
       },
      {"effective_date"             => "2012-05-01",
       "display_date"               => "2012-05-01",
       "full_rate"                  => 32452,
       "other_rate"                 => 12345,
       "unit_type"                  => "For Each",
       "unit_factor"                => 1,
       "unit_minimum"               => 10,
       "is_one_time_fee"            => false,
       "exclude_from_indirect_cost" => false
       },
      {"effective_date"             => "2100-01-01",
       "display_date"               => "2100-01-01",
       "full_rate"                  => 99999,
       "unit_type"                  => "For Each",
       "unit_factor"                => 7,
       "unit_minimum"               => 7,
       "is_one_time_fee"            => true,
       "exclude_from_indirect_cost" => false
      }
    ]
  }

  PROGRAM_SERVICE_REQUEST = {
    "id"                   => "SR1",
    "project_id"           => "5000",
    "sub_service_requests" => {
      "0001" => {
        "program_id" => "DEF456",
        "id"         => "0001"
      }
    },
    "line_items"           => [
      {"sub_service_request_id" => "0001",
       "service_id"             => "111"}
    ]
  }

  CORE_SERVICE_REQUEST = {
    "id"                   => "SR1",
    "project_id"           => "5000",
    "sub_service_requests" => {
      "0002" => {
        "core_id" => "GHI789",
        "id"      => "0002"
      }
    },
    "line_items"           => [
      {"sub_service_request_id" => "0002",
       "service_id"             => "111"}
    ]
  }

  BIG_SERVICE_REQUEST = {
    "id" => "SRBIG",
    "project_id" => "5000",
    "sub_service_requests" => {
      "0003" => {
        "program_id" => "DEF456",
        "id" => "0003"
      }
    },
    "line_items" => [
      {"sub_service_request_id" => "0003",
       "service_id" => "111"},
      {"sub_service_request_id" => "0003",
       "service_id" => "222"},
      {"sub_service_request_id" => "0003",
       "service_id" => "333"}
    ]
  }

  MULTI_SERVICE_REQUEST = {
    "id" => "SRMULTI",
    "project_id" => "5000",
    "sub_service_requests" => {
      "0004" => {
        "program_id" => "DEF456",
        "id" => "0004"
      },
      "0005" => {
        "core_id" => "GHI789",
        "id" => "0005"
      }
    },
    "line_items" => [
      {"sub_service_request_id" => "0004",
       "service_id" => "111"},
      {"sub_service_request_id" => "0004",
       "service_id" => "222"},
      {"sub_service_request_id" => "0005",
       "service_id" => "333"}
    ]
  }

  # Mock project hash
  # Don't forget to merge in the funding_source when using!
  FUNDED_PROJECT = {
    "id"             => "5000",
    "title"          => "Obvious Waste of Government Funds",
    "funding_status" => "funded"
  }

  # Mock project hash
  # Don't forget to merge in the potential_funding_source when using!
  PENDING_PROJECT = {
    "id"             => "5001",
    "title"          => "Potential Frivilous Taxpayer Fraud",
    "funding_status" => "pending_funding"
  }

  LINE_ITEM = {
    "subject_count" => 20,
    "visits" => [{"billing"=>"R", "quantity"=>10},
                 {"billing"=>"R", "quantity"=>10},
                 {"billing"=>"R", "quantity"=>10},
                 {"billing"=>"",  "quantity"=>10},
                 {"billing"=>"",  "quantity"=>10},
                 {"billing"=>"R", "quantity"=>10},
                 {"billing"=>"",  "quantity"=>10},
                 {"billing"=>"",  "quantity"=>10},
                 {"billing"=>"R", "quantity"=>10},
                 {"billing"=>"",  "quantity"=>10}],
     "quantity" => 100,
     "units_per_quantity" => 1
  }

  LINE_ITEM2 = {
    "subject_count" => 10,
    "visits" => [{"billing"=>"R", "quantity"=>5},
                 {"billing"=>"R", "quantity"=>5},
                 {"billing"=>"R", "quantity"=>5},
                 {"billing"=>"",  "quantity"=>5},
                 {"billing"=>"",  "quantity"=>5},
                 {"billing"=>"R", "quantity"=>5},
                 {"billing"=>"",  "quantity"=>5},
                 {"billing"=>"",  "quantity"=>5},
                 {"billing"=>"R", "quantity"=>5},
                 {"billing"=>"",  "quantity"=>5}],
     "quantity" => 50,
     "units_per_quantity" => 1    
  }

  LINE_ITEM3 = {
    "subject_count" => 10,
    "visits" => [{"billing"=>"", "quantity"=>5},
                 {"billing"=>"", "quantity"=>5},
                 {"billing"=>"", "quantity"=>5},
                 {"billing"=>"",  "quantity"=>5},
                 {"billing"=>"",  "quantity"=>5},
                 {"billing"=>"", "quantity"=>5},
                 {"billing"=>"",  "quantity"=>5},
                 {"billing"=>"",  "quantity"=>5},
                 {"billing"=>"", "quantity"=>5},
                 {"billing"=>"",  "quantity"=>5}],
     "quantity" => 50,
     "units_per_quantity" => 1
  }

  LINE_ITEM4 = {
    "quantity" => 50,
    "units_per_quantity" => 2
  }

  PRICING_MAP = { "exclude_from_indirect_cost" => true,
                  "unit_factor" => 1,
                  "is_one_time_fee" => true
                }
  
  PRICING_MAP2 = { "exclude_from_indirect_cost" => false,
                   "unit_factor" => 1,
                   "is_one_time_fee" => false
                 }

  LINE_ITEMS_WITH_RATES_AND_PRICING_MAPS = [ 
        { "line_item" => LINE_ITEM, "rate" => 100, "pricing_map" => PRICING_MAP },
        { "line_item" => LINE_ITEM2, "rate" => 50, "pricing_map" => PRICING_MAP2 },
        { "line_item" => LINE_ITEM, "rate" => 100, "pricing_map" => PRICING_MAP },
        { "line_item" => LINE_ITEM2, "rate" => 50, "pricing_map" => PRICING_MAP2 },
        { "line_item" => LINE_ITEM, "rate" => 100, "pricing_map" => PRICING_MAP },
        { "line_item" => LINE_ITEM2, "rate" => 50, "pricing_map" => PRICING_MAP2 }
  ]

end

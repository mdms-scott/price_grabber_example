module PriceGrabber::Business

  def self.per_unit_cost(pricing_map, rate, quantity_total)
    if quantity_total == 0
      0
    else
      unit_factor = pricing_map["unit_factor"]
      units_per_package = unit_factor || 1
      packages_we_have_to_get = (quantity_total.to_f / units_per_package.to_f).ceil
      total_cost = packages_we_have_to_get.to_f * rate.to_f
      ret_cost = total_cost / quantity_total.to_f
      ret_cost
    end
  end

  # Returns a list of subtotals for the visits in the line item.
  # Visit totals depend on the quantities in the other visits so
  # it would be clunky to compute one visit at a time.
  def self.per_subject_subtotals(line_item, rate, pricing_map)
    visits_array = line_item["visits"].collect{ |x| x['billing'] == "R" ? x : nil}.compact
    quantity_array = visits_array.collect { |x| x['quantity']}

    if rate == "N/A"
      totals_array = line_item["visits"].map { |x| x = "N/A" }
      totals_array
      
    elsif quantity_array != []
      print quantity_array
      quantity_total = quantity_array.inject(:+) * line_item["subject_count"]
      unit_cost = per_unit_cost(pricing_map, rate, quantity_total)
      totals_array = quantity_array.collect{ |x| x * unit_cost }
      totals_array

    else
      totals_array = line_item["visits"].map { |x| x = 0 }  
      totals_array
    end
  end

  def self.indirect_cost_rate(indirect_cost_rate)
    indirect_cost_rate.to_f / 100.0
  end

  def self.direct_costs_for_visit_based_service(line_item, rate, pricing_map)
    subject_totals = (per_subject_subtotals(line_item, rate, pricing_map)).inject(:+)
    line_item["subject_count"] * subject_totals
  end

  # Determine the direct costs for a one time fee
  def self.direct_costs_for_one_time_fee(line_item, rate, pricing_map)
    quantity = line_item["quantity"]
    units_per_quantity = line_item["units_per_quantity"]
    total = quantity * units_per_quantity
    total * per_unit_cost(pricing_map, rate, total)
  end

  def self.indirect_costs_for_visit_based_service(indirect_cost_rate, line_item, rate, pricing_map)
    direct_costs_for_visit_based_service(line_item, rate, pricing_map) * indirect_cost_rate(indirect_cost_rate)
  end

  def self.indirect_costs_for_one_time_fee(indirect_cost_rate, line_item, rate, pricing_map)
    if pricing_map["exclude_from_indirect_cost"]
      0
    else
      direct_costs_for_one_time_fee(line_item, rate, pricing_map) * indirect_cost_rate(indirect_cost_rate)
    end
  end

  # Return value is a map
  def self.total_totals(indirect_cost_rate, line_items_with_rates_and_pricing_maps)
    one_time_fees, visit_based = line_items_with_rates_and_pricing_maps.partition { |x| x['pricing_map']['is_one_time_fee'] == true }

    indirect_otf = direct_otf = indirect_vbs = direct_vbs = 0.0

    one_time_fees.each do |otf|
      indirect_otf += indirect_costs_for_one_time_fee(indirect_cost_rate, otf["line_item"], otf["rate"], otf["pricing_map"])
      direct_otf += direct_costs_for_one_time_fee(otf["line_item"], otf["rate"], otf["pricing_map"])
    end

    visit_based.each do |vb|
      indirect_vbs += indirect_costs_for_visit_based_service(indirect_cost_rate, vb["line_item"], vb["rate"], vb["pricing_map"])
      direct_vbs += direct_costs_for_visit_based_service(vb["line_item"], vb["rate"], vb["pricing_map"])
    end

    direct = direct_vbs + direct_otf
    indirect = indirect_vbs + indirect_otf
    total = direct + indirect
    {"direct" => direct, "indirect" => indirect, "total" => total}
  end

  def self.calculate_subsidy_percentage(pi_contribution, total)
    funded_amount = total - pi_contribution

    ((funded_amount.to_f / total.to_f).round(2) * 100).to_i
  end

  def self.calculate_pi_contribution(subsidy_percentage, total)
    contribution = total * (subsidy_percentage.to_f / 100.0)
    contribution = total - contribution
    contribution.ceil
  end

end

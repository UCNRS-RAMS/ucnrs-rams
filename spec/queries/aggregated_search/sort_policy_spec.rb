# frozen_string_literal: true

require "rails_helper"

RSpec.describe AggregatedSearch::SortPolicy do
  let(:alpha_inst) { build_stubbed(:institution, id: 1, name: "Alpha College", acronym: "AC") }
  let(:beta_inst) { build_stubbed(:institution, id: 2, name: "Beta University", acronym: "BU") }
  let(:gamma_inst) { build_stubbed(:institution, id: 3, name: "Gamma Institute", acronym: "GI") }

  def institution_item(inst)
    {
      id: inst.id,
      name: inst.name,
      city: inst.city,
      acronym: inst.acronym,
      type: :institution,
      source: inst
    }
  end

  def ror_item(ror)
    {
      id: ror.ror_id,
      name: ror.name,
      city: ror.cities&.first,
      acronym: ror.acronyms&.first,
      type: :ror,
      source: ror
    }
  end

  it "places records whose name starts with the query before other alphabetical matches" do
    # Query "Beta": beta_inst starts with "Beta", alpha_inst does not
    results = described_class.call(
      [ institution_item(alpha_inst), institution_item(beta_inst) ],
      query: "Beta"
    )

    expect(results.map { |r| r[:name] }).to eq([ "Beta University", "Alpha College" ])
  end

  it "places records whose acronym matches the query before other alphabetical matches" do
    # Query "GI": gamma_inst acronym matches "GI" (case-insensitive)
    results = described_class.call(
      [ institution_item(alpha_inst), institution_item(gamma_inst) ],
      query: "gi"
    )

    expect(results.map { |r| r[:name] }).to eq([ "Gamma Institute", "Alpha College" ])
  end

  it "matches acronym on a linked ROR record for institutions without a local acronym" do
    ror = build_stubbed(:ror, ror_id: "https://ror.org/ucla", acronyms: [ "UCLA" ])
    ucla_inst = build_stubbed(
      :institution,
      id: 4,
      name: "University of California, Los Angeles",
      acronym: nil,
      ror_id: "https://ror.org/ucla",
      ror: ror
    )

    results = described_class.call(
      [ institution_item(alpha_inst), institution_item(ucla_inst) ],
      query: "ucla"
    )

    expect(results.map { |r| r[:name] }).to eq([
      "University of California, Los Angeles",
      "Alpha College"
    ])
  end

  it "places ROR records whose alias begins with the query before other alphabetical matches" do
    stanford_ror = build_stubbed(
      :ror,
      ror_id: "https://ror.org/stanford",
      name: "Leland Stanford Junior University",
      aliases: [ "Stanford University", "The Farm" ]
    )

    results = described_class.call(
      [ institution_item(alpha_inst), ror_item(stanford_ror) ],
      query: "Stanford"
    )

    expect(results.map { |r| r[:name] }).to eq([
      "Leland Stanford Junior University",
      "Alpha College"
    ])
  end

  it "places institutions linked to a ROR whose alias begins with the query before other matches" do
    ror = build_stubbed(
      :ror,
      ror_id: "https://ror.org/0010abcd",
      name: "Golden Bear University",
      aliases: [ "Bruin Institute" ]
    )
    linked_inst = build_stubbed(
      :institution,
      id: 5,
      name: "Golden Bear College",
      acronym: "GBC",
      ror_id: "https://ror.org/0010abcd",
      ror: ror
    )

    results = described_class.call(
      [ institution_item(alpha_inst), institution_item(linked_inst) ],
      query: "Bruin"
    )

    expect(results.map { |r| r[:name] }).to eq([
      "Golden Bear College",
      "Alpha College"
    ])
  end

  it "treats name prefix, acronym match, and ROR alias prefix at the same level and sorts them alphabetically" do
    # 1) Name prefix: "Cal Arts"
    cal_arts = build_stubbed(:institution, id: 10, name: "Cal Arts", acronym: "CA")
    # 2) Acronym match: "Tech Institute" with acronym "CAL"
    cal_inst = build_stubbed(:institution, id: 11, name: "Tech Institute", acronym: "CAL")
    # 3) ROR alias begins with query: "Berkeley School" with alias "California College"
    cal_ror = build_stubbed(
      :ror,
      ror_id: "https://ror.org/berk",
      name: "Berkeley School",
      aliases: [ "California College" ]
    )
    # Non-prioritized: "Abc College"
    abc_inst = build_stubbed(:institution, id: 12, name: "Abc College", acronym: "ABC")

    results = described_class.call(
      [
        institution_item(abc_inst),
        institution_item(cal_arts),
        institution_item(cal_inst),
        ror_item(cal_ror)
      ],
      query: "cal"
    )

    # Priority items (all matching on equal level, sorted alphabetically):
    # Berkeley School (alias "California College" starts with "cal")
    # Cal Arts (name starts with "cal")
    # Tech Institute (acronym "CAL" matches "cal")
    # Followed by non-prioritized: Abc College
    expect(results.map { |r| r[:name] }).to eq([
      "Berkeley School",
      "Cal Arts",
      "Tech Institute",
      "Abc College"
    ])
  end

  it "falls back to pure alphabetical sorting when query is blank or nil" do
    results = described_class.call(
      [ institution_item(gamma_inst), institution_item(alpha_inst), institution_item(beta_inst) ],
      query: "   "
    )

    expect(results.map { |r| r[:name] }).to eq([
      "Alpha College",
      "Beta University",
      "Gamma Institute"
    ])
  end
end

# frozen_string_literal: true

require "rails_helper"
require "tempfile"

RSpec.describe Ops::InstitutionRorDeduplication::CsvReader do
  def with_csv(contents)
    Tempfile.create([ "ror-import", ".csv" ]) do |file|
      file.write(contents)
      file.flush
      yield file.path
    end
  end

  it "normalizes direct and non-direct rows while ignoring blank rows and extra columns" do
    contents = <<~CSV
      rams_id,rams_name,rams_acronym,rams_city,ror_id,ror_name,ror_match_type
      12,"A University",AU,"Town",https://ror.org/one,"A University",DIRECT
      13,"Related University",RU,"Town",,"A University",close

    CSV

    with_csv(contents) do |path|
      expect(described_class.new(path).rows).to eq([
        { rams_id: 12, ror_id: "https://ror.org/one", ror_match_type: "direct" },
        { rams_id: 13, ror_id: nil, ror_match_type: "close" }
      ])
    end
  end

  it "rejects CSVs missing a required header" do
    with_csv("rams_id,ror_id\n1,https://ror.org/one\n") do |path|
      expect { described_class.new(path).rows }.to raise_error(ArgumentError, /ror_match_type/)
    end
  end

  it "rejects malformed IDs, missing match types and direct rows without ROR IDs" do
    [
      [ "not-an-id,https://ror.org/one,direct", /Invalid rams_id/ ],
      [ "1,https://ror.org/one,", /Missing ror_match_type/ ],
      [ "1,,direct", /Missing ror_id for direct institution/ ]
    ].each do |row, message|
      with_csv("rams_id,ror_id,ror_match_type\n#{row}\n") do |path|
        expect { described_class.new(path).rows }.to raise_error(ArgumentError, message)
      end
    end
  end

  it "rejects a direct institution ID mapped to multiple ROR IDs" do
    csv = <<~CSV
      rams_id,ror_id,ror_match_type
      1,https://ror.org/one,direct
      1,https://ror.org/two,direct
    CSV

    with_csv(csv) do |path|
      expect { described_class.new(path).rows }.to raise_error(ArgumentError, /multiple ROR IDs: 1/)
    end
  end

  it "rejects a CSV with no data rows" do
    with_csv("rams_id,ror_id,ror_match_type\n\n") do |path|
      expect { described_class.new(path).rows }.to raise_error(ArgumentError, /no data rows/)
    end
  end
end

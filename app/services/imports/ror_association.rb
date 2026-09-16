# frozen_string_literal: true

require 'csv'

# takes a csv of institutions in the database to be associated with RORs
# and creates the associations in the database
#
# The data to be associated looks like:
# rams_id,rams_name,rams_city,ror_id,ror_name
# 521,Adventure Risk Management,Idyllwild,https://ror.org/05222ev03,Risk Management Agency
# 541,California Institute for Biodiversity,Oakland,https://ror.org/01n8ggb71,Institute for Biodiversity
module Imports
  class RorAssociation
    def initialize(csv_path = nil)
      @csv_path = csv_path
    end

    def call
      raise ArgumentError, 'CSV path is required' if @csv_path.blank?

      updated_institutions = []

      CSV.foreach(@csv_path, headers: true, header_converters: :symbol) do |row|
        institutions = self.class.find_matching_institutions(row)
        if institutions.empty?
          puts "No matches found for #{row[:rams_name]} (rams_id=#{row[:rams_id]})"
          next
        end

        institutions.update!(ror_id: row[:ror_id])
        updated_institutions.concat(institutions.to_a)
      end

      updated_institutions
    end

    def self.matching_string?(str1, str2)
      normalize_for_match(str1) == normalize_for_match(str2)
    end

    def self.normalize_for_match(value)
      value.to_s.strip.downcase
    end

    def self.normalize_row(row)
      row.to_h.transform_values { |value| normalize_for_match(value) }.with_indifferent_access
    end

    def self.find_matching_institutions(row)
      h = normalize_row(row)
      return [] if h[:ror_id].blank?

      by_id = Institution.where(id: h[:rams_id])

      # want to be sure the same as noted in spreadsheet since if this is run against a different database
      # then the database id autonumber might be completely wrong and refer to a different institution
      return by_id if by_id.exists? && matching_string?(by_id.first.name, h[:rams_name])

      # otherwise find the matching name and city record(s) for the item(s)
      Institution
        .where('TRIM(name) = ?', h[:rams_name])
        .where('TRIM(city) = ?', h[:rams_city])
    end

  end
end

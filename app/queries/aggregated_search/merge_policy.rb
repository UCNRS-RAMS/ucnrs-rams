# frozen_string_literal: true

class AggregatedSearch
  class MergePolicy
    def self.call(matching_rors:, matching_institutions:)
      new(matching_rors: matching_rors, matching_institutions: matching_institutions).call
    end

    def initialize(matching_rors:, matching_institutions:)
      @matching_rors = matching_rors
      @matching_institutions = matching_institutions
    end

    def call
      ror_ids = matching_rors.map(&:ror_id).to_set
      dup_ror_ids = ror_ids & matching_institutions.map(&:ror_id).compact.to_set
      filtered_rors = matching_rors.reject { |ror| dup_ror_ids.include?(ror.ror_id) }

      (matching_institutions.map { |inst| institution_result(inst) } +
        filtered_rors.map { |ror| ror_result(ror) })
          .sort_by { |item| "#{item[:name].to_s.downcase} #{item[:type]} #{item[:id]}" }
    end

    private

    attr_reader :matching_rors, :matching_institutions

    def institution_result(institution)
      {
        id: institution.id,
        name: institution.name,
        city: institution.city,
        acronym: institution.acronym,
        type: :institution,
        source: institution
      }
    end

    def ror_result(ror)
      {
        id: ror.ror_id,
        name: ror.name,
        city: ror.cities&.first,
        acronym: ror.acronyms&.first,
        type: :ror,
        source: ror
      }
    end
  end
end

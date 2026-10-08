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
      ror_ids = candidate_rors.map(&:ror_id).to_set
      dup_ror_ids = ror_ids & matching_institutions.map(&:ror_id).compact.to_set
      filtered_rors = candidate_rors.reject { |ror| dup_ror_ids.include?(ror.ror_id) }

      (matching_institutions.map { |inst| institution_result(inst) } +
        filtered_rors.map { |ror| ror_result(ror) })
          .sort_by { |item| "#{item[:name].to_s.downcase} #{item[:type]} #{item[:id]}" }
    end

    private

    attr_reader :matching_rors, :matching_institutions

    def candidate_rors
      matching_rors.select { |ror| ror.ror_id.present? }.uniq(&:ror_id)
    end

    def institution_result(institution)
      {
        id: institution.id,
        name: institution.name,
        city: institution.city,
        country: institution.country&.name,
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
        country: ror.country&.dig("country_name"),
        acronym: ror.acronyms&.first,
        type: :ror,
        source: ror
      }
    end
  end
end

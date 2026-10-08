# frozen_string_literal: true

class AggregatedSearch
  class MergePolicy
    def self.call(matching_rors:, matching_institutions:, query: nil)
      new(matching_rors: matching_rors, matching_institutions: matching_institutions, query: query).call
    end

    def initialize(matching_rors:, matching_institutions:, query: nil)
      @matching_rors = matching_rors
      @matching_institutions = matching_institutions
      @query = query
    end

    def call
      ror_ids = candidate_rors.map(&:ror_id).to_set
      dup_ror_ids = ror_ids & matching_institutions.map(&:ror_id).compact.to_set
      filtered_rors = candidate_rors.reject { |ror| dup_ror_ids.include?(ror.ror_id) }

      (matching_institutions.map { |inst| institution_result(inst) } +
        filtered_rors.map { |ror| ror_result(ror) })
          .sort_by { |item| sort_key(item) }
    end

    private

    attr_reader :matching_rors, :matching_institutions, :query

    def sort_key(item)
      priority = prioritized?(item) ? 0 : 1
      [ priority, item[:name].to_s.downcase, item[:type].to_s, item[:id].to_s ]
    end

    def candidate_rors
      matching_rors.select { |ror| ror.ror_id.present? }.uniq(&:ror_id)
    end

    def prioritized?(item)
      return false if normalized_query.blank?

      name_starts_with_query?(item) ||
        acronym_matches_query?(item) ||
        ror_alias_begins_with_query?(item)
    end

    def name_starts_with_query?(item)
      item[:name].to_s.downcase.start_with?(normalized_query)
    end

    def acronym_matches_query?(item)
      acronyms_for(item).any? { |acronym| acronym.to_s.strip.downcase == normalized_query }
    end

    def ror_alias_begins_with_query?(item)
      ror_aliases_for(item).any? { |alias_name| alias_name.to_s.strip.downcase.start_with?(normalized_query) }
    end

    def acronyms_for(item)
      if item[:type] == :institution
        inst = item[:source]
        [ inst.acronym, *Array(ror_for(inst)&.acronyms) ].compact_blank
      else
        Array(item[:source].acronyms).compact_blank
      end
    end

    def ror_aliases_for(item)
      if item[:type] == :institution
        Array(ror_for(item[:source])&.aliases).compact_blank
      else
        Array(item[:source].aliases).compact_blank
      end
    end

    def ror_for(institution)
      return nil if institution.try(:ror_id).blank?

      rors_by_id[institution.ror_id] || (institution.respond_to?(:ror) ? institution.ror : nil)
    end

    def rors_by_id
      @rors_by_id ||= matching_rors.index_by { |ror| ror.try(:ror_id) }.compact
    end

    def normalized_query
      @normalized_query ||= query.to_s.strip.downcase
    end


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

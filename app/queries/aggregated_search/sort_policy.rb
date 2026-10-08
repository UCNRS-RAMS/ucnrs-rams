# frozen_string_literal: true

class AggregatedSearch
  class SortPolicy
    def self.call(items, query: nil)
      new(items: items, query: query).call
    end

    def initialize(items:, query: nil)
      @items = items
      @query = query
    end

    def call
      items.sort_by { |item| sort_key(item) }
    end

    private

    attr_reader :items, :query

    def sort_key(item)
      priority = prioritized?(item) ? 0 : 1
      [ priority, item[:name].to_s.downcase, item[:type].to_s, item[:id].to_s ]
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
        [ inst.acronym, *Array(inst.try(:ror)&.acronyms) ].compact_blank
      else
        Array(item[:source].acronyms).compact_blank
      end
    end

    def ror_aliases_for(item)
      if item[:type] == :institution
        Array(item[:source].try(:ror)&.aliases).compact_blank
      else
        Array(item[:source].aliases).compact_blank
      end
    end

    def normalized_query
      @normalized_query ||= query.to_s.strip.downcase
    end
  end
end

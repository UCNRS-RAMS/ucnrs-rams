# frozen_string_literal: true

module Ops
  module InstitutionRorDeduplication
    # Institutions sharing one ROR ID: keep_id survives and duplicate_ids are merged into it.
    # set_ror_id is true when the retained institution has no ROR ID yet.
    Group = Struct.new(:ror_id, :keep_id, :duplicate_ids, :set_ror_id, keyword_init: true) do
      def institution_ids
        [ keep_id, *duplicate_ids ]
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::RorAssociation do
  describe '.find_matching_institutions' do
    it 'matches by id when the database id and name line up' do
      institution = create(:institution, name: '  University of California  ', city: ' Oakland ')
      row = {
        rams_id: institution.id.to_s,
        rams_name: 'university of california',
        rams_city: 'oakland',
        ror_id: 'https://ror.org/123'
      }

      expect(described_class.find_matching_institutions(row)).to contain_exactly(institution)
    end

    it 'falls back to name and city when the id is stale or belongs to a different institution' do
      institution = create(:institution, name: 'University of California', city: 'Oakland')
      row = {
        rams_id: (institution.id + 999).to_s,
        rams_name: 'university of california',
        rams_city: 'oakland',
        ror_id: 'https://ror.org/123'
      }

      expect(described_class.find_matching_institutions(row)).to contain_exactly(institution)
    end
  end


  describe '.matching_string?' do
    it 'ignores case and surrounding whitespace' do
      expect(described_class.matching_string?('  Example Institute  ', 'example institute')).to be(true)
    end
  end
end

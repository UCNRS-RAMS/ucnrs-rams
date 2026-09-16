# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::RorAssociation do
  describe '#find_matching_institution' do
    it 'matches names and cities case and whitespace insensitively' do
      institution = create(:institution, name: '  University of California  ', city: ' Oakland ')
      row = {
        rams_id: institution.id.to_s,
        rams_name: 'university of california',
        rams_city: 'oakland',
        ror_id: 'https://ror.org/123'
      }

      expect(described_class.new.send(:find_matching_institution, row)).to eq(institution)
    end
  end

  describe '.matching_string?' do
    it 'ignores case and surrounding whitespace' do
      expect(described_class.matching_string?('  Example Institute  ', 'example institute')).to be(true)
    end
  end
end

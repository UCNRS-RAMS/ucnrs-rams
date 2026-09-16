# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::RorAssociation do
  describe '#initialize' do
    it 'stores the csv path' do
      importer = described_class.new('/tmp/ror_association.csv')

      expect(importer.instance_variable_get(:@csv_path)).to eq('/tmp/ror_association.csv')
    end
  end

  describe '#call' do
    it 'raises an error when no csv path is supplied' do
      expect { described_class.new.call }.to raise_error(ArgumentError, 'CSV path is required')
    end

    it 'updates matching institutions and returns them' do
      institution = create(:institution, name: 'University of California', city: 'Oakland')
      csv_file = Tempfile.new(['ror_association', '.csv'])
      csv_file.write("rams_id,rams_name,rams_city,ror_id\n#{institution.id},university of california,oakland,https://ror.org/123\n")
      csv_file.rewind

      importer = described_class.new(csv_file.path)
      expect(importer.call).to contain_exactly(institution)
      expect(institution.reload.ror_id).to eq('https://ror.org/123')
    ensure
      csv_file.close
      csv_file.unlink
    end
  end

  describe '.normalize_for_match' do
    it 'strips surrounding whitespace and lowercases the value' do
      expect(described_class.normalize_for_match('  Example Institute  ')).to eq('example institute')
    end
  end

  describe '.normalize_row' do
    it 'normalizes all values and keeps indifferent access' do
      row = { 'rams_name' => '  University of California  ', 'rams_city' => ' Oakland ' }

      normalized = described_class.normalize_row(row)

      expect(normalized[:rams_name]).to eq('university of california')
      expect(normalized['rams_city']).to eq('oakland')
    end
  end

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

    it 'returns an empty array when the row does not include an ror id' do
      institution = create(:institution, name: 'University of California', city: 'Oakland')
      row = {
        rams_id: institution.id.to_s,
        rams_name: 'university of california',
        rams_city: 'oakland',
        ror_id: ''
      }

      expect(described_class.find_matching_institutions(row)).to eq([])
    end
  end

  describe '.matching_string?' do
    it 'ignores case and surrounding whitespace' do
      expect(described_class.matching_string?('  Example Institute  ', 'example institute')).to be(true)
    end
  end
end

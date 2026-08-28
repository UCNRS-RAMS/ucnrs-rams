# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ror::RecordMapper do
  describe '.call' do
    it 'returns mapped attributes for a valid ROR record' do
      record = {
        'id' => 'https://ror.org/1234567890',
        'name' => 'Example University',
        'links' => [{ 'type' => 'website', 'value' => 'https://example.edu' }],
        'types' => ['Education'],
        'names' => [
          { 'value' => 'Example University', 'types' => ['ror_display'] },
          { 'value' => 'Example', 'types' => ['alias'] }
        ],
        'country' => { 'country_name' => 'United States', 'country_code' => 'US' },
        'external_ids' => { 'FundRef' => { 'preferred' => '123', 'all' => ['123', '456'] } }
      }

      mapped = described_class.call(record)

      expect(mapped).to include(
        ror_id: 'https://ror.org/1234567890',
        aliases: ['Example'],
        acronyms: [],
        country: { 'country_name' => 'United States', 'country_code' => 'US' },
        types: ['Education'],
        language: 'en',
        fundref_id: '123',
        home_page: 'https://example.edu'
      )
      expect(mapped[:name]).to include('Example University')
      expect(mapped[:name]).to end_with('(example.edu)')
    end

    it 'returns an empty hash for invalid records' do
      expect(described_class.call('not a hash')).to eq({})
      expect(described_class.call({ 'name' => 'Missing ID' })).to eq({})
    end
  end

  describe 'record parsing helpers' do
    describe '.ror_names' do
      it 'returns matching values by name type' do
        item = {
          'names' => [
            { 'value' => 'Example University', 'types' => ['ror_display'] },
            { 'value' => 'Example', 'types' => ['alias'] },
            { 'value' => 'EU', 'types' => ['acronym'] }
          ]
        }

        expect(described_class.send(:ror_names, item: item, type: 'alias')).to eq(['Example'])
        expect(described_class.send(:ror_names, item: item, type: 'acronym')).to eq(['EU'])
      end
    end

    describe '.country_data' do
      it 'uses the top-level country hash when present' do
        item = { 'country' => { 'country_name' => 'United States', 'country_code' => 'US' } }

        expect(described_class.send(:country_data, item: item)).to eq({ 'country_name' => 'United States', 'country_code' => 'US' })
      end

      it 'falls back to geonames details when country is not present' do
        item = {
          'locations' => [
            { 'geonames_details' => { 'country_name' => 'Mexico', 'country_code' => 'MX' } }
          ]
        }

        expect(described_class.send(:country_data, item: item)).to eq({ 'country_name' => 'Mexico', 'country_code' => 'MX' })
      end
    end

    describe '.org_name' do
      it 'returns the raw name when no extra context is present' do
        item = { 'name' => 'Example College', 'links' => [], 'country' => {}, 'names' => [] }

        expect(described_class.send(:org_name, item: item)).to eq('Example College')
      end

      it 'keeps the website context when a display name is present' do
        item = {
          'name' => 'Legacy Name',
          'links' => [{ 'type' => 'website', 'value' => 'https://example.edu/path' }],
          'country' => { 'country_name' => 'Nowhere' },
          'names' => [{ 'value' => 'Preferred Name', 'types' => ['ror_display'] }]
        }

        name = described_class.send(:org_name, item: item)
        expect(name).to include('example.edu')
        expect(name).to include('Preferred Name')
      end

      it 'falls back to the country when the website is missing' do
        item = {
          'name' => 'Example College',
          'country' => { 'country_name' => 'Nowhere' },
          'links' => []
        }

        expect(described_class.send(:org_name, item: item)).to eq('Example College (Nowhere)')
      end
    end

    describe '.org_language' do
      it 'defaults to English for US organizations' do
        item = { 'country' => { 'country_code' => 'US' } }

        expect(described_class.send(:org_language, item: item)).to eq('en')
      end

      it 'uses the language from the preferred name when available' do
        item = { 'names' => [{ 'lang' => 'es', 'value' => 'Universidad', 'types' => ['ror_display'] }] }

        expect(described_class.send(:org_language, item: item)).to eq('es')
      end

      it 'falls back to the legacy labels iso639 value' do
        item = { 'labels' => [{ 'iso639' => 'fr' }] }

        expect(described_class.send(:org_language, item: item)).to eq('fr')
      end
    end

    describe '.primary_website' do
      it 'returns the first website link when present' do
        item = { 'links' => [{ 'type' => 'website', 'value' => 'https://example.edu' }, { 'type' => 'other', 'value' => 'https://example.org' }] }

        expect(described_class.send(:primary_website, item: item)).to eq('https://example.edu')
      end

      it 'returns the first string URL when the links array contains plain strings' do
        item = { 'links' => ['https://example.edu/path'] }

        expect(described_class.send(:primary_website, item: item)).to eq('https://example.edu/path')
      end
    end

    describe '.org_website' do
      it 'strips the protocol and www prefix to keep the domain only' do
        item = { 'links' => ['https://www.example.edu/path?a=b'] }

        expect(described_class.send(:org_website, item: item)).to eq('example.edu')
      end

      it 'returns nil when there is no usable website' do
        expect(described_class.send(:org_website, item: { 'links' => [] })).to be_nil
      end
    end

    describe '.fundref_id' do
      it 'returns an empty string when no fundref info is present' do
        expect(described_class.send(:fundref_id, item: { 'external_ids' => {} })).to eq('')
      end

      it 'returns the preferred fundref when the external IDs include a FundRef hash' do
        item = { 'external_ids' => { 'FundRef' => { 'preferred' => '1', 'all' => ['2', '1'] } } }

        expect(described_class.send(:fundref_id, item: item)).to eq('1')
      end

      it 'falls back to the first FundRef value when no preferred value exists' do
        item = { 'external_ids' => { 'fundref' => { 'preferred' => nil, 'all' => ['2', '1'] } } }

        expect(described_class.send(:fundref_id, item: item)).to eq('2')
      end
    end
  end
end

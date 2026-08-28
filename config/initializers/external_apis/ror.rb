# frozen_string_literal: true

# Configuration for importing the ROR registry's Zenodo data dump.
Rails.configuration.x.ror ||= ActiveSupport::OrderedOptions.new
Rails.configuration.x.organization ||= ActiveSupport::OrderedOptions.new
Rails.configuration.x.ror.download_url = 'https://zenodo.org/api/records/?communities=ror-data&sort=mostrecent'
Rails.configuration.x.ror.max_redirects = 3
Rails.configuration.x.ror.file_dir = Rails.root.join('tmp/ror')
Rails.configuration.x.ror.checksum_file = Rails.root.join('tmp/ror/checksum.txt')
Rails.configuration.x.ror.zip_file = Rails.root.join('tmp/ror/latest-ror-data.zip')

Rails.configuration.x.organization.helpdesk_email ||= 'support@ucnature.org'
# frozen_string_literal: true

module ExternalApis
  module Ror
    class Config
      class << self
        def landing_page_url
          Rails.configuration.x.ror&.landing_page_url || raise(NotImplementedError)
        end

        def api_base_url
          Rails.configuration.x.ror&.api_base_url || raise(NotImplementedError)
        end

        def download_url
          Rails.configuration.x.ror&.download_url
        end

        def full_catalog_file
          Rails.configuration.x.ror&.full_catalog_file || Rails.root.join('tmp/ror/ror.json')
        end

        def file_dir
          Rails.configuration.x.ror&.file_dir || Rails.root.join('tmp/ror')
        end

        def checksum_file
          Rails.configuration.x.ror&.checksum_file || Rails.root.join('tmp/ror/checksum.txt')
        end

        def zip_file
          Rails.configuration.x.ror&.zip_file || Rails.root.join('tmp/ror/latest-ror-data.zip')
        end

        def active?
          Rails.configuration.x.ror&.active.nil? ? false : Rails.configuration.x.ror.active
        end

        def heartbeat_path
          Rails.configuration.x.ror&.heartbeat_path
        end

        def search_path
          Rails.configuration.x.ror&.search_path
        end
      end
    end
  end
end

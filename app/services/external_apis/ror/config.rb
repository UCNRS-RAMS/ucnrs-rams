# frozen_string_literal: true

module ExternalApis
  module Ror
    class Config
      attr_reader :download_url, :file_dir, :checksum_file, :zip_file, :max_redirects

      def self.from_rails(configuration: Rails.configuration)
        ror = configuration.x.ror
        new(
          download_url: ror.download_url,
          file_dir: ror.file_dir || Rails.root.join('tmp/ror'),
          checksum_file: ror.checksum_file || Rails.root.join('tmp/ror/checksum.txt'),
          zip_file: ror.zip_file || Rails.root.join('tmp/ror/latest-ror-data.zip'),
          max_redirects: ror.max_redirects || 3,
          user_agent: "#{ApplicationService.application_name} (#{configuration.x.organization.helpdesk_email})"
        )
      end

      def initialize(download_url:, file_dir:, checksum_file:, zip_file:, max_redirects:, user_agent:)
        @download_url = download_url
        @file_dir = Pathname.new(file_dir)
        @checksum_file = Pathname.new(checksum_file)
        @zip_file = Pathname.new(zip_file)
        @max_redirects = max_redirects
        @user_agent = user_agent
      end

      def http_headers
        {
          'Content-Type': 'application/json',
          Accept: 'application/json',
          'User-Agent': @user_agent
        }
      end
    end
  end
end

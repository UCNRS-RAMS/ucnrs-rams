# frozen_string_literal: true

namespace :external_api do
  desc 'Populate the rors table from the latest ROR Zenodo dump. To force reprocessing pass `rails "external_api:sync_rors[true]"` (note the quotes)'
  task :sync_rors, [:force] => :environment do |_, args|
    Rails.logger.info 'Processing the latest ROR registry and updating the rors table'
    result = ExternalApis::RorService.fetch(force: args[:force])

    case result
    when :success
      Rails.logger.info 'ROR registry updated successfully'
      exit 0
    when :no_change
      Rails.logger.info 'ROR registry is already up to date'
      exit 0
    else
      Rails.logger.error 'ROR registry update failed'
      exit 1
    end
  end
end

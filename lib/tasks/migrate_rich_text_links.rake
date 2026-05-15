namespace :db do
  desc "Update active storage links embedded in rich text inside <action-text-attachment> tags to rails 7"
  task migrate_rich_text_links: :environment do
    match_term = "%rails/active_storage%"

    ActionText::RichText
      .where("body LIKE ?", match_term)
      .find_each do |rich_text|
        content = rich_text.to_s.gsub(/<div class="trix-content">(.*)<\/div>/m, '\1')

        new_body = ActiveStorageKeyConverter.new(content).process

        # rubocop:disable Rails/SkipsModelValidations
        rich_text.update_column(:body, new_body)
        # rubocop:enable Rails/SkipsModelValidations
      end
  end
end

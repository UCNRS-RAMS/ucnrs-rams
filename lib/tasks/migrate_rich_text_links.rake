namespace :db do
  desc "Update active storage links embedded in rich text to support in rails 7"
  task migrate_old_activestorage_links: :environment do
    match_term = "%rails/active_storage%"

    ActionText::RichText
      .where("body LIKE ?", match_term)
      .find_each do |rich_text|
        content = rich_text.to_s.gsub(/<div class="trix-content">(.*)<\/div>/m, '\1')

        new_body = ActiveStorageKeyConverter.new(content).process
        next if new_body == rich_text.body

        rich_text.update_column(:body, new_body)
    end
  end
end

namespace :db do
  desc "Update active storage links embedded in rich text after secret_key_base rotation"

  task :migrate_rich_text_secret_key, [:old_secret_key_base] => :environment do |_t, args|
    old_secret = args[:old_secret_key_base] || ENV.fetch("OLD_SECRET_KEY_BASE", nil)

    if old_secret.blank?
      abort <<~MSG
        ERROR: You must provide the previous secret_key_base.

        Usage:
          rake db:migrate_rich_text_secret_key[OLD_SECRET_KEY_BASE]
          # or
          OLD_SECRET_KEY_BASE=xxx rake db:migrate_rich_text_secret_key
      MSG
    end

    match_term = "%rails/active_storage%"
    sgid_term  = "%sgid=%"
    updated    = 0

    ActionText::RichText
      .where("body LIKE ? OR body LIKE ?", match_term, sgid_term)
      .find_each do |rich_text|
        content = rich_text.to_s.gsub(/<div class="trix-content">(.*)<\/div>/m, '\1')

        new_body = RichTextSecretKeyMigrator.new(content, old_secret_key_base: old_secret).process

        if new_body != content
          rich_text.update_column(:body, new_body)
          updated += 1
          puts "Updated RichText ##{rich_text.id}"
        end
      end

    puts "Done. #{updated} rich text record(s) updated."
  end
end

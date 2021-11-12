# Not exactly "taken" from this, but reimplementing the same way just gets you
# the same code, so go ask Theseus if it's really the same or not. Anyway, the
# idea is from there, so credit where it's due:
# https://stackoverflow.com/questions/8662127/how-to-use-seed-rb-to-selectively-populate-development-and-or-production-databas#answer-41936298

ActiveRecord::Base.transaction do
  ["base", Rails.env].each do |env|
    seed_file = "#{Rails.root}/db/seeds/#{env}.rb"
    if File.exists?(seed_file)
      puts "Seeding #{env}"
      require seed_file
    end
  end
end

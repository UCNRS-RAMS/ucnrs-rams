# frozen_string_literal: true

namespace :api do
  namespace :clients do
    desc "Create an API client and print its token (shown once; store it securely)"
    task create: :environment do
      name = ENV.fetch("NAME")
      reserve_id = ENV["RESERVE_ID"]

      client = ApiClient.create!(name: name, reserve_id: reserve_id)

      puts "Created API client #{client.id} (#{client.name})"
      puts "Token: #{client.plain_text_token}"
    end
  end
end

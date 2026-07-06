# frozen_string_literal: true

require "rails_helper"
require "rake"

RSpec.describe "ops:fix-orcid-format" do
  before do
    Rake.application = Rake::Application.new
    Rake::Task.define_task(:environment)
    load Rails.root.join("lib/tasks/ops.rake")
  end

  let(:task) { Rake::Task["ops:fix-orcid-format"] }
  let(:connection) { ActiveRecord::Base.connection }

  before do
    task.reenable
    @copy_tables = []
    connection.execute("DELETE FROM users WHERE email LIKE 'ops-orcid-test-%@example.com'")
  end

  after do
    @copy_tables.each { |table| connection.execute("DROP TABLE IF EXISTS `#{table}`") }
    connection.execute("DELETE FROM users WHERE email LIKE 'ops-orcid-test-%@example.com'")
  end

  def create_user_with_orcid(orcid)
    email = "ops-orcid-test-#{SecureRandom.hex(4)}@example.com"
    quoted_orcid = orcid.nil? ? "NULL" : "'#{connection.quote_string(orcid)}'"
    connection.execute(<<~SQL)
      INSERT INTO users (email, encrypted_password, orcid, created_at, updated_at)
      VALUES ('#{connection.quote_string(email)}', 'encrypted', #{quoted_orcid}, NOW(), NOW())
    SQL
    connection.select_value("SELECT id FROM users WHERE email = '#{connection.quote_string(email)}'")
  end

  def orcid_from(table, user_id)
    connection.select_value("SELECT orcid FROM `#{table}` WHERE id = #{user_id}")
  end

  describe "dry_run mode" do
    it "copies users to a timestamped table and transforms ORCID values without modifying the original users table" do
      freeze_time do
        copy_table = "users_copy-#{Time.current.strftime('%Y-%m-%d-%H%M%S')}"
        @copy_tables << copy_table

        user_placeholder = create_user_with_orcid("none")
        user_url_https = create_user_with_orcid("https://orcid.org/0000-0001-2345-6789")
        user_url_http = create_user_with_orcid("http://orcid.org/0000-0001-2345-6789")
        user_url_www = create_user_with_orcid("www.orcid.org/0000-0001-2345-6789")
        user_url_no_protocol = create_user_with_orcid("orcid.org/0000-0001-2345-6789")
        user_url_trailing_slash = create_user_with_orcid("https://orcid.org/0000-0001-2345-6789/")
        user_url_space = create_user_with_orcid("https://orcid.org/ 0000-0001-2345-6789")
        user_orcid_prefix = create_user_with_orcid("ORCID: 0000-0001-2345-6789")
        user_space_separated = create_user_with_orcid("0000 0001 2345 6789")
        user_16_digit = create_user_with_orcid("0000000123456789")
        user_already_correct = create_user_with_orcid("0000-0001-2345-6789")
        user_invalid = create_user_with_orcid("invalid-orcid")
        user_blank = create_user_with_orcid(nil)

        expect { task.invoke("dry_run") }.to output(/Dry run mode/).to_stdout

        expect(orcid_from(copy_table, user_placeholder)).to be_nil
        expect(orcid_from(copy_table, user_url_https)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_url_http)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_url_www)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_url_no_protocol)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_url_trailing_slash)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_url_space)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_orcid_prefix)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_space_separated)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_16_digit)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_already_correct)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_invalid)).to eq("invalid-orcid")
        expect(orcid_from(copy_table, user_blank)).to be_nil

        # Original users table is unchanged
        expect(orcid_from("users", user_placeholder)).to eq("none")
        expect(orcid_from("users", user_url_https)).to eq("https://orcid.org/0000-0001-2345-6789")
        expect(orcid_from("users", user_already_correct)).to eq("0000-0001-2345-6789")
      end
    end
  end

  describe "real_run mode" do
    it "transforms ORCID values directly in the users table" do
      user_placeholder = create_user_with_orcid("none")
      user_url_https = create_user_with_orcid("https://orcid.org/0000-0001-2345-6789")
      user_url_space = create_user_with_orcid("https://orcid.org/ 0000-0001-2345-6789")
      user_orcid_prefix = create_user_with_orcid("ORCID: 0000-0001-2345-6789")
      user_space_separated = create_user_with_orcid("0000 0001 2345 6789")
      user_16_digit = create_user_with_orcid("0000000123456789")
      user_already_correct = create_user_with_orcid("0000-0001-2345-6789")
      user_invalid = create_user_with_orcid("invalid-orcid")
      user_blank = create_user_with_orcid(nil)

      expect { task.invoke("real_run") }.to output(/Real run mode/).to_stdout

      expect(orcid_from("users", user_placeholder)).to be_nil
      expect(orcid_from("users", user_url_https)).to eq("0000-0001-2345-6789")
      expect(orcid_from("users", user_url_space)).to eq("0000-0001-2345-6789")
      expect(orcid_from("users", user_orcid_prefix)).to eq("0000-0001-2345-6789")
      expect(orcid_from("users", user_space_separated)).to eq("0000-0001-2345-6789")
      expect(orcid_from("users", user_16_digit)).to eq("0000-0001-2345-6789")
      expect(orcid_from("users", user_already_correct)).to eq("0000-0001-2345-6789")
      expect(orcid_from("users", user_invalid)).to eq("invalid-orcid")
      expect(orcid_from("users", user_blank)).to be_nil
    end
  end

  describe "default mode" do
    it "uses dry_run when no mode is provided" do
      freeze_time do
        copy_table = "users_copy-#{Time.current.strftime('%Y-%m-%d-%H%M%S')}"
        @copy_tables << copy_table
        user = create_user_with_orcid("https://orcid.org/0000-0001-2345-6789")

        expect { task.invoke }.to output(/Dry run mode/).to_stdout

        expect(orcid_from(copy_table, user)).to eq("0000-0001-2345-6789")
        expect(orcid_from("users", user)).to eq("https://orcid.org/0000-0001-2345-6789")
      end
    end
  end

  describe "invalid mode" do
    it "raises an ArgumentError" do
      expect { task.invoke("invalid") }.to raise_error(ArgumentError, /Invalid mode/)
    end
  end
end

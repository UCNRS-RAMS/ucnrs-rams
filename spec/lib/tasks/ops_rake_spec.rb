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
  end

  def create_user_with_orcid(orcid)
    create(:user, orcid: orcid)
  end

  def orcid_from(table, user_id)
    connection.select_value("SELECT orcid FROM `#{table}` WHERE id = #{user_id}")
  end

  describe "dry_run mode" do
    it "copies users to a timestamped table and transforms ORCID values without modifying the original users table" do
      freeze_time do
        copy_table = "users_copy-#{Time.current.strftime('%Y-%m-%d-%H%M%S')}"

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

        expect(orcid_from(copy_table, user_placeholder.id)).to be_nil
        expect(orcid_from(copy_table, user_url_https.id)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_url_http.id)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_url_www.id)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_url_no_protocol.id)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_url_trailing_slash.id)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_url_space.id)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_orcid_prefix.id)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_space_separated.id)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_16_digit.id)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_already_correct.id)).to eq("0000-0001-2345-6789")
        expect(orcid_from(copy_table, user_invalid.id)).to eq("invalid-orcid")
        expect(orcid_from(copy_table, user_blank.id)).to be_nil

        # Original users table is unchanged
        expect(User.find(user_placeholder.id).orcid).to eq("none")
        expect(User.find(user_url_https.id).orcid).to eq("https://orcid.org/0000-0001-2345-6789")
        expect(User.find(user_already_correct.id).orcid).to eq("0000-0001-2345-6789")
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

      expect(User.find(user_placeholder.id).orcid).to be_nil
      expect(User.find(user_url_https.id).orcid).to eq("0000-0001-2345-6789")
      expect(User.find(user_url_space.id).orcid).to eq("0000-0001-2345-6789")
      expect(User.find(user_orcid_prefix.id).orcid).to eq("0000-0001-2345-6789")
      expect(User.find(user_space_separated.id).orcid).to eq("0000-0001-2345-6789")
      expect(User.find(user_16_digit.id).orcid).to eq("0000-0001-2345-6789")
      expect(User.find(user_already_correct.id).orcid).to eq("0000-0001-2345-6789")
      expect(User.find(user_invalid.id).orcid).to eq("invalid-orcid")
      expect(User.find(user_blank.id).orcid).to be_nil
    end
  end

  describe "default mode" do
    it "uses dry_run when no mode is provided" do
      freeze_time do
        copy_table = "users_copy-#{Time.current.strftime('%Y-%m-%d-%H%M%S')}"
        user = create_user_with_orcid("https://orcid.org/0000-0001-2345-6789")

        expect { task.invoke }.to output(/Dry run mode/).to_stdout

        expect(orcid_from(copy_table, user.id)).to eq("0000-0001-2345-6789")
        expect(User.find(user.id).orcid).to eq("https://orcid.org/0000-0001-2345-6789")
      end
    end
  end

  describe "invalid mode" do
    it "raises an ArgumentError" do
      expect { task.invoke("invalid") }.to raise_error(ArgumentError, /Invalid mode/)
    end
  end
end

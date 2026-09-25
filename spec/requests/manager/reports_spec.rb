require "rails_helper"

RSpec.describe Manager::ReportsController, type: :request do
  describe "GET report_part_1" do
    # query_part_1 needs a reserve with a managing campus plus visits to report
    # on, and runs against the stored routines loaded in spec/support/db_routines.rb.
    before do
      load Rails.root.join("db/seeds/base.rb")
      load Rails.root.join("db/seeds/development.rb")
    end

    it "renders the annual report for the primer reserve manager" do
      sign_in(User.find_by!(email: "manager@single-tree.test"))
      reserve = Reserve.find_by!(name: "A Single Tree")

      get report_part_1_manager_reserve_report_path(reserve, Date.current.year)

      expect(response).to be_ok
      expect(response.body).to include("Part 1. Reserve Use Data")
    end
  end
end

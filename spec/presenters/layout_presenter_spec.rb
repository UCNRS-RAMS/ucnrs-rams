require "rails_helper"

RSpec.describe LayoutPresenter do
  let(:user) { create(:user, :confirmed) }

  describe "delegations" do
    subject { LayoutPresenter.new(current_user: build(:user), current_reserve: build(:reserve)) }
    it { is_expected.to delegate_method(:name).to(:current_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:managing_campus).to(:current_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:full_name).to(:current_user).with_prefix(true) }
  end

  describe "#current_user_logged_in?" do
    context "when current user is set and therefore logged in" do
      it "returns true" do
        user = create(:user)
        presenter = LayoutPresenter.new(current_user: user)

        expect(presenter.current_user_logged_in?).to eq true
      end
    end

    context "when current user is NOT set and therefore NOT logged in" do
      it "returns false" do
        presenter = LayoutPresenter.new(current_user: "")

        expect(presenter.current_user_logged_in?).to eq false
      end
    end
  end

  describe "#current_user_is_manager_admin?" do
    context "when current user is a personnel for a reserve" do
      it "returns true" do
        user = create(:user)
        create(:reserve_personnel, user: user)
        presenter = LayoutPresenter.new(current_user: user)

        expect(presenter.current_user_is_manager_admin?).to eq true
      end
    end

    context "when current user is an admin" do
      it "returns true" do
        user = create(:user, admin: true)
        presenter = LayoutPresenter.new(current_user: user)

        expect(presenter.current_user_is_manager_admin?).to eq true
      end
    end

    context "when current user is NOT a personnel or an admin" do
      it "returns false" do
        user = create(:user)
        presenter = LayoutPresenter.new(current_user: user)

        expect(presenter.current_user_is_manager_admin?).to eq false
      end
    end
  end

  describe "#current_user_is_admin?" do
    context "when current user is an admin" do
      it "returns true" do
        user = create(:user, admin: true)
        presenter = LayoutPresenter.new(current_user: user)

        expect(presenter.current_user_is_admin?).to eq true
      end
    end

    context "when current user is NOT an admin" do
      it "returns false" do
        user = create(:user)
        presenter = LayoutPresenter.new(current_user: user)

        expect(presenter.current_user_is_admin?).to eq false
      end
    end
  end

  describe "#current_user_managed_reserves" do
    it "returns list of reserve user is a personnel of" do
      user = create(:user)
      reserve1 = create(:reserve, name: "reserve xyz")
      reserve2 = create(:reserve, name: "reserve abc")
      reserve3 = create(:reserve, name: "reserve lmn")
      create(:reserve_personnel, user: user, reserve: reserve1)
      create(:reserve_personnel, user: user, reserve: reserve2)
      create(:reserve_personnel, user: user, reserve: reserve3)
      presenter = LayoutPresenter.new(current_user: user)

      current_user_managed_reserves = presenter.current_user_managed_reserves

      expect(current_user_managed_reserves).to match_array [reserve1, reserve2, reserve3]
    end

    it "returns the list of reserves alphabetically" do
      user = create(:user)
      reserve1 = create(:reserve, name: "reserve xyz")
      reserve2 = create(:reserve, name: "reserve abc")
      reserve3 = create(:reserve, name: "reserve lmn")
      create(:reserve_personnel, user: user, reserve: reserve1)
      create(:reserve_personnel, user: user, reserve: reserve2)
      create(:reserve_personnel, user: user, reserve: reserve3)
      presenter = LayoutPresenter.new(current_user: user)

      current_user_managed_reserves = presenter.current_user_managed_reserves

      expect(current_user_managed_reserves).to eq [reserve2, reserve3, reserve1]
    end

    context "when current user is NOT a personnel" do
      it "returns empty array" do
        user = create(:user)
        presenter = LayoutPresenter.new(current_user: user)

        current_user_managed_reserves = presenter.current_user_managed_reserves

        expect(current_user_managed_reserves).to eq []
      end
    end
  end

  describe "#admin_reserves" do
    it "returns the list of reserves alphabetically" do
      user = create(:user, admin: true)
      reserve1 = create(:reserve, name: "reserve xyz")
      reserve2 = create(:reserve, name: "reserve abc")
      reserve3 = create(:reserve, name: "reserve lmn")
      presenter = LayoutPresenter.new(current_user: user)

      admin_reserves = presenter.admin_reserves

      expect(admin_reserves).to eq [reserve2, reserve3, reserve1]
    end

    context "when current user is NOT an admin" do
      it "returns empty array" do
        user = create(:user)
        presenter = LayoutPresenter.new(current_user: user)

        admin_reserves = presenter.admin_reserves

        expect(admin_reserves).to eq []
      end
    end
  end

  describe "#current_user_first_managed_reserve" do
    it "returns user first managed reserve id" do
      user = create(:user)
      reserve1 = create(:reserve, name: "reserve xyz")
      reserve2 = create(:reserve, name: "reserve abc")
      reserve3 = create(:reserve, name: "reserve lmn")
      create(:reserve_personnel, user: user, reserve: reserve1)
      create(:reserve_personnel, user: user, reserve: reserve2)
      create(:reserve_personnel, user: user, reserve: reserve3)
      presenter = LayoutPresenter.new(current_user: user)

      current_user_first_managed_reserve = presenter.current_user_first_managed_reserve

      expect(current_user_first_managed_reserve).to eq reserve1.id
    end
  end

  describe "#in_manager_namespace?" do
    context "when controller path is in manager namespace" do
      it "returns true" do
        presenter = LayoutPresenter.new(controller_path: "manager/test1/test2/test3")

        expect(presenter.in_manager_namespace?).to eq true
      end
    end

    context "when controller path is NOT in manager namespace" do
      it "returns false" do
        presenter = LayoutPresenter.new(controller_path: "test1/test2/test3")

        expect(presenter.in_manager_namespace?).to eq false
      end
    end
  end

  describe "#current_reserve_managing_campus_name" do
    it "returns the name of the current reserve managing campus name" do
      institution = create :institution, name: "The Institution"
      reserve = create :reserve, managing_campus: institution
      presenter = LayoutPresenter.new(current_reserve: reserve)

      current_reserve_managing_campus_name = presenter.current_reserve_managing_campus_name

      expect(current_reserve_managing_campus_name).to eq "The Institution"
    end
  end

  describe "#current_user_dashboard" do
    it "returns the dashboard as symbol" do
      presenter = LayoutPresenter.new(dashboard: "dashboard")

      current_user_dashboard = presenter.current_user_dashboard

      expect(current_user_dashboard).to eq :dashboard
    end
  end

  describe "#current_reserve_logo" do
    context "when a reserve logo is uploaded" do
      it "returns the reserve logo" do
        reserve = build :reserve, :with_logo
        presenter = LayoutPresenter.new(current_reserve: reserve)

        current_reserve_logo = presenter.current_reserve_logo

        expect(current_reserve_logo).to match(/medium_test-image.jpeg/)
      end
    end

    context "when there is no uploaded reserve logo" do
      it "returns the path of the reserve logo placeholder" do
        reserve = build :reserve
        presenter = LayoutPresenter.new(current_reserve: reserve)

        current_reserve_logo = presenter.current_reserve_logo

        expect(current_reserve_logo).to eq("ucnature-logo.png")
      end
    end
  end
end

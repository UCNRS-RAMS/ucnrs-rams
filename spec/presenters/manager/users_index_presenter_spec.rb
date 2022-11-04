require "rails_helper"

RSpec.describe Manager::UsersIndexPresenter do
  describe "delegations" do
    subject { Manager::UsersIndexPresenter.new() }
    it { is_expected.to delegate_method(:user_search_filter).to(:filter) }
    it { is_expected.to delegate_method(:sort_by_filter).to(:filter) }
    it { is_expected.to delegate_method(:user_role_filter).to(:filter) }
    it { is_expected.to delegate_method(:user_institution_type_filter).to(:filter) }
    it { is_expected.to delegate_method(:present?).to(:filter).with_prefix(true) }
  end

  describe "#users" do
    it "presents the user records wrapped in Manager::UserShowPresenter" do
      user1 = create(:user)
      user2 = create(:user)
      presenter = Manager::UsersIndexPresenter.new()

      users = presenter.users

      expect(users.map(&:id)).to match_array [user1.id, user2.id]
      expect(users).to all(be_a(Manager::UserShowPresenter))
    end
  end

  describe "#user_scope" do
    it "returns only users with first name or last name containing the given search term" do
      user1 = create(:user, first_name: "bender", last_name: "rodriguez")
      create(:user, first_name: "first", last_name: "one")
      create(:user, first_name: "first", last_name: "two")
      user2 = create(:user, first_name: "rod", last_name: "stewart")
      presenter = Manager::UsersIndexPresenter.new(filter: { user_search: "rod" })

      user_scope = presenter.user_scope

      expect(user_scope).to match_array [user1, user2]
    end

    it "returns only users with given role" do
      user1 = create(:user, role: "faculty")
      create(:user, role: "research_scientist")
      create(:user, role: "k_12_instructor")
      user2 = create(:user, role: "faculty")
      presenter = Manager::UsersIndexPresenter.new(filter: { user_role: "faculty" })

      user_scope = presenter.user_scope

      expect(user_scope).to match_array [user1, user2]
    end

    it "returns only users with given with_institution_type" do
      uc_type_institution = create(:institution, institution_type: "university_of_california")
      k_12_type_institution = create(:institution, institution_type: "k_12_education")
      business_entity_type_institution = create(:institution, institution_type: "business_entity")
      user1 = create(:user, institution: uc_type_institution)
      create(:user, institution: business_entity_type_institution)
      create(:user, institution: k_12_type_institution)
      user2 = create(:user, institution: uc_type_institution)
      presenter = Manager::UsersIndexPresenter.new(
        filter: { user_institution_type: "university_of_california" }
      )

      user_scope = presenter.user_scope

      expect(user_scope).to match_array [user1, user2]
    end


    context "when given sort_by 'created_at'" do
      it "returns users sorted by latest created_at first" do
        user1 = create(:user, created_at: 2.year.ago)
        user2 = create(:user, created_at: 3.year.ago)
        user3 = create(:user, created_at: 1.year.ago)
        user4 = create(:user, created_at: 4.year.ago)
        presenter = Manager::UsersIndexPresenter.new(filter: { sort_by: "created_at" })

        user_scope = presenter.user_scope

        expect(user_scope).to eq [user3, user1, user2, user4]
      end
    end

    context "when given sort_by 'user_id'" do
      it "returns users sorted by higher user id first" do
        user1 = create(:user)
        user2 = create(:user)
        user3 = create(:user)
        user4 = create(:user)
        presenter = Manager::UsersIndexPresenter.new(filter: { sort_by: "user_id" })

        user_scope = presenter.user_scope

        expect(user_scope).to eq [user4, user3, user2, user1]
      end
    end

    context "when given sort_by 'last_name'" do
      it "returns users sorted alphabetically by user last name" do
        user1 = create(:user, last_name: "d")
        user2 = create(:user, last_name: "a")
        user3 = create(:user, last_name: "z")
        user4 = create(:user, last_name: "y")
        presenter = Manager::UsersIndexPresenter.new(filter: { sort_by: "last_name" })

        user_scope = presenter.user_scope

        expect(user_scope).to eq [user2, user1, user4, user3]
      end
    end


    it "returns a maximum of 10 users" do
      create_list(:user, 11)
      presenter = Manager::UsersIndexPresenter.new(page: 1)

      scope = presenter.user_scope

      expect(scope.length).to eq 10
    end
  end

  describe "#user_role_options" do
    it "is an array of user role options translated" do
      allow(User).to receive(:roles).and_return(
        {
          "role_1_key" => "role_1",
          "role_2_key" => "role_2",
        }
      )
      allow(I18n).to receive(:t)
        .with("all")
        .and_return("all_translate")
      allow(I18n).to receive(:t)
        .with("universal.roles.role_1_key")
        .and_return("role_1_key_translate")
      allow(I18n).to receive(:t)
        .with("universal.roles.role_2_key")
        .and_return("role_2_key_translate")
      presenter = Manager::UsersIndexPresenter.new()

      user_role_options = presenter.user_role_options

      expect(user_role_options.to_a).to match_array [
        ["all_translate", nil],
        ["role_1_key_translate", "role_1_key"],
        ["role_2_key_translate", "role_2_key"],
      ]
    end
  end

  describe "#user_institution_type_options" do
    it "is an array of institution type options translated" do
      allow(Institution).to receive(:institution_types).and_return(
        {
          "institution_type_1_key" => "institution_type_1",
          "institution_type_2_key" => "institution_type_2",
        }
      )
      allow(I18n).to receive(:t)
        .with("all")
        .and_return("all_translate")
      allow(I18n).to receive(:t)
        .with("universal.institution_types.institution_type_1_key")
        .and_return("institution_type_1_key_translate")
      allow(I18n).to receive(:t)
        .with("universal.institution_types.institution_type_2_key")
        .and_return("institution_type_2_key_translate")
      presenter = Manager::UsersIndexPresenter.new()

      user_institution_type_options = presenter.user_institution_type_options

      expect(user_institution_type_options.to_a).to match_array [
        ["all_translate", nil],
        ["institution_type_1_key_translate", "institution_type_1_key"],
        ["institution_type_2_key_translate", "institution_type_2_key"],
      ]
    end
  end

  describe "#sort_by_options" do
    it "is an array of sort by options" do
      presenter = Manager::UsersIndexPresenter.new()

      sort_by_options = presenter.sort_by_options

      expect(sort_by_options.to_a).to match_array [
        [I18n.t("manager.users.search.user_id"), :user_id],
        [I18n.t("manager.users.search.last_name"), :last_name],
        [I18n.t("manager.users.search.created_at"), :created_at],
      ]
    end
  end

  describe "#show_options_class" do
    context "when filter is present" do
      it "returns class name to hide the html element" do
        presenter = Manager::UsersIndexPresenter.new(filter: "something")

        show_options_class = presenter.show_options_class

        expect(show_options_class).to eq "loadhide"
      end
    end

    context "when filter is NOT present" do
      it "returns class name to show the html element" do
        presenter = Manager::UsersIndexPresenter.new(filter: nil)

        show_options_class = presenter.show_options_class

        expect(show_options_class).to eq "show"
      end
    end
  end

  describe "#hide_options_class" do
    context "when filter is present" do
      it "returns class name to show the html element" do
        presenter = Manager::UsersIndexPresenter.new(filter: "something")

        hide_options_class = presenter.hide_options_class

        expect(hide_options_class).to eq "show"
      end
    end

    context "when filter is NOT present" do
      it "returns class name to hide the html element" do
        presenter = Manager::UsersIndexPresenter.new(filter: nil)

        hide_options_class = presenter.hide_options_class

        expect(hide_options_class).to eq "loadhide"
      end
    end
  end
end

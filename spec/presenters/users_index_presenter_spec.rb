require "rails_helper"

RSpec.describe UsersIndexPresenter, type: :presenter do
  it "takes a query string and outputs presented users" do
    users = [
      create(:user, first_name: "John", last_name: "Smith"),
      create(:user, first_name: "Joan", last_name: "Robin"),
      create(:user, first_name: "Robyn", last_name: "Wrong"),
    ]
    allow(User).to receive(:search).and_return(users)
    presenter = UsersIndexPresenter.new(query: "Joen")

    results = presenter.users

    expect(User).to have_received(:search).with("Joen")
    results.each.with_index do |result, i|
      expect(result).to be_a UserPresenter
      expect(result.id).to eq users[i].id
    end
  end
end

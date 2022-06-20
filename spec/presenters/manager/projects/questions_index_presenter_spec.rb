require "rails_helper"

describe "#form_url" do
  it "returns permit url in manager namespace" do
    reserve = create(:reserve)
    project = create(:project, reserve_id: reserve.id)
    presenter = Manager::Projects::QuestionsIndexPresenter.new(project: project)

    expect(presenter.form_url).to eq("/manager/reserves/#{reserve.id}/projects/#{project.id}/permit")
  end
end

require "rails_helper"

RSpec.describe "projects/fundings/index.turbo_stream.erb", type: :view do
  it "renders an empty modal" do
    assign(:presenter, Projects::FundingsIndexPresenter.new(
      current_step: 4,
      project: build_stubbed(:project),
    ))

    render template: "projects/fundings/index", formats: [:turbo_stream]

    expect(rendered).to include(
      '<turbo-stream action="replace" target="modal-content"'
    )
    expect(rendered).to include(
      '<turbo-frame id="modal-content" class="modal-content empty"'
    )
  end

  it "renders the table of funding sources" do
    assign(:presenter, Projects::FundingsIndexPresenter.new(
      current_step: 4,
      project: build_stubbed(:project),
    ))

    render template: "projects/fundings/index", formats: [:turbo_stream]

    expect(rendered).to include(
      '<turbo-stream action="replace" target="funding-table"'
    )
    expect(rendered).to include(
      '<turbo-frame id="funding-table'
    )
  end
end

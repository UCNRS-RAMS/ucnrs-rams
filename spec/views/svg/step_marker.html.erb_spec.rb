require "rails_helper"

RSpec.describe "svg/_step_marker.html.erb", type: :view do
  let(:default_options) {{
    number: 1,
    size: 24,
    color: "#002045",
    fill_opacity: "1",
    use_checkmark: false,
    invert: false,
  }}

  describe "static options" do
    it "fills in number, size, color, and opacity" do
      presenter = StepMarkerPresenter.new(**default_options.merge({
        number: 3,
        color: "#336699",
        size: 44,
        fill_opacity: "0.5",
      }))

      render partial: "svg/step_marker", locals: { presenter: presenter }

      doc = Capybara.string(rendered)
      expect(doc).to have_css("circle", count: 1)
      expect(doc).to have_css("circle[fill='#336699']")
      expect(doc).to have_css("circle[stroke='#336699']")
      expect(doc).to have_css("circle[fill-opacity='0.5']")
      expect(doc).to have_css("svg[height='44'][width='44']")
      expect(doc).to have_css("svg defs #content-3")
      expect(doc).to have_css("svg defs mask#invert-3 use[href='#content-3']")
    end
  end

  describe "invert" do
    it "applies the mask to the circle when true" do
      presenter = StepMarkerPresenter.new(**default_options.merge({
        number: 3,
        invert: true,
      }))

      render partial: "svg/step_marker", locals: { presenter: presenter }

      doc = Capybara.string(rendered)
      expect(doc).to have_css("svg circle[mask='url(#invert-3)']")
      expect(doc).to have_no_css("svg > use")
    end

    it "uses the content when false" do
      presenter = StepMarkerPresenter.new(**default_options.merge({
        number: 3,
        invert: false,
      }))

      render partial: "svg/step_marker", locals: { presenter: presenter }

      doc = Capybara.string(rendered)
      expect(doc).to have_css("svg > use[href='#content-3']")
      expect(doc).to have_no_css("svg circle[mask='url(#invert-3)']")
    end
  end

  describe "use_checkmark" do
    it "generates the checkmark when true" do
      presenter = StepMarkerPresenter.new(**default_options.merge({
        number: 3,
        use_checkmark: true,
      }))

      render partial: "svg/step_marker", locals: { presenter: presenter }

      doc = Capybara.string(rendered)
      expect(doc).to have_css("svg defs polyline#content-3")
    end

    it "generates the number when false" do
      presenter = StepMarkerPresenter.new(**default_options.merge({
        number: 3,
        use_checkmark: false,
      }))

      render partial: "svg/step_marker", locals: { presenter: presenter }

      doc = Capybara.string(rendered)
      expect(doc).to have_css("svg defs text#content-3")
    end
  end
end

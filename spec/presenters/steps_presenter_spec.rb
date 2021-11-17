require "rails_helper"

RSpec.describe StepsPresenter do
  describe "#step_class" do
    it "is the correct class based on the supplied step number" do
      presenter = StepsPresenter.new(2)

      expect(presenter.step_class(1)).to eq "complete"
      expect(presenter.step_class(2)).to eq "active"
      expect(presenter.step_class(3)).to eq "upcoming"
    end
  end

  describe "#svg" do
    it "returns the right `render` args based on the supplied step number" do
      presenter = StepsPresenter.new(2)

      expect(presenter.svg(1)).to eq({
        partial: "svg/step_marker",
        locals: { presenter: StepMarkerPresenter.new(
          number: 1,
          size: 24,
          color: "#556b72",
          fill_opacity: "1",
          use_checkmark: true,
          invert: true,
        )}
      })
      expect(presenter.svg(2)).to eq({
        partial: "svg/step_marker",
        locals: { presenter: StepMarkerPresenter.new(
          number: 2,
          size: 24,
          color: "#002045",
          fill_opacity: "1",
          use_checkmark: false,
          invert: true,
        )}
      })
      expect(presenter.svg(3)).to eq({
        partial: "svg/step_marker",
        locals: { presenter: StepMarkerPresenter.new(
          number: 3,
          size: 24,
          color: "#556b72",
          fill_opacity: "0",
          use_checkmark: false,
          invert: false,
        )}
      })
    end
  end
end

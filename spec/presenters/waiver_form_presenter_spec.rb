require "rails_helper"

RSpec.describe WaiverFormPresenter do
  describe "delegations" do
    let(:form) { WaiverForm.new }
    subject { WaiverFormPresenter.new(form: form) }

    it { is_expected.to delegate_missing_methods_to(:form) }
  end
end

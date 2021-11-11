# In view specs, use this to fake out form rendering. It should be used as
# an object to call `fields_for` on:
#
# FakeForm.fields_for(<object>) do |form|
#   <render your view>
# end
#
class FakeForm
  class << self
    include ActionView::Helpers::FormOptionsHelper
    include ActionView::Helpers::FormHelper
    attr_accessor :output_buffer
  end
end

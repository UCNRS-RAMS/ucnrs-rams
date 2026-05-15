# I'm not sure this should be overridden since it seems size is already a property of Struct, so maybe this
# should be changed (not sure how it's used)
# rubocop:disable Lint/StructNewOverride
StepMarkerPresenter = Struct.new(:number, :color, :size, :fill_opacity, :use_checkmark, :invert, keyword_init: true)
# rubocop:enable Lint/StructNewOverride
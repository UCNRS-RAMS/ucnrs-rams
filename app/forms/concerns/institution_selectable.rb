# frozen_string_literal: true

# Shared helper for forms that let a user pick an institution or a ROR
# record from the combined autocomplete field. Each including form still
# controls its own transaction and error-reporting details (which errors
# object to report to, which attribute to blame, whether to raise or roll
# back); this only avoids repeating the "build a selection, resolve it, and
# translate failures into errors" boilerplate.
module InstitutionSelectable
  extend ActiveSupport::Concern

  private

  # Resolves (and persists, if it's a new ROR-backed institution) the
  # selection identified by `id`/`type`. Returns the institution on success.
  # On failure, appends the selection's error messages onto `error_target`
  # (an ActiveModel::Errors) under `error_attribute` and returns nil.
  def resolve_institution_selection(id:, type:, error_target:, error_attribute:)
    selection = InstitutionSelection.new(id: id, type: type)
    institution = selection.resolve_and_save
    return institution if institution

    selection.errors.each { |error| error_target.add(error_attribute, error.message) }
    nil
  end
end

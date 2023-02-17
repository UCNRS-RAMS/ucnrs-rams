class Manager::Visits::AmenityVisitsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_manager!
  before_action :is_administrator_or_accountant!

  def update
    if amenity_visit.save
      @form = InvoiceForm.new(params: { visit_id: params[:visit_id] }, remove_filter: true)
      @presenter = Manager::Visits::InvoicesIndexPresenter.new(visit: visit, form: @form)
    end
  end

  private

  def amenity_visit
    AmenityVisit.find_by(id: params[:visits_amenity_form][:id]).tap do |amenity_visit|
        amenity_visit.invoice_now = params[:visits_amenity_form][:invoice_now]
    end
  end

  def visit
    Visit.find(params[:visit_id])
  end
end

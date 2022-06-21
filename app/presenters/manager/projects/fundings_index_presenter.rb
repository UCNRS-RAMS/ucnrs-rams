class Manager::Projects::FundingsIndexPresenter < Projects::FundingsIndexPresenter
  def initialize(project:, form: nil)
    super(current_step: 0, project: project, form: form)
  end

  def fundings
    fundings_scope.map do |funding|
      Manager::Projects::FundingPresenter.new(funding)
    end
  end

  private

  def fundings_scope
    Funding
      .for_project(project)
      .includes(:project)
      .alphabetized
  end
end

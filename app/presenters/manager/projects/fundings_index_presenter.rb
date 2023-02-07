class Manager::Projects::FundingsIndexPresenter < Projects::FundingsIndexPresenter
  def initialize(project:, reserve:, form: nil)
    super(current_step: 4, project: project, form: form)
    @reserve = reserve
  end

  attr_reader :reserve

  def fundings
    fundings_scope.map do |funding|
      Manager::Projects::FundingPresenter.new(funding: funding, reserve: reserve)
    end
  end

  private

  def fundings_scope
    Funding
      .for_project(project)
      .alphabetized
  end
end

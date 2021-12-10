class UsersIndexPresenter
  def initialize(query:)
    @query = query
  end

  attr_reader :query

  def users
    results.map do |user|
      UserPresenter.new(user)
    end
  end

  private

  def results
    User.search(query)
  end
end

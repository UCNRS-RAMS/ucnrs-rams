class UsersIndexPresenter
  MINIMUM_QUERY_LENGTH = 2

  def initialize(query:)
    @query = query.to_s
  end

  attr_reader :query

  def users
    results.map do |user|
      UserPresenter.new(user)
    end
  end

  private

  def results
    return User.none if query.strip.length < MINIMUM_QUERY_LENGTH

    User.search(query)
  end
end

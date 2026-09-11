# frozen_string_literal: true

# An external application authorized to read RAMS data over the JSON API.
#
# Only the SHA-256 digest of the token is persisted. The plaintext token is
# available once, via #plain_text_token, on the instance that created or
# rotated it. If the client belongs to a reserve it may only see that reserve's
# projects; a client with no reserve is a platform-wide integration.
class ApiClient < ApplicationRecord
  TOKEN_LENGTH = 32
  TOKEN_PREFIX = "rams_"

  belongs_to :reserve, optional: true

  attr_reader :plain_text_token

  validates :name, presence: true
  validates :token_digest, presence: true, uniqueness: true

  before_validation :assign_token

  def self.authenticate(token)
    return nil if token.blank?

    where(active: true).find_by(token_digest: digest_for(token))
  end

  def self.digest_for(token)
    Digest::SHA256.hexdigest(token)
  end

  def self.generate_token
    "#{TOKEN_PREFIX}#{SecureRandom.urlsafe_base64(TOKEN_LENGTH)}"
  end

  # Projects this client is allowed to read.
  def projects
    reserve.present? ? Project.where(reserve: reserve) : Project.all
  end

  # Issues a new token, invalidating the previous one, and returns it.
  def rotate_token!
    token = self.class.generate_token
    update!(token_digest: self.class.digest_for(token))
    @plain_text_token = token
    self
  end

  private

  def assign_token
    return if token_digest.present?

    @plain_text_token = self.class.generate_token
    self.token_digest = self.class.digest_for(@plain_text_token)
  end
end

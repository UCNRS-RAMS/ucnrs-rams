# frozen_string_literal: true

# An external application authorized to read RAMS data over the JSON API.
#
# Only the SHA-256 digest of the token is persisted. The plaintext token is
# available once, via #plain_text_token, on the instance that created or
# rotated it. A client may optionally be scoped to a single reserve; endpoint
# controllers decide how that scope narrows what they return.
class ApiClient < ApplicationRecord
  # Number of random bytes encoded into each token.
  TOKEN_LENGTH = 32
  # Prefix that identifies a leaked value as a RAMS API token.
  TOKEN_PREFIX = "rams_"

  belongs_to :reserve, optional: true

  # @return [String, nil] the plaintext token, available only on the instance
  #   that just created or rotated it
  attr_reader :plain_text_token

  validates :name, presence: true
  validates :token_digest, presence: true, uniqueness: true

  before_validation :assign_token

  # @param token [String, nil] the plaintext bearer token presented by a client
  # @return [ApiClient, nil] the active client whose token matches, or nil when
  #   the token is blank, unknown, or belongs to a deactivated client
  def self.authenticate(token)
    return nil if token.blank?

    where(active: true).find_by(token_digest: digest_for(token))
  end

  # @param token [String] a plaintext token
  # @return [String] the SHA-256 hex digest stored in +token_digest+
  def self.digest_for(token)
    Digest::SHA256.hexdigest(token)
  end

  # @return [String] a new, unpersisted plaintext token
  def self.generate_token
    "#{TOKEN_PREFIX}#{SecureRandom.urlsafe_base64(TOKEN_LENGTH)}"
  end

  # Projects this client is allowed to read. A client with a reserve sees only
  # that reserve's projects; a client with no reserve is a platform-wide
  # integration and sees all of them.
  #
  # @return [ActiveRecord::Relation<Project>]
  def visible_projects
    reserve.present? ? Project.where(reserve: reserve) : Project.all
  end

  # Issues a new token, invalidating the previous one, and returns it.
  #
  # @return [self] the client, with {#plain_text_token} set to the new token
  def rotate_token!
    token = self.class.generate_token
    update!(token_digest: self.class.digest_for(token))
    @plain_text_token = token
    self
  end

  private

  # @return [void]
  def assign_token
    return if token_digest.present?

    @plain_text_token = self.class.generate_token
    self.token_digest = self.class.digest_for(@plain_text_token)
  end
end

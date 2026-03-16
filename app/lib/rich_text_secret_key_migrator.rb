class RichTextSecretKeyMigrator
  ACTIVE_STORAGE_PATH = "rails/active_storage".freeze
  SGID_PATTERN        = /sgid="([^"]+)"/

  class UrlSafeVerifier < ActiveSupport::MessageVerifier
    private

    def encode(data, **)
      ::Base64.urlsafe_encode64(data)
    end

    def decode(data, **)
      ::Base64.urlsafe_decode64(data)
    end
  end

  def initialize(text, old_secret_key_base:)
    @text = text
    @old_secret_key_base = old_secret_key_base
  end

  def process
    result = replace_signed_ids_in_urls(@text)
    replace_sgids(result)
  end

  private

  def old_key_generator
    @old_key_generator ||= ActiveSupport::CachingKeyGenerator.new(
      ActiveSupport::KeyGenerator.new(@old_secret_key_base, iterations: 1000),
    )
  end

  def old_signed_id_verifier
    @old_signed_id_verifier ||= begin
      secret = old_key_generator.generate_key("ActiveStorage")
      ActiveSupport::MessageVerifier.new(secret)
    end
  end

  def old_sgid_verifier
    @old_sgid_verifier ||= begin
      secret = old_key_generator.generate_key("signed_global_ids")
      UrlSafeVerifier.new(secret)
    end
  end

  def decode_signed_id(signed_id)
    old_signed_id_verifier.verify(signed_id, purpose: :blob_id)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end

  def convert_signed_id(signed_id)
    blob_id = decode_signed_id(signed_id)
    return nil unless blob_id

    ActiveStorage::Blob.find_by(id: blob_id)&.signed_id
  rescue StandardError
    nil
  end

  def extract_signed_ids(text)
    text
      .scan(URI::DEFAULT_PARSER.make_regexp)
      .flatten
      .select { |url| url&.include?(ACTIVE_STORAGE_PATH) }
      .map { |url| url.split("/")[-2] }
      .uniq
  end

  def replace_signed_ids_in_urls(text)
    extract_signed_ids(text).each do |old_id|
      new_id = convert_signed_id(old_id)
      text = text.gsub(old_id, new_id) if new_id
    end

    text
  end

  def convert_sgid(old_sgid)
    gid_uri = old_sgid_verifier.verify(old_sgid, purpose: "attachable")
    gid     = GlobalID.parse(gid_uri)
    return nil unless gid

    record = GlobalID::Locator.locate(gid)
    return nil unless record

    record.to_signed_global_id(for: "attachable", expires_in: nil).to_s
  rescue ActiveSupport::MessageVerifier::InvalidSignature, StandardError
    nil
  end

  def replace_sgids(text)
    text.gsub(SGID_PATTERN) do |match|
      old_sgid = Regexp.last_match(1)
      new_sgid = convert_sgid(old_sgid)
      new_sgid ? %(sgid="#{new_sgid}") : match
    end
  end
end

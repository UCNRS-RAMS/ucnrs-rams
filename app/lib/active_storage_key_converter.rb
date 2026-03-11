class ActiveStorageKeyConverter
  ACTIVE_STORAGE_PATH = "rails/active_storage".freeze
  VERIFIER_NAME       = "ActiveStorage".freeze
  SGID_PATTERN        = /sgid="([^"]+)"/

  def initialize(text)
    @text = text
  end

  def process
    result = replace_keys(@text)
    replace_sgids(result)
  end

  private

  def key_generator
    @key_generator ||= ActiveSupport::CachingKeyGenerator.new(
      ActiveSupport::KeyGenerator.new(
        Rails.application.secret_key_base,
        iterations: 1000,
        hash_digest_class: OpenSSL::Digest::SHA1,
      ),
    )
  end

  def signed_id_old_verifier
    @signed_id_old_verifier ||= begin
      secret = key_generator.generate_key(VERIFIER_NAME)
      ActiveSupport::MessageVerifier.new(secret)
    end
  end

  def signed_id_convert_key(old_key)
    blob_id = signed_id_old_verifier.verify(old_key, purpose: :blob_id)

    ActiveStorage::Blob.find_by(id: blob_id)&.signed_id
  rescue StandardError
    nil
  end

  def extract_keys(text)
    text
      .scan(URI::DEFAULT_PARSER.make_regexp)
      .flatten
      .select { |url| url&.include?(ACTIVE_STORAGE_PATH) }
      .map { |url| url.split("/")[-2] }
      .uniq
  end

  def replace_keys(text)
    extract_keys(text).each do |key|
      new_key = signed_id_convert_key(key)
      text = text.gsub(key, new_key) if new_key
    end

    text
  end

  def replace_sgids(text)
    text.gsub(SGID_PATTERN) do |match|
      new_sgid = new_sgid_from_context(Regexp.last_match.pre_match + Regexp.last_match.post_match)
      new_sgid ? %(sgid="#{new_sgid}") : match
    end
  end

  def new_sgid_from_context(surrounding_text)
    signed_id = extract_signed_id_from_url(surrounding_text)
    return nil unless signed_id

    blob = ActiveStorage::Blob.find_signed(signed_id)
    return nil unless blob

    blob.to_signed_global_id(for: "attachable", expires_in: nil).to_s
  rescue StandardError
    nil
  end

  def extract_signed_id_from_url(text)
    urls = text.scan(URI::DEFAULT_PARSER.make_regexp).flatten.compact
    url = urls.find { |u| u&.include?(ACTIVE_STORAGE_PATH) }
    return nil unless url

    url.split("/")[-2]
  end
end

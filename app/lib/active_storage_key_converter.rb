class ActiveStorageKeyConverter
  ACTIVE_STORAGE_PATH = "rails/active_storage".freeze
  VERIFIER_NAME       = "ActiveStorage".freeze

  def initialize(text)
    @text = text
  end

  def process
    replace_keys(@text)
  end

  private

  def verifier
    @verifier ||= begin
      key_generator =
        ActiveSupport::CachingKeyGenerator.new(
          ActiveSupport::KeyGenerator.new(
            Rails.application.secret_key_base,
            iterations: 1000,
            hash_digest_class: OpenSSL::Digest::SHA1
          )
        )

      secret = key_generator.generate_key(VERIFIER_NAME)
      ActiveSupport::MessageVerifier.new(secret)
    end
  end

  def convert_key(key)
    blob_id = verifier.verify(key, purpose: :blob_id)

    ActiveStorage::Blob.find_by(id: blob_id).try(:signed_id) rescue nil
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
      new_key = convert_key(key)
      text = text.gsub(key, new_key) if new_key
    end

    text
  end
end

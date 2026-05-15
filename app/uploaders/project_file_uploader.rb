class ProjectFileUploader < CarrierWave::Uploader::Base
  def filename
    "#{file_name}_#{file_date}#{file_extension}"
  end

  def extension_allowlist
    ["txt", "pdf", "rtf", "doc", "docx", "jpg", "jpeg", "gif", "png"]
  end

  def content_type_allowlist
    [
      "text/plain",
      "application/pdf",
      "application/rtf",
      "application/msword",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      /image\//,
    ]
  end

  def date
    match = self.identifier.match(/(.*)_(\d{4}-\d{2}-\d{2})(.*)/)
    match[2] if match
  end

  def name
    match = self.identifier.match(/(.*)_(\d{4}-\d{2}-\d{2})(.*)/)
    "#{match[1]}#{match[3]}" if match
  end

  def store_dir
    [
      ("uploads" if Rails.env.development?),
      "#{model.class.to_s.underscore}",
      "#{mounted_as}",
      "#{model.id || 'null'}",
    ].compact_blank.join("/")
  end

  private

  def file_name
    self.file&.filename&.split(".")&.[](0)
  end

  def file_date
    Time.zone.today.strftime("%Y-%m-%d")
  end

  def file_extension
    File.extname(self.file&.filename)
  end
end

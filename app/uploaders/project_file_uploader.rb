class ProjectFileUploader < CarrierWave::Uploader::Base
  def filename
    extension = File.extname(self.file&.filename)
    "#{self.file&.filename.split(".")[0]}_#{Time.zone.today.strftime("%Y-%m-%d")}#{extension}"
  end

  def extension_allowlist
    %w(txt pdf rtf doc docx)
  end

  def content_type_allowlist
    %w(text/plain application/pdf application/rtf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document)
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
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end

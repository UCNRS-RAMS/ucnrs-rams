require 'mini_magick'

MiniMagick.configure do |config|
  # Set timeout for image processing operations
  config.timeout = 30
  # The following is no longer used and ImageMagick should be on the system PATH. Setting was removed in mini_magick 5 and later
  # config.cli_path = '/usr/local/bin'
end



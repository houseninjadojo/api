# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :_key,
  :certificate,
  :crypt,
  :otp,
  :passw,
  :salt,
  :secret,
  :ssn,
  :stripe,
  :token,
  :device_id,
  :hapikey
]

class EncryptionService
  KEY = ActiveSupport::KeyGenerator.new(
    Rails.secrets.secret_key_base
  ).generate_key(
    Rails.secrets.secret_key_salt,
    ActiveSupport::MessageEncryptor.key_len
  ).freeze

  private_constant :KEY

  delegate :encrypt_and_sign, :decrypt_and_verify, to: :encryptor

  def self.encrypt(value, **options)
    new.encrypt_and_sign(value, **options)
  end

  def self.decrypt(value, **options)
    new.decrypt_and_verify(value, **options)
  end

  private

  def encryptor
    ActiveSupport::MessageEncryptor.new(KEY)
  end
end

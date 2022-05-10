  # generate an access_token for external viewing/paying of an invoice
  #
  # @example
  #   invoice = Invoice.find(1234)
  #   access_token = Invoice::AccessToken.new(invoice)
  #   access_token.to_s
  # generate code
  # add to work order
  # create access payload
  # encrypt payload
  # create branch link
class Invoice::EncryptedAccessToken
  attr_reader :invoice

  def initialize(invoice)
    @invoice = invoice
  end

  def self.create(invoice)
    encrypted_access_token = new(invoice)
  end

  def payload
    {
      "access_token" => access_token,
      "work_order_id" => work_order&.id,
      "user_id" => user&.id,
    }
  end

  def encrypted_payload
    @encrypted_payload = EncryptionService.encrypt(payload.as_json)
  end

  def access_token
    invoice.access_token
  end

  def to_s
    encrypted_payload.to_s
  end

  private

  def user
    invoice.user
  end

  def work_order
    invoice.work_order
  end
end

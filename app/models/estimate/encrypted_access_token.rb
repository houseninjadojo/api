  # generate an access_token for external viewing/paying of an estimate
  #
  # @example
  #   estimate = Estimate.find(1234)
  #   access_token = Estimate::EncryptedAccessToken.new(invoice)
  #   access_token.to_s
  # generate code
  # add to estimate
  # create access payload
  # encrypt payload
  # create branch link
class Estimate::EncryptedAccessToken
  attr_reader :estimate

  def initialize(estimate)
    @estimate = estimate
  end

  def self.create(estimate)
    encrypted_access_token = new(estimate)
  end

  def payload
    {
      "access_token" => access_token,
      "estimate_id" => estimate&.id,
      "work_order_id" => work_order&.id,
      "user_id" => user&.id,
    }
  end

  def encrypted_payload
    @encrypted_payload = EncryptionService.encrypt(payload.as_json)
  end

  def access_token
    estimate.access_token
  end

  def to_s
    encrypted_payload.to_s
  end

  private

  def user
    work_order.user
  end

  def work_order
    estimate.work_order
  end
end

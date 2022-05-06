class BranchClient
  def app_id
    Rails.secrets.branch[:app_id]
  end

  def access_token
    Rails.secrets.branch[:access_token]
  end

  def key
    Rails.secrets.branch[:key]
  end

  def secret
    Rails.secrets.branch[:secret]
  end

  def self.current
    @client ||= BranchIO::Client.new(
      Rails.secrets.branch[:key],
      Rails.secrets.branch[:secret]
    )
  end

  def self.client
    BranchClient.current
  end
end

class BranchLink
  attr_reader :url
  attr_reader :feature
  attr_reader :campaign
  attr_reader :stage
  attr_reader :tags
  attr_reader :data

  @channel = ""
  @feature = ""
  @campaign = ""
  @stage = ""
  @tags = []
  @data = {}

  # @see https://github.com/ushu/branch_io#clientlink-and-clientlink-registers-a-new-deep-linking-url
  def initialize(params)
    @params = params
    @channel = params[:channel]
    @feature = params[:feature]
    @campaign = params[:campaign]
    @stage = params[:stage]
    @tags = params[:tags]
    @data = params[:data]
    @url = params.dig(:data, "url")
  end

  # operations

  def destroy!
    delete_url = "https://api2.branch.io/v1/url?url=#{@url}&app_id=#{Rails.secrets.branch[:app_id]}"
    headers = { "Access-Token" => Rails.secrets.branch[:access_token] }
    res = HTTParty.delete(delete_url, headers: headers)
    if res.code == 401
      raise res.message
    else
      return true
    end
  end

  def destroy
    begin
      destroy!
      return true
    rescue => e
      Sentry.capture_exception(e)
      return false
    end
  end

  def save
    if !created?
      create_link
    else
      update_link
    end
  end

  # class methods

  # find by deep link uri
  #
  # @example
  #   DeepLink.find("https://w.hnja.io/fTARWYwFOpb") => #<DeepLink:0x000000013f472b20
  #   DeepLink.find("malformed")                     => nil
  def self.find(uri)
    begin
      res = BranchClient.current.link_info!(uri)
      return BranchLink.new(res.link_properties.as_json)
    rescue => e
      puts e
      Sentry.capture_exception(e)
      return nil
    end
  end

  def self.create(params)
    deep_link = new(params)
    deep_link.save
    deep_link
  end

  # helpers

  def created?
    @url.present?
  end

  private

  def branch_client
    BranchClient.current
  end

  def create_link!
    return if created?
    res = branch_client.link!(@params)
    @url = res.url
  end

  def create_link
    return if created?
    begin
      create_link!
    rescue => e
      Sentry.capture_exception(e)
    end
  end

  def update_link
    # @todo
  end
end

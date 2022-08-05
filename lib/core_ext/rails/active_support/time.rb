class Time
  def self.safe_at(val)
    if val.present?
      Time.at(val)
    else
      nil
    end
  end
end

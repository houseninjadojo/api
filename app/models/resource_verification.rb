class ResourceVerification
  include ActiveModel::Validations

  attr_accessor :resource_name
  attr_accessor :record_id
  attr_accessor :attribute
  attr_accessor :value
  attr_accessor :vgs_value
  attr_reader   :result

  validate :verification_validation

  def initialize(**params)
    @resource_name = params[:resource_name]
    @record_id = params[:record_id]
    @attribute = params[:attribute]
    @vgs_value = params[:vgs_value]
    @value = params[:value].presence || params[:vgs_value]
  end

  def self.create(**params)
    ResourceVerification.new(**params)
  end

  def id
    nil
  end

  def result
    @result ||= resource.read_attribute(@attribute) == @value
  end

  def resource_klass
    @resource_klass ||= resource_name.gsub('-', '_').classify.constantize
  end

  def resource
    @resource ||= resource_klass.find(record_id)
  end

  def save
    valid?
  end

  def verified?
    result
  end

  def verification_validation
    errors.add(:base, 'resource verification failed') unless verified?
  end

  #

  def self.all
    []
  end
end

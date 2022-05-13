class ResourceVerification
  include ActiveModel::Validations

  attr_accessor :resource_name
  attr_accessor :record_id
  attr_accessor :attribute
  attr_accessor :value
  attr_reader   :result

  validate :verification_validation

  def initialize(**params)
    @resource_name = params[:resource_name]
    @record_id = params[:record_id]
    @attribute = params[:attribute]
    @value = params[:value]
  end

  def self.create(resource_name, record_id, attribute, value)
    ResourceVerification.new(resource_name, record_id, attribute, value)
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
    errors.add(:base, 'Resource verification failed') unless verified?
  end

  #

  def self.all
    []
  end
end

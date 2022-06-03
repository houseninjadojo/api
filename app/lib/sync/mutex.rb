class Sync::Mutex
  attr_reader :services

  def initialize(resource:, services: [])
    if self.services.empty?
      self.service_list.append(services)
    end

    @resource = resource
  end

  def self.for_resource(resource, services: [])
    new(resource: resource, services: services)
  end

  def services
    service_list.elements
  end

  def service_list
    Kredis.unique_list("sync:mutexes:#{mutex_key}", expires_in: 1.minute)
  end

  def destroy
    service_list.del
  end

  def completed?
    service_list.elements.empty?
  end

  private

  def mutex_key
    "#{resource.class.name}:#{resource.id}"
  end
end

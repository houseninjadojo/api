class ResourceVerificationResource < ApplicationResource
  self.adapter = Graphiti::Adapters::Null
  self.model = ResourceVerification
  self.type = 'resource-verifications'

  primary_endpoint 'resource-verifications', [:create]

  attribute :resource_name, :string
  attribute :record_id,     :uuid
  attribute :attribute,     :string
  attribute :value,         :string
  attribute :result,        :boolean, only: [:readable]

  def base_scope
    {}
  end

  def resolve(scope)
    []
  end
end

class KebabCaseSerializer < Graphiti::Serializer
  extend JSONAPI::Serializable::Resource::KeyFormat
  key_format -> (key) { key.to_s.dasherize }
end

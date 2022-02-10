Graphiti.configure do |c|
  c.respond_to       = [:jsonapi]
  c.pagination_links = true

  c.debug        = Rails.env.development?
  c.debug_models = Rails.env.development?

  # c.schema_path = "#{Rails.root}/schema.json"
end

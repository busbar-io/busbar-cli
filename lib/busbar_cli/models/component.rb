class Component
  include Virtus.model

  attribute :app_id, String
  attribute :environment_name, String
  attribute :type, String
end

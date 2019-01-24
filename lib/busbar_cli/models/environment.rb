class Environment
  include Virtus.model

  attribute :id, String
  attribute :app_id, String
  attribute :name, String
  attribute :namespace, String
  attribute :buildpack_id, String
  attribute :state, String
  attribute :default_branch, String
  attribute :default_node_id, String
  attribute :settings, Hash
  attribute :public, Boolean
  attribute :created_at, String
  attribute :updated_at, String
  attribute :components, Array

  def as_text
    "App: #{app_id}\n" \
    "Environment: #{name}\n" \
    "Namespace: #{namespace}\n" \
    "--\n" \
    "Buildpack ID: #{buildpack_id}\n" \
    "State: #{state}\n" \
    "Public?: #{public}\n" \
    "Default Branch: #{default_branch}\n" \
    "Default Node ID: #{default_node_id}\n" \
    "Settings: \n#{pretty_settings}\n" \
    "Components: \n#{pretty_components}\n" \
    "Created_at: #{created_at}\n" \
    "Updated_at: #{updated_at}"
  end

  private

  def pretty_settings
    settings.sort.map do |setting, value|
      "\t#{setting}: #{value}"
    end.join("\n")
  end

  def pretty_components
    components.sort_by(&:first).map do |component|
      component.map do |attribute, value|
        "\t#{attribute}: #{value}"
      end.join("\n")
    end.join("\n\t--\n")
  end
end

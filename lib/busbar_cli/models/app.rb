class App
  include Virtus.model

  attribute :id, String
  attribute :buildpack_id, String
  attribute :environments, Array
  attribute :repository, String
  attribute :default_branch, String
  attribute :created_at, String
  attribute :updated_at, String

  def environment_list
    environments.join(' / ')
  end

  def as_text
    "App: #{id}\n" \
    "Environments: #{environment_list}\n" \
    "Buildpack ID: #{buildpack_id}\n" \
    "Repository: #{repository}\n" \
    "Default_branch: #{default_branch}\n" \
    "Created_at: #{created_at}\n" \
    "Updated_at: #{updated_at}"
  end
end

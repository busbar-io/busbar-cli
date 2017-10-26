class Database
  include Virtus.model

  attribute :id, String
  attribute :type, String
  attribute :size, String
  attribute :namespace, String
  attribute :url, String
  attribute :created_at, String
  attribute :updated_at, String

  def environment_list
    environments.join(' / ')
  end

  def as_text
    "Name: #{id}\n" \
    "Type: #{type}\n" \
    "Size: #{size}\n" \
    "URL: #{url}\n" \
    "Environment: #{namespace}\n" \
    "Created_at: #{created_at}\n" \
    "Updated_at: #{updated_at}"
  end
end

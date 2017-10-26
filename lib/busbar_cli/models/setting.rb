class Setting
  include Virtus.model

  attribute :key, String
  attribute :value, String
  attribute :environment_name, String
  attribute :app_id, String

  def as_text
    "App: #{app_id}\n" \
    "Environment: #{environment_name}\n" \
    "--\n" \
    "Key: #{key}\n" \
    "Value: #{value}"
  end

  def environment
    Environment.new(app_id: app_id, name: environment_name)
  end
end

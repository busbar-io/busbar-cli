class Build
  include Virtus.model

  attribute :app_id, String
  attribute :environment_name, String
  attribute :commit, String
  attribute :branch, String
  attribute :tag, String
  attribute :state, String
  attribute :updated_at, String
  attribute :log, String

  def as_text
    "App: #{app_id}\n" \
    "Environment: #{environment_name}\n" \
    "--\n" \
    "Commit: #{commit}\n" \
    "Branch: #{branch}\n" \
    "Tag: #{tag}\n" \
    "State: #{state}\n" \
    "Updated at: #{updated_at}\n"
  end
end

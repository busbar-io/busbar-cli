class ComponentLog
  include Virtus.model

  attribute :content, String

  def as_text
    content
  end
end

class NodeType
  include Virtus.model

  attribute :id, String
  attribute :cpu, String
  attribute :guaranteed_cpu, String
  attribute :memory, String

  def as_text
    "#{id} =>\tCPU: #{cpu} \tMemory: #{memory}"
  end
end

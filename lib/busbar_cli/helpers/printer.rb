class Printer
  class << self
    def print_reponse_for(response)
      if response.body.empty?
        puts "#{response.code} #{response.message}"
      elsif response['Content-Type'].include?('application/json')
        puts JSON.pretty_generate(JSON.parse(response.body))
      else
        puts response.body
      end
    end

    def print_resource(resource)
      if resource.nil? || !resource
        puts 'Resource not found'
        exit 0
      end

      puts resource.as_text
    end

    def print_result(result:, success_message:, failure_message:)
      puts result ? success_message : failure_message
    end
  end
end

module Services
  class DatabaseCreator
    def self.call(name, type, environment)
      puts "Creating database #{name} #{type} on environment #{environment}"

      if DatabasesRepository.create(
        id: name,
        type: type,
        namespace: environment
      )
        puts 'Database scheduled for creation'
      else
        puts "There was an issue with the creation of the DB #{name} #{type}" \
              "Make sure that:\n" \
              "- DB name must be unique\n" \
              "- DB name must not contain uppercase characters, dots(.) or underscores(_)\n" \
              '- DB type must be supported'
      end
    end
  end
end

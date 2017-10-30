module Services
  module AppConfig
    class Reseter
      def self.call
        Confirmator.confirm(
          question: 'Are you sure you want to reset all of your application configs? ' \
                    'This action is irreversible.',
          exit_message: 'Exiting without resetting application configs.'
        )
        Services::AppConfig.reset_all
        puts 'Application configuration reset with success.'
        exit 1
      end
    end
  end
end

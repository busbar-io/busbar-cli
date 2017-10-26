module Commands
  module Profile
    extend ActiveSupport::Concern

    included do
      desc 'profile [PROFILE]', 'Set the Busbar profile. With no arguments get current profile'

      def profile(profile_id = nil)
        return puts "Busbar Profile: #{BUSBAR_PROFILE}" if profile_id.nil?
        return unless Services::Kube.validate_profile(profile_id)
        Services::Kube.config_download
        puts "Busbar Profile: #{Services::BusbarConfig.set('busbar_profile', profile_id)}"
      end
    end
  end
end

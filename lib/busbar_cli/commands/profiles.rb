module Commands
  module Profiles
    extend ActiveSupport::Concern

    included do
      desc 'profiles', 'Show the available profiles'
      def profiles
        Services::Kube.config_download

        puts "Available profiles:\n#{Services::Kube.contexts}"
      end
    end
  end
end

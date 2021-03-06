require 'trollop'

module MiQLdapToSssd
  class MiqLdapConfigurationArgumentError < StandardError; end

  class MiqLdapConfiguration

    def self.initial_settings
      initial_settings = current_authentication_settings.merge(user_provided_settings)

      if initial_settings[:mode] == "ldaps" && initial_settings[:tls_cacert].nil?
        LOGGER.fatal("Unprovided TLS certificate are required when mode is ldaps")

        # TODO: May not want to raise an exception and produce a backtrace here.
        #       May simpley want to puts the error and exit.
        raise MiqLdapConfigurationArgumentError.new "TLS certificate were not provided and are required when mode is ldaps"
      end

      # Munge the basedn once for use in multiple places for the basedn domain name.
      initial_settings[:basedn_domain] = initial_settings[:basedn].split(",").collect { |p| p.split('=')[1] }.join('.')

      initial_settings
    end

    def self.current_authentication_settings
      LOGGER.debug("Invokded #{self.class}\##{__method__}")

      settings = Settings.authentication.to_hash
      LOGGER.debug("Current authentication settings: #{settings}")

      settings
    end

    def self.user_provided_settings
      LOGGER.debug("Invokded #{self.class}\##{__method__}")

      opts = Trollop::options do
        opt :tls_cacert,
            "Path to certificate file",
            :short => "-c",
            :default => nil,
            :type => :string

        opt :normalize_userids_only,
            "Normalize the userids then exit",
            :short => "-n",
            :default => false,
            :type => :flag

        opt :skip_normalizing_userids,
            "Do the MiqLdap to SSSD conversion but skip the normalizing of the userids",
            :short => "-s",
            :default => false,
            :type => :flag
      end

      opts[:tls_cacertdir] = File.dirname(opts[:tls_cacert]) unless opts[:tls_cacert].nil?
      LOGGER.debug("User provided settings: #{opts}")

      opts
    end
  end
end

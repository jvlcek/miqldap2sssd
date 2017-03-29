require 'sssd_conf/common'

module MiQLdapToSssd
  class Sssd < Common
    def initialize(_initial_settings)
      super %w(
        default_domain_suffix
        domains
        sbus_timeout
        services
      )
    end

    def default_domain_suffix
      initial_settings[:basedn_domain]
    end

    def domains
      initial_settings[:basedn_domain]
    end

    def sbus_timeout
      "30"
    end

    def services
      "nss, pam, ifp"
    end
  end
end

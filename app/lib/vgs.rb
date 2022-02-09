class VGS
  class << self
    def outbound_proxy
      Rails.application.credentials.vgs.outbound.proxy_url
    end

    def cert_store
      store = OpenSSL::X509::Store.new
      store.set_default_paths
      store.add_file(Rails.secrets.dig(:vgs, :outbound, :ssl_cert))
      store
    end
  end
end

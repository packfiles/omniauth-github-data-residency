require "omniauth/strategies/github"

module OmniAuth
  module Strategies
    class GitHubDataResidency < OmniAuth::Strategies::GitHub
      # The enterprise options are set in the setup phase proc (see: config/initializers/devise.rb) from the request params either enterprise_subdomain or github_host
      # The enterprise subdomain is used to build the client_options urls for the GitHub Enterprise with Data Residency OAuth API
      # The enterprise_subdomain is required to be set in the request params for the GitHubDR strategy to work
      option :enterprise_options, {
        enterprise_subdomain: nil
      }
      option :client_options, {
        site: "https://api.github.com",
        authorize_url: "https://github.com/login/oauth/authorize",
        token_url: "https://github.com/login/oauth/access_token"
      }

      # Override the setup_phase to build the client options before calling super.
      # This is necessary to ensure that the correct client options are used for the request.
      # Specifically, we need to set the redirect_uri with the callback URL to include the enterprise subdomain and ghe.com domain.
      # https://github.com/omniauth/omniauth-oauth2/blob/master/lib/omniauth/strategies/oauth2.rb#L58-L60
      def request_phase
        # First call build_client_options to set up the client options
        build_client_options

        # Call the parent method to continue the OAuth flow
        super
      end

      # Override the callback_phase to build the client options before calling super.
      # This is necessary to ensure that the correct client options are used for the callback request.
      # Specifically, we need to set the redirect_uri with the callback URL to include the enterprise subdomain and ghe.com domain when
      #   we build the access token.
      # https://github.com/omniauth/omniauth-oauth2/blob/master/lib/omniauth/strategies/oauth2.rb#L124-L127
      # https://github.com/omniauth/omniauth-oauth2/blob/master/lib/omniauth/strategies/oauth2.rb#L91
      def callback_phase
        # First call build_client_options to set up the client options
        build_client_options

        # Call the parent method to continue the OAuth flow
        super
      end

      protected

      # Set client_options with the enterprise_subdomain and the ghe.com domain
      def build_client_options
        raise OAuth2::CallbackError.new("An Enterprise subdomain is required.") if invalid_enterprise_subdomain?

        options.client_options.site = "https://api.#{options.enterprise_options.enterprise_subdomain}.ghe.com"
        options.client_options.authorize_url = "https://#{options.enterprise_options.enterprise_subdomain}.ghe.com/login/oauth/authorize"
        options.client_options.token_url = "https://#{options.enterprise_options.enterprise_subdomain}.ghe.com/login/oauth/access_token"
      end

      def invalid_enterprise_subdomain?
        options.enterprise_options.enterprise_subdomain.to_s.empty?
      end
    end
  end
end

OmniAuth.config.add_camelization "github_data_residency", "GitHubDataResidency"

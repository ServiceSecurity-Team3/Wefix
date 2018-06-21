# frozen_string_literal: true

require "http"

module Wefix
  # Find or create an SsoAccount based on Github code
  class AuthenticateGoogleSsoAccount
    def initialize(config)
      @config = config
    end

    def call(access_token)
      google_account = get_google_account(access_token)
      sso_account = find_or_create_sso_account(google_account)

      [sso_account, AuthToken.create(sso_account)]
    end

    private_class_method

    def get_google_account(access_token)
      google_response = HTTP.headers(user_agent: "Config Secure",
                                     accept: "application/json")
        .get("https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{access_token}")

      raise unless google_response.status == 200
      account = GoogleAccount.new(google_response.parse)
      {username: account.email, email: account.email}
    end

    def find_or_create_sso_account(google_account)
      SsoAccount.first(google_account) || SsoAccount.create(google_account)
    end

    # Google class
    class GoogleAccount
      def initialize(gl_account)
        @gl_account = gl_account
      end

      def username
        @gl_account["email"]
      end

      def email
        @gl_account["email"]
      end
    end
  end
end

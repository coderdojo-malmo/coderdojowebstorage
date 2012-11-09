# encoding: utf-8

module Sinatra
  module Authenticator
    module Helpers
      def warden
        request.env['warden']
      end

      def is_authenticated?
        warden.authenticated?
      end

      def current_user
        warden.user
      end

      def ensure_authenticated!
        halt(403) unless is_authenticated?
      end
    end
  end
end

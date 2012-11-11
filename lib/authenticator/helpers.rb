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

      def is_admin?
        ensure_authenticated!
        current_user.is_admin?
      end

      def ensure_authenticated!
        halt(403) unless is_authenticated?
      end

      def ensure_admin!
        halt(403) unless is_admin?
      end
    end
  end
end

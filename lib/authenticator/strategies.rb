# encoding: utf-8

module Sinatra
  module Authenticator
    Warden::Strategies.add :password do
      def valid?
        params['username'] && params['password']
      end

      def authenticate!
        user = User.authenticate_by_password(
          params['username'],
          params['password']
        )
        user ?  success!(user) : fail!("misslyckades att logga in")
      end
    end
  end
end

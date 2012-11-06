# encoding: utf-8
require 'warden'

Warden::Manager.serialize_into_session{|user| user.id}
Warden::Manager.serialize_from_session{|id| User.get(id)}

Warden::Strategies.add :password do
  def authenticate!
    user = User.authenticate_by_password(params[:username], params[:password])
    if user
      return success(user)
    end
    fail!("authentication fail")
  end
end

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

    def self.registered app
      app.enable :sessions

      app.helpers Authenticator::Helpers

      #
      # endpoints for authentication
      #

      app.get "/foo/?" do
        "hej hopp"
      end
      app.get "/signin" do
        erb :signin
      end

      app.post "/signin" do
        warden.authenticate!
        redirect :to => "/"
      end

      app.post "/signout" do
        session[:user_id] = nil
        warden.logout
        redirect :to => "/"
      end

      ['post','get','delete','put'].each do |m|
        app.send("#{m}", '/unauthenticated/?') do
          status 401
          erb :signin
        end
      end
    end

  end
end
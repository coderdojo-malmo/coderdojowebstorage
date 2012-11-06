# encoding: utf-8
require 'warden'

Warden::Strategies.add :password do
  def valid?
    (params[:username] && params[:password])
  end

  def authenticate!
    puts "am I even executed?! with params #{params.inspect}"
    user = User.authenticate_by_password(
      params[:username],
      params[:password]
    )
    return user ? success(user) : fail!("Misslyckades att logga in")
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

      app.use Warden::Manager do |manager|
        manager.default_strategies :password
        manager.failure_app = app
        manager.serialize_into_session { |user| user.id }
        manager.serialize_from_session { |id| User.get(id) }
      end

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
        puts "will try to authenticate with params: #{params.inspect}"
        warden.authenticate!
        redirect "/"
      end

      app.post "/signout" do
        session[:user_id] = nil
        warden.logout
        redirect "/"
      end

      ['post','get','delete','put'].each do |m|
        app.send("#{m}", '/unauthenticated/?') do
          puts "in unauthenticated with #{params.inspect}"
          status 401
          erb :signin
        end
      end
    end

  end
end

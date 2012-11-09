# encoding: utf-8
module Sinatra
  module Authenticator
    def self.registered app
      # need sessions
      app.enable :sessions

      app.helpers Authenticator::Helpers

      # use warden
      app.use Warden::Manager do |manager|
        manager.default_strategies :password
        manager.failure_app = app
        manager.serialize_into_session { |user| user.id }
        manager.serialize_from_session { |id| User.get(id) }
      end

      #
      # endpoints for authentication
      #

      app.get "/signin" do
        if is_authenticated?
          "du är redan inloggad; vill du logga ut?
          <form method=\"post\" action=\"/signout\">
          <input type=\"submit\" value=\"Logga ut\"/>
          </form>
          "
        else
          erb :signin
        end
      end

      app.post "/signin" do
        warden.authenticate!(:password)
        flash[:notice] = "Du är nu inloggad!"
        redirect "/"
      end

      app.post "/signout" do
        session[:user_id] = nil
        warden.logout
        flash[:notice] = "Du är nu utloggad!"
        redirect "/"
      end

      # handle all methods the same for unauthenticated
      ['post','get','delete','put'].each do |m|
        app.send("#{m}", '/unauthenticated/?') do
          flash[:error] = "Inloggning misslyckades"
          redirect "/signin"
        end
      end
    end
  end
end

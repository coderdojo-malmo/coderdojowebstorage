require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{File.dirname(__FILE__)}/db.sqlite3")
require File.dirname(__FILE__)+'/lib/user'
#require File.dirname(__FILE__)+'/lib/static_files'
DataMapper.auto_upgrade!

# need to require this after require of lib/user
require './authenticator'

class CoderDojoWebStorage < Sinatra::Base
  configure do
    Sinatra::Application.reset!
    use Rack::Reloader
  end

  set    :session_secret, "abc123"
  PWSALT = "abc123"

  register Sinatra::Authenticator



  helpers do
    Sinatra::Authenticator::Helpers
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    @user = User.new
    erb :signup
  end

  post "/signup" do
    @user = User.new params[:user]
    if @user.save
      redirect :to => "/users/#{@user.username}"
    else
      erb :signup
    end
  end

  get "/users" do
    ensure_authenticated!
  end

  get "/users/:username/update" do
    @user = User.first :username => params[:username]
  end

  post "/users/:username/update" do
    @user = User.first :username => params[:username]
    unless @user.id.eql? session[:user_id]
      ensure_admin!
    end
  end

  get "/users/:username" do
    @user = User.first :username =>  params[:username]
    erb :show_user
  end

end

# encoding: utf-8
require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'
require 'rack-flash'
require 'data_mapper'
require 'rack-flash'
require File.dirname(__FILE__)+'/lib/user'
require File.dirname(__FILE__)+'/lib/user_file'
require File.dirname(__FILE__) + '/lib/authenticator'
require File.dirname(__FILE__)+'/lib/filetype_helpers'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{File.dirname(__FILE__)}/db.sqlite3")
DataMapper.auto_upgrade!


class CoderDojoWebStorage < Sinatra::Base

  # @todo this should be set in a configuration file
  set    :session_secret, "abc123"
  PWSALT = "abc123"

  enable :sessions
  use Rack::Flash

  # use authentication
  register Sinatra::Authenticator
  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end
  helpers Sinatra::FiletypeHelpers

  get "/" do
    if is_authenticated?
      @files = current_user.files
    end
    erb :index
  end

  ["/om", "/about"].each do |about_url|
    get about_url do
      erb :about
    end
  end

  # user signup
  get "/signup" do
    @user = User.new
    erb :signup
  end

  post "/signup" do
    @user = User.new params[:user]
    if @user.save
      erb :signed_up
    else
      erb :signup
    end
  end

  # simple list of all the users in the system
  get "/handleusers" do
    ensure_admin!
    @users = User.all
    erb :handleusers
  end

  post "/handleusers/changeauthlevel/:username" do
    ensure_admin!
    @user = User.first :username => params[:username]
    @user.auth_level = params[:auth_level]
    if @user.save
      flash[:notice] = "#{@user.username} har nu status #{@user.role}"
    else
      flash[:error] = "Lyckades inte ändra #{@user.username} status till #{User.role_name(params[:auth_level])}"
    end
    redirect "/handleusers"
  end

  post "/handleusers/newpassword/:username" do
    ensure_admin!
    @user = User.first :username => params[:username]
    @user.password = params[:new_password]
    if @user.save
      flash[:notice] = "#{@user.username} har ett nytt lösenord"
    else
      flash[:error] = "Lyckades inte sätta ett nytt lösenord till #{@user.username}"
    end
    redirect "/handleusers"
  end

  # edit a user, changing password etc.
  # ensure admin if not editing self
  get "/edit/:username" do
    ensure_authenticated!
    @user = User.first :username => params[:username]
    halt(403) unless @user.is_editable_by current_user
    erb :edituser
  end

  post "/edit/:username" do
    ensure_authenticated!
    @user = User.first :username => params[:username]
    halt(403) unless @user.is_editable_by current_user
    # @todo implement
  end

  get "/show/:username" do
    @user = User.first :username =>  params[:username]
    erb :show_user
  end

  get "/upload" do
    ensure_authenticated!
    erb :upload
  end
  
  post "/upload" do
    ensure_authenticated!
    if new_uri = current_user.upload_file(params[:file])
      redirect '/'
    else
      @errors = current_user.custom_errors
      erb :upload
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
    ensure_admin! unless @user.id.eql?(current_user.id)
  end

  get "/users/:username" do
    @user = User.first :username =>  params[:username]
    erb :show_user
  end

  get "/editor/*" do
    ensure_authenticated!
    @file_name = File.basename(params[:splat][0])
    @file_type = file_type(@file_name)
    @file_content = current_user.content_of @file_name
    @user_base_url = "/u/#{current_user.username}/"
    erb :editor
  end

  post "/editor/*" do
    ensure_authenticated!
    file_name = File.basename(params[:splat][0])
    if current_user.update_file(file_name, params[:file_content])
      flash[:notice] = 'Filen sparades'
    else
      flash[:error] = 'filen kunde inte sparas!'
    end
    redirect "/editor/#{file_name}"
  end


  error 403 do
    erb :error_403
  end

end

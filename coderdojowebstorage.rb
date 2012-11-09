# encoding: utf-8
require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'
require 'rack-flash'
require 'data_mapper'
require 'rack-flash'
require File.dirname(__FILE__)+'/lib/user'
require File.dirname(__FILE__) + '/lib/authenticator'

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

  get "/" do
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
      erb :show_user
    else
      erb :signup
    end
  end

  # simple list of all the users in the system
  get "/list" do
    ensure_authenticated!
    @users = User.all
    erb :listusers
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
    # @todo move this logic into lib/ something
    ensure_authenticated!
    unless params[:file] && (tmpfile = params[:file][:tempfile]) && (name = params[:file][:filename])
      return erb :upload
    end
    target_dir = current_user.file_dir
    while blk = tmpfile.read(65536)
      unless File.directory? target_dir
        Dir.mkdir target_dir
      end
      begin
        File.open(File.join(target_dir, name), "wb") do |f|
          f.write(tmpfile.read)
        end
      rescue Exception, e
        puts "exception writing file: #{e}"
      end
    end
    redirect current_user.file_path(name)
  end

end

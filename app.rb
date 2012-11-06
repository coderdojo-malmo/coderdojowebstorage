# encoding: utf-8
require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{File.dirname(__FILE__)}/db.sqlite3")
require File.dirname(__FILE__)+'/lib/user'
#require File.dirname(__FILE__)+'/lib/static_files'
DataMapper.auto_upgrade!

# need to require this after require of lib/user
require File.dirname(__FILE__) + '/lib/authenticator'

class CoderDojoWebStorage < Sinatra::Base
  configure do
    Sinatra::Application.reset!
    use Rack::Reloader
  end

  set    :session_secret, "abc123"
  PWSALT = "abc123"

  # depends on warden
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
      redirect "/users/#{@user.username}"
    else
      erb :signup
    end
  end

  get "/upload" do
    ensure_authenticated!
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

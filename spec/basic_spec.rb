require 'sinatra/base'
require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'
require 'data_mapper'
require File.dirname(File.dirname(__FILE__)) + '/app'
require 'rspec'
require 'rack/test'

describe 'The CoderDojo Web Storage App' do
  include Rack::Test::Methods

  def app
    CoderDojoWebStorage
  end

  it "says hello" do
    get '/'
    last_response.should be_ok
    last_response.body.should == 'Hello World'
  end
end

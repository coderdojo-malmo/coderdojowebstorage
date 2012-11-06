# encoding: utf-8
require File.dirname(__FILE__) + '/coderdojospec_helper'

describe 'The CoderDojo Web Storage App' do
  include Rack::Test::Methods

  def app
    CoderDojoWebStorage
  end

  it "says hello" do
    get '/'
    last_response.should be_ok
    last_response.body.should match(/CoderDojo/)
  end
end

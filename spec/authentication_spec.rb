require File.dirname(__FILE__) + '/coderdojospec_helper'

describe 'The authentication system.' do
  include Rack::Test::Methods

  def app
    CoderDojoWebStorage
  end

  it "does not allow anonymous access" do
    post '/signin', :username => '', :password => ''
	last_response.should_not be_ok
  end
 
end

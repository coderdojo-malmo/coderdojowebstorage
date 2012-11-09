# encoding: utf-8
require 'warden'
require File.dirname(__FILE__)+'/authenticator/helpers'
require File.dirname(__FILE__)+'/authenticator/strategies'
require File.dirname(__FILE__)+'/authenticator/authenticator'
module Sinatra
  register Authenticator
end

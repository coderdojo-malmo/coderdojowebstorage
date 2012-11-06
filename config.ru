# encoding: utf-8
require File.dirname(__FILE__)+'/app'

use Warden::Manager do |manager|
    manager.default_strategies :password
    manager.failure_app = CoderDojoWebStorage
end
run CoderDojoWebStorage.new

require 'sinatra'
require 'json'
require 'mustache/sinatra'
require 'oauth2'

# control part of MVC
# an HTTP method paired with a URL-matching pattern
get '/' do
  # page variable
  @version = RUBY_VERSION
  @os = RUBY_PLATFORM
  @env = {}
  ENV.each do |key, value|
    begin
      hash = JSON.parse(value)
      @env[key] = hash
    rescue
      @env[key] = value
    end
  end
  
  appInfo = @env["VCAP_APPLICATION"]
  services = @env["VCAP_SERVICES"]
  #TODO: Get service credentials and communicate with bluemix services.

  # render template
  #haml :hi
  mustache :login
end
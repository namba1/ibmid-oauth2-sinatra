require 'sinatra'
require 'json'
require 'mustache/sinatra'
require 'oauth2'


class App < Sinatra::Base
	register Mustache::Sinatra
	require 'views/layout'
	
	set :mustache, {
		:views => 'views/',
		:templates => 'templates/'
	}
	############################################
	
	get '/' do
=begin
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
	  
	  @appInfo = @env["VCAP_APPLICATION"]
	  @services = @env["VCAP_SERVICES"]
=end
		content_type 'text/plain'
	  mustache :login
	end
end 
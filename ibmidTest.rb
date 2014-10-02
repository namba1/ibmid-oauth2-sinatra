require 'sinatra'
require 'json'
require 'mustache/sinatra'
require './singlesignon.rb'

class App < Sinatra::Base
	register Mustache::Sinatra
	require './views/layout'
	
	include Rack::Utils
	alias_method :h, :escape_html
	
	set :mustache, {
		:views     => './views',
		:templates => './templates',
	}
	
	configure do
		CLIENT_ID     = "KraXSNezEWGomEFpYYUW"
		CLIENT_SECRET = "AP5chAYohb2Mo8f8goQ4"
		REDIRECT_URL  = "https://sinatra99.mybluemix.net/auth/callback"
		@@sso = SingleSignOn.new(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL)
	end
	############################################

	get '/' do
	  @version = RUBY_VERSION
	  @os = RUBY_PLATFORM
    @params = @@sso.credentials.collect { |k, v|  {:key => k, :value => v} }
    @auth_url = @@sso.authorize_url

	  mustache :home
	end
	
	get '/auth/login' do
		@auth_url = @@sso.authorize_url
	  mustache :login  
	end
	
	get '/auth/callback' do
	  @@sso.token_request(params[:code])
		redirect (@@sso.authorized) ? '/greetings' : '/auth/error'
	end
	
	get '/auth/profile' do
	  @token_string = @@sso.token_string
	  @auth_code    = @@sso.auth_code
	  @user_info    = @@sso.profile.collect do |k, v| {"key" => k, "value" => v} end
		mustache :profile
	end

	get '/auth/error' do
		@message = @@sso.error_message
		mustache :error
	end
	
  post '/auth/logout' do
  	@@sso.logout()
    redirect '/auth/login'
  end
  	
	get '/greetings' do
		@profile = @@sso.profile_request()
		@profile_url = '/auth/profile'
		@logout_url  = '/auth/logout'
	  mustache :greetings
	end

end 

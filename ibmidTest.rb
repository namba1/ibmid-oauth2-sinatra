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
		@@sso = SingleSignOn.new("KraXSNezEWGomEFpYYUW", "AP5chAYohb2Mo8f8goQ4", "https://sinatra99.mybluemix.net/auth/callback")
		@@access_token = ""
		@@auth_code = ""
		#set :sso, @@sso
		@@credentials = JSON.parse(ENV["VCAP_SERVICES"])["single.sign.on"].first["credentials"]		
	end
	############################################

	get '/' do
	  @version = RUBY_VERSION
	  @os = RUBY_PLATFORM
    @params = @@credentials.collect { |k, v|  {:key => k, :value => v} }
    @auth_url = @@sso.authorize_url

	  mustache :home
	end
	
	get '/auth/login' do
		@auth_url = @@sso.authorize_url
	  mustache :login  
	end
	
	post '/auth/ibmid' do
	  "<p>IBM ID authorization code</p>"
	end
	
	get '/auth/callback' do
	  @@auth_code    = params[:code]
	  @@token_string = @@sso.token_request(@@auth_code)
		redirect '/auth/profile'
	end
	
	get '/auth/profile' do
	  @token_string = @@token_string
	  @auth_code = @@auth_code
		mustache :profile
	end

  post '/auth/logout' do
    redirect '/auth/login'
  end
  	
	get '/greetings' do
		@profile   = @@sso.profile_request()
		@user_info = JSON.parse(@profile)
	  mustache :greetings
	end

end 

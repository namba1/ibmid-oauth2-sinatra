require 'sinatra'
require 'json'
require 'mustache/sinatra'
require './lib/singlesignon.rb'

#-----------------------------------------------------------		
CLIENT_ID     = "KraXSNezEWGomEFpYYUW"
CLIENT_SECRET = "AP5chAYohb2Mo8f8goQ4"
REDIRECT_URL  = "https://sinatra99.mybluemix.net/auth/callback"
#-----------------------------------------------------------
	
class App < Sinatra::Base
	register Mustache::Sinatra
	require './views/layout'
	
	include Rack::Utils
	alias_method :h, :escape_html
	
	set :mustache, {
		:views     => './views',
		:templates => './templates',
	}

	def sso; settings.sso; 	end			

	configure do
		set :sso, SingleSignOn.new(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL, ENV["VCAP_SERVICES"])
	end
	
	before '/' do
    unless sso.authorized
      redirect '/auth/login'
    end
  end
  
	before '/:path' do
		unless sso.authorized || params[:path][0..4] == 'auth/'
			redirect '/auth/login'
		end
	end
	
  ###################################################
	get '/auth/login' do
		@auth_url = sso.authorize_url
	  mustache :login  
	end
	
	get '/auth/callback' do
	  sso.token_request(params[:code])				#### obtain token from the token URL
	  sso.profile_request { |profile_data|  #### obtain profile data and validate it
	  	profile_data['userRealm'] == 'www.ibm.com' && profile_data['AUTHENTICATION_LEVEL'] == '2'
	  }
		redirect (sso.authorized) ? '/' : '/auth/error'
	end

	get '/auth/error' do
		@error_message = sso.error_message
		mustache :autherror
	end
	
  post '/auth/logout' do
  	sso.logout()
    redirect '/auth/login'
  end

  ###################################################
  get '/' do
    @user_name   = sso.profile["name"][0]
    @view_profile_url = '/profile'
    @logout_url  = '/auth/logout'
    mustache :home
  end
  
  get '/profile' do
    @version     = RUBY_VERSION
    @platform    = RUBY_PLATFORM
    @credentials  = sso.credentials.collect { |k, v|  {:key => k, :value => v} }
    @token_string = sso.token_string
    @auth_code    = sso.auth_code
    @user_info    = sso.profile.collect { |k, v| {"key" => k, "value" => v} }
    @logout_url   = '/auth/logout'
    mustache :profile
  end
end 

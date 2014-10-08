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

	use Rack::Session::Cookie,					# enable Rack sessions
					:path => '/',
					:expire_after => 60*60, 		# 1 hour
					:secret => 'singlesignon_secret'
							
	configure do
		@@sso = SsoCredentials.new(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL, ENV["VCAP_SERVICES"])
	end
  
	before do
		unless session[:authorized] || request.path_info[0..5] == '/auth/'
			redirect '/auth/login'
		end
	end
	
  ###################################################
	get '/auth/login' do
		@auth_url = @@sso.authorize_url
	  mustache :login  
	end
	
	get '/auth/callback' do
		login_ctl = SsoLogin.new(@@sso)
	  if login_ctl.token_request(params[:code]) then																#### obtain token from the token URL
		  session[:profile] = login_ctl.profile_request { |profile_data|  					#### obtain profile data and validate it
		  	profile_data['userRealm'] == 'www.ibm.com' && profile_data['AUTHENTICATION_LEVEL'] == '2'	### or just 'true' to skip validation
		  }
	  end
 		session[:auth_code]      = params[:code]
	  session[:token_string]   = login_ctl.token_string
	  session[:authorized]     = login_ctl.authorized
	  session[:error_message] = login_ctl.error_message
	  
		redirect (login_ctl.authorized) ? '/' : '/auth/error'
	end

	get '/auth/error' do
		@error_message = session[:error_message]
		mustache :autherror
	end
	
  post '/auth/logout' do
  	session[:authorized] = false
    redirect '/auth/login'
  end

  ###################################################
  get '/' do
    @user_name   = session[:profile]["name"][0]
    @view_profile_url = '/profile'
    @logout_url  = '/auth/logout'
    mustache :home
  end
  
  get '/profile' do
    @version     = RUBY_VERSION
    @platform    = RUBY_PLATFORM
    @credentials  = @@sso.credentials.collect { |k, v|  {:key => k, :value => v} }
    @token_string = session[:token_string] 
    @auth_code    = session[:auth_code]
    @user_info    = session[:profile].collect { |k, v| {"key" => k, "value" => v} }
    @logout_url   = '/auth/logout'
    mustache :profile
  end
end 

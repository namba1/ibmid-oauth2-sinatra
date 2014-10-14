# Licensed under the Apache License. See footer for details.
require 'sinatra'
require 'json'
require 'mustache/sinatra'
require './lib/ibmid-oauth2-sinatra.rb'

#-----------------------------------------------------------
CLIENT_ID     = ENV['CLIENT_ID']	    || 'KraXSNezEWGomEFpYYUW'
CLIENT_SECRET = ENV['CLIENT_SECRET'] || 'AP5chAYohb2Mo8f8goQ4'
REDIRECT_URL  = ENV['REDIRECT_URL']	|| 'https://myapp.mybluemix.net/auth/callback'
SESSION_EXPIRE = ENV['SESSION_EXPIRE'] || '3600'  # default value for session expiration is 1 hour
#-----------------------------------------------------------
class App < Sinatra::Base
	register Mustache::Sinatra
	require './views/layout'
	include Rack::Utils
	alias_method :h, :escape_html
	
	set :mustache, { :views => './views', :templates => './templates' 	}                       # directories for views and mustache templates
	use Rack::Session::Cookie, :path => '/',	:expire_after => SESSION_EXPIRE.to_i, :secret => 'foo bar' 	# enable Rack sessions
							
	configure do
		@@sso = SsoCredentials.new(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL, ENV['VCAP_SERVICES']) 
	end
	
	before do    # redirect to login page first if not logged-in
		unless session[:authorized] || request.path_info[0..5] == '/auth/'
			redirect '/auth/login'
		end
	end
	
  #--- Routes for login/logout operations ------------------------------------
	get '/auth/login' do 		# view login page
		@auth_url = @@sso.authorize_url
	  mustache :login  
	end
	
	get '/auth/callback' do    # User redirects to this page with authorization code
		login_ctl = SsoLogin.new(@@sso)
	  if login_ctl.token_request(params[:code]) then																#### obtain token from the token URL
		  session[:profile] = login_ctl.profile_request { |profile_data|  					#### obtain profile data and validate it
		     # true
		  	 profile_data['userRealm'] == 'www.ibm.com' && profile_data['AUTHENTICATION_LEVEL'] == '2'	### or just 'true' to skip validation
		  }
	  end

    session[:authorized]    = login_ctl.authorized
    session[:error_message] = login_ctl.error_message
	  session[:token_string]  = login_ctl.token_string      # optional info
    session[:auth_code]     = params[:code]               # optional info
		redirect (login_ctl.authorized ? '/' : '/auth/error')
	end

	get '/auth/error' do
		@error_message = session[:error_message]
		mustache :autherror
	end
	
  post '/auth/logout' do
  	session[:authorized] = false
    redirect '/auth/login'
  end

  #--- Routes after successful login ------------------------------------------
  get '/' do        # view home page
    @user_name        = session[:profile]["name"][0]
    @view_profile_url = '/profile'
    @logout_url       = '/auth/logout'
    mustache :home
  end
  
  get '/profile' do # view profile info page
    @environment  = { "ruby_version" => RUBY_VERSION, "platform" => RUBY_PLATFORM }
    @credentials  = @@sso.credentials.collect { |k, v|  {:key => k, :value => v} }
    @oauth2       = { "token" => session[:token_string] , "auth_code" => session[:auth_code] }
    @user_info    = session[:profile].collect { |k, v| {"key" => k, "value" => v} }
    @logout_url   = '/auth/logout'
    mustache :profile
  end
end 

#-------------------------------------------------------------------------------
# Copyright IBM Corp. 2014
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------
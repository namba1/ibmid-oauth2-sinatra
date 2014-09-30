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
		sso_instance = SingleSignOn.new("KraXSNezEWGomEFpYYUW", "AP5chAYohb2Mo8f8goQ4", "https://sinatra99.mybluemix.net/auth/callback")
		@@sso = sso_instance
		@@access_token = ""
		set :sso, sso_instance
	end
	############################################
	## Test 
=begin
sso = SingleSignOn.new("KraXSNezEWGomEFpYYUW", "AP5chAYohb2Mo8f8goQ4", "https://sinatra99.mybluemix.net/auth/callback")
puts sso.authorize_url
code = "70r6CQkd6KR9EIlKXByJdicODPVINy"
token_request = sso.token_request(code)
p token_request
=end

	get '/' do
	  @version = RUBY_VERSION
	  @os = RUBY_PLATFORM
		credentials = JSON.parse(ENV["VCAP_SERVICES"])["single.sign.on"].first["credentials"]
    @params = credentials.collect { |k, v|  {:key => k, :value => v} }
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
	  auth_code = params[:code]
	  token_string = @@sso.token_request(auth_code)
	  @@token_string = token_string
	  #prof_request = @@sso.profile_request()
		#resp = prof_request.post('https://idaas.ng.bluemix.net/idaas/resources/profile.jsp')
	  #"<p>IBM ID callback token = #{auth_code}</p><br/> Token String: #{token_string}<br/>#{resp.body}"
	  "<p>IBM ID callback token = #{auth_code}</p><br/> Token String: #{token_string}<br/>"

	  #redirect '/greetings'
	end
	
  post '/auth/logout' do
    redirect '/auth/login'
  end
  	
	get '/greetings' do
	  @user_info = { :name => "Unknown" }
	  @token = @@token_string
	  mustache :greetings
	end

	get '/exp' do
		
	end
end 


=begin
    options = {
        authorizationURL: 'https://idaas.ng.bluemix.net/sps/oauth20sp/oauth20/authorize',
        tokenURL: 'https://idaas.ng.bluemix.net/sps/oauth20sp/oauth20/token',
        profileURL: 'https://idaas.ng.bluemix.net/idaas/resources/profile.jsp',
        logoutURL: 'https://www-304.ibm.com/pkmslogout?page=',
        policy: 'http://www.ibm.com/idaas/authnpolicy/reauth',
        scope: ['profile']
    };
    {
			"single.sign.on":[
				{
					"name":"Single Sign On -kr",
					"label":"single.sign.on",
					"tags":["ibm_created","security"],
					"plan":"standard",		
					"credentials":{
						"profile_resource":"https://idaas.ng.bluemix.net/idaas/resources/profile.jsp",
						"tokeninfo_resource":"https://idaas.ng.bluemix.net/idaas/resources/tokeninfo.jsp",
						"token_url":"https://idaas.ng.bluemix.net/sps/oauth20sp/oauth20/token",
						"authorize_url":"https://idaas.ng.bluemix.net/sps/oauth20sp/oauth20/authorize"
					}
				}
			]
		}	
=end
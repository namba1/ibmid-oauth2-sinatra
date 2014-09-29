require 'sinatra'
require 'json'
require 'mustache/sinatra'
#require 'oauth2'


class App < Sinatra::Base
	register Mustache::Sinatra
	require './views/layout'
	
	include Rack::Utils
	alias_method :h, :escape_html
	
	set :mustache, {
		:views     => './views',
		:templates => './templates',
	}
	############################################
	
	get '/' do
	  @version = RUBY_VERSION
	  @os = RUBY_PLATFORM
	  #@appInfo = ENV["VCAP_APPLICATION"]
    credentials = JSON.parse(ENV["VCAP_SERVICES"])["single.sign.on"].first["credentials"]
    @params = []
    credentials.each do |key, value|
      @params.push { :key => key, :value => value}
    end
	  mustache :home
	end
	
	get '/login' do
	   mustache :login  
	end
	
	get '/auth/login' do
	  
	end
	
	get '/auth/callback' do
	  redirect '/greetings'
	end
	
	get '/greetins' do
	  @user_info = { :name => "Unknown" }
	  mustache :greetings
	end
	
	get '/logout' do
	  redirect '/login'
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
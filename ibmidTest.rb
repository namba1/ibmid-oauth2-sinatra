require 'sinatra'
require 'json'
require 'mustache/sinatra'
require 'oauth2'


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

	  @appInfo = ENV["VCAP_APPLICATION"]
	  @services = ENV["VCAP_SERVICES"]

	  mustache :login
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
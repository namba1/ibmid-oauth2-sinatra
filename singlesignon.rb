require 'oauth2'
require 'json'
require 'uri'

class SingleSignOn
	attr_reader :credentials, :auth_code, :authorized, :token_string, :profile, :error_message
	
  def initialize(client_id, client_secret, redirect_uri, env_services = nil)
    init_variables()
    
    begin
      @credentials = JSON.parse(env_services)["single.sign.on"].first["credentials"]
    rescue
      @credentials = {
        "profile_resource" =>  "https://idaas.ng.bluemix.net/idaas/resources/profile.jsp",
        "tokeninfo_resource"=> "https://idaas.ng.bluemix.net/idaas/resources/tokeninfo.jsp",
        "openidProviderURL"=> "https://idaas.ng.bluemix.net/idaas/openid",
        "token_url"=>          "https://idaas.ng.bluemix.net/sps/oauth20sp/oauth20/token",
        "authorize_url"=>      "https://idaas.ng.bluemix.net/sps/oauth20sp/oauth20/authorize"      
      }
    end
    
    @redirect_uri = redirect_uri
    @site       = site(@credentials["authorize_url"])
    @auth_path  = path(@credentials["authorize_url"])
    @token_path = path(@credentials["token_url"])
    @client     = OAuth2::Client.new(client_id, client_secret, :token_url => @token_path, :site => @site, :authorize_url => @auth_path)
  end
  
  def init_variables
  	@auth_code = ""
  	@token = nil
    @token_string = ""
    @profile = {}
    @authorized = false
    @error_message = "Please log in."
  end
  
  def authorize_url
    @auth_url = @client.auth_code.authorize_url(:redirect_uri => @redirect_uri, :response_type => 'code', :scope => 'profile')
  end
  
  def token_request(code)
  	begin
	  	@auth_code = code
	    @token = @client.auth_code.get_token(@auth_code, :redirect_uri => @redirect_uri)
	    @token.options[:header_format] = "OAuth %s"
			@token_string = @token.token
			@authorized = true
		rescue
			@error_message = "Failed to obtain token."
			@token = nil
			@token_string = ""
			@authorized = false
		end
  end
  
  def profile_request()
  	if @token then
  		begin
		  	token_options = {:header_format => @token.options[:header_format] , :mode => :body, :expires_at => @token[:expires_at]}
		  	access_token = OAuth2::AccessToken.new( @client, @token.token, token_options)
		  	resp = access_token.post(@credentials["profile_resource"])
		  	@profile = JSON.parse(resp.body)
		  rescue
		  	@profile = {}
		  	@error_message = "Failed to obtain profile information."
		  end
  	end
  	@profile
  end
  
  def logout()
  		init_variables()
  end
  
  ## Helper Functions ----------------------------------------------------------
  def site (url)
    url.match(/^(.....\:\/\/[^\/]+)(.+$)/) do |s| s[1] end  
  end
  
  def path (url)
    url.match(/^(.....\:\/\/[^\/]+)(.+$)/) do |s| s[2] end  
  end
end # class

require 'oauth2'
require 'json'
require 'uri'

class SingleSignOn

  def initialize(client_id, client_secret, redirect_uri, env_services = nil)
    @client_id     = client_id
    @client_secret = client_secret
    @redirect_uri = redirect_uri
    
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
    
    @site       = site(@credentials["authorize_url"])
    @auth_path  = path(@credentials["authorize_url"])
    @token_path = path(@credentials["token_url"])
    @client = OAuth2::Client.new(client_id, client_secret, :token_url => @token_path, :site => @site, :authorize_url => @auth_path)
  end
  
  def authorize_url
    @auth_url = @client.auth_code.authorize_url(:redirect_uri => @redirect_uri, :response_type => 'code', :scope => 'profile')
  end
  
  def token_request(code)
    @token = @client.auth_code.get_token(code, :redirect_uri => @redirect_uri)
    @token.options[:header_format] = "OAuth %s"
		@token.token
  end
  
  def profile_request()
  	token_options = {:header_format => @token.options[:header_format] , :mode => :body, :expires_at => @token[:expires_at]}
  	access_token = OAuth2::AccessToken.new( @client, @token.token, token_options)
		## access_options = {:headers => {"Content-Length" => "access_token=#{@token.token}".length().to_s }}
  	## resp = access_token.post(profile_url, access_options)
  	resp = access_token.post(profile_url)
  	resp.body
  end
  
  def profile_url
  	@credentials["profile_resource"]
  end
  
  ## Helper Functions
  def site (url)
    url.match(/^(.....\:\/\/[^\/]+)(.+$)/) do |s| s[1] end  
  end
  
  def path (url)
    url.match(/^(.....\:\/\/[^\/]+)(.+$)/) do |s| s[2] end  
  end
end # class

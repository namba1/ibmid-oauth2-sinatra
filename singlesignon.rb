require 'oauth2'
require 'json'
require 'uri'

class SingleSignOn

  def initialize(client_id, client_secret, redirect_uri, env_services = nil)
    @client_id = client_id
    @client_secret =client_secret
    @redirect_uri = redirect_uri
    
    if env_services then
      @credentials = JSON.parse(env_services)["single.sign.on"].first["credentials"]
    else
      @credentials = {
        "profile_resource" =>  "https://idaas.ng.bluemix.net/idaas/resources/profile.jsp",
        "tokeninfo_resource"=>"https://idaas.ng.bluemix.net/idaas/resources/tokeninfo.jsp",
        "openidProviderURL"=>"https://idaas.ng.bluemix.net/idaas/openid",
        "token_url"=>         "https://idaas.ng.bluemix.net/sps/oauth20sp/oauth20/token",
        "authorize_url"=>     "https://idaas.ng.bluemix.net/sps/oauth20sp/oauth20/authorize"      
      }
    end
    
    @site       = site(@credentials["authorize_url"])
    @auth_path  = path(@credentials["authorize_url"])
    @token_path = path(@credentials["token_url"])
    @client = OAuth2::Client.new(client_id, client_secret, :token_url => @token_path, :site => @site, :authorize_url => @auth_path)
  end
  
  def authorize_url
    @auth_url = @client.auth_code.authorize_url(:redirect_uri => @redirect_uri, :response_type => 'code')
  end
  
  def token_request(code)
    @token = @client.auth_code.get_token(code, :redirect_uri => @redirect_uri)
  end
  ## Helper Functions
  def site (url)
    url.match(/^(.....\:\/\/[^\/]+)(.+$)/) do |part| part[1] end  
  end
  
  def path (url)
    url.match(/^(.....\:\/\/[^\/]+)(.+$)/) do |part| part[2] end  
  end
end # class


## Test 
=begin
sso = SingleSignOn.new("KraXSNezEWGomEFpYYUW", "AP5chAYohb2Mo8f8goQ4", "https://sinatra99.mybluemix.net/auth/callback")
puts sso.authorize_url
code = "70r6CQkd6KR9EIlKXByJdicODPVINy"
token_request = sso.token_request(code)
p token_request
=end
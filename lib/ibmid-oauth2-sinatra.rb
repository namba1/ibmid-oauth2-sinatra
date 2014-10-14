# Licensed under the Apache License. See footer for details.
require 'oauth2'
require 'json'

class SsoCredentials
	attr_reader :redirect_uri, :credentials, :client
	
  def initialize(client_id, client_secret, redirect_uri, env_services = nil)
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
    @site       = site_path(@credentials["authorize_url"])[0]
    @auth_path  = site_path(@credentials["authorize_url"])[1]
    @token_path = site_path(@credentials["token_url"])[1]
    @client     = OAuth2::Client.new(client_id, client_secret, :token_url => @token_path, :site => @site, :authorize_url => @auth_path)
  end

  def authorize_url (response_type = 'code', scope = 'profile')
    @auth_url = @client.auth_code.authorize_url(:redirect_uri => @redirect_uri, :response_type => response_type, :scope => scope)
  end

  def site_path (url)
    url.match(/^(.....\:\/\/[^\/]+)(.+$)/) do |s| [s[1], s[2]] end  
  end
  private :site_path
end # class

class SsoLogin
	attr_reader :auth_code, :authorized, :token_string, :profile, :error_message
	
	def initialize(sso)
			@sso = sso
			@client = sso.client
	  	@auth_code = ""
	  	@token = nil
	    @token_string = ""
	    @profile = {}
	    @authorized = false
	    @error_message = "Please log in."
  end
  
  def token_request(code)
  	@auth_code  = code
  	@authorized = false
  	begin
	    @token = @client.auth_code.get_token(@auth_code, :redirect_uri => @sso.redirect_uri)
	    @token.options[:header_format] = "OAuth %s"
			@token_string = @token.token
			@authorized = true
		rescue => ex
			@error_message = "Failed to obtain token: #{ex.message} Auth code: #{code}"
			@token = nil
		end
		
		@authorized
  end
  
  def profile_request()
  	if @token then
  		begin
		  	token_options = {:header_format => @token.options[:header_format] , :mode => :body, :expires_at => @token[:expires_at]}
		  	access_token = OAuth2::AccessToken.new( @client, @token.token, token_options)
		  	resp = access_token.post(@sso.credentials["profile_resource"])
		  	@profile = JSON.parse(resp.body)
		  	if block_given? then
			  	if yield( @profile ) then
			  	  @error_message = "Login successful."
			  	else
						@error_message = "Failed to validate profile. Token: #{@token_string} "
            @authorized = false
			  	end
			  end
		  rescue => ex
		  	@profile = {}
		  	@error_message = "Failed to obtain profile information: #{ex.message}  Token: #{@token_string}"
		  end
  	end
	  
  	@profile
  end
end # class

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
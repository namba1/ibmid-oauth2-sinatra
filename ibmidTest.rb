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
		@@sso = SingleSignOn.new("KraXSNezEWGomEFpYYUW", "AP5chAYohb2Mo8f8goQ4", "https://sinatra99.mybluemix.net/auth/callback")
		@@access_token = ""
		@@auth_code = ""
		#set :sso, @@sso
		@@credentials = JSON.parse(ENV["VCAP_SERVICES"])["single.sign.on"].first["credentials"]		
	end
	############################################

	get '/' do
	  @version = RUBY_VERSION
	  @os = RUBY_PLATFORM
    @params = @@credentials.collect { |k, v|  {:key => k, :value => v} }
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
	  @@auth_code    = params[:code]
	  @@token_string = @@sso.token_request(@@auth_code)

	  #prof_request = @@sso.profile_request()
		#resp = prof_request.get('https://idaas.ng.bluemix.net/idaas/resources/profile.jsp')
		# resp.body
		
	  redirect '/greetings'
	end
	
	post '/auth/profile' do
		prof_request = @@sso.profile_request()
		resp = prof_request.post('https://idaas.ng.bluemix.net/idaas/resources/profile.jsp')
	end

  post '/auth/logout' do
    redirect '/auth/login'
  end
  	
	get '/greetings' do
	  @user_info = { :name => "Unknown" }
	  @token_string = @@token_string
	  @auth_code = @@auth_code
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
    
if( code != null && code.length() > 0 ){
  //. アクセストークンを取得
  String req_url = "https://idaas.ng.bluemix.net/sps/oauth20sp/oauth20/token?client_id=" + client_identifier + "&client_secret=" + client_secret;
  String param = "grant_type=authorization_code"
      + "&redirect_uri=" + URLEncoder.encode( server_url )
      + "&code=" + code;
  try{
    HttpClient client = new HttpClient();
    PostMethod post = new PostMethod( req_url );
		
    post.setRequestHeader( "Content-Type", "application/x-www-form-urlencoded" );
    post.setRequestHeader( "Content-Length", "" + param.length() );
    post.setRequestBody( param );
		
    int sc = client.executeMethod( post );
    if( sc == 200 ){
      String body = post.getResponseBodyAsString();
      int n1 = body.indexOf( "\"access_token\":\"" );
      if( n1 > 0 ){
        int n2 = body.indexOf( "\"", n1 + 16 );
        if( n2 > n1 ){
          access_token = body.substring( n1 + 16, n2 );
					
          //. アクセストークンを使ってプロファイルデータを取得
          String req_url1 = "https://idaas.ng.bluemix.net/idaas/resources/profile.jsp";
          String param1 = "access_token=" + access_token;

          HttpClient client1 = new HttpClient();
          PostMethod post1 = new PostMethod( req_url1 );
						
          post1.setRequestHeader( "Content-Type", "application/x-www-form-urlencoded" );
          post1.setRequestHeader( "Content-Length", "" + param1.length() );
          post1.setRequestBody( param1 );
          int sc1 = client.executeMethod( post1 );
          if( sc1 == 200 ){
            String body1 = post1.getResponseBodyAsString();
            n1 = body1.indexOf( "\"email\":[\"" );
            if( n1 > 0 ){
              n2 = body1.indexOf( "\"", n1 + 10 );
              if( n2 > n1 ){
                email = body1.substring( n1 + 10, n2 );
              }
            }
          }
        }
      }
    }
=end
class App < Sinatra::Base
	module Views
		class Profile < Mustache
			def ruby_version; @version end
			def platform; @platform 	end
		  def credentials; @credentials end
			def auth_code; @auth_code end
			def token; @token_string 	end
			def user_info; @user_info end
      def logout_url; @logout_url end 
		end		
	end
end

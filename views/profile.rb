class App < Sinatra::Base
	module Views
		class Profile < Mustache
			def environment; @environment end
		  def credentials; @credentials end
			def oauth2; @oauth2 end
			def user_info; @user_info end
      def logout_url; @logout_url end 
		end		
	end
end

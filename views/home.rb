class App < Sinatra::Base
	module Views
		class Home < Mustache
      def user_name; @user_name end
      def profile_url; @view_profile_url end
      def logout_url; @logout_url end 
		end		
	end
end

class App < Sinatra::Base
	module Views
		class Login < Mustache
      def auth_url; @auth_url end
		end		
	end
end

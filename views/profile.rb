class App < Sinatra::Base
	module Views
		class Profile < Mustache
		
			def auth_code
				@auth_code
			end
			
			def token
				@token_string
			end

		end		
	end
end

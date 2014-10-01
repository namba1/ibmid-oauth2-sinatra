class App < Sinatra::Base
	module Views
		class Greetings < Mustache
		
			def user_name
			  @user_info[:name]
			end
			
			def auth_code
				@auth_code
			end
			
			def token
				@token_string
			end
		end		
	end
end

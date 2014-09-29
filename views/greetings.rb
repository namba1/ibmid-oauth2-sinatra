class App < Sinatra::Base
	module Views
		class Greetings < Mustache
		
			def user_name
			  @user_info[:name]
			end
		end		
	end
end

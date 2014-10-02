class App < Sinatra::Base
	module Views
		class Greetings < Mustache
		
			def user_name
			  @user_info["name"][0]
			end
			
			def profile
				@profile
			end
			
			def body_size
				if @profile then
					@profile.length() 
				else
					0
				end
			end
		end		
	end
end

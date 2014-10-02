class App < Sinatra::Base
	module Views
		class Greetings < Mustache
		
			def user_name
			  @profile["name"][0]
			end

			def profile_url
				@profile_url
			end
			
			def logout_url
				@logout_url
			end			
		end		
	end
end

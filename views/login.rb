class App < Sinatra::Base
	module Views
		class Login < Mustache

			def version
				"0.01"
			end	
		end		
	end
end

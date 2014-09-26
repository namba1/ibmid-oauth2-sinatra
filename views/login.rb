class App < Sinatra::Base
	module Views
		class Login < Mustache
			
			def doit
				
				"This is a test"
			end
			
			def version
				"0.01"
			end	
				
		end
	end

end

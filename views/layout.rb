class App < Sinatra::Base
	module Views
		class Layout < Mustache
			
			def title
				"IBM ID Test"
			end
			
			def version
				"0.01"
			end	
				
		end
	end

end

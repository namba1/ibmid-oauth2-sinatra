class App < Sinatra::Base
	module Views
		class Layout < Mustache
			def title; "IBM ID Test" 	end	
		end
	end
end

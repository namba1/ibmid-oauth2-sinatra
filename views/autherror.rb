class App < Sinatra::Base
	module Views
		class AuthError < Mustache
		
			def message
				@message
			end

		end		
	end
end

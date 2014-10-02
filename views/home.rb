class App < Sinatra::Base
	module Views
		class Home < Mustache
			
			def ruby_version
				@version
			end
			
			def platform
				@os
			end
			
		  def params
	  		@params
	  	end

		end		
	end
end

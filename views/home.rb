class App < Sinatra::Base
	module Views
		class Home < Mustache
			
			def info_msg
				"Ruby Version: #{@version}  Platform: #{@os}"
			end
			
		  def params
	  		@params
	  	end
		end		
	end
end

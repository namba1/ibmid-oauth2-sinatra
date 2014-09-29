class App < Sinatra::Base
	module Views
		class Home < Mustache
			
			def info_msg
				"Ruby Version: #{@version}  Platform: #{@os}"
			end
			
			def appInfo
				@appInfo
			end
			
		  def services
	  		@services
	  	end
		end		
	end
end

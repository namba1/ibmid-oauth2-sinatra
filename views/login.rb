class App < Sinatra::Base
	module Views
		class Login < Mustache
			
			def info_msg
				"Ruby Version: #{@version}  Platform: #{@os}"
			end
			
			def appInfo
				@appInfo
			end
		  def services
	  		@services
	  	end
	  			
			def version
				"0.01"
			end	
		end		
	end

end

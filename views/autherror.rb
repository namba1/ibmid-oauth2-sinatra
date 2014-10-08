class App < Sinatra::Base
	module Views
		class Autherror < Mustache
      def error_message; @error_message end
		end		
	end
end

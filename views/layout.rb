class App < Sinatra::Base
	module Views
		class Layout < Mustache
		  def title; @title || "Sample Login via IBM ID" end
		end
	end
end

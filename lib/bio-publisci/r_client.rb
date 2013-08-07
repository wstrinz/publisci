module PubliSci
	module Rconnect

		def connect(address=nil)
			if address
				Rserve::Connection.new(address)
			else
				Rserve::Connection.new
			end
		end

		def load_workspace(connection,loc=Dir.home,file=".RData")
			loc = File.join(loc,file)
			connection.eval "load(\"#{loc}\")"
		end

		def get(connection, instruction)
			connection.eval instruction
		end

		def get_vars(connection)
			connection.eval("ls()")
		end

	end

	class Client
		include PubliSci::Rconnect
    attr :R

		def initialize(auto=true, loc=Dir.home)
      @R = connect
			@loc = loc
			load_ws if auto
			puts "vars: #{vars.payload}" if auto
		end

		def load_ws
			load_workspace(@R, @loc)
		end

		def get_var(var)
			get(@R,var)
		end

		def get_ws
			"#{@loc}/.RData"
		end

		def vars
			get_vars(@R)
		end
  end
end

##
# RubyShogi, a Shogi Engine
# Author: Toni Helminen
# License: GPLv3
##

module RubyShogi

module Utils
	def Utils.log(x)
		File.open("ruby_shogi-log.txt", 'a+') { |file| file.write "#{x}\n" }
	end
end # module Utils

end # module RubyShogi

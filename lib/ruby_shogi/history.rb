##
# RubyShogi, a Shogi Engine
# Author: Toni Helminen
# License: GPLv3
##

module RubyShogi

class History
	def initialize
		reset
	end

	def reset
		@data = []
		@pos = -1
	end
	
	def debug
		puts "@pos: #{@pos} .. @data: #{@data.length}"
	end
	
	def remove
		if @pos > 1
			board = @data[@pos - 2]
			@pos -= 2
			return board
		end
		@data.last
	end

	def undo
		if @pos > 0
			board = @data[@pos - 1]
			@pos -= 1
			return board
		end
		@data.last
	end
	
	def add(board)
		@data.push(board)
		@pos += 1
	end
	
	def draw_too_long?
		@data.length > 900 # I give up...
	end
	
	def is_draw?(board, repsn = 4)
		len, hash = @data.length, board.hash
		i, n, reps = len - 1, 0, 0
		while i > 0
			break if n >= 100 
			reps += 1 if hash == @data[i].hash
			n, i = n + 1, i - 1
			return true if reps >= repsn
		end
		false
	end
end # class History

end # module RubyShogi

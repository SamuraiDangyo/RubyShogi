##
# RubyShogi, a Shogi Engine
# Author: Toni Helminen
# License: GPLv3
##

module RubyShogi

class Perft
	attr_accessor :board
	
	NUMS = { # https://groups.google.com/forum/#!topic/shogi-l/U7hmtThbk1k
		0 => 1,
		1 => 30,
		2 => 900,
		3 => 25470,
		4 => 719731,
		5 => 19861490,
		6 => 547581517
	}
	
	def initialize(fen = nil)
		@board = RubyShogi::Board.new
		@board.fen2(fen)
	end
	
	def perft_number(depth)
		return 1 if depth == 0
		board = @board
		mgen = @board.mgen_generator
		n, moves = 0, mgen.generate_moves
		return moves.length if depth <= 1
		moves.each do |move|
			@board = move
			n += perft_number(depth - 1)
		end
		@board = board
		n
	end
	
	def randperft(depth)
		@board = @board.randpos
		perft(depth)
	end
	
	def perft(depth)
		puts "~~~ perft( #{depth} ) ~~~"
		puts "[ fen: #{@board.pos2fen} ]"
		total_time = 0
		total_nodes = 0
		copy = @board
		(depth+1).times do |i|
			start = Time.now
			@board = copy
			n = perft_number(i)
			diff = Time.now - start
			total_time += diff
			total_nodes += n
			nps = (diff == 0 or n == 1) ? n : (n / diff).to_i
			puts "#{i}: #{n} | #{diff.round(3)}s | #{nps} nps"
		end
		total_time = 1 if total_time == 0
		puts "= #{total_nodes} | #{total_time.round(3)}s | #{(total_nodes/total_time).to_i} nps"
	end
	
	def suite(depth)
		puts "~~~ suite( #{depth} ) ~~~"
		total_time = 0
		total_nodes = 0
		copy = @board
		(depth+1).times do |i|
			start = Time.now
			@board = copy
			n = perft_number(i)
			diff = Time.now - start
			total_time += diff
			total_nodes += n
			nps = (diff == 0 or n == 1) ? n : (n / diff).to_i
			error = ["ok", "error"][NUMS[i] - n == 0 ? 0 : 1]
			break if i >= NUMS.length - 1
			puts "#{i}: #{n} | #{diff.round(3)}s | #{nps} nps | #{error}"
		end
		total_time = 1 if total_time == 0
		puts "= #{total_nodes} | #{total_time.round(3)}s | #{(total_nodes/total_time).to_i} nps"
	end
end # class Perft

end # module ShurikenShogi

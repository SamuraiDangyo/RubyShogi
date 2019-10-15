##
# RubyShogi, a Shogi Engine
# Author: Toni Helminen
# License: GPLv3
##

module RubyShogi

class Perft
	attr_accessor :board
	
	SUITE = [
		
		{ 
			# https://groups.google.com/forum/#!topic/shogi-l/U7hmtThbk1k
			"fen" => "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL[-] w 0 1",
			"numbers" => [
				1,
				30,
				900,
				25470,
				719731,
				19861490,
				547581517
			]
		},
		{
			# http://talkchess.com/forum3/viewtopic.php?f=7&t=32014
			"fen" => "7lk/9/8S/9/9/9/9/7L1/8K[P] w 0 1",
			"numbers" => [
				1,
				85,
				639,
				10786,
				167089,
				3458811
			]
		},
		{ 
			"fen" => "2k6/L8/+b6p1/+b1+b2+n2P/5P1s+N/9/9/7K1/9[LPPpsn] w 0 1",
			"numbers" => [
				1,
				122,
				26689,
				0,#2308091,
				0,
				0,
				0
			]
		}
	]
	
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
	
	def randperft(depth, i, n)
		@board = @board.randpos
		puts "\n[ Round: #{i+1} / #{n} ]"
		perft(depth)
	end
	
	def perft_by_moves(depth=2)
		puts "~~~ perft_by_numbers( #{depth} ) ~~~"
		puts "[ fen: #{@board.pos2fen} ]"
		total_time = 0
		total_nodes = 0
		copy = @board
		mgen = @board.mgen_generator
		moves = mgen.generate_moves
		moves.each_with_index do |m, i|
			@board = m
			start = Time.now
			nn = perft_number(depth-1)
			diff = Time.now - start
			total_time += diff
			total_nodes += nn
			puts "#{i+1}: #{m.move2str}: #{nn}"
			#break
		end
		@board = copy
		puts "= #{total_nodes} | #{total_time.round(3)}s | #{(total_nodes/total_time).to_i} nps"
	end
	
	def perft(depth)
		#puts "~~~ perft( #{depth} ) ~~~"
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
	
	def run_suite(data, i2, depth)
		fen, nums = data["fen"], data["numbers"]
		puts "[ round: #{i2+1} / #{SUITE.length} ]"
		puts "[ fen: #{fen} ]"
		total_nodes, total_time = 0, 0
		@board = RubyShogi::Board.new
		@board.fen2(fen)
		(depth+1).times do |i|
			break if nums[i] == 0
			start = Time.now
			n = perft_number(i)
			diff = Time.now - start
			total_nodes += n
			total_time += diff
			nps = (diff == 0 or n == 1) ? n : (n / diff).to_i
			error = ["ok", "error"][nums[i] - n == 0 ? 0 : 1]
			break if i >= nums.length - 1
			puts "#{i}: #{n} | #{diff.round(3)}s | #{nps} nps | #{error}"
		end
		total_time = 1 if total_time == 0
		puts "= #{total_nodes} | #{total_time.round(3)}s | #{(total_nodes/total_time).to_i} nps\n\n"
	end
	
	def suite(depth)
		puts "~~~ suite( #{depth} ) ~~~"
		SUITE.each_with_index { |s, i| run_suite(s, i, depth) }
	end
end # class Perft

end # module ShurikenShogi

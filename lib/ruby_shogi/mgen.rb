##
# RubyShogi, a Shogi Engine
# Author: Toni Helminen
# License: GPLv3
##

module RubyShogi

class Mgen
	# both
	ROOK_MOVES = [[1, 0], [0, 1], [-1, 0], [0, -1]].freeze
	BISHOP_MOVES = [[1, 1], [-1, 1], [1, -1], [-1, -1]].freeze
	KING_MOVES = (ROOK_MOVES + BISHOP_MOVES).freeze
	
	PROMOTED_BISHOP_MOVES = ROOK_MOVES
	PROMOTED_ROOK_MOVES = BISHOP_MOVES
	
	# white
	WHITE_GOLD_GENERAL_MOVES = [[1, 0], [-1, 0], [0, -1], [0, 1], [1, 1], [-1, 1]].freeze
	WHITE_SILVER_GENERAL_MOVES = [[-1, -1], [-1, 1], [0, 1], [1, 1], [1, -1]].freeze
	WHITE_KNIGHT_MOVES = [[-1, 2], [1, 2]].freeze
	WHITE_LANCE_MOVES = [[0, 1]].freeze
	
	# black
	BLACK_GOLD_GENERAL_MOVES = [[1, 0], [-1, 0], [0, 1], [0, -1], [1, -1], [-1, -1]].freeze
	BLACK_SILVER_GENERAL_MOVES = [[-1, 1], [-1, -1], [0, -1], [1, -1], [1, 1]].freeze
	BLACK_KNIGHT_MOVES = [[-1, -2], [1, -2]].freeze
	BLACK_LANCE_MOVES = [[0, -1]].freeze

	# promotions
	PROMO_NO   = 0
	PROMO_STAY = 1
	PROMO_YES  = 2
	
	attr_accessor :pseudo_moves, :only_captures
	
	def initialize(board)
		@board, @moves = board, []
		@x_gen, @y_gen, @from_gen = 0, 0, 0 # move generation
		@x_checks, @y_checks = 0, 0 # checks
		@pseudo_moves = false # 3x speed up
	end

	##
	# Utils
	##
	
	def print_move_list
		@moves.each_with_index { |board, i| puts "#{i}: #{board.move_str}" }
	end
	
	def is_on_board?(x, y)	
		x >= 0 && x <= 8 && y >= 0 && y <= 8
	end
	
	def remove_from_array(array, x)
		array.delete_at(array.index(x) || array.length)
		array
	end
	
	def good_coord?(i)
		i >= 0 && i <= 80
	end
	
	def eaten_piece(eat) 
		case eat
		when 2 then 1
		when 4 then 3
		when 6 then 5
		when 8 then 7
		when 11 then 10
		when 13 then 12
		else eat
		end
	end

	##
	# Checks
	##
	
	def pawn_checks_w?(here)
		@x_checks + 9 * (@y_checks + 1) == here
	end
	
	def pawn_checks_b?(here)
		@x_checks + 9 * (@y_checks - 1) == here
	end

	def slider_checks_to?(slider, here)
		slider.each do |jmp|
			px, py = @x_checks, @y_checks
			loop do
				px, py = px + jmp[0], py + jmp[1]
				break if !is_on_board?(px, py)
				to = px + py * 9
				return true if to == here
				break if !@board.empty?(to)
			end
		end
		false
	end
	
	def jump_checks_to?(jumps, here)
		jumps.each do |jmp|
			px, py = @x_checks + jmp[0], @y_checks + jmp[1]
			return true if is_on_board?(px, py) && px + py * 9 == here
		end
		false
	end
	
	def checks_w?(here = nil, useking = true)
		here = here == nil ? @board.bking : here
		#fail if @board.find_black_king !=  here
		81.times do |i|
			@x_checks, @y_checks = i % 9, (i / 9).to_i
			case @board.brd[i]
			when 1 then return true if pawn_checks_w?(here)
			when 2 then return true if jump_checks_to?(WHITE_GOLD_GENERAL_MOVES, here)
			when 3 then return true if slider_checks_to?(WHITE_LANCE_MOVES, here)
			when 4 then return true if jump_checks_to?(WHITE_GOLD_GENERAL_MOVES, here)
			when 5 then return true if jump_checks_to?(WHITE_KNIGHT_MOVES, here)
			when 6 then return true if jump_checks_to?(WHITE_GOLD_GENERAL_MOVES, here)
			when 7 then return true if jump_checks_to?(WHITE_SILVER_GENERAL_MOVES, here)
			when 8 then return true if jump_checks_to?(WHITE_GOLD_GENERAL_MOVES, here)
			when 9 then return true if jump_checks_to?(WHITE_GOLD_GENERAL_MOVES, here)
			when 10 then return true if slider_checks_to?(BISHOP_MOVES, here)
			when 11 then return true if slider_checks_to?(BISHOP_MOVES, here) || jump_checks_to?(PROMOTED_BISHOP_MOVES, here)
			when 12 then return true if slider_checks_to?(ROOK_MOVES, here)
			when 13 then return true if slider_checks_to?(ROOK_MOVES, here) || jump_checks_to?(PROMOTED_ROOK_MOVES, here)
			when 14 then return true if useking && jump_checks_to?(KING_MOVES, here)
			end
		end
		false
	end
	 
	def checks_b?(here = nil, useking = true)
		here = here == nil ? @board.wking : here
		#fail if @board.find_white_king != here
		81.times do |i|
			@x_checks, @y_checks = i % 9, (i / 9).to_i
			case @board.brd[i]
			when -1 then return true if pawn_checks_b?(here)
			when -2 then return true if jump_checks_to?(BLACK_GOLD_GENERAL_MOVES, here)
			when -3 then return true if slider_checks_to?(BLACK_LANCE_MOVES, here)
			when -4 then return true if jump_checks_to?(BLACK_GOLD_GENERAL_MOVES, here)
			when -5 then return true if jump_checks_to?(BLACK_KNIGHT_MOVES, here)
			when -6 then return true if jump_checks_to?(BLACK_GOLD_GENERAL_MOVES, here)
			when -7 then return true if jump_checks_to?(BLACK_SILVER_GENERAL_MOVES, here)
			when -8 then return true if jump_checks_to?(BLACK_GOLD_GENERAL_MOVES, here)
			when -9 then return true if jump_checks_to?(BLACK_GOLD_GENERAL_MOVES, here)
			when -10 then return true if slider_checks_to?(BISHOP_MOVES, here)
			when -11 then return true if slider_checks_to?(BISHOP_MOVES, here) || jump_checks_to?(PROMOTED_BISHOP_MOVES, here)
			when -12 then return true if slider_checks_to?(ROOK_MOVES, here)
			when -13 then return true if slider_checks_to?(ROOK_MOVES, here) || jump_checks_to?(PROMOTED_ROOK_MOVES, here)
			when -14 then return true if useking && jump_checks_to?(KING_MOVES, here)
			end
		end
		false
	end
end # class Mgen

end # module RubyShogi

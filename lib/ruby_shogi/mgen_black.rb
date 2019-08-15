##
# RubyShogi, a Shogi Engine
# Author: Toni Helminen
# License: GPLv3
##

module RubyShogi

class MgenBlack < RubyShogi::Mgen
	def initialize(board)
		@board = board
	end
	
	def handle_capture(copy, eat) 
		piece = case eat
			when -2..-1 then -1
			when -4..-3 then -3
			when -6..-5 then -5
			when -8..-7 then -7
			when -9 then -9
			when -11..-10 then -10
			when -13..-12 then -12
			end
		copy.white_pocket.push(piece)
	end
	
	def add_new_move(me, to, promo = 0)
		return if handle_promotion?(me, to)
		push_move(me, to, promo)
	end
	
	def push_move(me, to, promo) 
		board2 = @board
		copy = @board.copy_me
		copy.from = @from_gen
		copy.promo = promo
		copy.r50 += 1
		copy.fullmoves += 1
		copy.r50 = 0 if [-1, -3, -5].include?(me)
		copy.to = to
		copy.eat = copy.brd[to]
		copy.black_pocket.push(-1 * eaten_piece(copy.eat)) if copy.eat != 0
		copy.wtm = !copy.wtm
		copy.brd[@from_gen] = 0
		copy.brd[to] = me
		copy.bking = to if me == -14
		#fail if copy.find_black_king != copy.bking
		@board = copy
		@moves.push << copy if !checks_w?
		@board = board2
	end
	
	def pawn_drop_checkmate?(to) 
		@board.brd[to - 9] == 14 && !checks_w?(to - 9) ? true : false
	end
	
	def add_new_drop_move(me, to) 
		return if me == -3 && to / 9 == 0
		return if me == -5 && to / 9 <= 1
		board2 = @board
		copy = @board.copy_me
		copy.from = @from_gen
		copy.to = to
		copy.drop = me
		copy.r50 += 1
		copy.fullmoves += 1
		copy.eat = 0
		copy.wtm = ! copy.wtm
		copy.brd[@from_gen] = 0
		copy.brd[to] = me
		copy.black_pocket = remove_from_array(copy.black_pocket, me)
		#fail if copy.find_black_king != copy.bking
		@board = copy
		if !checks_w? && !(me == 1 && pawn_drop_checkmate?(to))
			@moves.push << copy
		end
		@board = board2
	end
	
	def handle_promotion?(me, to)
		return true if must_promote?(me, to)
		return false if to / 9 > 2 && @from_gen / 9 > 2
		case me
		when -1 
			push_move(-1, to, PROMO_STAY)
			push_move(-2, to, PROMO_YES)
			return true
		when -3 
			push_move(-3, to, PROMO_STAY)
			push_move(-4, to, PROMO_YES)
			return true
		when -5 
			push_move(-5, to, PROMO_STAY)
			push_move(-6, to, PROMO_YES)
			return true
		when -7 
			push_move(-7, to, PROMO_STAY)
			push_move(-8, to, PROMO_YES)
			return true
		when -10 
			push_move(-10, to, PROMO_STAY)
			push_move(-11, to, PROMO_YES)
			return true
		when -12 
			push_move(-12, to, PROMO_STAY)
			push_move(-13, to, PROMO_YES)
			return true
		end
	end
	
	def must_promote?(me, to)
		if me == -5 && to / 9 <= 1
			push_move(-6, to, PROMO_YES)
			return true
		end
		return false if to / 9 != 0
		case me
		when -1 
			push_move(-2, to, PROMO_YES)
			return true
		when -3
			push_move(-4, to, PROMO_YES)
			return true
		end
		false
	end

	def add_new_pawn_move(to)
		case to / 9
		when 1..2
			push_move(-1, to, PROMO_STAY)
			push_move(-2, to, PROMO_YES)
		when 0 then push_move(-2, to, PROMO_YES)
		else
			push_move(-1, to, PROMO_NO)
		end
	end
	
	def generate_pawn_moves
		to = @x_gen + (@y_gen - 1) * 9
		add_new_pawn_move(to) if to >= 0 && @board.walkable_b?(to)
	end
		
	def generate_jump_moves(jumps, me)
		jumps.each do |jmp|
			px, py = @x_gen + jmp[0], @y_gen + jmp[1]
			to = px + 9 * py
			add_new_move(me, to) if is_on_board?(px, py) && @board.walkable_b?(to)
		end
	end
	
	def generate_slider_moves(slider, me)
		slider.each do | jmp |
			px, py = @x_gen, @y_gen
			loop do
				px, py = px + jmp[0], py + jmp[1]
				break if !is_on_board?(px, py)
				to = px + 9 * py
				add_new_move(me, to) if @board.walkable_b?(to)
				break if !@board.empty?(to)
			end
		end
	end
	
	def pawn_on_column?(c)
		ret = false
		9.times do |i|
			to = -9 * i + 8 * 9 + c
			if to != @from_gen && @board.brd[to] == -1
				ret = true
				break
			end
		end
		ret
	end
	
	def put_pawn_drops
		(9*8).times do |i2|
			i = i2 + 9
			@x_gen, @y_gen, @from_gen = i % 9, i / 9, i
			add_new_drop_move(-1, i) if (!pawn_on_column?(i % 9 ) && @board.brd[i].zero?)
		end
	end
	
	def put_drops(piece)
		81.times do |i|
			@x_gen, @y_gen, @from_gen = i % 9, i / 9, i
			add_new_drop_move(piece, i) if @board.brd[i].zero?
		end
	end
	
	def generate_drops
		@board.black_pocket.each do |piece|
			case piece
			when -1 then put_pawn_drops
			when -3 then put_drops(-3)
			when -5 then put_drops(-5)
			when -7 then put_drops(-7)
			when -9 then put_drops(-9)
			when -10 then put_drops(-10)
			when -11 then put_drops(-11)
			when -12 then put_drops(-12)
			end
		end
		@moves
	end
	
	def generate_moves
		@moves = []
		81.times do |i|
			@x_gen, @y_gen, @from_gen = i % 9, i / 9, i
			case @board.brd[i]
			when -1 then generate_pawn_moves
			when -2 then generate_jump_moves(BLACK_GOLD_GENERAL_MOVES, -2)
			when -3 then generate_slider_moves(BLACK_LANCE_MOVES, -3)
			when -4 then generate_jump_moves(BLACK_GOLD_GENERAL_MOVES, -4)
			when -5 then generate_jump_moves(BLACK_KNIGHT_MOVES, -5)
			when -6 then generate_jump_moves(BLACK_GOLD_GENERAL_MOVES, -6)
			when -7 then generate_jump_moves(BLACK_SILVER_GENERAL_MOVES, -7)
			when -8 then generate_jump_moves(BLACK_GOLD_GENERAL_MOVES, -8)
			when -9 then generate_jump_moves(BLACK_GOLD_GENERAL_MOVES, -9)
			when -10 then generate_slider_moves(BISHOP_MOVES, -10)
			when -11 
				generate_slider_moves(BISHOP_MOVES, -11)
				generate_jump_moves(PROMOTED_BISHOP_MOVES, -11)
			when -12 then generate_slider_moves(ROOK_MOVES, -12)
			when -13 
				generate_slider_moves(ROOK_MOVES, -13)
				generate_jump_moves(PROMOTED_ROOK_MOVES, -13)
			when -14 then generate_jump_moves(KING_MOVES, -14)
			end
		end
		generate_drops
	end
end # class MgenBlack

end # module RubyShogi

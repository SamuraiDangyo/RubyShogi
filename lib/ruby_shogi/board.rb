##
# RubyShogi, a Shogi Engine
# Author: Toni Helminen
# License: GPLv3
##

module RubyShogi

class Board
	START_POS = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL[-] w 0 1"
	
	PIECES = {
		".":    0,
		"P":    1, # Pawn
		"p":   -1,
		"+P":   2, # Promoted Pawn
		"+p":  -2,
		"L":    3, # Lance
		"l":   -3,
		"+L":   4, # Promoted Lance
		"+l":  -4,
		"N":    5, # Knight
		"n":   -5,
		"+N":   6, # Promoted Knight
		"+n":  -6,
		"S":    7, # Silver
		"s":   -7,
		"+S":   8, # Promoted Silver
		"+s":  -8,
		"G":    9, # Gold
		"g":   -9,
		"B":   10, # Bishop
		"b":  -10,
		"+B":  11, # Promoted Bishop
		"+b": -11,
		"R":   12, # Rook
		"r":  -12,
		"+R":  13, # Promoted Rook
		"+r": -13,
		"K":   14, # King
		"k":  -14
	}.freeze
	
	attr_accessor :brd, :wking, :bking, :white_pocket, :black_pocket, :variant, :nodetype, :r50, :drop, :hash, :fullmoves, :wtm, :eat, :from, :to, :score, :promo, :index
	
	def initialize
		initme
	end

	def initme
		@brd = [0] * 81
		@wtm, @from, @to, @eat = true, 0, 0, 0
		@score, @promo = 0, 0
		@white_pocket = []
		@black_pocket = []
		@index = 0
		@r50 = 0
		@drop = 0
		@hash = 0
		@wking = 0
		@bking = 0
		@fullmoves = 2
		@nodetype = 0 # 2 draw 1 win -1 loss
	end
	
	def brd2str
		s, empty, counter = "", 0, 0
		80.times do |j|
			i = 10 * (7 - j / 10) + ( j % 10 )
			p = @brd[i]
			if p != 0
				if empty > 0
					s += empty.to_s 
					empty = 0
				end
				s += "fcakqrbnp.PNBRQKACF"[p + 9]
			else
				empty += 1
			end
			counter += 1
			if counter % 10 == 0
				s += empty.to_s if empty > 0
				s += "/" if counter < 80
				empty = 0
			end
		end
		s
	end
	
	def wtm2str
		@wtm ? "w" : "b"
	end
	
	def tofen
		"#{brd2str} #{wtm2str}"
	end
	
	def mgen_generator
		@wtm ? RubyShogi::MgenWhite.new(self) : RubyShogi::MgenBlack.new(self)
	end
	
	def create_hash
		@hash = 0
		81.times { | i | @hash ^= RubyShogi::Zobrist.get(20 * i + 8 + @brd[i]) }
		@hash ^= RubyShogi::Zobrist.get(20 * 80 + (@wtm ? 1 : 0))
	end
	
	def legal?
		pieces = [0] * 20
		@brd.each { |p| pieces[p + 9] += 1 }
		return false if pieces[-6 + 9] == 0 || pieces[6 + 9] == 0
		true
	end
		
	def make_move(me, from, to)
		#fail unless (good_coord?(from) && good_coord?(to))
		@eat = @brd[to]
		@brd[to] = me
		@brd[from] = 0
	end
	
	def find_white_king
		@brd.index { | x | x == 14 }
	end
	
	def find_black_king
		@brd.index { | x | x == -14 }
	end
	
	def find_piece_all(piece)
		@brd.index { | x | x == piece }
	end
	
	# scans ->
	def find_piece(start_square, end_square, me, diff = 1)
		i = start_square
		loop do
			return i if @brd[i] == me
			fail "ShurikenShogi Error: Couldn't Find: '#{me}'" if i == end_square
			i += diff
		end
	end
	
	# scans ->
	def just_kings?
		81.times do |i|
			return false if @brd[i] != 14 && @brd[i] != -14
		end
		true
	end
	
	def material_draw?
		81.times do |i|
			return false if @brd[i] != 14 && @brd[i] != -14 && @brd[i] != 0
		end
		true
	end
	
	def copy_me()
		copy = RubyShogi::Board.new
		copy.brd = @brd.dup
		copy.white_pocket = @white_pocket.dup
		copy.black_pocket = @black_pocket.dup
		copy.wtm = @wtm
		copy.from = @from
		copy.to = @to
		copy.r50 = @r50
		copy.wking = @wking
		copy.bking = @bking
		copy
	end

	def startpos
		fen(START_POS)
	end

	def last_rank?(square)
		y_coord(square) == 8
	end
	
	def first_rank?(x)
		y_coord(x) == 0
	end
	
	def empty?(i)
		@brd[i] == 0
	end
	
	def walkable_w?(square)
		@brd[square] < 1
	end
	
	def walkable_b?(square)
		@brd[square] > -1
	end
	
	def is_on_board?(x, y)	
		x >= 0 && x <= 8 && y >= 0 && y <= 8
	end
	
	def good_coord?(i)	
		i >= 0 && i < 81
	end
	
	def distance(p1, p2)
		[(p1 % 9 - p2 % 9 ).abs, (p1 / 9 - p2 / 9).abs].max
	end
	
	def jishogi_likely_w?(wking)
		res = 0
		81.times { |i| res += 1 if @brd[i] > 0 && distance(wking, i) < 3 }
		res > 5
	end
	
	def jishogi_likely_b?(bking)
		res = 0
		81.times { |i| res += 1 if @brd[i] < 0 && distance(bking, i) < 3 }
		res > 5
	end
	
	# TODO improve likely?
	def jishogi?
		wking, bking = find_white_king, find_black_king
		if wking / 9 >= 6 && bking / 9 <= 2 && jishogi_likely_w?(wking) && jishogi_likely_b?(bking)
			return true
		end
		false
	end
	
	def count_jishogi_w
		res = 0
		81.times do |i|
			if [10, 12].include?(@brd[i])
				res += 5 
			elsif @brd[i] != 14
				res += 1
			end
		end
		res
	end
	
	def count_jishogi_b
		res = 0
		81.times do |i|
			if [-10, -12].include?(@brd[i])
				res += 5 
			elsif @brd[i] != -14
				res += 1
			end
		end
		res
	end
	
	def mirror_board
		(4*9).times do | i |
			x, y = i % 9, i / 9
			flip_y = x + (8 - y) * 9
			p1 = @brd[i]
			p2 = @brd[flip_y]
			@brd[i] = p2
			@brd[flip_y] = p1
		end
	end
	
	def flip_coord(coord)
		(9 - 1 - y_coord(coord)) * 9 + x_coord(coord)
	end
	
	# TODO optimize
	def number2piece(num)
		ret = 0
		PIECES.each { |piece2, num2| 
			if num.to_i == num2.to_i
				ret = piece2
				break
			end
		}
		ret.to_s
	end
	
	# TODO optimize
	def piece2number(piece)
		ret = 0
		PIECES.each { |piece2, num| 
			if piece == piece2.to_s
				ret = num 
				break
			end
		}
		ret
	end
	
	def pos2fen
		s = ""
		9.times do |y|
			empty = 0
			9.times do |x|
				p = @brd[9 * (8 - y) + x]
				if p == 0
					empty += 1
				else
					if empty > 0
						s << empty.to_s
						empty = 0
					end
					s << number2piece(p)
				end
			end
			s << empty.to_s if empty > 0
			s << "/" if y < 8
		end
		s << "["
		@white_pocket.each { |p| s << number2piece(p) }
		@black_pocket.each { |p| s << number2piece(p) }
		s << "-" if @white_pocket.empty? && @black_pocket.empty?
		s << "] "
		s << (@wtm ? "w" : "b")
		s << " #{@r50.to_s}"
		s << " #{(@fullmoves/2).to_i}"
		s
	end
	
	def fen_board(s)
		s = s.gsub(/\d+/) { | m | "_" * m.to_i }
			.gsub(/\//) { | m | "" }
		i, k = 0, 0
		while i < s.length
			piece = s[i]
			if s[i] == "+"# && i + 1 < s.length
				i += 1
				piece = "+#{s[i]}"
			end
			@brd[k] = piece2number(piece)
			k += 1
			i += 1
		end
	end
	
	def fen_pocket(s)
		@white_pocket = []
		@black_pocket = []
		s.strip!
		return if s == "-"
		i = 0
		while i < s.length
			num = piece2number(s[i])
			if num > 0
				@white_pocket.push(num)
			elsif num < 0
				@black_pocket.push(num)
			end
			i += 1
		end
	end
	
	def fen_wtm(s)
		@wtm = s == "w" ? true : false
	end
	
	def fen2(s = nil)
		if s.nil?
			fen(START_POS)
		else
			fen(s)
		end
	end
	
	def fen(str)
		initme
		s = str.strip.split(" ")
		fail if s.length < 3
		t = s[0].strip.split("[")
		fen_board(t[0])
		fen_pocket(t[1])
		@wtm = s[1] == "w" ? true : false
		@r50 = 2 * s[2].to_i if s.length >= 3
		@fullmoves = 2 * s[3].to_i if s.length >= 4
		mirror_board
		@wking = find_white_king
		@bking = find_black_king
	end
	
	def eval
		Eval.eval(self)
	end

	def material
		Eval.material(self)
	end
		
	def pocket2str
		s = ""
		@white_pocket.each { |num| s << number2piece(num) }
		@black_pocket.each { |num| s << number2piece(num) }
		s.strip.length == 0 ? "-" : s
	end
	
	def move_str
		if @drop != 0
			s = "#{number2piece(@drop).upcase}@"
			tox, toy = @to % 9, @to / 9
			s << ("a".ord + tox).chr
			s << (toy + 1).to_s
			return s
		end
		fromx, fromy = @from % 9, @from / 9
		tox, toy = @to % 9, @to / 9
		s = ("a".ord + fromx).chr
		s << (fromy + 1).to_s
		s << ("a".ord + tox).chr
		s << (toy + 1).to_s
		if @promo == 2
			s << "+"
		elsif @promo == 1
			s << "="
		end
		s
	end
		
	def randpos
		copy = RubyShogi::Board.new
		copy.brd[rand(0..	32)] = 14
		copy.brd[rand((81-32)..80)] = -14
		32.times { |i| copy.brd[32 + i] = rand(-13..13) if rand < 0.3 }
		3.times { |i| copy.white_pocket.push([1, 3, 5, 7, 9].sample) }
		3.times { |i| copy.black_pocket.push([-1, -3, -5, -7, -9].sample) }
		copy
	end
	
	def print_board
		s =""
		81.times do | i |
			x, y = i % 9, i / 9
			p = @brd[9 * (8 - y) + x]
			ch = "."
			PIECES.each do |pie, num|
				if num.to_i == p.to_i
					ch = pie.to_s
					break
				end
			end
			s << " " if ch.length < 2
			s << ch
   			if (i + 1) % 9 == 0
				s << " #{((9 - i / 9).to_i).to_s}\n"
   			end
		end
		9.times { |i| s << " " << ("a".ord + i).chr }
		s << "\n[ wtm: #{@wtm} ]\n"
		s << "[ r50: #{(@r50/2).to_i} ]\n"
		s << "[ pocket: #{pocket2str} ]\n"
		s << "[ fen: #{pos2fen} ]\n"
		puts s
	end
end # class Board

end # module RubyShogi

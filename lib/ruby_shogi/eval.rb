##
# RubyShogi, a Shogi Engine
# Author: Toni Helminen
# License: GPLv3
##

module RubyShogi

module Eval
	# https://en.wikipedia.org/wiki/Shogi_strategy#Relative_piece_value
	MATERIAL_SCORE = {
		1 => 1,
		2 => 4.2,
		3 => 4.3,
		4 => 6.3,
		5 => 4.5,
		6 => 6.4,
		7 => 6.4,
		8 => 6.7,
		9 => 6.9,
		10 => 8.9,
		11 => 11.5,
		12 => 10.4,
		13 => 13,
		14 => 0
	}

	MATERIAL_HAND_SCORE = {
		1 => 1.15,
		3 => 4.8,
		5 => 5.1,
		7 => 7.2,
		9 => 7.8,
		10 => 11.10,
		12 => 10.4,
		13 => 12.7
	}
	
	CENTRAL_BONUS = [1,2,3,4,5,4,3,2,1].freeze
	
	CENTRAL_SCORE = {
		1 => 0,
		2 => 2,
		3 => 1,
		4 => 2,
		5 => 1,
		6 => 2,
		7 => 2,
		8 => 2,
		9 => 2,
		10 => 2,
		11 => 2,
		12 => 2,
		13 => 2,
		14 => 0
	}
	
	EVAL_PST_MG = []

	def Eval.init
		return if EVAL_PST_MG.length > 0
		14.times do |i|
			arr = []
			81.times do |j|
				score = 0.1 * (MATERIAL_SCORE[i + 1] + 2 * CENTRAL_SCORE[i + 1] * (CENTRAL_BONUS[j % 9 ] + CENTRAL_BONUS[j / 9]))
				arr.push(score)
			end
			EVAL_PST_MG.push(arr)
		end
		EVAL_PST_MG.freeze
	end
	
	def Eval.eval(board)
		score = 0
		board.brd.each_with_index do |p, i|
			score += case p
				when 1..14 then EVAL_PST_MG[p - 1][i]
				when -14..-1 then EVAL_PST_MG[-p - 1][i]
				else 
					0
				end
		end
		0.01 * score
	end
	
	def Eval.material2(board)
		#board.print_board
		#puts Eval.material2(board)
		#puts Eval.material3(board)
		#fail if Eval.material2(board) != Eval.material3(board)
		0
	end
	
	def Eval.material3(board)
		score = board.brd.inject do |sum, p|
			sum += case p
				when 1..14 then MATERIAL_SCORE[p]
				when -14..-1 then -MATERIAL_SCORE[-p]
				else 
					0
				end
		end
		board.white_pocket.each { |p| score += MATERIAL_HAND_SCORE[p] }
		board.black_pocket.each { |p| score -= MATERIAL_HAND_SCORE[-p] }
		score
	end
	
	def Eval.material(board)
		score = 0
		board.brd.each do |p|
			score += case p
				when 1..14 then MATERIAL_SCORE[p]
				when -14..-1 then -MATERIAL_SCORE[-p]
				else 
					0
				end
		end
		board.white_pocket.each { |p| score += MATERIAL_HAND_SCORE[p] }
		board.black_pocket.each { |p| score -= MATERIAL_HAND_SCORE[-p] }
		score
	end
end # module Eval

end # module RubyShogi

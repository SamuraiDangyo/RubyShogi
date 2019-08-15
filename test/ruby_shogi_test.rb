##
# RubyShogi, a Shogi Engine
# Author: Toni Helminen
# License: GPLv3
##

require 'minitest/autorun'
require 'ruby_shogi'

class RubyShogiTest < Minitest::Test
 	def test_mgen_1
		p = RubyShogi::Perft.new("k8/9/9/9/9/9/9/9/K8[P] w 0 1")
    	assert_equal(1, p.perft_number(0))
    	assert_equal(74, p.perft_number(1))
  	end
  	
 	def test_mgen_2
		p = RubyShogi::Perft.new("k8/9/9/9/9/9/9/9/K8[-] w 0 1")
    	assert_equal(1, p.perft_number(0))
    	assert_equal(3, p.perft_number(1))
  	end
  	
 	def test_mgen_3
		p = RubyShogi::Perft.new("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL[-] w 0 1")
    	assert_equal(1, p.perft_number(0))
    	assert_equal(30, p.perft_number(1))
    	assert_equal(900, p.perft_number(2))
    	assert_equal(25470, p.perft_number(3))
  	end
  	
 	def test_mgen_4
		p = RubyShogi::Perft.new("k8/9/9/9/9/9/3L5/9/K8[-] w 0 1")
    	assert_equal(1, p.perft_number(0))
    	assert_equal(11, p.perft_number(1))
  	end
  	
 	def test_mgen_5
		p = RubyShogi::Perft.new("k8/9/9/9/9/9/3+R5/9/K8[-] w 0 1")
    	assert_equal(1, p.perft_number(0))
    	assert_equal(23, p.perft_number(1))
  	end
  	
 	def test_mgen_6
		p = RubyShogi::Perft.new("k8/9/9/3P5/9/9/9/9/K8[-] w 0 1")
    	assert_equal(1, p.perft_number(0))
    	assert_equal(5, p.perft_number(1))
  	end
  	
 	def test_mgen_7
		p = RubyShogi::Perft.new("k8/9/9/9/9/3p5/9/9/K8[-] b 0 1")
    	assert_equal(1, p.perft_number(0))
    	assert_equal(5, p.perft_number(1))
  	end
  	
 	def test_board_1
 		f = "3k5/2P1P4/3K5/9/1N7/9/9/9/9[-] w 0 1"
		b = RubyShogi::Board.new
		b.fen(f)
    	assert_equal(b.pos2fen, f)
  	end
  	
 	def test_board_2
 		f = "4k4/9/4K4/9/9/9/9/9/9[G] w 0 1"
		b = RubyShogi::Board.new
		b.fen(f)
    	assert_equal(b.pos2fen, f)
  	end
  	
 	def test_board_3
 		f = "9/9/9/9/9/9/4K4/R4R3/6k2[-] w 0 1"
		b = RubyShogi::Board.new
		b.fen(f)
    	assert_equal(b.pos2fen, f)
  	end
end

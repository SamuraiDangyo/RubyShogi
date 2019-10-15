##
# RubyShogi, a Shogi Engine
# Author: Toni Helminen
# License: GPLv3
##

module RubyShogi

class Cmd
	attr_accessor :engine, :random_mode
	
	def initialize
		@random_mode = false
		@tokens = RubyShogi::Tokens.new(ARGV)
		@fen = nil
	end
	
	def name
		puts "#{RubyShogi::NAME} v#{RubyShogi::VERSION} by #{RubyShogi::AUTHOR}"
	end
	
	def randommode
		@random_mode = true
	end
	
	def peek_argint(defval)
		val = @tokens.peek(1)
		if val != nil && val.match(/\d+/)
			@tokens.forward
			defval = @tokens.cur.to_i
		end
		defval
	end
		
	def mbench
		p = RubyShogi::Perft.new
		p.suite(peek_argint(4))
	end
	
	def perft
		n = peek_argint(5)
		puts "~~~ perft( #{n} ) ~~~"
		p = RubyShogi::Perft.new(@fen)
		p.perft(n)
	end
	
	def randperft
		n = peek_argint(10)
		puts "~~~ randperft( #{n} ) ~~~"
		n.times do |i|
			p = RubyShogi::Perft.new
			p.randperft(2, i, n)
		end
	end
	
	def suite
		p = RubyShogi::Perft.new
		p.suite(peek_argint(4))
	end
	
	def bench
		e = RubyShogi::Engine.new(random_mode: @random_mode)
		e.bench
	end
	
	def stats
		e = RubyShogi::Engine.new(random_mode: @random_mode)
		e.board.fen(@fen) if @fen != nil
		e.stats(peek_argint(100))
	end
	
	def tactics
		RubyShogi::Tactics.run
	end
	
	def fen
		@tokens.go_next
		@fen = @tokens.cur
	end
	
	def list
		board = RubyShogi::Board.new
		board.fen2(@fen)
		mgen = board.mgen_generator
		moves = mgen.generate_moves
		mgen.print_move_list
		puts "= #{moves.length} moves"
	end
	
	#def list
	#	board = RubyShogi::Board.new
	#	board.fen(@fen)
	#	mgen = board.mgen_generator
	#	moves = mgen.generate_moves
	#	moves.each_with_index { |b, i| puts "> #{i}: #{b.move_str}" }
	#end

	def perft_by_moves
		#b = RubyShogi::Board.new
		#b.startpos
		#b.fen("lnsgkgsnl/2r4b1/ppppp+Pp1p/7p1/9/9/PPPPP1PPP/1B5R1/LNSGKGSNL[P] w 1 5")
		#b.fen("9/3k5/7+P1/8P/9/9/6P2/R3K4/1NSG1GSNL[PPPPPPPPPNNBRLLSSGGppppppbl] w 19 100")
		#      +P8/9/8L/L3k3R/1KP6/9/3s5/2S6/1+n1g4+B[PPPPPPPPPNBRLLSGpppppppnnsgg] b
		#		b.fen("5K3/2+P6/6+P2/9/4k4/9/9/9/9[PPPPPPPPPNNBRLLSSGGpppppppnnbrllssgg] w 67 185")
		#b.fen("8+r/5K3/9/9/9/9/k8/9/9[-] w 24 1")
		#b.fen("9/+l4k3/+P1+r2L1+l1/+l3+B2S1/1n5rR/5+l+l2/9/9/1K7[LGNpgl] w 0 1")
		#b.print_board
		#mgen = b.mgen_generator
		#mgen.generate_moves
		
		# 5k3/+n8/1G5R1/2+s+P3b1/n+s2l+B+N2/5s+prp/9/7K1/9 w
		#p = RubyShogi::Perft.new("5k3/+n8/1G5R1/2+s+P3b1/n+s2l+B+N2/5s+prp/9/7K1/9[SPGnpn] w 0 1")
		p = RubyShogi::Perft.new("5k3/+n8/1G5R1/2+s+P3b1/n+s2l+B+N2/5s+prp/9/8K/9[PSGpnn] b 0 1")
		
		p.perft_by_moves(peek_argint(1))
	end
	
	def test
		#b = RubyShogi::Board.new
		#b.startpos
		#b.fen("lnsgkgsnl/2r4b1/ppppp+Pp1p/7p1/9/9/PPPPP1PPP/1B5R1/LNSGKGSNL[P] w 1 5")
		#b.fen("9/3k5/7+P1/8P/9/9/6P2/R3K4/1NSG1GSNL[PPPPPPPPPNNBRLLSSGGppppppbl] w 19 100")
		#      +P8/9/8L/L3k3R/1KP6/9/3s5/2S6/1+n1g4+B[PPPPPPPPPNBRLLSGpppppppnnsgg] b
		#		b.fen("5K3/2+P6/6+P2/9/4k4/9/9/9/9[PPPPPPPPPNNBRLLSSGGpppppppnnbrllssgg] w 67 185")
		#b.fen("8+r/5K3/9/9/9/9/k8/9/9[-] w 24 1")
		#b.fen("9/+l4k3/+P1+r2L1+l1/+l3+B2S1/1n5rR/5+l+l2/9/9/1K7[LGNpgl] w 0 1")
		#b.print_board
		#mgen = b.mgen_generator
		#mgen.generate_moves
		# 5k3/+n8/1G5R1/2+s+P3b1/n+s2l+B+N2/5s+prp/9/7K1/9 w
		p = RubyShogi::Perft.new("5k3/+n8/1G5R1/2+s+P3b1/n+s2l+B+N2/5s+prp/9/7K1/9[SPGnpn] w 0 1")
		
		p = RubyShogi::Perft.new("7lk/9/8S/9/9/9/9/7L1/8K[P] w 0 1")
		
		
		p.board.print_board
		p.perft_by_moves(peek_argint(1))
		#p.perft(peek_argint(5))
	end
	
	def print_numbers
		s = ""
		9.times do |y|
			9.times do |x|
				i = (8 - y) * 9 + x
				s << "#{i}"
				s << (i < 10 ? "  " : " ")
			end
			s << "\n"
		end
		puts "~~~ Table Numbers ~~~"
		puts s
	end
	
	def rubybench
		RubyShogi::Bench.go
	end

	def xboard
		xboard = RubyShogi::Xboard.new(@random_mode)
		xboard.go
	end
	
	def profile
		require 'ruby-prof'
		result = RubyProf.profile do
			e = RubyShogi::Engine.new(random_mode: @random_mode)
			e.bench
		end
		printer = RubyProf::FlatPrinter.new(result)
		printer.print(STDOUT)
	end
	
	def help
		puts "Usage: ruby shuriken_ruby.rb [OPTION]... [PARAMS]..."
		puts "###"
		puts "-help: This Help"
		puts "-xboard: Enter Xboard Mode"
		puts "-tactics: Run Tactics"
		puts "-name: Print Name Tactics"
		puts "-rubybench: Benchmark Ruby"
		puts "-bench: Benchmark ShurikenShogi Engine"
		puts "-mbench: Benchmark ShurikenShogi Movegen"
		puts "-perft [NUM]: Run Perft"
		puts "-perft_by_moves [NUM]: Run Perft By Moves"
		puts "-profile: Profile ShurikenShogi"
		puts "-randommode: Activate Random Mode"
		puts "-fen [FEN]: Set Fen"
		puts "-stats [NUM]: Statistical Analysis"
		puts "-list: List Moves"
		puts "-numbers: Board Numbers"
	end

	def args
		help && return if ARGV.length < 1
		while @tokens.ok?
			case @tokens.cur
			when "-xboard" then xboard and return # enter xboard mode
			when "-rubybench" then rubybench
			when "-bench" then bench
			when "-mbench" then mbench
			when "-stats" then stats
			when "-variant" then variant
			when "-randommode" then randommode
			when "-tactics" then tactics
			when "-test" then test
			when "-name" then name
			when "-fen" then fen
			when "-list" then list
			when "-profile" then profile
			when "-perft" then perft
			when "-randperft" then randperft
			when "-suite" then suite
			when "-perft_by_moves" then perft_by_moves
			when "-numbers" then print_numbers
			when "-help" then help
			else
				puts "RubyShogi Error: Unknown Command: '#{@tokens.cur}'"
				return
			end
			@tokens.forward
		end
	end
end # class Cmd

end # module RubyShogi

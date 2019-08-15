##
# RubyShogi, a Shogi Engine
# Author: Toni Helminen
# License: GPLv3
##

module RubyShogi

module Tactics
	TACTICS = [	
		["3k5/2P1P4/3K5/9/1N7/9/9/9/9[-] w 0 1", "b5c7="], # mate in 1
		["4k4/9/4K4/9/9/9/9/9/9[G] w 0 1", "G@e8"], # mate in 1
		["9/9/9/9/9/9/4K4/R4R3/6k2[-] w 0 1", "a2a1"] # mate in 1
	]
	
	def Tactics.run
		puts "~~~ Tactics ~~~"
		score, total = 0, 0
		TACTICS.each do |tactic|
			engine = RubyShogi::Engine.new
			engine.printinfo = false
			engine.board.fen(tactic[0])
			engine.time = 50
			result = engine.think
			total += 1
			score += 1 if tactic[1] == result
			puts "#{total}. move #{result} | " + (tactic[1] == result ? "ok" : "error")
		end
		puts "= #{score} / #{total}"
	end
end # module Tactics

end # module RubyShogi

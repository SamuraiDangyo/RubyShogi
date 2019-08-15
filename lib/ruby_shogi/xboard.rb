##
# RubyShogi, a Shogi Engine
# Author: Toni Helminen
# License: GPLv3
##

module RubyShogi

class Xboard
	def initialize(random_mode = false)
		@random_mode = random_mode
		@engine = RubyShogi::Engine.new(random_mode: random_mode)
		@movestogo_orig = 40
		@forcemode = false
		Signal.trap("SIGPIPE", "SYSTEM_DEFAULT") 
		trap("INT", "IGNORE") # no interruptions
	end
	
	def print_xboard
		rv = @random_mode ? " random" : ""
		puts "feature myname=\"#{RubyShogi::NAME} #{RubyShogi::VERSION}#{rv}\""
		puts "feature variants=\"shogi\""
		puts "feature setboard=1"
		puts "feature ping=1"
		puts "feature done=1"
	end
	
	def play
		@engine.think 
	end
	
	def update_movestogo
		if @engine.movestogo == 1
			@engine.movestogo =	@movestogo_orig
		elsif @engine.movestogo > 0
			@engine.movestogo -= 1 
		end
	end
	
	def cmd_variant(variant)
		@variant = variant
	end
	
	def cmd_new
		@engine = RubyShogi::Engine.new(random_mode: @random_mode)
		@canmakemove = true
	end
	
	def cmd_level(level)
		@engine.movestogo = level.to_i
		@movestogo_orig = @engine.movestogo
	end
	
	def cmd_go
		if @canmakemove
			puts "move #{play}"
			@canmakemove = false
		end
	end
	
	def cmd_move(move)
		#@engine.board.print_board
		update_movestogo # update counter
		if @engine.make_move?(move)
			@canmakemove = true
			if @canmakemove && ! @engine.gameover
				puts "move #{play}"
				@canmakemove = false
			end
		end
	end
	
	def go
		puts "#{RubyShogi::NAME} #{RubyShogi::VERSION} by #{RubyShogi::AUTHOR}"
		@movestogo_orig = 40
		@canmakemove = true
		$stdin.each do |cmd|
			cmd.strip!
			case cmd	
			when "xboard" then
			when "hard" then
			when "easy" then
			when "random" then
			when "nopost" then
			when "post" then
			when "white" then
			when "black" then
				# ignore
			when "remove" then @engine.history_remove
			when "undo" then @engine.history_undo
			when "?" then @engine.move_now = true
			when /^computer/ then
			when /^st/ then
			when /^otim/ then
			when /^accepted/ then
			when /^result/ then
				# ignore
			when /^protover/ then print_xboard
			when /^ping\s+(.*)/ then puts "pong #{$1}"
			when /^variant\s+(.*)/ then cmd_variant($1)
			when "new" then cmd_new
			when "list" then @engine.move_list
			when /^level\s+(.+)\s+.*/ then cmd_level($1)
			when /^time\s+(.+)/ then @engine.time = 0.01 * $1.to_i
			when /^setboard\s+(.+)/ then @engine.board.fen($1)
			when "quit" then return
			when "p" then @engine.board.print_board
			when "force" then @forcemode = true
			when "go" then cmd_go
			else # assume move
				cmd_move(cmd)
			end
		end
	end
end # class Xboard

end # module RubyShogi

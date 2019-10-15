##
#
# RubyShogi, a Shogi Engine
# Copyright (C) 2019 Toni Helminen ( kalleankka1@gmail.com )
#
# RubyShogi is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# RubyShogi is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
##

require_relative "./engine"
require_relative "./zobrist"
require_relative "./history"
require_relative "./cmd"
require_relative "./xboard"
require_relative "./eval"
require_relative "./utils"
require_relative "./bench"
require_relative "./tokens"
require_relative "./board"
require_relative "./mgen"
require_relative "./mgen_white"
require_relative "./mgen_black"
require_relative "./perft"
require_relative "./tactics"

$stdout.sync = true
$stderr.sync = true
Thread.abort_on_exception = true
$stderr.reopen("ruby_shogi-error.txt", "a+")

module RubyShogi
	NAME = "RubyShogi"
	VERSION = "0.23"
	AUTHOR = "Toni Helminen"

	def RubyShogi.init
		RubyShogi::Eval.init
		RubyShogi::Zobrist.init
	end
	
	# Start RubyShogi
	#
	# Example:
	#   >> ruby_shogi -xboard
	#   => enter xboard mode
	def RubyShogi.go
		cmd = RubyShogi::Cmd.new
		cmd.args
	end
end # module RubyShogi

RubyShogi.init # init just once

if __FILE__ == $0
	RubyShogi.go
end

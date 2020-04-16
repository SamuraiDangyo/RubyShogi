# RubyShogi, a Shogi engine written in Ruby
# Toni Helminen
# GPLv3

#-debug
all:
	xboard -cp -fcp "ruby RubyShogi.rb" -scp "ruby RubyShogi.rb -random"

clean:
	rm -f games.pgn xboard.debug

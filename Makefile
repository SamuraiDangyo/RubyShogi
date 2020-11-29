#
# RubyShogi. Shogi engine written in Ruby
# Toni Helminen
# GPLv3
#

xboard:
	xboard -cp -fcp "ruby RubyShogi.rb"

clean:
	rm -f games.pgn xboard.debug

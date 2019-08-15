##
# ShurikenShogi, a Ruby shogi engine
# Author: Toni Helminen
# License: GPLv3
##

##
# Targets
##

xboard: clean
	xboard -cp \
		-scp "ruby ruby_shogi.rb -randommode -xboard" \
		-fcp "ruby ruby_shogi.rb -xboard" \
		-debug
		
run: clean
	ruby ruby_shogi.rb

profile: clean
	ruby ruby_shogi.rb -profile
	
stats: clean
	ruby ruby_shogi.rb -stats 10
	
rubybench: clean
	ruby ruby_shogi.rb -rubybench
	
bench: clean
	ruby ruby_shogi.rb -bench
	
mbench: clean
	ruby ruby_shogi.rb -mbench

perft: clean
	ruby ruby_shogi.rb -perft
	
randperft: clean
	ruby ruby_shogi.rb -randperft
	
numbers: clean
	ruby ruby_shogi.rb -numbers

suite: clean
	ruby ruby_shogi.rb -suite 5

test: clean
	ruby ruby_shogi.rb -test
	
tactics: clean
	ruby ruby_shogi.rb -tactics
	
clean:
	rm -f games.pgn xboard.debug ruby_shogi-error.txt ruby_shogi-log.txt

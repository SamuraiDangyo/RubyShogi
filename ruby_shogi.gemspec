Gem::Specification.new do |s|
	s.name        = 'RubyShogi'
	s.version     = '0.23'
	s.executables << 'ruby_shogi'
	s.date        = '2019-10-15'
	s.summary     = "a Shogi Engine"
	s.description = "RubyShogi, a Shogi Engine"
	s.authors     = ["Toni Helminen"]
	s.email       = 'kalleankka1@gmail.com'
	s.files       = Dir['lib/*.rb'] + Dir['lib/ruby_shogi/*.rb']
	s.homepage    = 'https://github.com/SamuraiDangyo/RubyShogi'
	s.license     = 'GPL-3.0'
end

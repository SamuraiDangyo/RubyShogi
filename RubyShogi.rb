# RubyShogi, a Shogi Engine written in Ruby
# Toni Helminen
# GPLv3

module RubyShogi
NAME = "RubyShogi 0.42"

class Board
  START_POS = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL[-] w 0 1"

  PIECES = {
    ".":    0, # .
    "P":    1, # Pawn
    "p":   -1,
    "+P":   2, # Promoted Pawn
    "+p":  -2,
    "L":    3, # Lance
    "l":   -3,
    "+L":   4, # Promoted Lance
    "+l":  -4,
    "N":    5, # Knight
    "n":   -5,
    "+N":   6, # Promoted Knight
    "+n":  -6,
    "S":    7, # Silver
    "s":   -7,
    "+S":   8, # Promoted Silver
    "+s":  -8,
    "G":    9, # Gold
    "g":   -9,
    "B":   10, # Bishop
    "b":  -10,
    "+B":  11, # Promoted Bishop
    "+b": -11,
    "R":   12, # Rook
    "r":  -12,
    "+R":  13, # Promoted Rook
    "+r": -13,
    "K":   14, # King
    "k":  -14
  }.freeze

  attr_accessor :brd, :wking, :bking, :white_pocket, :black_pocket, :variant, :nodetype, :r50, :drop, :hash, :fullmoves, :wtm, :eat, :from, :to, :score, :promo, :index

  def initialize
    initme
  end

  def initme
    @brd = [0] * 81
    @wtm, @from, @to, @eat = true, 0, 0, 0
    @score, @promo = 0, 0
    @white_pocket, @black_pocket = [], []
    @index, @r50, @drop, @hash, @wking, @bking, @fullmoves = 0, 0, 0, 0, 0, 0, 2
    @nodetype = 0 # 2 draw 1 win -1 loss
  end

  def brd2str
    str, empty, counter = "", 0, 0
    80.times do |j|
      sq = 10 * (7 - j / 10) + ( j % 10 )
      piece = @brd[sq]
      if piece != 0
        if empty > 0
          str += empty.to_s
          empty = 0
        end
        str += "fcakqrbnp.PNBRQKACF"[piece + 9]
      else
        empty += 1
      end
      counter += 1
      if counter % 10 == 0
        str += empty.to_s if empty > 0
        str += "/" if counter < 80
        empty = 0
      end
    end
    str
  end

  def mustbeok
    fail if find_white_king != @wking
    fail if find_black_king != @bking
  end

  def wtm2str
    @wtm ? "w" : "b"
  end

  def tofen
    "#{brd2str} #{wtm2str}"
  end

  def mgen_generator
    @wtm ? RubyShogi::MgenWhite.new(self) : RubyShogi::MgenBlack.new(self)
  end

  def create_hash
    @hash = 0
    81.times { |sq| @hash ^= RubyShogi::Zobrist.get(20 * sq + 8 + @brd[sq]) }
    @hash ^= RubyShogi::Zobrist.get(20 * 80 + (@wtm ? 1 : 0))
  end

  def legal?
    pieces = [0] * 20
    @brd.each { |piece| pieces[piece + 9] += 1 }
    return false if pieces[-6 + 9] == 0 || pieces[6 + 9] == 0
    true
  end

  def make_move(me, from, to)
    @eat = @brd[to]
    @brd[to], @brd[from] = me, 0
  end

  def find_white_king
    @brd.index { |x| x == 14 }
  end

  def find_black_king
    @brd.index { |x| x == -14 }
  end

  def find_piece_all(piece)
    @brd.index { |x| x == piece }
  end

  # scans ->
  def find_piece(start_square, end_square, me, diff = 1)
    sq = start_square
    loop do
      return sq if @brd[sq] == me
      fail "Couldn't Find: '#{me}'" if sq == end_square
      sq += diff
    end
  end

  # scans ->
  def just_kings?
    81.times do |sq|
      return false if @brd[sq] != 14 && @brd[sq] != -14
    end
    true
  end

  def material_draw?
    81.times do |sq|
      return false if @brd[sq] != 14 && @brd[sq] != -14 && @brd[sq] != 0
    end
    true
  end

  def copy_me()
    copy = RubyShogi::Board.new
    copy.brd = @brd.dup
    copy.white_pocket, copy.black_pocket = @white_pocket.dup, @black_pocket.dup
    copy.wtm, copy.from, copy.to, copy.r50, copy.wking, copy.bking = @wtm, @from, @to, @r50, @wking, @bking
    copy
  end

  def startpos
    fen(START_POS)
  end

  def last_rank?(square)
    y_coord(square) == 8
  end

  def first_rank?(x)
    y_coord(x) == 0
  end

  def empty?(sq)
    @brd[sq].zero?
  end

  def walkable_w?(square)
    @brd[square] <= 0
  end

  def walkable_b?(square)
    @brd[square] >= 0
  end

  def is_on_board?(x, y)
    x >= 0 && x <= 8 && y >= 0 && y <= 8
  end

  def good_coord?(sq)
    sq >= 0 && sq < 81
  end

  def distance(p1, p2)
    [(p1 % 9 - p2 % 9 ).abs, (p1 / 9 - p2 / 9).abs].max
  end

  def jishogi_likely_w?(wking)
    res = 0
    81.times { |sq| res += 1 if @brd[sq] > 0 && distance(wking, sq) < 3 }
    res > 5
  end

  def jishogi_likely_b?(bking)
    res = 0
    81.times { |sq| res += 1 if @brd[sq] < 0 && distance(bking, sq) < 3 }
    res > 5
  end

  # TODO improve likely?
  def jishogi?
    wking, bking = find_white_king, find_black_king
    if wking / 9 >= 6 && bking / 9 <= 2 && jishogi_likely_w?(wking) && jishogi_likely_b?(bking)
      return true
    end
    false
  end

  def count_jishogi_w
    res = 0
    81.times do |sq|
      if [10, 12].include?(@brd[sq])
        res += 5
      elsif @brd[sq] != 14
        res += 1
      end
    end
    res
  end

  def count_jishogi_b
    res = 0
    81.times do |sq|
      if [-10, -12].include?(@brd[sq])
        res += 5
      elsif @brd[sq] != -14
        res += 1
      end
    end
    res
  end

  def mirror_board
    (4*9).times do |sq|
      x, y = sq % 9, sq / 9
      flip_y = x + (8 - y) * 9
      p1 = @brd[sq]
      p2 = @brd[flip_y]
      @brd[sq] = p2
      @brd[flip_y] = p1
    end
  end

  def flip_coord(coord)
    (9 - 1 - y_coord(coord)) * 9 + x_coord(coord)
  end

  # TODO optimize
  def number2piece(num)
    ret = 0
    PIECES.each { |piece2, num2|
      if num.to_i == num2.to_i
        ret = piece2
        break
      end
    }
    ret.to_s
  end

  # TODO optimize
  def piece2number(piece)
    ret = 0
    PIECES.each { |piece2, num|
      if piece == piece2.to_s
        ret = num
        break
      end
    }
    ret
  end

  def fen_board(str)
    str, i, sq = str.gsub(/\d+/) { | m | "_" * m.to_i }.gsub(/\//) { | m | "" }, 0, 0
    while i < str.length
      piece = str[i]
      if str[i] == "+"
        i += 1
        piece = "+#{s[i]}"
      end
      @brd[sq] = piece2number(piece)
      sq += 1
      i += 1
    end
  end

  def fen_pocket(str)
    @white_pocket, @black_pocket = [], []
    str.strip!
    return if str == "-"
    sq = 0
    while sq < str.length
      num = piece2number(str[sq])
      if num > 0
        @white_pocket.push(num)
      elsif num < 0
        @black_pocket.push(num)
      end
      sq += 1
    end
  end

  def fen_wtm(str)
    @wtm = str == "w" ? true : false
  end

  def fen2(str = nil)
    if str.nil?
      fen(START_POS)
    else
      fen(str)
    end
  end

  def fen(str2)
    initme
    str = str2.strip.split(" ")
    fail if str.length < 3
    tmp = str[0].strip.split("[")
    fen_board(tmp[0])
    fen_pocket(tmp[1])
    @wtm       = str[1] == "w" ? true : false
    @r50       = 2 * str[2].to_i if str.length >= 3
    @fullmoves = 2 * str[3].to_i if str.length >= 4
    mirror_board
    @wking = find_white_king
    @bking = find_black_king
  end

  def material
    Eval.material(self)
  end

  def pocket2str
    str = ""
    @white_pocket.each { |num| str << number2piece(num) }
    @black_pocket.each { |num| str << number2piece(num) }
    str.strip.length == 0 ? "-" : str
  end

  def move2str
    move_str
  end

  def move_str
    if @drop != 0
      str = "#{number2piece(@drop).upcase}@"
      tox, toy = @to % 9, @to / 9
      str << ("a".ord + tox).chr
      str << (toy + 1).to_s
      return str
    end
    fromx, fromy = @from % 9, @from / 9
    tox, toy = @to % 9, @to / 9
    str = ("a".ord + fromx).chr << (fromy + 1).to_s << ("a".ord + tox).chr << (toy + 1).to_s
    if @promo == 2
      str << "+"
    elsif @promo == 1
      str << "="
    end
    str
  end

  def randpos2
    copy = RubyShogi::Board.new
    copy.brd[rand(0..9)]   = 14
    copy.brd[rand(71..80)] = -14
    8.times { |sq| copy.brd[32 + sq] = rand(-13..13) if rand < 0.3 }
    3.times { |i| copy.white_pocket.push([1, 3, 5, 7, 9].sample) if rand < 0.3  }
    3.times { |i| copy.black_pocket.push([-1, -3, -5, -7, -9].sample) if rand < 0.3 }
    copy.wking = copy.find_white_king
    copy.bking = copy.find_black_king
    copy
  end


  def randpos
    brd = nil
    loop do
      brd = randpos2
      mgen = brd.mgen_generator
      next if mgen.checks_b? || mgen.checks_w?
      break
    end
    brd.mustbeok
    brd
  end

  def print_board
    s =""
    81.times do | i |
      x, y = i % 9, i / 9
      p = @brd[9 * (8 - y) + x]
      ch = "."
      PIECES.each do |pie, num|
        if num.to_i == p.to_i
          ch = pie.to_s
          break
        end
      end
      s << " " if ch.length < 2
      s << ch
         if (i + 1) % 9 == 0
        s << " #{((9 - i / 9).to_i).to_s}\n"
         end
    end
    9.times { |i| s << " " << ("a".ord + i).chr }
    s << "\n[ wtm: #{@wtm} ]\n"
    s << "[ r50: #{(@r50/2).to_i} ]\n"
    s << "[ pocket: #{pocket2str} ]\n"
    s << "[ fen: #{pos2fen} ]\n"
    puts s
  end
end # class Board

class Engine
  attr_accessor :board, :random_mode, :gameover, :move_now, :debug, :time, :movestogo, :printinfo

  INF              = 1000
  MATERIAL_SCALE   = 0.01
  RESULT_DRAW      = 1
  RESULT_BLACK_WIN = 2
  RESULT_WHITE_WIN = 4

  def initialize(random_mode: false)
    init_mate_bonus
    @board        = RubyShogi::Board.new
    @random_mode  = random_mode
    @history      = RubyShogi::History.new
    @board.startpos
    @printinfo, @time, @movestogo, @stop_time, @stop_search, @nodes, @move_now, @gameover = true, 10, 40, 0, false, 0, false, false
  end

  def init_mate_bonus
    @mate_bonus = [1] * 100
    (0..20).each { |i| @mate_bonus[i] += 20 - i }
    @mate_bonus[0] = 50
    @mate_bonus[1] = 40
    @mate_bonus[2] = 30
    @mate_bonus[3] = 25
  end

  def history_reset
    @history.reset
  end

  def history_remove
    @board = @history.remove
  end

  def history_undo
    @board = @history.undo
  end

  def print_move_list(moves)
    moves.each_with_index { |board, i| puts "#{i} / #{board.move_str} / #{board.score}" }
  end

  def move_list
    mgen = @board.mgen_generator
    moves = mgen.generate_moves
    moves.each_with_index { |board, i| puts "#{i} / #{board.move_str} / #{board.score}" }
  end

  def make_move?(move)
    mgen = @board.mgen_generator
    moves = mgen.generate_moves
    moves.each do |board|
      if board.move_str == move
        @history.add(board)
        @board = board
        return true
      end
    end
    puts "illegal move: #{move}"
    false
  end

  def print_score(moves, depth, started)
    return unless @printinfo
    moves = moves.sort_by(&:score).reverse
    best = moves[0]
    n = (100 * (Time.now - started)).to_i
    puts " #{depth}     #{(best.score).to_i}     #{n}     #{@nodes}     #{best.move_str}"
  end

  def search_moves_w(cur, depth, total = 0)
    @nodes += 1
    @stop_search = Time.now > @stop_time || total > 90
    return 0 if @stop_search
    return MATERIAL_SCALE * cur.material if depth < 1
    mgen = RubyShogi::MgenWhite.new(cur)
    moves = mgen.generate_moves
    if moves.length == 0 # assume mate
      return mgen.checks_b? ? 0.1 * @mate_bonus[total] * -INF + rand : 1
    end
    search_moves_b(moves.sample, depth - 1, total + 1)
  end

  def search_moves_b(cur, depth, total = 0)
    @nodes += 1
    @stop_search = Time.now > @stop_time || total > 90
    return 0 if @stop_search
    return MATERIAL_SCALE * cur.material if depth < 1
    mgen = RubyShogi::MgenBlack.new(cur)
    moves = mgen.generate_moves
    if moves.length == 0 # assume mate
      return mgen.checks_w? ? 0.1 * @mate_bonus[total] * INF + rand : 1
    end
    search_moves_w(moves.sample, depth - 1, total + 1)
  end

  def search(moves)
    now = Time.now
    time4print = 0.5
    divv = @movestogo < 10 ? 20 : 30
    @stop_time = now + (@time / divv)
    depth = 2
    while true
      moves.each do |board|
        next if board.nodetype == 2
        depth = 3 + rand(20)
        board.score += board.wtm ? search_moves_w(board, depth, 0) : search_moves_b(board, depth, 0)
        if Time.now > @stop_time || @move_now
          print_score(moves, depth, now)
          return
        end
      end
      if Time.now - now > time4print
        now = Time.now
        print_score(moves, depth, now)
      end
    end
  end

  def draw_moves(moves)
    moves.each do | board |
      if @history.is_draw?(board)
        board.nodetype, board.score = 2, 0
      end
    end
  end

  def hash_moves(moves)
    moves.each { |board| board.create_hash }
  end

  def game_status(mgen, moves)
    if moves.length == 0
      if @board.wtm && mgen.checks_b?
        return RubyShogi::Engine::RESULT_BLACK_WIN
      elsif !@board.wtm && mgen.checks_w?
        return RubyShogi::Engine::RESULT_WHITE_WIN
      end
      return RubyShogi::Engine::RESULT_DRAW
    end
    @board.create_hash
    if @history.is_draw?(@board, 3) || @board.material_draw?
      return RubyShogi::Engine::RESULT_DRAW
    end
    0
  end

  def jishogi?
    if @board.jishogi?
      w = @board.count_jishogi_w
      b = @board.count_jishogi_b
      if w >= 24 && b < 24
        puts "1-0 {White wins by Jishogi}"
        return true
      elsif w < 24 && b >= 24
        puts "0-1 {Black wins by Jishogi}"
        return true
      else
        puts "1/2-1/2 {Draw by Impasse}"
        return true
      end
    end
    false
  end

  def is_gameover?(mgen, moves)
    @board.create_hash
    return true if jishogi?
    if @board.fullmoves > 900
      puts "1/2-1/2 {Draw by Max Moves}"
      return true
    end
    if @history.is_draw?(@board, 3)
      puts "1/2-1/2 {Draw by Sennichite}"
      return true
    end
    if moves.length == 0
      if @board.wtm && mgen.checks_b?
        puts "0-1 {Black mates}"
        return true
      elsif !@board.wtm && mgen.checks_w?
        puts "1-0 {White mates}"
        return true
      end
    end
    false
  end

  def bench
    t = Time.now
    @time = 500
    think
    diff = Time.now - t
    puts "= #{@nodes} nodes | #{diff.round(3)} s | #{(@nodes/diff).to_i} nps"
  end

  def think
    @nodes = 0
    @move_now = false
    board = @board
    mgen = @board.mgen_generator
    moves = mgen.generate_moves
    hash_moves(moves)
    draw_moves(moves)
    func = -> { board.wtm ? moves.sort_by(&:score).reverse : moves.sort_by(&:score) }
    @gameover = is_gameover?(mgen, moves)
    return if @gameover
    if @random_mode
      @board = moves.sample
    else
      search(moves)
      moves = func.call
      @board = moves[0]
    end
    @history.add(@board)
    @board.move_str
  end
end # class Engine

module Eval
  # https://en.wikipedia.org/wiki/Shogi_strategy#Relative_piece_value
  MATERIAL_SCORE = {
    1 =>  1,
    2 =>  4.2,
    3 =>  4.3,
    4 =>  6.3,
    5 =>  4.5,
    6 =>  6.4,
    7 =>  6.4,
    8 =>  6.7,
    9 =>  6.9,
    10 => 8.9,
    11 => 11.5,
    12 => 10.4,
    13 => 13,
    14 => 0
  }

  MATERIAL_HAND_SCORE = {
    1 =>  1.15,
    3 =>  4.8,
    5 =>  5.1,
    7 =>  7.2,
    9 =>  7.8,
    10 => 11.10,
    12 => 10.4,
    13 => 12.7
  }

  def Eval.material(board)
    score = 0
    board.brd.each do |piece|
      score += case piece
        when 1..14   then MATERIAL_SCORE[ piece]
        when -14..-1 then -MATERIAL_SCORE[-piece]
        else
          0
        end
    end
    board.white_pocket.each { |piece| score += MATERIAL_HAND_SCORE[ piece] }
    board.black_pocket.each { |piece| score -= MATERIAL_HAND_SCORE[-piece] }
    score
  end
end # module Eval

class History
  def initialize
    reset
  end

  def reset
    @data = []
    @pos = -1
  end

  def debug
    puts "@pos: #{@pos} .. @data: #{@data.length}"
  end

  def remove
    if @pos > 1
      board = @data[@pos - 2]
      @pos -= 2
      return board
    end
    @data.last
  end

  def undo
    if @pos > 0
      board = @data[@pos - 1]
      @pos -= 1
      return board
    end
    @data.last
  end

  def add(board)
    @data.push(board)
    @pos += 1
  end

  def draw_too_long?
    @data.length > 900 # I give up...
  end

  def is_draw?(board, repsn = 4)
    len, hash = @data.length, board.hash
    i, maxply, reps = len - 1, 0, 0
    while i > 0
      break if maxply >= 100
      reps += 1 if hash == @data[i].hash
      maxply, i = maxply + 1, i - 1
      return true if reps >= repsn
    end
    false
  end
end # class History

class Mgen
  # both
  ROOK_MOVES   = [[1, 0], [0, 1], [-1, 0], [0, -1]].freeze
  BISHOP_MOVES = [[1, 1], [-1, 1], [1, -1], [-1, -1]].freeze
  KING_MOVES   = (ROOK_MOVES + BISHOP_MOVES).freeze

  PROMOTED_BISHOP_MOVES = ROOK_MOVES
  PROMOTED_ROOK_MOVES   = BISHOP_MOVES

  # white
  WHITE_GOLD_GENERAL_MOVES    = [[1, 0], [-1, 0], [0, -1], [0, 1], [1, 1], [-1, 1]].freeze
  WHITE_SILVER_GENERAL_MOVES  = [[-1, -1], [-1, 1], [0, 1], [1, 1], [1, -1]].freeze
  WHITE_KNIGHT_MOVES          = [[-1, 2], [1, 2]].freeze
  WHITE_LANCE_MOVES           = [[0, 1]].freeze

  # black
  BLACK_GOLD_GENERAL_MOVES    = [[1, 0], [-1, 0], [0, 1], [0, -1], [1, -1], [-1, -1]].freeze
  BLACK_SILVER_GENERAL_MOVES  = [[-1, 1], [-1, -1], [0, -1], [1, -1], [1, 1]].freeze
  BLACK_KNIGHT_MOVES          = [[-1, -2], [1, -2]].freeze
  BLACK_LANCE_MOVES           = [[0, -1]].freeze

  # promotions
  PROMO_NO   = 0
  PROMO_STAY = 1
  PROMO_YES  = 2

  attr_accessor :pseudo_moves, :only_captures

  def initialize(board)
    @board, @moves = board, []
    @x_gen, @y_gen, @from_gen = 0, 0, 0 # move generation
    @x_checks, @y_checks = 0, 0 # checks
    @pseudo_moves = false # 3x speed up
  end

  def print_move_list
    @moves.each_with_index { |board, i| puts "#{i}: #{board.move_str}" }
  end

  def is_on_board?(x, y)
    x >= 0 && x <= 8 && y >= 0 && y <= 8
  end

  def remove_from_array(array, x)
    array.delete_at(array.index(x) || array.length)
    array
  end

  def good_coord?(sq)
    sq >= 0 && sq <= 80
  end

  def eaten_piece(eat)
    case eat
    when 2 then 1
    when 4 then 3
    when 6 then 5
    when 8 then 7
    when 11 then 10
    when 13 then 12
    else eat
    end
  end

  def pawn_checks_w?(here)
    @x_checks + 9 * (@y_checks + 1) == here
  end

  def pawn_checks_b?(here)
    @x_checks + 9 * (@y_checks - 1) == here
  end

  def slider_checks_to?(slider, here)
    slider.each do |jmp|
      px, py = @x_checks, @y_checks
      loop do
        px, py = px + jmp[0], py + jmp[1]
        break if !is_on_board?(px, py)
        to = px + py * 9
        return true if to == here
        break if !@board.empty?(to)
      end
    end
    false
  end

  def jump_checks_to?(jumps, here)
    jumps.each do |jmp|
      px, py = @x_checks + jmp[0], @y_checks + jmp[1]
      return true if is_on_board?(px, py) && px + py * 9 == here
    end
    false
  end

  def checks_w?(here = nil, useking = true)
    here = here == nil ? @board.bking : here
    81.times do |sq|
      @x_checks, @y_checks = sq % 9, (sq / 9).to_i
      case @board.brd[sq]
      when 1  then return true if pawn_checks_w?(here)
      when 2  then return true if jump_checks_to?(WHITE_GOLD_GENERAL_MOVES, here)
      when 3  then return true if slider_checks_to?(WHITE_LANCE_MOVES, here)
      when 4  then return true if jump_checks_to?(WHITE_GOLD_GENERAL_MOVES, here)
      when 5  then return true if jump_checks_to?(WHITE_KNIGHT_MOVES, here)
      when 6  then return true if jump_checks_to?(WHITE_GOLD_GENERAL_MOVES, here)
      when 7  then return true if jump_checks_to?(WHITE_SILVER_GENERAL_MOVES, here)
      when 8  then return true if jump_checks_to?(WHITE_GOLD_GENERAL_MOVES, here)
      when 9  then return true if jump_checks_to?(WHITE_GOLD_GENERAL_MOVES, here)
      when 10 then return true if slider_checks_to?(BISHOP_MOVES, here)
      when 11 then return true if slider_checks_to?(BISHOP_MOVES, here) || jump_checks_to?(PROMOTED_BISHOP_MOVES, here)
      when 12 then return true if slider_checks_to?(ROOK_MOVES, here)
      when 13 then return true if slider_checks_to?(ROOK_MOVES, here) || jump_checks_to?(PROMOTED_ROOK_MOVES, here)
      when 14 then return true if useking && jump_checks_to?(KING_MOVES, here)
      end
    end
    false
  end

  def checks_b?(here = nil, useking = true)
    here = here == nil ? @board.wking : here
    81.times do |sq|
      @x_checks, @y_checks = sq % 9, (sq / 9).to_i
      case @board.brd[sq]
      when -1  then return true if pawn_checks_b?(here)
      when -2  then return true if jump_checks_to?(BLACK_GOLD_GENERAL_MOVES, here)
      when -3  then return true if slider_checks_to?(BLACK_LANCE_MOVES, here)
      when -4  then return true if jump_checks_to?(BLACK_GOLD_GENERAL_MOVES, here)
      when -5  then return true if jump_checks_to?(BLACK_KNIGHT_MOVES, here)
      when -6  then return true if jump_checks_to?(BLACK_GOLD_GENERAL_MOVES, here)
      when -7  then return true if jump_checks_to?(BLACK_SILVER_GENERAL_MOVES, here)
      when -8  then return true if jump_checks_to?(BLACK_GOLD_GENERAL_MOVES, here)
      when -9  then return true if jump_checks_to?(BLACK_GOLD_GENERAL_MOVES, here)
      when -10 then return true if slider_checks_to?(BISHOP_MOVES, here)
      when -11 then return true if slider_checks_to?(BISHOP_MOVES, here) || jump_checks_to?(PROMOTED_BISHOP_MOVES, here)
      when -12 then return true if slider_checks_to?(ROOK_MOVES, here)
      when -13 then return true if slider_checks_to?(ROOK_MOVES, here) || jump_checks_to?(PROMOTED_ROOK_MOVES, here)
      when -14 then return true if useking && jump_checks_to?(KING_MOVES, here)
      end
    end
    false
  end
end # class Mgen

class MgenBlack < RubyShogi::Mgen
  def initialize(board)
    @board = board
  end

  def handle_capture(copy, eat)
    piece = case eat
      when -2..-1 then -1
      when -4..-3 then -3
      when -6..-5 then -5
      when -8..-7 then -7
      when -9 then -9
      when -11..-10 then -10
      when -13..-12 then -12
      end
    copy.white_pocket.push(piece)
  end

  def add_new_move(me, to, promo = 0)
    return if handle_promotion?(me, to)
    push_move(me, to, promo)
  end

  def push_move(me, to, promo)
    board2 = @board
    copy = @board.copy_me
    copy.from = @from_gen
    copy.promo = promo
    copy.r50 += 1
    copy.fullmoves += 1
    copy.r50 = 0 if [-1, -3, -5].include?(me)
    copy.to = to
    copy.eat = copy.brd[to]
    copy.black_pocket.push(-1 * eaten_piece(copy.eat)) if copy.eat != 0
    copy.wtm = !copy.wtm
    copy.brd[@from_gen] = 0
    copy.brd[to] = me
    copy.bking = to if me == -14
    copy.mustbeok
    @board = copy
    @moves.push << copy if !checks_w?
    @board = board2
  end

  def can_white_king_run?(to2)
    x, y = to2 % 9, to2 / 9
    KING_MOVES.each do |jmp|
      px, py = x + jmp[0], y + jmp[1]
      to = px + 9 * py
      return true if is_on_board?(px, py) && @board.walkable_w?(to) && !checks_b?(to, false)
    end
    false
  end

  def pawn_drop_checkmate?(to)
    @board.brd[to - 9] == 14 && (!checks_w?(to, false) && !can_white_king_run?(to - 9)) ? true : false
  end

  def add_new_drop_move(me, to)
    return if me == -3 && to / 9 == 0
    return if me == -5 && to / 9 <= 1
    board2 = @board
    copy = @board.copy_me
    copy.from = -1
    copy.to = to
    copy.drop = me
    copy.r50 += 1
    copy.fullmoves += 1
    copy.eat = 0
    copy.wtm = !copy.wtm
    copy.brd[to] = me
    copy.black_pocket = remove_from_array(copy.black_pocket, me)
    copy.mustbeok
    @board = copy
    if !checks_w? && !(me == -1 && pawn_drop_checkmate?(to))
      @moves.push << copy
    end
    @board = board2
  end

  def handle_promotion?(me, to)
    return true if must_promote?(me, to)
    return false if to / 9 >= 3 && @from_gen / 9 >= 3
    case me
    when -1
      push_move(-1, to, PROMO_STAY)
      push_move(-2, to, PROMO_YES)
      return true
    when -3
      push_move(-3, to, PROMO_STAY)
      push_move(-4, to, PROMO_YES)
      return true
    when -5
      push_move(-5, to, PROMO_STAY)
      push_move(-6, to, PROMO_YES)
      return true
    when -7
      push_move(-7, to, PROMO_STAY)
      push_move(-8, to, PROMO_YES)
      return true
    when -10
      push_move(-10, to, PROMO_STAY)
      push_move(-11, to, PROMO_YES)
      return true
    when -12
      push_move(-12, to, PROMO_STAY)
      push_move(-13, to, PROMO_YES)
      return true
    end
  end

  def must_promote?(me, to)
    if me == -5 && to / 9 <= 1
      push_move(-6, to, PROMO_YES)
      return true
    end
    return false if to / 9 != 0
    case me
    when -1
      push_move(-2, to, PROMO_YES)
      return true
    when -3
      push_move(-4, to, PROMO_YES)
      return true
    end
    false
  end

  def add_new_pawn_move(to)
    case to / 9
    when 1..2
      push_move(-1, to, PROMO_STAY)
      push_move(-2, to, PROMO_YES)
    when 0 then push_move(-2, to, PROMO_YES)
    else
      push_move(-1, to, PROMO_NO)
    end
  end

  def generate_pawn_moves
    to = @x_gen + (@y_gen - 1) * 9
    add_new_pawn_move(to) if to >= 0 && @board.walkable_b?(to)
  end

  def generate_jump_moves(jumps, me)
    jumps.each do |jmp|
      px, py = @x_gen + jmp[0], @y_gen + jmp[1]
      to = px + 9 * py
      add_new_move(me, to) if is_on_board?(px, py) && @board.walkable_b?(to)
    end
  end

  def generate_slider_moves(slider, me)
    slider.each do | jmp |
      px, py = @x_gen, @y_gen
      loop do
        px, py = px + jmp[0], py + jmp[1]
        break if !is_on_board?(px, py)
        to = px + 9 * py
        add_new_move(me, to) if @board.walkable_b?(to)
        break if !@board.empty?(to)
      end
    end
  end

  def pawn_on_column?(column)
    9.times do |sq|
      to = 9 * sq + column
      return true if to != @from_gen && @board.brd[to] == -1
    end
    false
  end

  def put_pawn_drops
    (9*8).times do |sq|
      to = sq + 9
      @x_gen, @y_gen, @from_gen = to % 9, to / 9, to
      add_new_drop_move(-1, to) if (!pawn_on_column?(to % 9 ) && @board.brd[to].zero?)
    end
  end

  def put_drops(piece)
    81.times do |sq|
      @x_gen, @y_gen, @from_gen = sq % 9, sq / 9, sq
      add_new_drop_move(piece, sq) if @board.brd[sq].zero?
    end
  end

  def generate_drops
    nodub = @board.black_pocket.dup.uniq
    nodub.each do |piece|
      case piece
      when -1  then put_pawn_drops
      when -3  then put_drops(-3)
      when -5  then put_drops(-5)
      when -7  then put_drops(-7)
      when -9  then put_drops(-9)
      when -10 then put_drops(-10)
      when -11 then put_drops(-11)
      when -12 then put_drops(-12)
      end
    end
    @moves
  end

  def generate_moves
    @moves = []
    81.times do |sq|
      @x_gen, @y_gen, @from_gen = sq % 9, sq / 9, sq
      case @board.brd[sq]
      when -1 then generate_pawn_moves
      when -2 then generate_jump_moves(BLACK_GOLD_GENERAL_MOVES, -2)
      when -3 then generate_slider_moves(BLACK_LANCE_MOVES, -3)
      when -4 then generate_jump_moves(BLACK_GOLD_GENERAL_MOVES, -4)
      when -5 then generate_jump_moves(BLACK_KNIGHT_MOVES, -5)
      when -6 then generate_jump_moves(BLACK_GOLD_GENERAL_MOVES, -6)
      when -7 then generate_jump_moves(BLACK_SILVER_GENERAL_MOVES, -7)
      when -8 then generate_jump_moves(BLACK_GOLD_GENERAL_MOVES, -8)
      when -9 then generate_jump_moves(BLACK_GOLD_GENERAL_MOVES, -9)
      when -10 then generate_slider_moves(BISHOP_MOVES, -10)
      when -11
        generate_slider_moves(BISHOP_MOVES, -11)
        generate_jump_moves(PROMOTED_BISHOP_MOVES, -11)
      when -12 then generate_slider_moves(ROOK_MOVES, -12)
      when -13
        generate_slider_moves(ROOK_MOVES, -13)
        generate_jump_moves(PROMOTED_ROOK_MOVES, -13)
      when -14 then generate_jump_moves(KING_MOVES, -14)
      end
    end
    generate_drops
  end
end # class MgenBlack

class MgenWhite < RubyShogi::Mgen
  def initialize(board)
    @board = board
  end

  def push_move(me, to, promo)
    board2 = @board
    copy = @board.copy_me
    copy.from = @from_gen
    copy.to         = to
    copy.promo      = promo
    copy.r50       += 1
    copy.fullmoves += 1
    copy.r50        = 0 if [1, 3, 5].include?(me)
    copy.eat = copy.brd[to]
    copy.white_pocket.push(eaten_piece(-copy.eat)) if copy.eat != 0
    copy.wtm = !copy.wtm
    copy.brd[@from_gen] = 0
    copy.brd[to] = me
    copy.wking = to if me == 14
    copy.mustbeok
    @board = copy
    @moves.push << copy if !checks_b?
    @board = board2
  end

  def can_black_king_run?(to2)
    x, y = to2 % 9, to2 / 9
    KING_MOVES.each do |jmp|
      px, py = x + jmp[0], y + jmp[1]
      return true if is_on_board?(px, py) && @board.walkable_b?(px + 9 * py) && !checks_w?(px + 9 * py, false)
    end
    false
  end

  def pawn_drop_checkmate?(to)
    @board.brd[to + 9] == -14 && (!checks_b?(to, false) && !can_black_king_run?(to + 9)) ? true : false
  end

  def add_new_drop_move(me, to)
    return if me == 3 && to / 9 == 8
    return if me == 5 && to / 9 >= 7
    fail if !@board.brd[to].zero?
    board2          = @board
    copy            = @board.copy_me
    copy.from       = -1
    copy.to         = to
    copy.drop       = me
    copy.eat        = 0
    copy.r50       += 1
    copy.fullmoves += 1
    copy.wtm        = !copy.wtm
    copy.brd[to]    = me
    copy.white_pocket = remove_from_array(copy.white_pocket, me)
    copy.mustbeok
    @board = copy
    if !checks_b? && !(me == 1 && pawn_drop_checkmate?(to))
      @moves.push << copy
    end
    @board = board2
  end

  def handle_capture(copy, eat)
    piece = case eat
      when 1..2   then 1
      when 3..4   then 3
      when 5..6   then 5
      when 7..8   then 7
      when 9      then 9
      when 10..11 then 10
      when 12..13 then 12
      end
    copy.white_pocket.push(piece)
  end

  def add_new_move(me, to, promo = 0)
    return if handle_promotion?(me, to)
    push_move(me, to, promo)
  end

  def handle_promotion?(me, to)
    return true if must_promote?(me, to)
    return false if to / 9 <= 5 && @from_gen / 9 <= 5
    case me
    when 1
      push_move(1, to, PROMO_STAY)
      push_move(2, to, PROMO_YES)
      return true
    when 3
      push_move(3, to, PROMO_STAY)
      push_move(4, to, PROMO_YES)
      return true
    when 5
      push_move(5, to, PROMO_STAY)
      push_move(6, to, PROMO_YES)
      return true
    when 7
      push_move(7, to, PROMO_STAY)
      push_move(8, to, PROMO_YES)
      return true
    when 10
      push_move(10, to, PROMO_STAY)
      push_move(11, to, PROMO_YES)
      return true
    when 12
      push_move(12, to, PROMO_STAY)
      push_move(13, to, PROMO_YES)
      return true
    end
    false
  end

  def must_promote?(me, to)
    if me == 5 && to / 9 >= 7
      push_move(6, to, PROMO_YES)
      return true
    end
    return false if to / 9 != 8
    case me
    when 1
      push_move(2, to, PROMO_YES)
      return true
    when 3
      push_move(4, to, PROMO_YES)
      return true
    end
    false
  end

  def add_new_pawn_move(to)
    case to / 9
    when 6..7
      push_move(1, to, PROMO_STAY)
      push_move(2, to, PROMO_YES)
    when 8 then push_move(2, to, PROMO_YES)
    else
      push_move(1, to, PROMO_NO)
    end
  end

  def generate_pawn_moves
    to = @x_gen + (@y_gen + 1) * 9
    add_new_pawn_move(to) if (to < 81 && @board.walkable_w?(to))
  end

  def generate_jump_moves(jumps, me)
    jumps.each do |jmp|
      px, py = @x_gen + jmp[0], @y_gen + jmp[1]
      to = px + 9 * py
      add_new_move(me, to) if is_on_board?(px, py) && @board.walkable_w?(to)
    end
  end

  def generate_slider_moves(slider, me)
    slider.each do |jmp|
      px, py = @x_gen, @y_gen
      loop do
        px, py = px + jmp[0], py + jmp[1]
        break if !is_on_board?(px, py)
        to = px + 9 * py
        add_new_move(me, to) if @board.walkable_w?(to)
        break if !@board.empty?(to)
      end
    end
  end

  def pawn_on_column?(column)
    9.times do |y|
      to = 9 * y + column
      return true if to != @from_gen && @board.brd[to] == 1
    end
    false
  end

  def put_pawn_drops
    (9*8).times do |sq|
      @x_gen, @y_gen, @from_gen = sq % 9, sq / 9, sq
      add_new_drop_move(1, sq) if !pawn_on_column?(sq % 9 ) && @board.brd[sq].zero?
    end
  end

  def put_drops(piece)
    81.times do |sq|
      @x_gen, @y_gen, @from_gen = sq % 9, sq / 9, sq
      add_new_drop_move(piece, sq) if @board.brd[sq].zero?
    end
  end

  def generate_drops
    nodub = @board.white_pocket.dup.uniq
    nodub.each do |piece|
      case piece
      when 1  then put_pawn_drops
      when 3  then put_drops(3)
      when 5  then put_drops(5)
      when 7  then put_drops(7)
      when 9  then put_drops(9)
      when 10 then put_drops(10)
      when 11 then put_drops(11)
      when 12 then put_drops(12)
      else
        fail
      end
    end
    @moves
  end

  def generate_moves
    @moves = []
    81.times do |sq|
      @x_gen, @y_gen, @from_gen = sq % 9, sq / 9, sq
      case @board.brd[sq]
      when 1 then  generate_pawn_moves
      when 2 then generate_jump_moves(WHITE_GOLD_GENERAL_MOVES, 2)
      when 3 then generate_slider_moves(WHITE_LANCE_MOVES, 3)
      when 4 then generate_jump_moves(WHITE_GOLD_GENERAL_MOVES, 4)
      when 5 then generate_jump_moves(WHITE_KNIGHT_MOVES, 5)
      when 6 then generate_jump_moves(WHITE_GOLD_GENERAL_MOVES, 6)
      when 7 then generate_jump_moves(WHITE_SILVER_GENERAL_MOVES, 7)
      when 8 then generate_jump_moves(WHITE_GOLD_GENERAL_MOVES, 8)
      when 9 then generate_jump_moves(WHITE_GOLD_GENERAL_MOVES, 9)
      when 10 then generate_slider_moves(BISHOP_MOVES, 10)
      when 11
        generate_slider_moves(BISHOP_MOVES, 11)
        generate_jump_moves(PROMOTED_BISHOP_MOVES, 11)
      when 12 then generate_slider_moves(ROOK_MOVES, 12)
      when 13
        generate_slider_moves(ROOK_MOVES, 13)
        generate_jump_moves(PROMOTED_ROOK_MOVES, 13)
      when 14 then generate_jump_moves(KING_MOVES, 14)
      end
    end
    generate_drops
  end
end # class MgenWhite

class Xboard
  def initialize(random_mode = false)
    @random_mode = random_mode
    @engine = RubyShogi::Engine.new(random_mode: random_mode)
    @movestogo_orig, @forcemode = 40, false
    Signal.trap("SIGPIPE", "SYSTEM_DEFAULT")
    trap("INT", "IGNORE") # no interruptions
  end

  def print_xboard
    rv = @random_mode ? " random" : ""
    puts "feature myname=\"#{RubyShogi::NAME}#{rv}\""
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
      @engine.movestogo =  @movestogo_orig
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
    puts "#{RubyShogi::NAME} by Toni Helminen"
    @movestogo_orig, @canmakemove = 40, true
    $stdin.each do |cmd|
      cmd.strip!
      case cmd
      when "xboard", "hard", "easy", "random", "nopost", "post", "white", "black", /^computer/, /^st/, /^otim/, /^accepted/, /^result/ then
        # ignore
      when "remove"             then @engine.history_remove
      when "undo"               then @engine.history_undo
      when "?"                  then @engine.move_now = true
      when /^protover/          then print_xboard
      when /^ping\s+(.*)/       then puts "pong #{$1}"
      when /^variant\s+(.*)/    then cmd_variant($1)
      when "new"                then cmd_new
      when "list"               then @engine.move_list
      when /^level\s+(.+)\s+.*/ then cmd_level($1)
      when /^time\s+(.+)/       then @engine.time = 0.01 * $1.to_i
      when /^setboard\s+(.+)/   then @engine.board.fen($1)
      when "quit"               then return
      when "p"                  then @engine.board.print_board
      when "force"              then @forcemode = true
      when "go"                 then cmd_go
      else # assume move
        cmd_move(cmd)
      end
    end
  end
end # class Xboard

module Zobrist
  HASH = []

  def Zobrist.init
    return if HASH.length > 0
    10_000.times do |i| HASH.push(rand(1024) | (rand(1024) << 10) | (rand(1024) << 20) | (rand(1024) << 30) | (rand(1024) << 40)) end
  end

  def Zobrist.get(nth)
    HASH[nth]
  end
end # module Zobrist

class Cmd
  attr_accessor :engine, :random_mode

  def initialize
    @random_mode = false
  end

  def xboard
    xboard = RubyShogi::Xboard.new(@random_mode)
    xboard.go
  end

  def args
    if ARGV.length == 1 and ARGV[0] == "-version"
      puts "#{RubyShogi::NAME} by Toni Helminen"
      return
    elsif ARGV.length == 1 and ARGV[0] == "-random"
      @random_mode = true
    end
    xboard
  end
end # class Cmd

module Main
  def Main.init
    $stdout.sync = true
    $stderr.sync = true
    Thread.abort_on_exception = true
    RubyShogi::Zobrist.init
  end

  def Main.go
    cmd = RubyShogi::Cmd.new
    cmd.args
  end
end # module Main
end # module RubyShogi

if __FILE__ == $0
  RubyShogi::Main.init # init just once
  RubyShogi::Main.go
end

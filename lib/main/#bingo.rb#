
module Bingo
  def self.card u
    Card.new(u)
  end
  class Card
    def initialize user
      @win = { row: false, col: false, corner: false }
      @user = user
      @sq = Set.new
      @h = Hash.new { |h,k| h[k] = {} }
      @s = Hash.new { |h,k| h[k] = Hash.new { |hh,kk|  hh[kk] = 0 }  }
      5.times do |row|
        5.times do |col|
          if row == 2 && col == 2
          # center square
            @h[row][col] = Square.center
          else
            @h[row][col] = Square.new(unique)
          end
          @sq << @h[row][col].value
        end
      end
    end
    def unique
      r = Square.random
      until !@sq.include?(r) do
        r = Square.random
      end
      return r
    end
    
    def win?
      rr = Hash.new { |h,k| h[k] = [] }
      cc = Hash.new { |h,k| h[k] = [] }
      @h.each_pair do |r, row|
        row.each_pair do |c, sq|
#          puts "[#{r}][#{c}] #{sq}"
          x = sq.checked?
          rr[r][c] = x
          cc[c][r] = x
        end
      end
      rr.each_pair do |c, a|
        if a == [true, true, true, true, true]
          @win[:row] = true
        end
      end
      cc.each_pair do |r, a|
        if a == [true, true, true, true, true]
          @win[:col] = true
        end
      end
      if @h[0][0] == true && @h[4][0] == true && @h[4][0] == true && @h[4][0] == true
        @win[:corner] = true
      end
      puts "rr: #{rr}"
      puts "cc: #{cc}"
      return @win
    end
    def [] k
      @h[k]
    end
    def sq
      @sq
    end
    def to_html
      o = []
      @h.each_pair do |r, row|
        rr = []
        row.each_pair do |c, sq|
          if sq.checked?
            rr[c] = %[<button class='check checked' id='check_#{r}_#{c}' value='#{r}_#{c}'>#{sq.value}</button>]
          else
            rr[c] = %[<button class='check' id='check_#{r}_#{c}' value='#{r}_#{c}'>#{sq.value}</button>]
          end
        end
        o[r] = %[<p>#{rr.join("")}</p>]
      end
      return %[<div id='card' style='width: 100%; height: 85%;'>#{o.join("")}</div>]
    end
    def to_h
      @h
    end
  end
  SQUARES = [
    "another <%= [:boy, :girl].sample %>friend",
    "lame <%= [:boy, :girl].sample %>friend",
    "<%= rand(2..47) %> eskimo cousins",
    "magic crystals",
    "drugs",
    "booze",
    "can't drink",
    "dumb",
    "aggressive",
    "narcissism",
    "rude",
    "aggressive <%= [:boy, :girl].sample %>friend",
    "smoker",
    "clown",
    "more than <%= rand(2..27) %> face tats",
    "less than <%= rand(2..27) %> face tats",
    "more than <%= rand(2..27) %> tattoos",
    "less than <%= rand(2..27) %> tattoos",
    "more than <%= rand(2..27) %> piercings",
    "less than <%= rand(2..27) %> piercings",
    "bike",
    "no bike",
    "doesn't like cats",
    "likes cats",
    "doesn't like dogs",
    "likes dogs",
    "doesn't like kids",
    "likes kids",
    "doesn't like ferrets",
    "likes ferrets",
    "doesn't like squirrels",
    "likes squirrels",
    "big family",
    "only child",
    "selfish",
    "car",
    "no car",
    "hard alcohol",
    "beer",
    "cigarettes",
    "marijuana",
    "cocaine",
    "aderall",
    "mushrooms",
    "vegan",
    "eats meat",
    "christian",
    "satanist",
    "budhist",
    "athiest",
    "jewish",
    "fat",
    "skinny",
    "lazy",
    "uncoordinated",
    "republican",
    "conservative",
    "liberal",
    "democrat",
    "nazi",
    "boring",
    "talks too fast",
    "dumb",
    "smart",
    "easy",
    "tease"
  ]
  class Square
    def initialize k
      @value = k
      if k == :center
        @checked = true
      else
        @checked = false
      end
    end
    def self.center
      self.new(:center)
    end
    
    def self.random      
      ERB.new(SQUARES.sample).result(binding)
    end
    def checked?
      @checked
    end
    def check
      @checked = true
    end
    def value
      @value
    end
  end
end

module Z4
  def self.bingo u
    Bingo.card u
  end
end

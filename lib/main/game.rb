class Game
  def initialize g, ch
    @g = g
    @game = Z4.db(:game, @g);
    @games = @game.dictionary[:stats]
    @ch = ch
    @chan = Z4.db(:chan, ch)
    @id = "game:#{g}-#{ch}"
    @user = Hash.new { |h,k| h[k] = Z4.db(:user, k, @ch).dictionary[@id]; }
  end
  def [] k
    @game[k]
  end
  def []= k,v
    @game[k] = v
  end
  
  # player: points
  def turn h={}
    h.each_pair { |k,v|
      @games.incr(:turns, k);
      @user[k].incr(:turns, @g);
      if v > 0
        @games.incr(:points, k, v);
        @user[k].incr(:points, @g, v);
      end
    }
  end
  
  # player: wins
  def game h={}
    h.each_pair { |k,v|
      @games.incr(:games, k);
      @user[k].incr(:games, @g);
      if v > 0
        @games.incr(:wins, k, v);
        @user[k].incr(:wins, @g, v);
      end
    }
  end

  def users &b
    if block_given?
      @user.keys.each { |e| b.call(e) }
    else
      @user.keys
    end
  end
  
  def user u, &b
    uu  = @user[u]
    if block_given?
      b.call(uu)
    end
    return uu
  end
  
  def to_h
    @game.to_h
  end
end

module GAME
  @@GAME = {}
  @@GAMES = Z4.db('/').collection[:games]
  def self.game g, ch
    @@GAMES.add(g, ch)
    @@GAME["#{g}-#{ch}"] = Game.new(g,ch)    
  end
  def self.[] k
    @@GAME[k]
  end
  def self.games
    @@GAMES
  end
end

@pool = GAME.game('pool', 'ops')
@dart = GAME.game('dart', 'ops')


@user = Z4.db(:user, 'maxcatman', 'ops')


class Group
  def initialize h
    @host = h
    @db = Z4.db("group:#{h}")
  end
  def incr k
    @db.incr k
  end
  def decr k
    @db.decr k
  end
  def [] k
    incr(k)
    Profile.new(k, @host)
  end
  def to_h
    @db.to_h
  end
end

class Profile
  def initialize u, k
    @user = u
    @key = k
    @db = Z4.db("user:#{k}:#{u}")
  end
  def [] k
    incr k
    return Group.new(k)
  end
  def incr k
    Group.new(k).incr @user
    @db.incr k
  end
  def decr k
    Group.new(k).decr @user
    @db.decr k
  end
  def to_h
    @db.to_h
  end
end

module Z4
  def self.group g
    Group.new(g)
  end
  def self.profile(u, k)
    Profile.new(u, k)
  end
  def self.match(k, p, *u)
    h = Hash.new {|h,k|h[k] = {}}
    pp = Z4.profile(p,k).to_h
    pp.each_pair {|interest, score|
      [u].flatten.each { |e|
        uu = Z4.profile(e,k).to_h;
        if uu.has_key? interest
          h[e][interest] = ((0 - score) + uu[interest])
        end
      }
    }
    return h
  end
end

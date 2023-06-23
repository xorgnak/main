module Z4
  def db(*t)
    Db.new(t)
  end
  def self.db(*t)
    Db.new(t)
  end

  class Db
    def initialize *t
      @db = PStore.new("db/#{t.join('-')}.pstore")
      @dict = Hash.new {|h,k| dictionaries(k); h[k] = DbDict.new(t) }
      @coll = Hash.new {|h,k| collections(k); h[k] = DbColl.new(t) }
      collections.each {|e| @coll[e] }
      dictionaries.each {|e| @dict[e] }
    end
    
    def collections *k
      if k[0]
        @db.transaction do |db|
          if db[:collections] != nil;
            x = db[:collections].split(", ");
          else
            x = [];
          end;
          x << k[0].to_s;
          db[:collections] = x.uniq.join(', ');
        end
      else
        @db.transaction do |db|
          if db[:collections] != nil;
            return db[:collections].split(", ");
          else;
            return [];
          end
      end
      end
    end
    def collection
      @coll
    end
    def has_collection? k
      @coll.has_key? k
    end
    def dictionaries *k
      if k[0]
        @db.transaction do |db|
          if db[:dictionaries] != nil
            x = db[:dictionaries].split(", ");
          else
            x = [];
          end
          x << k[0].to_s;
          db[:dictionaries] = x.uniq.join(', ');
        end
      else
        @db.transaction do |db|
          if db[:dictionaries] != nil;
            db[:dictionaries].split(", ");
          else;
            return [];
          end
        end
      end
    end
    def dictionary
      @dict
    end
    def has_dictionary? k
      @dict.has_key? k
    end
    def has_key? k
      @db.transaction {|db| return db.key? k }
    end
    def [] k
      if @coll.has_key? k
        return @coll[k]
      elsif @dict.has_key? k
        return @dict[k]
      elsif has_key? k
        @db.transaction {|db| db[k] }
      else
        return nil
      end
    end
    def []= k, v
      @db.transaction {|db| db[k] = v }
    end
    def incr k
      @db.transaction {|db| db[k] = db[k].to_i + 1 }
    end
    def decr k
      @db.transaction {|db| db[k] = db[k].to_i - 1 }
    end
    def transaction &b
      @db.transaction {|db| b.call(db) }
    end
    def to_h
      h = {}
      @db.transaction { |db| db.keys.each { |k| h[k.to_sym] = db[k] }}
      @coll.to_h.each_pair { |k,v| h[k.to_sym] = v.raw }
      @dict.to_h.each_pair { |k,v| h[k.to_sym] = v.raw }
      return h
    end
  end
  
  class DbDict
    def initialize *t
      @db = PStore.new("db/#{t.join('-')}-dict.pstore")
    end
    def has_key? k
      @db.transaction {|db| return db.key? k }
    end
    def [] h
      @db.transaction {|db| x = JSON.parse(db[h] || '{}'); return x }
    end
    def get h, k
      @db.transaction {|db| x = JSON.parse(db[h] || '{}'); return x[k.to_s]; }
    end
    def set h, k, v
      @db.transaction {|db| x = JSON.parse(db[h] || '{}'); x[k] = v; db[h] = JSON.generate(x); }
    end
    def incr h, k, *v
      if v[0]
        n = v[0]
      else
        n = 1
      end
      @db.transaction {|db| x = JSON.parse(db[h] || '{}'); x[k] = x[k].to_i + n; db[h] = JSON.generate(x); }
    end
    def decr h, k, *v
      if v[0]
        n = v[0]
      else
        n = 1
      end
      @db.transaction {|db| x = JSON.parse(db[h] || '{}'); x[k] = x[k].to_i - n; db[h] = JSON.generate(x); }
    end
    def raw
      h = {}
      @db.transaction {|db| db.keys.each { |k| h[k] = JSON.parse(db[k] || '{}') }}
      return h
    end
  end
  
  class DbColl
    def initialize *t
      @db = PStore.new("db/#{t.join('-')}-coll.pstore")
    end
    def has_key? k
      @db.transaction {|db| return db.key? k }
    end
    def [] k
      @db.transaction {|db| x = db[k].split(', '); return x }
    end
    def uniq k
      @db.transaction {|db| x = db[k].split(', '); x.uniq!; db[k] = x.join(', '); }
    end
    def has k, i
      @db.transaction {|db| x = db[k].split(', '); return x.include?(i); }
    end
    def add k, i
      @db.transaction {|db| if db[k] != nil; x = db[k].split(', '); else x = []; end;  x << i; db[k] = x.join(', '); }
    end
    def del k, i
      @db.transaction {|db| x = db[k].split(', '); return x.delete(i) }
    end
    def sample k
      @db.transaction {|db| x = db[k].split(', '); return x.sample }
    end
    def length k
      @db.transaction {|db| x = db[k].split(', '); return x.length }
    end
    def index k, i
      @db.transaction {|db| x = db[k].split(', '); return x.index(i) }
    end
    def raw
      h = {}
      @db.transaction {|db| db.keys.each { |k| h[k] = db[k].split(', '); }}
      return h
    end
  end
end

if File.exist? "z4/db.rb"
  load "z4/db.rb"
end

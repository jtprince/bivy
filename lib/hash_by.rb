
module Enumerable

  # Given a single symbol, hashes on that one symbol. 
  #   
  # Given a list of symbols, Hashes on the list of attributes (keyed as an 
  # array if > 1)
  #
  # Given a block, it will hash on the value returned from the block
  #
  # Examples for these three cases:
  #   objs = [<obj1 @size=3, @shape="round", @color="red">, ...]
  #   hash = objs.hash_by(:shape)
  #   hash["round"]                                   # -> [obj1, ...]
  #   hash = objs.hash_by(:size, :shape, :color)      # List of attrs
  #   hash[[3,"round","red"]]                         # -> [obj1, ...]
  #   hash = objs.hash_by {|obj| obj.size - 1}        # Block
  #   hash[2]                                         # -> [obj1, ...]
  #   
  # Usual caveats about messing with the arrays as hash keys apply, but 
  # shouldn't be an issue since they are all created inside the method.  (If
  # you didn't create it you are much less likely to mess around with it ;).
  # Just so you have some idea of how to shoot yourself in the foot (and how
  # to fix it):
  #   obj1.size = 10; obj1.shape = "round", obj1.color = "red"
  #   [obj1].hash_by(:size,:shape,:color)
  #   hash[arr]                 # -> <obj1>
  #   hash[[10,"round","red"]]  # -> <obj1>
  #   arr = hash.keys.first
  #   arr.pop
  #   hash[[10,"round","red"]]  # -> nil 
  #   hash[[10,"round"]]        # -> nil 
  #   hash[arr]                 # -> nil  (hash is clearly broken!)
  #   hash.rehash               # If you want to fix hash with new key
  #   hash[[10,"round","red"]]  # -> nil
  #   hash[[10,"round"]]        # -> <obj1>
  #   hash[arr]                 # -> <obj1>
  def hash_by(*att_symbol_list)
    hash = Hash.new {|h,k| h[k] = [] }
    if block_given?
      self.each do |obj|
        hash[yield(obj)].push obj
      end
    else
      if att_symbol_list.size > 1
        self.each do |obj|
          key = att_symbol_list.collect do |att|
            obj.send(att)
          end
          hash[key].push obj
        end
      elsif att_symbol_list.size == 1
        att = att_symbol_list[0]
        self.each do |obj|
          hash[obj.send(att)].push obj
        end
      else
        # @TODO: throw proper exception here
        puts "Trying to hash on empty list!"
        exit
      end
    end
    hash
  end

  # Same as hash_by but it assumes there is only a single entry
  # for each key.  If this is violated, the last occurence
  # will end up being the value returned by a key
  def hash_uniq_by(*att_symbol_list)
    hash = {}
    if block_given?
      self.each do |obj|
        hash[yield(obj)] = obj
      end
    else
      if att_symbol_list.size > 1
        self.each do |obj|
          key = att_symbol_list.collect do |att|
            obj.send(att)
          end
          hash[key] = obj
        end
      elsif att_symbol_list.size == 1
        att = att_symbol_list[0]
        self.each do |obj|
          hash[obj.send(att)] = obj
        end
      else
        # @TODO: throw proper exception here
        puts "Trying to hash on empty list!"
        exit
      end
    end
    hash
  end

end



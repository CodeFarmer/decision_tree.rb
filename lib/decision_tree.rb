module DecisionTree

  # amap: map of (input, output)
  # return: the entropy with regard to (output) of the current list
  def self.entropy(amap)
    output_counts = {}
    amap.each do |i, o|
      output_counts[o] ||= 0
      output_counts[o] += 1
    end

    # it would be great if Ruby hashes had #reduce
    e = 0

    output_counts.each do |o, c|
      p = c.to_f / amap.count
      e += -p * Math.log2(p)
    end

    return e

  end

  # amap: map of (input, output) where input is also a map
  # key:  a particular key from the input maps to use to partition the map
  #
  # return a new map, whose keys are the various values that 'key' takes in input, and whose values are the segments of map where input is equal that value (but with 'key' removed). This can include the nil key.
  #
  # Hmm. Makes sense when you say it out lout.
  def self.partition(key, amap)

    ret = {}

    amap.each do |i, o|

      part_without_key_in_keys = {}

      amap.select do |k, v|
        k[key] == i[key]
      end.each do |k, v|
        part_without_key_in_keys[k.select{|l, w| l != key}] = v
      end

      ret[i[key]] = part_without_key_in_keys

    end

    return ret

  end

  # alist: a list of maps
  # return an Enumerable containing all of the keys that occur in the various maps
  def self.all_keys(alist)
    alist.reduce(Set.new) {|a, m| a.merge(m.keys)}.to_a
  end

  # amap: as with .partition, a map of (input, output) whose inputs are also maps
  # return: the key which, when used to partition amap, produces the creates net information gain (across all the partitions) compared to amap
  def self.most_informative_key(amap)

    winner = nil
    winning_gain = nil

    current_entropy = entropy(amap)

    all_keys(amap.keys).each do |key|
      g = gain(key, amap, current_entropy)
      if winner.nil? || g > winning_gain then
        winner = key
        winning_gain = g
      end
        
    end

    return winner

  end

  def self.gain(key, amap, current_entropy=nil)
    current_entropy = entropy(amap) if current_entropy.nil?
    return current_entropy - partition(key, amap).reduce(0) {|a, v| a + entropy(v)}
  end

end


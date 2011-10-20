module DecisionTree


  # pairs: list of [input, output]
  # return: the entropy with regard to (output) of the current list
  #
  # TODO: allow a map, as well as a list
  def self.entropy(pairs)

    output_counts = {}
    pairs.each do |pair|
      output_counts[pair[1]] ||= 0
      output_counts[pair[1]] += 1
    end

    # it would be great if Ruby hashes had #reduce
    e = 0

    output_counts.each do |o, c|
      p = c.to_f / pairs.count
      e += -p * Math.log2(p)
    end

    return e

  end


  # pairs: list of pairs  (input, output) where input is a map
  # key:  a particular key from the input maps to use to partition the map
  #
  # return a map, whose keys are the various values that 'key' takes in the maps that make up the first elements of each pair, and whose values are the segments of 'pairs' where input is equal that value (but with 'key' removed). This can include the nil key.
  #
  # Hmm. Makes sense when you say it out loud.
  #
  # TODO: Allow a map as well as a list (? or should we; just let entropy and most_informative be the interface?)
  def self.partition(key, pairs)

    ret = {}

    pairs.each do |pair|

      part_without_key_in_keys = [] 

      pairs.select do |p|
        p[0][key] == pair[0][key]
      end.each do |p|
        first_without_key_in_keys = p[0].select{|l, w| l != key}
        part_without_key_in_keys << [first_without_key_in_keys, p[1]]
      end

      ret[pair[0][key]] = part_without_key_in_keys

    end

    return ret

  end


  # alist: a list of maps
  # return an Enumerable containing all of the keys that occur in the various maps
  def self.all_keys(alist)
    alist.reduce(Set.new) {|a, m| a.merge(m.keys)}.to_a
  end

  def self.most_informative_key(pairs)

    winner = nil
    winning_gain = nil

    current_entropy = entropy(pairs)

    all_keys(pairs.map(&:first)).each do |key|
      g = gain(key, pairs, current_entropy)
      if winner.nil? || g > winning_gain then
        winner = key
        winning_gain = g
      end
        
    end

    return winner


  end

  def self.gain(key, pairs, current_entropy=nil)
    current_entropy = entropy(pairs) if current_entropy.nil?
    return current_entropy - partition(key, pairs).values.reduce(0) {|a, v| a + ((v.count.to_f / pairs.count) * entropy(v))}
  end

end


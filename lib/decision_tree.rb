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

  def self.build(pairs)
    # NOTE this ends up calculating entropy and partitions way more times than it should, there is a better way to structure these functions even without state (the Clojure version will be lovely).
    return [pairs.first[1]] if entropy(pairs) == 0

    mik = most_informative_key(pairs)
    choice_map = {}
    partition(mik, pairs).each do |v, part|
      choice_map[v] = build(part)
    end

    return [mik, choice_map]
  end

  INDENT = '  '
  def self.tree_string(tree, indent = '')

    ret = '' + indent
    if tree.count == 1 then # leaf
      ret << "=> #{tree[0]}\n"
    else

      ret << "#{tree[0]}?\n"

      consolidate_keys(tree[1]).each do |k, v|
        ret << indent + INDENT
        ret << "#{k}:\n"
        ret << tree_string(v, indent + INDENT + INDENT)
      end

    end

    return ret
    
  end

  # return a map where no value is repeated, and keys that share values are now an array of keys
  # ie., {:a => 1, :b => 1, :c => 2} => {[:a, :b] => 1, :c => 2}
  def self.consolidate_keys(map)
    ret = {}
    map.values.uniq.each do |v|
      ret[map.keys.select{|k| map[k] == v}] = v
    end

    ret
  end

end


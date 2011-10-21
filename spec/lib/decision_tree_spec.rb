require File.expand_path('../../../lib/decision_tree', __FILE__)

describe DecisionTree do

  describe '.entropy' do

    it 'should return zero for an empty data set' do
      DecisionTree.entropy({}).should == 0
    end

    it 'should return 0.940 for the example in the Mitchell book' do

      nine_five = [ 
        [1,  'Y'],
        [2,  'Y'],
        [3,  'Y'],
        [4,  'Y'],
        [5,  'Y'],
        [6,  'Y'],
        [7,  'Y'],
        [8,  'Y'],
        [9,  'Y'],
        [10, 'N'],
        [11, 'N'],
        [12, 'N'],
        [13, 'N'],
        [14, 'N'],
      ]

      DecisionTree.entropy(nine_five).should be_within(0.0005).of(0.940)

    end

  end

  describe '.partition' do

    it 'should deal with the simple case of inputs that have matching keys' do

      pairs = [
        [{:a => 1, :b => 1}, 'A'],
        [{:a => 2, :b => 1}, 'B'],
        [{:a => 2, :b => 2}, 'C'],
      ]

      DecisionTree.partition(:a, pairs).should == {
        1 => [[{:b => 1}, 'A']],
        2 => [[{:b => 1}, 'B'], [{:b => 2}, 'C']]
      }

    end

    it 'should deal with inputs that have differing keys' do
      pairs = [
        [{:a => 1, :b => 1}, 'A'],
        [{:a => 2, :b => 1}, 'B'],
        [{:c => 2, :b => 2}, 'C'],
        [{:d => 3, :b => 2}, 'D'],
      ]

      DecisionTree.partition(:a, pairs).should == { 
        1   => [[{:b => 1}, "A"]],
        2   => [[{:b => 1}, "B"]],
        nil => [[{:c => 2, :b =>2}, 'C'], [{:d => 3, :b => 2}, 'D']]
      }
      
    end

  end

  describe '.all_keys' do
    it 'should deal with the simple case of completely disjoint maps' do
      DecisionTree.all_keys([{:a => 1, :b => 2}, {:c => 3, :d => 4}]).should == [:a, :b, :c, :d]
    end
    
    it 'should return each key only once, when there are repeated keys' do
      DecisionTree.all_keys([{:a => 1, :b => 2}, {:c => 3, :a => 4}]).should == [:a, :b, :c]
    end
  end

  describe '.most_informative_key' do

    it 'should return nil for an empty map' do
      DecisionTree.most_informative_key({}).should be_nil
    end

    it 'should return a key when all are equally informative' do
      pairs = [
        [{:a => 1, :b => 2}, 'Y'],
        [{:a => 2, :b => 3}, 'M'],
      ]

      mik = DecisionTree.most_informative_key(pairs)
      mik.should_not be_nil
      mik.class.should == Symbol
    end
  end

  describe '.build' do

    context 'from a single keyed map as the sole example' do

      it 'should return only a leaf node' do
        DecisionTree.build([[{:a => 1}, :b]]).should == [:b]
      end

    end

    context 'from multiple examples with the same result' do
      it 'should return only a leaf node' do
        DecisionTree.build([[{:a => 1, :b => 2}, :x],
                            [{:a => 2, :b => 3}, :x],
                            [{:a => 1, :b => 3}, :x]]).should == [:x]
      end
    end

    context 'from two examples, differentiated only by a single key in a single-keyed map' do
      it 'should return a pair whose first element is the differentiating key, and whose second element is a map of the different values that key takes to their corresponding leaf nodes' do
        DecisionTree.build([[{:a => 1}, :x], [{:a => 2}, :y]]).should == [:a, {1 => [:x], 2 => [:y]}]
      end
    end

    context 'from four examples with two keys' do

      it 'should return the simple expected tree corresponding to "If a = 1 then :x, else if :a =2 then (if :b = 1 then :y else if :b = 2 then :z)"' do

        DecisionTree.build([[{:a => 1, :b => 1}, :x],
                            [{:a => 2, :b =>1}, :y],
                            [{:a => 1, :b => 2}, :x],
                            [{:a => 2, :b => 2}, :z]]).should == [
          :a, {1 => [:x],
               2 => [:b, {1 => [:y], 2 => [:z]}]}
        ]

      end

    end

  end

  describe '.consolidate_keys' do

    it 'should at least follow the comment in front of the method' do
      DecisionTree.consolidate_keys({:a => 1, :b => 1, :c => 2}).should == {[:a, :b] => 1, :c => 2}
    end

  end

  context 'with the example from the Mitchell book' do

    before(:each) do
      @sample_data = [ 
        [{:outlook => 'Sunny',    :temperature => 'Hot',  :humidity => 'High',   :wind => 'Weak'},   'No'],
        [{:outlook => 'Sunny',    :temperature => 'Hot',  :humidity => 'High',   :wind => 'Strong'}, 'No'],
        [{:outlook => 'Overcast', :temperature => 'Hot',  :humidity => 'High',   :wind => 'Weak'},   'Yes'],
        [{:outlook => 'Rain',     :temperature => 'Mild', :humidity => 'High',   :wind => 'Weak'},   'Yes'],
        [{:outlook => 'Rain',     :temperature => 'Cool', :humidity => 'Normal', :wind => 'Weak'},   'Yes'],
        [{:outlook => 'Rain',     :temperature => 'Cool', :humidity => 'Normal', :wind => 'Strong'}, 'No'],
        [{:outlook => 'Overcast', :temperature => 'Cool', :humidity => 'Normal', :wind => 'Strong'}, 'Yes'],
        [{:outlook => 'Sunny',    :temperature => 'Mild', :humidity => 'High',   :wind => 'Weak'},   'No'],
        [{:outlook => 'Sunny',    :temperature => 'Cool', :humidity => 'Normal', :wind => 'Weak'},   'Yes'],
        [{:outlook => 'Rain',     :temperature => 'Mild', :humidity => 'Normal', :wind => 'Weak'},   'Yes'],
        [{:outlook => 'Sunny',    :temperature => 'Mild', :humidity => 'Normal', :wind => 'Strong'}, 'Yes'],
        [{:outlook => 'Overcast', :temperature => 'Mild', :humidity => 'High',   :wind => 'Strong'}, 'Yes'],
        [{:outlook => 'Overcast', :temperature => 'Hot',  :humidity => 'Normal', :wind => 'Weak'},   'Yes'],
        [{:outlook => 'Rain',     :temperature => 'Mild', :humidity => 'High',   :wind => 'Strong'}, 'No'],
      ]

    end

    describe '.gain' do

      # NOTE that the gain calculations in the textbook are floored, not rounded!
      it 'should return 0.247 for :outlook' do
        DecisionTree.gain(:outlook, @sample_data).should be_within(0.0005).of 0.247
      end

      it 'should return 0.152 for :humidity' do
        DecisionTree.gain(:humidity, @sample_data).should be_within(0.0005).of 0.152
      end

      it 'should return 0.048 for :wind' do
        DecisionTree.gain(:wind, @sample_data).should be_within(0.0005).of 0.048
      end

      it 'should return 0.029 for :temperature' do
        DecisionTree.gain(:temperature, @sample_data).should be_within(0.0005).of 0.029
      end

     end

    describe '.most_informative_key' do
      it 'should return :outlook as the first choice' do
        DecisionTree.most_informative_key(@sample_data).should == :outlook
      end
    end

    describe '.build' do

      xit "should build the same tree as generated by the book's example algorithm" do
      end

    end

  end

end


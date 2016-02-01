require "minitest/autorun"
require "./sudoku-solver"

describe Node do
  before do
    @node = Node.new({row:1, col:1, possibilities:[1,4,7,9]}, 2)
  end

  describe "when initialize class" do
    it "should be Node class" do
      @node.class.must_equal Node
    end
  end
  describe "#possibilities_show" do
    it "should show the possibilities with break line" do
      # @node.possibilities_show.must_equal "[[1, 4\n7, 9]]"
    end
  end
end

describe Sudoku do
  before do
    @game = Sudoku.new
  end

  describe "#initialize" do
    it "#default game" do
      @game.class.must_equal Sudoku
    end
    it "data should be an Array" do
      @game.data.class.must_equal Array
    end
    it "data should be an Array of Node objects" do
      @game.data.first.class.must_equal Node
    end
    it "data should be some specific node values" do
     	@game.data.map(&:val).compact.must_equal [8, 5, 3, 6, 2, 9, 7, 5, 4, 3, 8, 1, 7, 5, 9, 7, 1, 7, 2, 6, 2, 4, 1, 4, 9]
    end
    it "data should be 81 positions" do
      @game.data.size.must_equal 81
    end
    it "a node should be a Fixnum" do
      @game.data[1].val.class.must_equal Fixnum
    end
  end
  describe "getting node" do
    it "#get should get a specific node" do
  		node = @game.get('0x1')	
      node.row.must_equal 0
      node.col.must_equal 1
      node.val.must_equal 8
    end
    it "#get_square_key should get a specific node" do
  		@game.get_square_key(1, 2).must_equal '1'
    end
    it "#get_square number #1" do
  		@game.get_square(1).size.must_equal 9
  		@game.get_square(1).map(&:row).must_equal [0, 0, 0, 1, 1, 1, 2, 2, 2]
  		@game.get_square(1).map(&:col).must_equal [0, 1, 2, 0, 1, 2, 0, 1, 2]
  		@game.get_square(1).map(&:val).must_equal [nil, 8, nil, 6, nil, 2, nil, 5, nil]
    end
  end
  describe "#square_valid?" do
  	it "# 1 is valid for first square" do
  		@game.square_valid?('1', 1).must_equal true
  	end
  	it "# 8 ins't valid for first square" do
  		@game.square_valid?('1', 8).must_equal false
  	end
  end
  describe "#col_valid?" do
  	it "# 3 is valid for first column" do
  		@game.col_valid?(0, 3).must_equal true
  	end
  	it "# 6 ins't valid for first col" do
  		@game.col_valid?(0, 6).must_equal false
  	end
  end
  describe "#line_valid?" do
  	it "# 2 is valid for first line" do
  		@game.line_valid?(0, 2).must_equal true
  	end
  	it "# 8 ins't valid for first line" do
  		@game.line_valid?(0, 8).must_equal false
  	end
  end
  describe "#valid?" do
  	before do
  		@node = @game.data.first
  	end
  	it "#1 is valid for first block" do
  		@game.valid?(@node, 1).must_equal true
  	end
  	it "#8 ins't valid for first block" do
  		@game.valid?(@node, 8).must_equal false
  	end
  end
  describe "#load_possibilities_for" do
  	before do
  		@node = @game.data.first
  	end
  	it "should load the possibilities for one block" do
  		@game.load_possibilities_for(@node).must_equal [1, 4, 7, 9]
  	end
  end
end
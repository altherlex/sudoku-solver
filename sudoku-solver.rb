require 'terminal-table'
require "minitest/autorun"

class Sudoku
	SQUARES = {
		"1" => ["0x0","0x1","0x2", "1x0","1x1","1x2", "2x0","2x1","2x2"],
		"2" => ["0x3","0x4","0x5", "1x3","1x4","1x5", "2x3","2x4","2x5"],
		"3" => ["0x6","0x7","0x8", "1x6","1x7","1x8", "2x6","2x7","2x8"],

		"4" => ["3x0","3x1","3x2", "4x0","4x1","4x2", "5x0","5x1","5x2"],
		"5" => ["3x3","3x4","3x5", "4x3","4x4","4x5", "5x3","5x4","5x5"],
		"6" => ["3x6","3x7","3x8", "4x6","4x7","4x8", "5x6","5x7","5x8"],

		"7" => ["6x0","6x1","6x2", "7x0","7x1","7x2", "8x0","8x1","8x2"],
		"8" => ["6x3","6x4","6x5", "7x3","7x4","7x5", "8x3","8x4","8x5"],
		"9" => ["6x6","6x7","6x8", "7x6","7x7","7x8", "8x6","8x7","8x8"],
	}

	attr_accessor :data

	def initialize
		arr_initial = [
			[[ ],[8],[ ],  [ ],[ ],[ ],  [5],[ ],[3]],
			[[6],[ ],[2],  [ ],[ ],[9],  [ ],[7],[ ]],
			[[ ],[2],[ ],  [4],[3],[ ],  [ ],[ ],[ ]],

			[[8],[ ],[ ],  [1],[ ],[7],  [ ],[ ],[5]],
			[[ ],[ ],[ ],  [9],[ ],[ ],  [7],[ ],[1]],
			[[ ],[ ],[7],  [ ],[ ],[ ],  [ ],[ ],[ ]],

			[[2],[ ],[ ],  [ ],[ ],[ ],  [ ],[ ],[ ]],
			[[ ],[ ],[6],  [ ],[2],[ ],  [4],[1],[ ]],
			[[ ],[ ],[ ],  [ ],[4],[ ],  [9],[ ],[ ]]
		]
		@data = []
		arr_initial.each_with_index do |row, index_line|
			row.each_with_index do |number, index_col|
				@data << Node.new({col:index_col ,row:index_line}, number.first) 
			end
		end
	end
	def validation_line(line_num = 0)
		@data.select{|node| node.row==line_num}.map{|node| node.val}.reduce(:+)==45
	end
	def validation_col(col_num = 0)
		@data.select{|node| node.col==col_num}.map{|node| node.val}.reduce(:+)==45
	end
	def validation_square(square_num = "1")
		arr_sum_valid = []
		arr_pos = SQUARES[square_num.to_s]
		arr_pos.each{|pos| 
			row, col = pos.split('x').map(&:to_i)
			arr_sum_valid << @data.detect{|node| node.row==row and node.col==col}.val || 0
		}
		arr_sum_valid.reduce(:+)==45
	end
	def square_valid?(square_key, val)
		_all_valid = []
		get_square(square_key).each do |node_analysed| 
			if node_analysed.defined?
				_all_valid << (node_analysed.val != val)
			end
		end		
		!_all_valid.include?(false)
	end
	def line_valid?(row_num, val)
		_all_valid = []
		(0...9).to_a.each_with_index do |i, index|
			node_analysed = get(row_num, index)
			if node_analysed.defined?
				_all_valid << (node_analysed.val != val)	
			end
		end
		!_all_valid.include?(false)
	end
	def col_valid?(col_num, val)
		_all_valid = []
		(0...9).to_a.each_with_index do |i, index|
			node_analysed = get(index, col_num)
			if node_analysed.defined?
				_all_valid << (node_analysed.val != val)	
			end
		end
		!_all_valid.include?(false)
	end
	def valid?(node, val)
		line_valid?(node.row, val) and col_valid?(node.col, val) and square_valid?( get_square_key(node.row, node.col), val )
	end
	def load_possibilities!
		(1..9).to_a.each_with_index do |i, line|
			(1..9).to_a.each_with_index do |number, col|
				node = data.get(line,col)
				node.possibilities<<number if !node.defined? and valid?(node, number)
			end
		end
	end
	def get(*args)
		if args.size==1 and args.first.is_a? String
			row, col = args.first.split('x').map(&:to_i)
		else args.size==2
			row, col = args.map(&:to_i)
		end
		self.data.detect{|node| node.row==row and node.col==col}
	end
	def get_square_key(row_num, col_num)
		pos = "#{row_num}x#{col_num}"
		SQUARES.detect do |key, arr|
			arr.include?(pos)
		end.first
	end
	def get_square(square_key)
		arr_nodes = []
		SQUARES[square_key.to_s].each do |pos| 
			arr_nodes << get(pos)
		end
		arr_nodes
	end
	def show
		table = Terminal::Table.new :rows => data
		puts table
	end
end
class Node
	attr_accessor :col, :row, :possibilities, :defined, :val
	def initialize(options, val=nil)
		@val= val
		@col = options[:col]
		@row = options[:row]
		@possibilities = options[:possibilities] || []
		@defined = !val.nil?
	end
	def defined?
		@defined
	end
end

# game = Sudoku.new
# puts game.get.inspect
# Terminal::Table.new :rows => game.data

describe Node do
  before do
    @node = Node.new({row:1, col:1}, 2)
  end

  describe "when initialize class" do
    it "should be Node class" do
      @node.class.must_equal Node
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
    it "data should be some specific noe values" do
     	@game.data.map(&:val).compact.must_equal [8, 5, 3, 6, 2, 9, 7, 2, 4, 3, 8, 1, 7, 5, 9, 7, 1, 7, 2, 6, 2, 4, 1, 4, 9]
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
  		@game.get_square(1).map(&:val).must_equal [nil, 8, nil, 6, nil, 2, nil, 2, nil]
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
end
require 'terminal-table'
require "minitest/autorun"

class Sudoku
	SQUARES = {
		"1" => ["0x0","0x1","0x2", "2x0","2x1","2x2", "3x0","3x1","3x2"],
		"2" => ["0x3","0x4","0x5", "2x3","2x4","2x5", "3x3","3x4","3x5"],
		"3" => ["0x6","0x7","0x8", "2x6","2x7","2x8", "3x6","3x7","3x8"],

		"4" => ["4x0","4x1","4x2", "5x0","5x1","5x2", "6x0","6x1","6x2"],
		"5" => ["4x3","4x4","4x5", "5x3","5x4","5x5", "6x3","6x4","6x5"],
		"6" => ["4x6","4x7","4x8", "5x6","5x7","5x8", "6x6","6x7","6x8"],

		"7" => ["7x0","7x1","7x2", "8x0","8x1","8x2", "9x0","9x1","9x2"],
		"8" => ["7x3","7x4","7x5", "8x3","8x4","8x5", "9x3","9x4","9x5"],
		"9" => ["7x6","7x7","7x8", "8x6","8x7","8x8", "9x6","9x7","9x8"],
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
	def square_valid?(square_num, val)
		_all_valid = []
		arr_pos = SQUARES[square_num.to_s]
		arr_pos.each do |pos| 
			node_analysed = get(pos)
			# puts 'k'*50
			# puts node_analysed.inspect
			# puts 'k'*50
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
				_all_valid << node_analysed.val != val	
			end
		end
		!_all_valid.include?(false)
	end
	def col_valid?(col_num, val)
		_all_valid = []
		(0...9).to_a.each_with_index do |i, index|
			node_analysed = get(index, col_num)
			if node_analysed.defined?
				_all_valid << node_analysed.val != val	
			end
		end
		!_all_valid.include?(false)
	end
	def valid?(node, val)
		line_valid?(node.row, val) and col_valid?(node.col, val) and square_valid?( get_square_key(node.row, node.col), val )
	end
	# TODO Escrever minitests
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
			row, col = args
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
			puts '--'*20
			puts get(pos).inspect
			puts '--'*20
		end
		arr_nodes
	end
	def show
		table = Terminal::Table.new :rows => data
		puts table
	end
end
class Node
	# {l:1, j:1, possibilities:[1,2,3], defined:false, val:nil}
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
      node.row.must_equal 1
      node.col.must_equal 2
      node.val.must_equal 8
    end
    it "#get_square_key should get a specific node" do
  		@game.get_square_key(1, 2).must_equal '1'
    end
    it "#get_square" do
  		# @game.get_square(1).size.must_equal 9
  		# @game.get_square(1).map(&:row).must_equal false
  		# @game.get_square(1).map(&:col).must_equal false
  		# @game.get_square(1).map(&:val).must_equal false
    end
  end
  describe "validate square" do
  	it "# 8 ins't valid for first square" do
  		# @game.square_valid?('1', 8).must_equal false
  	end
  end
end
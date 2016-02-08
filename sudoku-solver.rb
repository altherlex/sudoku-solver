require 'terminal-table'
require 'colorize'

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

	def initialize(arr_initial=nil)
		arr_initial = arr_initial || [
			[[ ],[8],[ ],  [ ],[ ],[ ],  [5],[ ],[3]],
			[[6],[ ],[2],  [ ],[ ],[9],  [ ],[7],[ ]],
			[[ ],[5],[ ],  [4],[3],[ ],  [ ],[ ],[ ]],

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

		load_possibilities!
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
#--------------------- Core ------------------------------
	def next
		# row
		(1..9).to_a.each_with_index do |val, index|
			calculate!(index, :row)	
		end
		# col
		(1..9).to_a.each_with_index do |val, index|
			calculate!(index, :col)	
		end
		# square
		(1..9).to_a.each do |square_key|
			calculate!(square_key, :square)
		end
		puts show
	end

	def one_possibilite!
		data.each do |node|
			if node.possibilities.one?
				node.val = node.possibilities.first
				reload_possibilities!
			end
		end
	end
	
	def calculate!(num_or_square_key, type=:row)
		one_possibilite!

		case type
		when :row
			nodes = row(num_or_square_key).select(&:undefined?)
		when :col
			nodes = col(num_or_square_key).select(&:undefined?)
		when :square
			nodes = get_square(num_or_square_key).select(&:undefined?)
		end
		nodes.each_with_index do |node, index|
			
			node_review = nodes.select{|i| i!=node}.map(&:possibilities)
			result = [node.possibilities, *node_review].inject(:-)

			if result.one?
				node.val = result.first
				load_possibilities!
			end
		end
		show
	end
#--------------------- end Core ------------------------------

	def load_possibilities!
		data.each do |node| 
			load_possibilities_for(node)
			# TODO: Recarregar possibilidades para a coluna, linha e bloco
			# if node.possibilities.size==0
			# 	load_possibilities_for(node)
			# 	node.defined=true
			# end
		end
	end
	alias_method :reload_possibilities!, :load_possibilities!

	def load_possibilities_for(node)
		if node.undefined?
			node.possibilities = []
			(1..9).to_a.each_with_index do |val, index|
				node.possibilities << val if valid?(node, val)
			end
			node.possibilities.uniq!
		end
		node.possibilities
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
	def get_all_line(num, type=:row)
		arr_nodes = []
		(1..9).to_a.each_with_index do |val, index|
			node = get(num, index) if type==:row
			node = get(index, num) if type==:col
			arr_nodes << get(num, index)
		end
		arr_nodes
	end	
	def row(index)
		get_all_line(index, :row)
	end
	def col(index)
		get_all_line(index, :col)
	end
	def show
		# table = Terminal::Table.new :rows => data.map(&:val).each_slice(9).to_a
		separator_for = [2,5,8]
		table = Terminal::Table.new do |t|
			rows = data.each_slice(9).to_a
			rows.each_with_index do |row, index|
				t.add_row row.map{|node| (node.val.nil?) ? node.possibilities_show : node.val_color}
				if separator_for.include?(index)
				  t.add_separator
				end
			end
		end		
		
		table.style = {:width => 130, :padding_left => 0, :border_x => "=", :border_i => "x"}
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
	def val_color(color=:green)
		val.to_s.send(color) 
		# val.to_s.blue.on_red #colorize(:color => :light_blue, :background => :red)
	end
	def val=(value)
		@defined = true
		@val = value
	end
	def possibilities_show
		if self.possibilities.size==1 
			self.possibilities.each_slice(2).to_a.join('-').blue
		else
			self.possibilities.each_slice(2).to_a.join('-').red #.gsub('], [', '\n').gsub('[[', '').gsub(']]', '')
		end
	end
	def defined?
		@defined
	end
	def undefined?
		!self.defined?
	end
end

game = [
  [[ ],[8],[ ],  [ ],[ ],[ ],  [5],[ ],[3]],
  [[6],[ ],[2],  [ ],[ ],[9],  [ ],[7],[ ]],
  [[ ],[5],[ ],  [4],[3],[ ],  [ ],[ ],[ ]],

  [[8],[ ],[ ],  [1],[ ],[7],  [ ],[ ],[5]],
  [[ ],[ ],[ ],  [9],[ ],[ ],  [7],[ ],[1]],
  [[ ],[ ],[7],  [ ],[ ],[ ],  [ ],[ ],[ ]],

  [[2],[ ],[ ],  [ ],[ ],[ ],  [ ],[ ],[ ]],
  [[ ],[ ],[6],  [ ],[2],[ ],  [4],[1],[ ]],
  [[ ],[ ],[ ],  [ ],[4],[ ],  [9],[ ],[ ]]
]
game = Sudoku.new game
puts game.show

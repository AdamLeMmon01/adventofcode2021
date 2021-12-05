file = File.read("day4_input.txt")

lines = file.split("\n")

draw_numbers_line = lines[0]
draw_numbers = draw_numbers_line.split(",").map { |value| value.to_i }
boards = []

class BingoSquare
  attr_accessor :value, :marked
  def initialize(value)
    @value = value
    @marked = false
  end
end

class Board
  def initialize
    @rows = []
  end

  def input_line(number_string)
    @rows << number_string.split(" ").map { |value| BingoSquare.new(value.to_i) }
  end
  def is_valid?
    @rows.length == 5 && @rows.all? { |row| row.length == 5 }
  end

  def all_squares
    (0..4).flat_map do |i|
      (0..4).map do |j|
        @rows[i][j]
      end
    end
  end

  def unmarked_squares
    all_squares.filter { |square| !square.marked }
  end

  def marked_squares
    all_squares.filter { |square| square.marked }
  end

  def won?
    currently_marked_squares = marked_squares
    @rows.each do |row|
      return true if (row - currently_marked_squares).empty?
    end

    (0..4).each do |column_index|
      column = @rows.map { |row| row[column_index] }
      return true if (column - currently_marked_squares).empty?
    end
    false
  end

  def sum_unmarked_squares
    total = 0
    unmarked_squares.each do |square|
      total += square.value
    end
    total
  end

  def mark(number)
    all_squares.each do |square|
      if square.value == number
        square.marked = true
        break
      end
    end
  end
end

(1..lines.length-1).each do |index|
  if lines[index].empty?
    boards << Board.new
    next
  end
  boards.last.input_line(lines[index])
end

boards = boards.filter{ |board| board.is_valid? }

results = []
draw_numbers.each do |number|
  boards.filter {|board| !board.won? }.each do |board|
    board.mark(number)
    if board.won?
      results << "winning board had total score: #{board.sum_unmarked_squares * number}"
    end
  end
end

pp "First #{results.first}"
pp "Last #{results.last}"
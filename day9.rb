file = File.read("day9_input.txt")

lines = file.split("\n")

rows = lines.map do |line|
  line.split("").map { |char| char.to_i }
end

class Cell
  attr_accessor :value
  def initialize(value, up, down, left, right)
    @value = value
    @up = up || 10
    @down = down || 10
    @left = left || 10
    @right = right || 10
  end
  def low_point?
    @value < @up &&
      @value < @down &&
      @value < @left &&
      @value < @right
  end
end

class Grid
  def initialize(rows)
    @cells = []
    (0..(rows.length - 1)).each do |i|
      (0..(rows[i].length - 1)).each do |j|
        up_value = i == 0 ? nil : rows[i - 1][j]
        down_value = i == rows.length - 1 ? nil : rows[i + 1][j]
        @cells << Cell.new(
          rows[i][j],
          up_value,
          down_value,
          rows[i][j - 1],
          rows[i][j + 1],
        )
      end
    end
  end

  def low_points
    @cells.filter { |cell| cell.low_point? }.flat_map { |cell| cell.value }
  end
end

grid = Grid.new(rows)
low_points = grid.low_points

pp "risk level #{ low_points.map { |value| value + 1 }.sum}"

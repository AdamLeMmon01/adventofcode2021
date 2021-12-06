file = File.read("day5_input.txt")

input_lines = file.split("\n")

class Point
  attr_accessor :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end

  def self.parse(coords)
    x, y = coords.split(",")
    Point.new(x.to_i, y.to_i)
  end
end

def get_range(start_value, end_value)
  if start_value <= end_value
    (start_value..end_value).to_a
  else
    start_value.downto(end_value).to_a
  end
end

class Line
  attr_accessor :start_point, :end_point

  def initialize(line_definition)
    p1, p2 = line_definition.split(" -> ")
    @start_point = Point.parse(p1)
    @end_point = Point.parse(p2)
  end

  def vertical?
    @start_point.x == @end_point.x
  end

  def horizontal?
    @start_point.y == @end_point.y
  end

  def coords_covered
    if vertical?
      ([@start_point.y, @end_point.y].min..[@start_point.y, @end_point.y].max).map do |y|
        Point.new(@start_point.x, y)
      end
    elsif horizontal?
      ([@start_point.x, @end_point.x].min..[@start_point.x, @end_point.x].max).map do |x|
        Point.new(x, @start_point.y)
      end
    else
      y_coords = get_range(@start_point.y, @end_point.y)
      x_coords = get_range(@start_point.x, @end_point.x)

      (0..x_coords.count - 1).map do |index|
        Point.new(x_coords[index], y_coords[index])
      end
    end
  end
end

lines = input_lines.map do |input|
  Line.new(input)
end

horiz_and_vert_lines = lines.filter { |line| line.horizontal? || line.vertical? }
diagonal_lines = lines.filter { |line| !line.horizontal? && !line.vertical?}
max_coord = 0
lines.each do |line|
  line.coords_covered.each do |coord|
    max_coord = coord.x if coord.x > max_coord
    max_coord = coord.y if coord.y > max_coord
  end
end

class Graph
  def initialize(size)
    @grid = (0..size).map do
      (0..size).map do
        0
      end
    end
  end

  def add_line(line)
    line.coords_covered.each do |coord|
      @grid[coord.x][coord.y] = @grid[coord.x][coord.y] + 1
    end
  end

  def print_grid
    @grid.each do |row|
      puts row.join("")
    end
  end

  def cells
    @grid.flat_map do |row|
      row.map do |cell|
        cell
      end
    end
  end

  def hot_zones
    cells.filter { |cell| cell > 1 }
  end
end


graph = Graph.new(max_coord)

horiz_and_vert_lines.each do |line|
  graph.add_line(line)
end

# graph.print_grid

# pp graph.hot_zones
pp "just considering horizontal and vertical #{graph.hot_zones.count}"

diagonal_lines.each do |line|
  graph.add_line(line)
end

# graph.print_grid

# pp graph.hot_zones
pp "including diagonal also #{graph.hot_zones.count}"
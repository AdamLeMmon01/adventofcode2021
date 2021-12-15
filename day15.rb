require "set"

file = File.read("day15_input.txt")

lines = file.split("\n")

rows = lines.map do |line|
  line.split("").map { |char| char.to_i }
end

class CaveCoord
  attr_accessor :tentative_distance, :visited, :value, :up_left, :up, :up_right, :left, :right, :down_left, :down_right, :down, :x, :y
  def initialize(x, y, value)
    @tentative_distance = nil
    @visited = false
    @value = value
    @up = nil
    @down = nil
    @left = nil
    @right = nil
    @up_left = nil
    @down_left = nil
    @up_right = nil
    @down_right = nil
    @x = x
    @y = y
  end

  def unvisited_neighbors
    [@up, @down, @left, @right].compact.filter { |node| node.visited == false }
  end

  def <=>(other)
    value <=> other.value
  end
end

def mark_all_unvisited(grid)
  grid.each do |row|
    row.each do |coord|
      coord.visited = false
    end
  end
end

def infinity_value(grid)
  grid.length * grid[0].length
end

def assign_tentative_distance(grid, initial_node)
  grid.each do |row|
    row.each do |coord|
      coord.tentative_distance = infinity_value(grid)
    end
  end
  initial_node.tentative_distance = 0
end

@non_default_values = Set.new

def recalc_unvisited_neighbors(node)
  node.unvisited_neighbors.each do |neighbor_node|
    new_distance = node.tentative_distance + neighbor_node.value
    if new_distance < neighbor_node.tentative_distance
      neighbor_node.tentative_distance = new_distance
      @non_default_values.add(neighbor_node)
    end
  end
end


def get_all_unvisited_nodes(grid)
  grid.flat_map do |row|
    row.map.filter do |coord|
      coord.visited == false
    end
  end
end

def dijkstras_algorithm(grid, initial_node, destination_node)
  mark_all_unvisited(grid)
  assign_tentative_distance(grid, initial_node)
  current_node = initial_node
  loop do
    # pp "processing: #{current_node.x}, #{current_node.y} at distance: #{current_node.tentative_distance} with #{@non_default_values.count} nodes left to process"
    recalc_unvisited_neighbors(current_node)
    current_node.visited = true
    if destination_node.visited == true # assume this is always the end condition for the puzzle
      pp "shortest path was: #{destination_node.tentative_distance}"
      break
    else
      @non_default_values.delete(current_node)
      current_node = @non_default_values.sort_by(&:tentative_distance).first
    end
  end
end

def add(grid, new_grid)
  cell_count = 0
  new_grid.each do |row|
    row.each do |coord|
      cell_count += 1
      grid[coord.y] ||= []
      grid[coord.y][coord.x] = coord.clone
      # @never_called_for[coord.y][coord.x] = nil
    end
  end
  # pp cell_count
  # @added_cells += cell_count
end

def calculate_values(grid, offset, offset_x, offset_y)
  result = grid.map do |row|
    row.map do |cell|
      new_value = cell.value + offset
      new_value = new_value - 9 if new_value > 9
      CaveCoord.new(cell.x + offset_x, cell.y + offset_y, new_value)
    end
  end
  result
end

def copy_right_and_down(grid, original_grid, offset)
  original_grid_width = original_grid.length - 1

  #1,2,3,4,3,2,1,0 #number of grids to add on the right
  grids_to_add_right = 4 - (4 - offset).abs

  # always add one grid down
  # down grid index should be x = 0,0,0,0,1,2,3,4 and y = 1,2,3,4,4,4,4,4
  grid_offset_x = [offset - 4, 0].max
  grid_offset_y = [offset, 4].min

  if grids_to_add_right > 0
    (1..grids_to_add_right).each do |right_offset|
      # right offset will be: [1], [1,2], [1,2,3], [1,2,3,4], [1,2,3], [1,2], [1]

      # should be x [1], [2,1], [3,2,1], [4,3,2,1], [4,3,2], [4,3], [4]
      right_grid_offset_x = [1] if offset == 1
      right_grid_offset_x = [2,1] if offset == 2
      right_grid_offset_x = [3,2,1] if offset == 3
      right_grid_offset_x = [4,3,2,1] if offset >= 4
      right_grid_offset_x = right_grid_offset_x[right_offset - 1]

      # should be y [0], [0,1], [0,1,2], [0,1,2,3], [1,2,3], [2,3], [3]
      right_grid_offset_y = right_offset - 1 if offset < 5
      right_grid_offset_y = right_offset if offset == 5
      right_grid_offset_y = right_offset + 1 if offset == 6
      right_grid_offset_y = right_offset + 2 if offset == 7

      # pp "right offset #{right_grid_offset_x}"
      new_grid = calculate_values(original_grid, offset, right_grid_offset_x + right_grid_offset_x * original_grid_width, right_grid_offset_y + right_grid_offset_y * original_grid_width)
      add(grid, new_grid)
    end
  end

  new_grid = calculate_values(original_grid, offset, grid_offset_x + grid_offset_x * original_grid_width, grid_offset_y + grid_offset_y * original_grid_width)
  add(grid, new_grid)
end


grid = []
(0..(rows.length - 1)).each do |y|
  grid[y] = []
  (0..(rows[y].length - 1)).each do |x|
    grid[y] << CaveCoord.new(x, y, rows[y][x])
  end
end

small_grid = Marshal.load(Marshal.dump(grid))
(1..8).each do |offset|
  copy_right_and_down(grid, small_grid, offset)
end

# second pass to link up all their neighbors
(0..(grid.length - 1)).each do |y|
  (0..(grid[y].length - 1)).each do |x|
    cave_coord = grid[y][x]
    if y != 0
      cave_coord.up = grid[y - 1][x]

      if x != 0
        cave_coord.up_left = grid[y - 1][x - 1]
      end

      if x != grid[y].length - 1
        cave_coord.up_right = grid[y - 1][x + 1]
      end
    end
    if y != grid.length - 1
      cave_coord.down = grid[y + 1][x]

      if x != 0
        cave_coord.down_left = grid[y + 1][x - 1]
      end

      if x != grid[y].length - 1
        cave_coord.down_right = grid[y + 1][x + 1]
      end
    end

    cave_coord.left = grid[y][x - 1] if x != 0
    cave_coord.right = grid[y][x + 1] if x != grid[y].length - 1

  end
end

# total_cells = 0
# grid.each do |row|
#   row.each do |coord|
#     total_cells += 1
#     print coord&.value
#   end
#   print "\n"
# end
# @never_called_for.each do |row|
#   pp row.filter{|i| i != nil}
# end
# pp "found #{total_cells} cells total when there should have been 2025"
# pp "added #{@added_cells}"
#

starting = Time.now
dijkstras_algorithm(grid, grid[0][0], grid[grid.length-1][grid[0].length - 1])
ending = Time.now
elapsed = ending - starting
pp elapsed

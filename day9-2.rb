file = File.read("day9_input.txt")

lines = file.split("\n")

rows = lines.map do |line|
  line.split("").map { |char| char.to_i }
end

class Cell
  attr_accessor :is_wall, :up, :down, :left, :right, :x, :y
  def initialize(x, y, is_wall)
    @is_wall = is_wall
    @up = nil
    @down = nil
    @left = nil
    @right = nil
    @x = x
    @y = y
  end

  def non_wall_neighbors
    # pp [@up, @down, @left, @right]
    # pp [@up, @down, @left, @right].compact
    # pp [@up, @down, @left, @right].compact.filter { |cell| !cell.is_wall }
    [@up, @down, @left, @right].compact.filter { |cell| !cell.is_wall }
  end

  def recursive_basin_search(already_searched = [])
    return 0 if is_wall
    return 0 if already_searched.include?([@x,@y])

    already_searched << [@x, @y]
    # pp already_searched

    1 + non_wall_neighbors.map { |cell| cell.recursive_basin_search(already_searched) }.sum
  end

  def inspect
    "is_wall: #{@is_wall}, x: #{@x}, y: #{@y}, up: #{@up&.is_wall}, down: #{@down&.is_wall}, left: #{@left&.is_wall}, right: #{@right&.is_wall}, "
  end
end

class Grid
  def initialize(rows)
    # first pass to populate all the cells
    @cells = []
    (0..(rows.length - 1)).each do |y|
      @cells[y] = []
      (0..(rows[y].length - 1)).each do |x|
        @cells[y] << Cell.new(x, y, rows[y][x] == 9)
      end
    end

    # second pass to link up all their neighbors
    (0..(@cells.length - 1)).each do |y|
      (0..(@cells[y].length - 1)).each do |x|
        cell      = @cells[y][x]
        cell.up   = y == 0 ? nil : @cells[y - 1][x]
        cell.down = y == @cells.length - 1 ? nil : @cells[y + 1][x]
        cell.left = x == 0 ? nil : @cells[y][x - 1]
        cell.right = x == @cells[y].length - 1 ? nil : @cells[y][x + 1]
      end
    end
  end

  def find_basin(x,y)
    basin_coords = []
    basin_size = @cells[y][x].recursive_basin_search(basin_coords)
    [basin_size, basin_coords.sort]
  end

  def find_all_basins
    all_possible_basins = @cells.flat_map do |row|
      row.map do |cell|
        find_basin(cell.x, cell.y)
      end
    end

    all_possible_basins.uniq.filter { |basin| basin[0] != 0 }
  end
end

grid = Grid.new(rows)

basins = grid.find_all_basins

areas = basins.map { |basin| basin[0] }
largest_three = areas.sort.reverse.take(3)
pp "#{largest_three} basins for total of #{largest_three.inject(:*)}"

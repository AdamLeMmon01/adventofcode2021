file = File.read("day11_input.txt")

lines = file.split("\n")

rows = lines.map do |line|
  line.split("").map { |char| char.to_i }
end

class Octopus
  attr_accessor :value, :up_left, :up, :up_right, :left, :right, :down_left, :down_right, :down, :x, :y
  def initialize(x, y, value)
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
    @flashed_during_step = {}
  end

  def step
    @value += 1
  end

  def get_flashed(step)
    @value += 1
    flash(step)
  end

  def flash(step)
    return 0 unless @value > 9
    return 0 if @flashed_during_step[step] == true
    @flashed_during_step[step] = true
    recursive_neighbor_flashes = [@up, @up_left, @up_right, @left, @right, @down_left, @down, @down_right].compact.map { |oct| oct.get_flashed(step) }.sum
    # pp "had #{recursive_neighbor_flashes} flashes from neighbors"
    1 + recursive_neighbor_flashes
  end

  def did_flash(step)
    @value = 0 if @flashed_during_step[step] == true
    @flashed_during_step[step] == true
  end
end

# first pass to populate all the grid
grid = []
(0..(rows.length - 1)).each do |y|
  grid[y] = []
  (0..(rows[y].length - 1)).each do |x|
    grid[y] << Octopus.new(x, y, rows[y][x])
  end
end

# second pass to link up all their neighbors
(0..(grid.length - 1)).each do |y|
  (0..(grid[y].length - 1)).each do |x|
    octopus      = grid[y][x]
    if y != 0
      octopus.up = grid[y - 1][x]

      if x != 0
        octopus.up_left = grid[y - 1][x - 1]
      end

      if x != grid[y].length - 1
        octopus.up_right = grid[y - 1][x + 1]
      end
    end
    if y != grid.length - 1
      octopus.down = grid[y + 1][x]

      if x != 0
        octopus.down_left = grid[y + 1][x - 1]
      end

      if x != grid[y].length - 1
        octopus.down_right = grid[y + 1][x + 1]
      end
    end

    octopus.left = grid[y][x - 1] if x != 0
    octopus.right = grid[y][x + 1] if x != grid[y].length - 1

  end
end

def all_octopi(grid)
  grid.flat_map do |row|
    row.map do |octopus|
      octopus
    end
  end
end

all = all_octopi(grid)
total_flashes = 0
(1..1000).each do |step|
  all.each(&:step)
  prev_flashes = total_flashes
  all.each do |octopus|
    total_flashes += octopus.flash(step)
  end
  pp "all flashed during #{step}" if !(all.map do |octopus|
    octopus.did_flash(step)
  end.any? { |did_flash| did_flash == false})
  # pp "during step #{step} there were #{total_flashes - prev_flashes} flashes"
  #
  # grid.each do |row|
  #   row.each do |oct|
  #     print oct.value
  #   end
  #   print "\n"
  # end
end

pp "total flashes #{total_flashes}"

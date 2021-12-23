require "pqueue"

file = File.read("day23_input.txt")

@spaces = {}
@amphipods = []

class Amphipod
  attr_accessor :x, :y
  attr_reader :energy_used
  def initialize(x,y, energy_used = 0)
    @x = x
    @y = y
    @energy_used = energy_used
    @in_hallway = y == 1
  end
  def in_destination
    destinations.include?([x, y])
  end
  def copy
    nil
  end
  def energy_multiplier
    0
  end
  def destinations
    []
  end
  def move(path)
    @energy_used += (path.length - 1) * energy_multiplier
    @x = path.last.x
    @y = path.last.y
    @in_destination = destinations.include?([x, y])
    @in_hallway = !@in_destination
  end

  def paths_home(spaces, amphipods)
    path_home = []
    front_occupant = spaces[destinations.first].occupant(amphipods)
    back_occupant = spaces[destinations.last].occupant(amphipods)
    return if back_occupant == self
    if back_occupant.nil?
      path_home << spaces[[@x, @y]].can_reach?(destinations.last[0], destinations.last[1], [], amphipods)
    elsif back_occupant.label == label
      if front_occupant.nil?
        path_home << spaces[[@x, @y]].can_reach?(destinations.first[0], destinations.first[1], [], amphipods)
      end
    end
    path_home.compact.first
  end

  def all_possible_destinations(spaces, amphipods)
    possible_destinations = []

    front_occupant = spaces[destinations.first].occupant(amphipods)
    back_occupant = spaces[destinations.last].occupant(amphipods)

    if !front_occupant.nil? && !back_occupant.nil? && front_occupant.label == label && back_occupant.label == label
      return [] # our destinations are reached, skip us from now on.
    end

    path_home = paths_home(spaces, amphipods)
    return [path_home] if !path_home.nil?

    spaces.each do |_location, space|
      next if space.occupied?(amphipods)
      current_space = spaces[[@x, @y]]
      next if destinations[1] == [current_space.x, current_space.y]
      next if current_space == space
      next if space.doorway?
      if @in_hallway
        next if !destinations.include?([space.x, space.y])
      else
        next if space.y != 1
      end

      if destinations.first == [space.x, space.y]
        back_occupant = spaces[destinations.last].occupant(amphipods)
        next if back_occupant.nil?
        next unless back_occupant.label == self.label
      end
      possible_destinations << current_space.can_reach?(space.x, space.y, [], amphipods)
    end
    possible_destinations.compact
  end
  def to_s
    "Amphipod #{@x},#{@y} energy: #{@energy_used}"
  end
  def inspect
    "Amphipod #{@x},#{@y} energy: #{@energy_used}"
  end
  def label
    "!"
  end
  def <=>(other)
    0 if other.nil?
    label == other.label && @x == other.x && @y == other.y ? 1:0
  end
  def ==(other)
    label == other.label && @x == other.x && @y == other.y
  end
end
class A < Amphipod
  def energy_multiplier
    1
  end
  def destinations
    [[3,2], [3,3]]
  end
  def label
    "A"
  end
  def copy
    A.new(@x, @y, @energy_used)
  end
end
class B < Amphipod
  def energy_multiplier
    10
  end
  def destinations
    [[5,2], [5,3]]
  end
  def label
    "B"
  end
  def copy
    B.new(@x, @y, @energy_used)
  end
end
class C < Amphipod
  def energy_multiplier
    100
  end
  def destinations
    [[7,2], [7,3]]
  end
  def label
    "C"
  end
  def copy
    C.new(@x, @y, @energy_used)
  end
end
class D < Amphipod
  def energy_multiplier
    1000
  end
  def destinations
    [[9,2], [9,3]]
  end
  def label
    "D"
  end
  def copy
    D.new(@x, @y, @energy_used)
  end
end

class Space
  attr_accessor :x, :y
  def initialize(x,y)
    @x = x
    @y = y
    @neighbors = []
  end
  def occupied?(amphipods)
    amphipods.each do |amphipod|
      return true if amphipod.x == @x && amphipod.y == @y
    end
    false
  end
  def occupant(amphipods)
    amphipods.each do |amphipod|
      return amphipod if amphipod.x == @x && amphipod.y == @y
    end
    nil
  end
  def link_neighbors(all_possible_neighbors)
    all_possible_neighbors.each do |possible_neighbor|
      if (possible_neighbor.y - @y).abs + (possible_neighbor.x - @x).abs == 1
        @neighbors << possible_neighbor
      end
    end
  end
  def can_reach?(x,y, neighbors_tried, amphipods)
    return neighbors_tried + [self] if @x == x && @y == y
    can_reach = nil
    (@neighbors - neighbors_tried).each do |neighbor|
      next if neighbor.occupied?(amphipods)
      can_reach ||= neighbor.can_reach?(x,y, neighbors_tried + [self], amphipods)
    end
    can_reach
  end
  def doorway?
    [[3,1],[5,1],[7,1],[9,1]].include?([@x, @y])
  end
  def to_s
    "Space: #{@x},#{@y}"
  end
  def inspect
    "Space: #{@x},#{@y}"
  end
  def label
    "."
  end
end

class Wall < Space
  def occupied?(amphipods)
    true
  end
  def label
    "#"
  end
end

y = 0
file.split("\n").each do |line|
  x = 0
  line.split("").each do |char|
    case char
    when "#"
      @spaces[[x,y]] = Wall.new(x,y)
    when "."
      @spaces[[x,y]] = Space.new(x,y)
    when "A"
      @amphipods << A.new(x,y)
      @spaces[[x,y]] = Space.new(x,y)
    when "B"
      @amphipods << B.new(x,y)
      @spaces[[x,y]] = Space.new(x,y)
    when "C"
      @amphipods << C.new(x,y)
      @spaces[[x,y]] = Space.new(x,y)
    when "D"
      @amphipods << D.new(x,y)
      @spaces[[x,y]] = Space.new(x,y)
    else
      # no-op
    end
    x += 1
  end
  y += 1
end

@spaces.each do |location, space|
  space.link_neighbors(@spaces.values)
end

#@amphipods[0].all_possible_destinations(@spaces, @amphipods)
def print_current_state(amphipods, spaces)
  result = ""
  (0..4).each do |y|
    (0..12).each do |x|
      amphipod = amphipods.filter { |a| a.x == x && a.y == y }.first
      if amphipod.nil?
        if !spaces[[x,y]].nil?
          result += spaces[[x,y]].label
        else
          result += " "
        end
      else
        result += amphipod.label
      end
    end
    result += "\n"
  end
  result += "\n"
  result
end

@tried_variations = {}
@smallest_energy = 1000000
@times_processed = 1
@queue = PQueue.new { |a, b| a.min_cost < b.min_cost }

def get_all_paths(spaces, depth = 0)
  amphipods = @queue.pop
  energy_used_so_far = amphipods.sum { |a| a.energy_used }
  return if @smallest_energy <= energy_used_so_far
  return if depth > 20
  total_moves_available_from_here = 0
  available_moves = []
  amphipods.each do |amphipod|
    amphipod.all_possible_destinations(spaces, amphipods).each do |move|
      total_moves_available_from_here += 1
      available_moves << move
    end
  end
  # pp "currently available moves #{total_moves_available_from_here}"
  # pp available_moves
  # print_current_state(amphipods, spaces)
  if @tried_variations.include?(amphipods.sort)
    if(energy_used_so_far < @tried_variations[amphipods.sort])
      @tried_variations[amphipods.sort] = energy_used_so_far
    end
    return [@tried_variations[amphipods.sort]]
  end

  @times_processed += 1

  # pp "energy_used_so_far #{energy_used_so_far}"
  if @times_processed % 1000 == 0
    # pp "times processed: #{@times_processed}"
    # pp "currently available moves #{total_moves_available_from_here}"
    # pp available_moves
    # pp "depth #{depth}"
    # print_current_state(amphipods, spaces)
    # pp "current energy #{energy_used_so_far}"
    # pp "queue length: #{@queue.length}"
    # pp "energy_used_so_far #{energy_used_so_far}"
    # pp "tried variations"
    # pp @tried_variations
  end

  successful_variations_so_far = 0
  @tried_variations.each do |variation, energy_used|
    success = variation.all? { |a| a.in_destination }
    if success
      successful_variations_so_far += 1
      if energy_used < @smallest_energy
        @smallest_energy = energy_used
        pp "smallest energy so far: #{@smallest_energy} with #{successful_variations_so_far} successful variations after #{@times_processed} processes"
      end
    end
  end

  @tried_variations[amphipods.sort] = energy_used_so_far
  return if total_moves_available_from_here == 0

  # print_current_state(amphipods, spaces)

  # amphipods.each do |amphipod|
  amphipods.sort_by{ |a| a.energy_multiplier }.reverse_each do |amphipod|
    amphipod.all_possible_destinations(spaces, amphipods).each do |move|
      # pp "doing a move at depth #{depth}"
      # pp "#{amphipod.label} at #{amphipod.x},#{amphipod.y} having used #{amphipod.energy_used} has new possible destination: #{move}"
      copy = amphipod.copy
      list_copy = copy_amphipod_list(amphipods, amphipod, copy)
      copy.move(move)
      @queue.push(list_copy)
    end
  end
end

def copy_amphipod_list(amphipods,to_remove, to_add)
  amphipods - [to_remove] + [to_add]
end

print_current_state(@amphipods, @spaces)

class State
  attr_accessor :amphipods, :energy, :depth

  def initialize(amphipods, energy, depth)
    @amphipods = amphipods
    @energy = energy
    @depth = depth
  end

  def possible_moves(spaces)
    next_states = []

    @amphipods.sort_by{ |a| a.energy_multiplier }.reverse_each do |amphipod|
      amphipod.all_possible_destinations(spaces, @amphipods).each do |move|
        copy = amphipod.copy
        list_copy = copy_amphipod_list(@amphipods, amphipod, copy)
        previous_energy = copy.energy_used
        copy.move(move)
        consumption = copy.energy_used - previous_energy
        next_states << State.new(list_copy, @energy + consumption, depth + 1)
      end
    end
    next_states
  end
  def finish?
    amphipods.all? { |a| a.in_destination }
  end
  def min_cost
    @min_cost ||= energy + amphipods.sum { |a| a.energy_multiplier * (a.x - a.destinations.first[0]).abs }
  end
end

@queue.push(State.new(@amphipods, 0, 0))
visited = {}
last_time = Time.now
while @queue.length > 0
  # get_all_paths(@spaces)
  first = @queue.pop
  break unless first
  next if visited[first.amphipods]
  visited[first.amphipods] = true
  if first.finish?
      puts first.energy
      break
  end
  if Time.now > last_time + 1.0
      p [visited.length, @queue.size, first.energy, first.min_cost]
      last_time = Time.now
  end
  first.possible_moves(@spaces).each { |s| @queue.push(s) }
end
pp @tried_variations.count
@tried_variations.each do |variation, energy_used|
  success = variation.all? { |a| a.in_destination }
  pp energy_used if success
end
pp "times processed: #{@times_processed}"


pp "18900 was too high"
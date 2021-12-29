require "pqueue"
require "set"

file = File.read("day23_input.txt")


# class Amphipod
#   attr_reader :x, :y, :energy_used
#   def initialize(x,y, energy_used)
#     @x = x
#     @y = y
#     @energy_used = energy_used
#   end
#   def in_destination
#     @is_finalized || destinations.include?([x, y])
#   end
#   def copy
#     nil
#   end
#   def energy_multiplier
#     0
#   end
#   def destinations
#     []
#   end
#   def move(path)
#     energy_to_move = (path.length - 1) * energy_multiplier
#     # it's not getting a good path. It's saying my position is going grom 9,3 to 5,3 in one step.
#     # pp "move to #{path} path_length #{path.length} using energy #{energy_to_move} and energ_multiplier #{energy_multiplier}"
#     @energy_used += energy_to_move
#     @x = path.last.x
#     @y = path.last.y
#     @is_finalized = in_destination
#     @in_hallway = !@is_finalized
#   end
#
#   def paths_home(spaces, amphipods, occupied)
#     path_home = []
#     front_occupant = occupied[spaces[destinations.first]]
#     back_occupant = occupied[spaces[destinations.last]]
#     return if back_occupant == self
#     if back_occupant.nil?
#       path_home << spaces[[@x, @y]].can_reach?(destinations.last[0], destinations.last[1], [], amphipods, occupied)
#     elsif back_occupant.label == label
#       if front_occupant.nil?
#         path_home << spaces[[@x, @y]].can_reach?(destinations.first[0], destinations.first[1], [], amphipods, occupied)
#       end
#     end
#     path_home.compact.first
#   end
#
#   def all_possible_destinations(spaces, amphipods, occupied)
#     if @is_finalized
#       # pp "was finalized"
#       return []
#     else
#       if destinations.include?([@x, @y])
#         destinations_contain_invalid = false
#         destinations.each do |dest|
#           occupant = occupied[dest]
#           if !occupant.nil?
#             if occupant.label != label
#               destinations_contain_invalid = true
#               break
#             end
#           end
#         end
#
#         if !destinations_contain_invalid
#           # lock yourself in if we're already correct and nothing incorrect is in our destination
#           @is_finalized = true
#           # pp "locking in letter that is already in right spot"
#           return []
#         end
#       end
#     end
#
#     if @in_hallway
#       path_home = paths_home(spaces, amphipods, occupied)
#       if !path_home.nil?
#         # pp "path home had length #{path_home.length} which should never be 1"
#         return [path_home]
#       end
#     end
#
#     #we must still be in our starting location, so only consider hallway options.
#
#     possible_destinations = []
#
#     spaces.each do |_location, space|
#       next if space.y != 1
#       next if space.doorway?
#       next if occupied.include?([space.x, space.y])
#       possible_destination = spaces[[@x, @y]].can_reach?(space.x, space.y, [], amphipods, occupied)
#       # pp possible_destinations
#
#       if !possible_destination.nil?
#         # pp "possible destination path length #{possible_destinations.length} should never be less than three"
#         possible_destinations << possible_destination
#       end
#     end
#     # pp "somehow got to the end of the loop"
#     possible_destinations
#   end
#   def to_s
#     "Amphipod #{@x},#{@y} energy: #{@energy_used}"
#   end
#   def inspect
#     "Amphipod #{@x},#{@y} energy: #{@energy_used}"
#   end
#   def label
#     "!"
#   end
#   def <=>(other)
#     0 if other.nil?
#     label == other.label && @x == other.x && @y == other.y ? 1:0
#   end
#   def ==(other)
#     label == other.label && @x == other.x && @y == other.y
#   end
# end
# class A < Amphipod
#   def energy_multiplier
#     1
#   end
#   def destinations
#     [[3,2], [3,3]]
#   end
#   def label
#     "A"
#   end
#   def copy
#     A.new(@x, @y, @energy_used)
#   end
# end
# class B < Amphipod
#   def energy_multiplier
#     10
#   end
#   def destinations
#     [[5,2], [5,3]]
#   end
#   def label
#     "B"
#   end
#   def copy
#     B.new(@x, @y, @energy_used)
#   end
# end
# class C < Amphipod
#   def energy_multiplier
#     100
#   end
#   def destinations
#     [[7,2], [7,3]]
#   end
#   def label
#     "C"
#   end
#   def copy
#     C.new(@x, @y, @energy_used)
#   end
# end
# class D < Amphipod
#   def energy_multiplier
#     1000
#   end
#   def destinations
#     [[9,2], [9,3]]
#   end
#   def label
#     "D"
#   end
#   def copy
#     D.new(@x, @y, @energy_used)
#   end
# end
#
# class Space
#   attr_accessor :x, :y
#   def initialize(x,y)
#     @x = x
#     @y = y
#     @neighbors = []
#   end
#   def occupied?(amphipods)
#     # $occupied.include?([@x, @y])
#     amphipods.each do |amphipod|
#       return true if amphipod.x == @x && amphipod.y == @y
#     end
#     false
#   end
#   def occupant(amphipods)
#     amphipods.each do |amphipod|
#       return amphipod if amphipod.x == @x && amphipod.y == @y
#     end
#     nil
#   end
#   def link_neighbors(all_possible_neighbors)
#     all_possible_neighbors.each do |possible_neighbor|
#       if (possible_neighbor.y - @y).abs + (possible_neighbor.x - @x).abs == 1
#         next if possible_neighbor.class.to_s == "Wall"
#         @neighbors << possible_neighbor
#       end
#     end
#   end
#   def can_reach?(x,y, neighbors_tried, amphipods, occupied)
#     return neighbors_tried + [self] if @x == x && @y == y
#     can_reach = nil
#     (@neighbors - neighbors_tried).each do |neighbor|
#       # pp [neighbor.x, neighbor.y]
#       next if occupied.include?([neighbor.x, neighbor.y])
#       can_reach ||= neighbor.can_reach?(x,y, neighbors_tried + [self], amphipods, occupied)
#       break if can_reach
#     end
#     can_reach
#   end
#   def doorway?
#     @doorway ||= [[3,1],[5,1],[7,1],[9,1]].include?([@x, @y])
#   end
#   def to_s
#     "Space: #{@x},#{@y}"
#   end
#   def inspect
#     "Space: #{@x},#{@y}"
#   end
#   def label
#     "."
#   end
# end
#
# class Wall < Space
#   def occupied?(amphipods)
#     true
#   end
#   def label
#     "#"
#   end
# end

# y = 0
# file.split("\n").each do |line|
#   x = 0
#   line.split("").each do |char|
#     case char
#     when "#"
#       # @spaces[[x,y]] = Wall.new(x,y)
#     when "."
#       @spaces[[x,y]] = Space.new(x,y)
#     when "A"
#       @amphipods << A.new(x,y)
#       @spaces[[x,y]] = Space.new(x,y)
#     when "B"
#       @amphipods << B.new(x,y)
#       @spaces[[x,y]] = Space.new(x,y)
#     when "C"
#       @amphipods << C.new(x,y)
#       @spaces[[x,y]] = Space.new(x,y)
#     when "D"
#       @amphipods << D.new(x,y)
#       @spaces[[x,y]] = Space.new(x,y)
#     else
#       # no-op
#     end
#     x += 1
#   end
#   y += 1
# end

# @spaces.each do |location, space|
#   space.link_neighbors(@spaces.values)
# end

#@amphipods[0].all_possible_destinations(@spaces, @amphipods)
# def print_current_state(amphipods, spaces)
#   result = ""
#   (0..4).each do |y|
#     (0..12).each do |x|
#       amphipod = amphipods.filter { |a| a.x == x && a.y == y }.first
#       if amphipod.nil?
#         if !spaces[[x,y]].nil?
#           result += spaces[[x,y]].label
#         else
#           result += " "
#         end
#       else
#         result += amphipod.label
#       end
#     end
#     result += "\n"
#   end
#   result += "\n"
#   result
# end

# @tried_variations = {}
# @smallest_energy = 1000000
# @times_processed = 1

# def get_all_paths(spaces, depth = 0)
#   amphipods = @queue.pop
#   energy_used_so_far = amphipods.sum { |a| a.energy_used }
#   return if @smallest_energy <= energy_used_so_far
#   return if depth > 20
#   total_moves_available_from_here = 0
#   available_moves = []
#   amphipods.each do |amphipod|
#     amphipod.all_possible_destinations(spaces, amphipods).each do |move|
#       total_moves_available_from_here += 1
#       available_moves << move
#     end
#   end
#   # pp "currently available moves #{total_moves_available_from_here}"
#   # pp available_moves
#   # print_current_state(amphipods, spaces)
#   if @tried_variations.include?(amphipods.sort)
#     if(energy_used_so_far < @tried_variations[amphipods.sort])
#       @tried_variations[amphipods.sort] = energy_used_so_far
#     end
#     return [@tried_variations[amphipods.sort]]
#   end
#
#   @times_processed += 1
#
#   # pp "energy_used_so_far #{energy_used_so_far}"
#   if @times_processed % 1000 == 0
#     # pp "times processed: #{@times_processed}"
#     # pp "currently available moves #{total_moves_available_from_here}"
#     # pp available_moves
#     # pp "depth #{depth}"
#     # print_current_state(amphipods, spaces)
#     # pp "current energy #{energy_used_so_far}"
#     # pp "queue length: #{@queue.length}"
#     # pp "energy_used_so_far #{energy_used_so_far}"
#     # pp "tried variations"
#     # pp @tried_variations
#   end
#
#   successful_variations_so_far = 0
#   @tried_variations.each do |variation, energy_used|
#     success = variation.all? { |a| a.in_destination }
#     if success
#       successful_variations_so_far += 1
#       if energy_used < @smallest_energy
#         @smallest_energy = energy_used
#         pp "smallest energy so far: #{@smallest_energy} with #{successful_variations_so_far} successful variations after #{@times_processed} processes"
#       end
#     end
#   end
#
#   @tried_variations[amphipods.sort] = energy_used_so_far
#   return if total_moves_available_from_here == 0
#
#   # print_current_state(amphipods, spaces)
#
#   # amphipods.each do |amphipod|
#   amphipods.sort_by{ |a| a.energy_multiplier }.reverse_each do |amphipod|
#     amphipod.all_possible_destinations(spaces, amphipods).each do |move|
#       # pp "doing a move at depth #{depth}"
#       # pp "#{amphipod.label} at #{amphipod.x},#{amphipod.y} having used #{amphipod.energy_used} has new possible destination: #{move}"
#       copy = amphipod.copy
#       list_copy = copy_amphipod_list(amphipods, amphipod, copy)
#       copy.move(move)
#       @queue.push(list_copy)
#     end
#   end
# end

# def copy_amphipod_list(amphipods, i, to_add)
#   copy = amphipods.dup
#   copy[i] = to_add
#   copy
# end

# print_current_state(@amphipods, @spaces)

# class State
#   attr_accessor :amphipods, :energy, :depth, :occupied
#
#   def initialize(amphipods, energy, depth)
#     @amphipods = amphipods
#     @energy = energy
#     @depth = depth
#     @occupied = {}
#     @amphipods.each do |a|
#       @occupied[[a.x, a.y]] = a
#     end
#   end
#
#   def possible_moves(spaces)
#     next_states = []
#
#     @amphipods.each_with_index do |amphipod, i|
#       amphipod.all_possible_destinations(spaces, @amphipods, @occupied).each do |move|
#         copy = amphipod.copy
#         list_copy = copy_amphipod_list(@amphipods, i, copy)
#         previous_energy = copy.energy_used
#         # pp "#{copy.x} #{copy.y}"
#         copy.move(move)
#         consumption = copy.energy_used - previous_energy
#
#         # pp "move#{move}"
#         # pp "consumption #{consumption}"
#         next_states << State.new(list_copy, @energy + consumption, depth + 1)
#       end
#     end
#     next_states
#   end
#   def finish?
#     @amphipods.all? { |a| a.in_destination }
#   end
#   def min_cost
#     @min_cost ||= energy + amphipods.sum { |a| a.energy_multiplier * (a.x - a.destinations.first[0]).abs }
#   end
# end
# @queue = PQueue.new { |a, b| a.min_cost < b.min_cost }
#
# @queue.push(State.new(@amphipods, 0, 0))
# visited = {}
# last_time = Time.now
# first = nil
# while @queue.length > 0
#   first = @queue.pop
#   break unless first
#   next if visited[first.amphipods]
#   visited[first.amphipods] = true
#   if first.finish?
#       puts "lowest energy to solve: #{first.energy}"
#       break
#   end
#
#   # TODO: It's not working. I don't know why, but it's getting stuck cycling and never progressing very early on. It's depth is going crazy!
#
#   # p [visited.length, @queue.size, first.energy, first.min_cost, first.depth]
#   # p @queue.to_a
#   # exit if @queue.length > 100
#   # pp $occupied
#   if Time.now > last_time + 1.0
#       p [visited.length, @queue.size, first.energy, first.min_cost, first.depth]
#       # pp print_current_state(first.amphipods, @spaces)
#       last_time = Time.now
#   end
#   first.possible_moves(@spaces).each { |s| @queue.push(s) }
# end
#
# pp "ended loop"
# pp first.energy
# # pp @tried_variations.count
# # @tried_variations.each do |variation, energy_used|
# #   success = variation.all? { |a| a.in_destination }
# #   pp energy_used if success
# # end
# # pp "times processed: #{@times_processed}"
#
# #13565 is too low
# pp "18900 was too high"
#


$possible_y = [1,2,3]
$possible_x_1 = [1,2,4,6,8,10,11].to_set
$possible_x_2 = [3,5,7,9]
$destination_x = { "A" => 3, "B" => 5, "C" => 7, "D" => 9 }
$letter_weight = { "A" => 1, "B" => 10, "C" => 100, "D" => 1000 }

class Amphipod
  attr_accessor :x, :y, :label
  def initialize(x,y,label)
    @x = x
    @y = y
    if !["A","B","C","D"].include?(label)
      pp "got label #{label}"
      exit
    end
    @label = label
  end
end

class Node
  attr_accessor :visited, :tentative_distance
  attr_reader :amphipods
  def initialize(hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11, dest_3_1, dest_3_2, dest_5_1, dest_5_2, dest_7_1, dest_7_2, dest_9_1, dest_9_2)
    @amphipods = {}
    @visited = false
    @tentative_distance = 1_000_000
    @amphipods[[1,1]] = Amphipod.new(1,1, hall_1) if hall_1 != "."
    @amphipods[[2,1]] = Amphipod.new(2,1, hall_2) if hall_2 != "."
    @amphipods[[4,1]] = Amphipod.new(4,1, hall_4) if hall_4 != "."
    @amphipods[[6,1]] = Amphipod.new(6,1, hall_6) if hall_6 != "."
    @amphipods[[8,1]] = Amphipod.new(8,1, hall_8) if hall_8 != "."
    @amphipods[[10,1]] = Amphipod.new(10,1, hall_10) if hall_10 != "."
    @amphipods[[11,1]] = Amphipod.new(11,1, hall_11) if hall_11 != "."
    @amphipods[[3,2]] = Amphipod.new(3,2, dest_3_1) if dest_3_1 != "."
    @amphipods[[3,3]] = Amphipod.new(3,3, dest_3_2) if dest_3_2 != "."
    @amphipods[[5,2]] = Amphipod.new(5,2, dest_5_1) if dest_5_1 != "."
    @amphipods[[5,3]] = Amphipod.new(5,3, dest_5_2) if dest_5_2 != "."
    @amphipods[[7,2]] = Amphipod.new(7,2, dest_7_1) if dest_7_1 != "."
    @amphipods[[7,3]] = Amphipod.new(7,3, dest_7_2) if dest_7_2 != "."
    @amphipods[[9,2]] = Amphipod.new(9,2, dest_9_1) if dest_9_1 != "."
    @amphipods[[9,3]] = Amphipod.new(9,3, dest_9_2) if dest_9_2 != "."
  end

  def neighbors
    neighbors = []
    dest_moves = get_destination_moves

    hallway_moves = get_hallway_moves
    all_moves = (dest_moves + hallway_moves)
    # all_moves = (hallway_moves)
    # pp all_moves.count
    # pp all_moves
    all_moves.each do |move|
      moving_amphipod = move[0]

      @amphipods.delete([moving_amphipod.x, moving_amphipod.y])
      @amphipods[move[1]] = moving_amphipod

      new_placement = [
        @amphipods[[1, 1]]&.label || ".",
        @amphipods[[2, 1]]&.label || ".",
        @amphipods[[4, 1]]&.label || ".",
        @amphipods[[6, 1]]&.label || ".",
        @amphipods[[8, 1]]&.label || ".",
        @amphipods[[10, 1]]&.label || ".",
        @amphipods[[11, 1]]&.label || ".",
        @amphipods[[3, 2]]&.label || ".",
        @amphipods[[3, 3]]&.label || ".",
        @amphipods[[5, 2]]&.label || ".",
        @amphipods[[5, 3]]&.label || ".",
        @amphipods[[7, 2]]&.label || ".",
        @amphipods[[7, 3]]&.label || ".",
        @amphipods[[9, 2]]&.label || ".",
        @amphipods[[9, 3]]&.label || "."]
      # pp new_placement
      neighbors << $trie.find_or_create_node(new_placement)
      @amphipods[[moving_amphipod.x, moving_amphipod.y]] = moving_amphipod
      @amphipods.delete(move[1])
    end
    neighbors
  end

  def get_destination_moves
    destination_moves = []
    far_left = @amphipods[[2,1]] || @amphipods[[1,1]]
    dest_move = get_destination_move(far_left)
    destination_moves << dest_move if !dest_move.nil?
    mid_left = @amphipods[[4,1]]
    dest_move = get_destination_move(mid_left)
    destination_moves << dest_move if !dest_move.nil?
    middle = @amphipods[[6,1]]
    dest_move = get_destination_move(middle)
    destination_moves << dest_move if !dest_move.nil?
    mid_right = @amphipods[[8,1]]
    dest_move = get_destination_move(mid_right)
    destination_moves << dest_move if !dest_move.nil?
    far_right = @amphipods[[10,1]] || @amphipods[[11,1]]
    # pp far_right
    dest_move = get_destination_move(far_right)
    destination_moves << dest_move if !dest_move.nil?
    destination_moves
  end

  def get_destination_move(amphipod)
    return nil if amphipod.nil?
    destination = get_destination(amphipod)
    # pp destination
    return nil if destination.nil?
    if hallway_is_clear(amphipod.x, destination[0])
      # pp "hallway is clear"
      return [amphipod, destination]
    end
  end

  def get_destination(amphipod)
    dest_x = $destination_x[amphipod.label]

    dest_y = 3 # TODO: this will need to be more for part 2

    while (dest_y > 1)

      current_occupant = @amphipods[[dest_x, dest_y]]
      if current_occupant.nil?
        break
      elsif current_occupant.label != amphipod.label
        return nil
      end

      dest_y -= 1
    end

    if dest_y == 1
      return nil
    end

    [dest_x, dest_y]
  end

  def hallway_is_clear(start_coord, end_coord)
    # pp "checking hallway for #{start_coord} to #{end_coord}"
    (([start_coord, end_coord].min + 1)..([start_coord, end_coord].max - 1)).each do |x|
      if $possible_x_1.include?(x)
        # pp "checking #{x}"
        if !@amphipods[[x, 1]].nil?
          # pp "#{x} was filled"
          # pp @amphipods[[x, 1]]
          return false
        end
      end
    end
    true
  end

  def get_hallway_moves
    hallway_moves = []
    possible_destinations = $possible_x_1.filter do |x|
      @amphipods[[x,1]].nil?
    end.map do |x|
      [x,1]
    end
    $possible_x_2.each do |x|
      highest_occupant = find_highest_occupant(x)
      next if highest_occupant.nil?
      # pp "highest occupant in #{x} is #{highest_occupant.label}"
      # TODO: bail early if all occupants in this column are in the right place
      if((@amphipods[[x,2]].nil? || $destination_x[@amphipods[[x,2]].label] == x) &&
        (@amphipods[[x,3]].nil? || $destination_x[@amphipods[[x,3]].label] == x)) # TODO: for part 2, go deeper
        next
      end
      possible_destinations.each do |dest|
        if hallway_is_clear(x, dest[0])
          hallway_moves << [highest_occupant, dest]
        end
      end
    end
    hallway_moves
  end

  def find_highest_occupant(x)
    highest_occupant = @amphipods[[x,2]] || @amphipods[[x,3]] # TODO: dig deeper for part 2
    return nil if highest_occupant.nil?
    return nil if highest_occupant.label == $destination_x[x]
    highest_occupant
  end

  def self.generate_all
    nodes = []
    [".", "A", "B", "C", "D"].each do |hall_1|
      # pp "#{hall_1}:#{count}"
      [".", "A", "B", "C", "D"].each do |hall_2|
        # pp "#{hall_1}#{hall_2}:#{count}"
        [".", "A", "B", "C", "D"].each do |hall_4|
          break if hall_4 != "." && [hall_1, hall_2].count(hall_4) >= 2
          # pp "#{hall_1}#{hall_2}#{hall_4}:#{count}"
          [".", "A", "B", "C", "D"].each do |hall_6|
            break if hall_6 != "." && [hall_1, hall_2, hall_4].count(hall_6) >= 2
            # pp "#{hall_1}#{hall_2}#{hall_4}#{hall_6}:#{count}"
            # exit if count > 0
            [".", "A", "B", "C", "D"].each do |hall_8|
              break if hall_8 != "." && [hall_1, hall_2, hall_4, hall_6].count(hall_8) >= 2
              [".", "A", "B", "C", "D"].each do |hall_10|
                break if hall_10 != "." && [hall_1, hall_2, hall_4, hall_6, hall_8].count(hall_10) >= 2
                [".", "A", "B", "C", "D"].each do |hall_11|
                  break if hall_11 != "." && [hall_1, hall_2, hall_4, hall_6, hall_8, hall_10].count(hall_11) >= 2
                  [".", "A", "B", "C", "D"].each do |dest_3_1|
                    break if dest_3_1 != "." && [hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11].count(dest_3_1) >= 2
                    next if [hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11, dest_3_1].count(".") > 7
                    [".", "A", "B", "C", "D"].each do |dest_3_2|
                      break if dest_3_2 != "." && [hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11, dest_3_1].count(dest_3_2) >= 2
                      next if [hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11, dest_3_1, dest_3_2].count(".") > 7
                      if dest_3_1 != "."
                        next if dest_3_2 == "." # can't have hanging dot
                      end
                      [".", "A", "B", "C", "D"].each do |dest_5_1|
                        if hall_1 == "." && hall_2 == "." &&hall_4 == "." &&hall_6 == "." &&hall_8 == "." &&hall_10 == "." &&hall_11 == "."
                        if dest_3_1 == "B" && dest_3_2 == "A" && dest_5_1 == "C"
                          pp "before checks in 51"
                        end
                        end
                        break if dest_5_1 != "." && [hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11, dest_3_1, dest_3_2].count(dest_5_1) >= 2
                        if hall_1 == "." && hall_2 == "." &&hall_4 == "." &&hall_6 == "." &&hall_8 == "." &&hall_10 == "." &&hall_11 == "."
                        if dest_3_1 == "B" && dest_3_2 == "A" && dest_5_1 == "C"
                          pp "middle checks in 51"
                        end
                        end
                        next if [hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11, dest_3_1, dest_3_2, dest_5_1].count(".") > 7
                        if hall_1 == "." && hall_2 == "." &&hall_4 == "." &&hall_6 == "." &&hall_8 == "." &&hall_10 == "." &&hall_11 == "."
                          if dest_3_1 == "B" && dest_3_2 == "A" && dest_5_1 == "C"
                          pp "after checks in 51"
                          end
                        end
                        [".", "A", "B", "C", "D"].each do |dest_5_2|
                          if hall_1 == "." && hall_2 == "." &&hall_4 == "." &&hall_6 == "." &&hall_8 == "." &&hall_10 == "." &&hall_11 == "."
                          if dest_3_1 == "B" && dest_3_2 == "A" && dest_5_1 == "C" && dest_5_2 == "D"
                            pp "before checks in 52"
                          end
                          end
                          break if dest_5_2 != "." && [hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11, dest_3_1, dest_3_2, dest_5_1].count(dest_5_2) >= 2
                          next if [hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11, dest_3_1, dest_3_2, dest_5_1, dest_5_2].count(".") > 7
                          if dest_5_1 != "."
                            next if dest_5_2 == "." # can't have hanging dot
                          end
                          if hall_1 == "." && hall_2 == "." &&hall_4 == "." &&hall_6 == "." &&hall_8 == "." &&hall_10 == "." &&hall_11 == "."
                          if dest_3_1 == "B" && dest_3_2 == "A" && dest_5_1 == "C" && dest_5_2 == "D"
                            pp "after checks in 52"
                          end
                          end
                          [".", "A", "B", "C", "D"].each do |dest_7_1|

                            if dest_7_1 == "A" || dest_7_1 == "B"
                              if hall_1 == "." && hall_2 == "." &&hall_4 == "." &&hall_6 == "." &&hall_8 == "." &&hall_10 == "." &&hall_11 == "."
                                if dest_3_1 == "B" && dest_3_2 == "A" && dest_5_1 == "C" && dest_5_2 == "D"
                                  pp "in the #{dest_7_1} slot before checks"
                                end
                              end
                            end
                            if hall_1 == "." && hall_2 == "." &&hall_4 == "." &&hall_6 == "." &&hall_8 == "." &&hall_10 == "." &&hall_11 == "."
                              if dest_3_1 == "B" && dest_3_2 == "A" && dest_5_1 == "C" && dest_5_2 == "D"
                              pp "before checks in 71"
                              end
                              end
                            break if dest_7_1 != "." && [hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11, dest_3_1, dest_3_2, dest_5_1, dest_5_2].count(dest_7_1) >= 2
                            if dest_7_1 == "A" || dest_7_1 == "B"
                              if hall_1 == "." && hall_2 == "." &&hall_4 == "." &&hall_6 == "." &&hall_8 == "." &&hall_10 == "." &&hall_11 == "."
                                if dest_3_1 == "B" && dest_3_2 == "A" && dest_5_1 == "C" && dest_5_2 == "D"
                                  pp "in the #{dest_7_1} slot after first check"
                                end
                              end
                            end
                            next if [hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11, dest_3_1, dest_3_2, dest_5_1, dest_5_2, dest_7_1].count(".") > 7
                            if dest_7_1 == "A" || dest_7_1 == "B"
                              if hall_1 == "." && hall_2 == "." &&hall_4 == "." &&hall_6 == "." &&hall_8 == "." &&hall_10 == "." &&hall_11 == "."
                                if dest_3_1 == "B" && dest_3_2 == "A" && dest_5_1 == "C" && dest_5_2 == "D"
                                  pp "in the #{dest_7_1} slot after 2 check" # I have A and B here, but they don't get to the check on line 595 - I only get C and D there
                                end
                              end
                            end
                            if hall_1 == "." && hall_2 == "." &&hall_4 == "." &&hall_6 == "." &&hall_8 == "." &&hall_10 == "." &&hall_11 == "."
                              if dest_3_1 == "B" && dest_3_2 == "A" && dest_5_1 == "C" && dest_5_2 == "D"
                              pp "after checks in 71"
                              end
                              end
                            [".", "A", "B", "C", "D"].each do |dest_7_2|

                              if hall_1 == "." && hall_2 == "." &&hall_4 == "." &&hall_6 == "." &&hall_8 == "." &&hall_10 == "." &&hall_11 == "."
                              if dest_3_1 == "B" && dest_3_2 == "A" && dest_5_1 == "C" && dest_5_2 == "D"
                                # pp "first 2 columns match"
                                if dest_7_2 == "C"
                                  pp "dest 72 is C and 71 is #{dest_7_1}"
                                end
                                # if dest_7_1 == "B"
                                #   pp "dest 71 is B"
                                #   if dest_7_2 == "C"
                                #     pp "dest 72 is C"
                                #   end
                                # end
                              end
                              end

                              break if dest_7_2 != "." && [hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11, dest_3_1, dest_3_2, dest_5_1, dest_5_2, dest_7_1].count(dest_7_2) >= 2
                              next if [hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11, dest_3_1, dest_3_2, dest_5_1, dest_5_2, dest_7_1, dest_7_2].count(".") > 7
                              if dest_7_1 != "."
                                next if dest_7_2 == "." # can't have hanging dot
                              end
                              if dest_3_1 == "B" && dest_3_2 == "A" && dest_5_1 == "C" && dest_5_2 == "D" && dest_7_1 == "B" && dest_7_2 == "C"
                                pp "first 3 columns match"
                              end
                              [".", "A", "B", "C", "D"].each do |dest_9_1|
                                break if dest_9_1 != "." && [hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11, dest_3_1, dest_3_2, dest_5_1, dest_5_2, dest_7_1, dest_7_2].count(dest_9_1) >= 2
                                next if [hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11, dest_3_1, dest_3_2, dest_5_1, dest_5_2, dest_7_1, dest_7_2, dest_9_1].count(".") > 7
                                [".", "A", "B", "C", "D"].each do |dest_9_2|
                                  break if dest_9_2 != "." && [hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11, dest_3_1, dest_3_2, dest_5_1, dest_5_2, dest_7_1, dest_7_2, dest_9_1].count(dest_9_2) >= 2
                                  next if [hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11, dest_3_1, dest_3_2, dest_5_1, dest_5_2, dest_7_1, dest_7_2, dest_9_1, dest_9_2].count(".") > 7
                                  if dest_9_1 != "."
                                    next if dest_9_2 == "." # can't have hanging dot
                                  end
                                  nodes << Node.new(hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11, dest_3_1, dest_3_2, dest_5_1, dest_5_2, dest_7_1, dest_7_2, dest_9_1, dest_9_2)
                                  # count += 1
                                  # if hall_1 == "." && hall_2 == "." &&hall_4 == "." &&hall_6 == "." &&hall_8 == "." &&hall_10 == "." &&hall_11 == "."
                                  #   pp "#############"
                                  #   pp "##{hall_1}#{hall_2}.#{hall_4}.#{hall_6}.#{hall_8}.#{hall_10}#{hall_11}#"
                                  #   pp "####{dest_3_1}##{dest_5_1}##{dest_7_1}##{dest_9_1}###"
                                  #   pp "  ##{dest_3_2}##{dest_5_2}##{dest_7_2}##{dest_9_2}#"
                                  #   pp "  #########"
                                  #   pp ""
                                  # end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    nodes
  end

  def self.generate_all_valid
    generate_all.filter{ |n| n.valid? }
  end

  def ==(other)
    @amphipods == other.amphipods
  end

  def -(other)
    my_diff = nil
    their_diff = nil
    moved_letter = nil
    # pp @amphipods
    # pp other.amphipods
    @amphipods.each do |k,v|
      if other.amphipods[k].nil? || other.amphipods[k].label != v.label
        my_diff = k
        # pp "line 796 #{v}"
        # pp "line 797 label #{v.label}"
        moved_letter ||= (v.label)
        # pp "moved letter #{moved_letter}"
        break
      end
    end
    other.amphipods.each do |k,v|
      if @amphipods[k].nil? || @amphipods[k].label != v.label
        their_diff = k
        # pp v
        moved_letter ||= v.label
        break
      end
    end
    if moved_letter.nil?
      return 0
    end
    # pp "moved letter #{moved_letter}"
    ((my_diff[0] - their_diff[0]).abs * $letter_weight[moved_letter]) + ((my_diff[1] - their_diff[1]).abs * $letter_weight[moved_letter])
  end
end

def dijkstras_algorithm(start_node, end_node)
  # nodes.each do |n|
  #   n.visited = false
  #   n.tentative_distance = 1_000_000
  # end
  end_node.tentative_distance = 1_000_000
  start_node.tentative_distance = 0
  @unvisited = []#PQueue.new { |a, b| a.tentative_distance < b.tentative_distance }
  current_node = start_node
  last_node = nil
  counter = 0
  last_time = Time.now
  started_at_time = Time.now
  while(!current_node.nil?)
    counter += 1
    # current_node = @unvisited.pop if current_node.visited
    # pp "neighborcount #{current_node.neighbors.filter{ |n| !n.visited }.count}"
    current_node.neighbors.filter{ |n| !n.visited }.each do |neighbor|
      is_new = neighbor.tentative_distance == 1_000_000
      # pp is_new ? "is new" : "already existed"
      # pp neighbor
      # pp current_node
      # pp neighbor - current_node
      neighbor_tentative_distance_through_me = current_node.tentative_distance + (neighbor - current_node)
      if neighbor_tentative_distance_through_me < neighbor.tentative_distance
        neighbor.tentative_distance = neighbor_tentative_distance_through_me
        # if !is_new
        #   pp "updated a neigbor's distance but now it's out of order in the queue"
        #   exit
        # end
        # @unvisited.delete(neighbor)
        # @unvisited.push(neighbor)
      end
      # @unvisited.push neighbor #if is_new
      @unvisited << neighbor if is_new
    end
    current_node.visited = true
    if end_node.visited
      pp "just visited end node"
      break
    end
    # pp last_node = current_node
    # exit
    # pp @unvisited.count
    if Time.now > last_time + 1.0
      # p [visited.length, @queue.size, first.energy, first.min_cost, first.depth]
      # pp print_current_state(first.amphipods, @spaces)
      pp "iterations: #{counter} unvisited count: #{@unvisited.length}, current_path: #{current_node.tentative_distance}"
      # pp current_node
      last_time = Time.now
    end
    # current_node = @unvisited.pop
    current_node = @unvisited.sort_by!(&:tentative_distance).delete_at(0)


  end
  ended_at_time = Time.now
  pp "took #{ended_at_time - started_at_time} seconds"
  pp "iterated #{counter} times"
  if !end_node.visited
    pp "did not find end node"
    # pp last_node
    return
  end
end

class Trie
  def initialize(label = ".")
    @children = {}
    @node = nil
    @label = "."
  end

  def find_or_create_node(all_positions, current_positions = nil)
    if current_positions.nil?
      current_positions = all_positions.dup
    end
    key = current_positions.delete_at(0)
    if current_positions.empty?
      @node ||= Node.new(*all_positions)
      return @node
    end
    child = @children[key] ||= Trie.new(key)
    child.find_or_create_node(all_positions, current_positions)
  end
end

$trie = Trie.new

# start_node = $trie.find_or_create_node([".",".",".",".",".",".",".","B","A","C","D","B","C","D","A"]) #12521
start_node = $trie.find_or_create_node([".",".",".",".",".",".",".","C","D","A","D","B","B","C","A"]) #18300
 # start_node = $trie.find_or_create_node(["A",".",".","B",".",".",".",".","B",".","A","C","C","D","D"])
end_node = $trie.find_or_create_node([".",".",".",".",".",".",".","A","A","B","B","C","C","D","D"])

# pp second_node - start_node

dijkstras_algorithm(start_node, end_node)

pp end_node.tentative_distance # should be 2 for dummy example

# nodes = Node.generate_all
# pp nodes.count

# start_node = nil
# end_node = nil
# nodes.each do |n|
#   if n == Node.new(".",".",".",".",".",".",".","B","A","C","D","B","C","D","A")
#     pp "found matching start node"
#     start_node = n
#   end
#   if n == Node.new(".",".",".",".",".",".",".","A","A","B","B","C","C","D","D")
#     pp "found matching end node"
#     start_node = n
#   end
# end
# should_be_start_node = Node.new(".",".",".",".",".",".",".","B","A","C","D","B","C","D","A")
# pp should_be_start_node
# pp nodes.first.amphipods
# pp should_be_start_node == nodes.first
# pp start_node
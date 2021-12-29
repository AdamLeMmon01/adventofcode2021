require "pqueue"
require "set"

file = File.read("day23_input.txt")

$possible_y = [1,2,3,4,5]
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
  def initialize(hall_1, hall_2, hall_4, hall_6, hall_8, hall_10, hall_11,
                 dest_3_1, dest_3_2, dest_3_3, dest_3_4,
                 dest_5_1, dest_5_2, dest_5_3, dest_5_4,
                 dest_7_1, dest_7_2, dest_7_3, dest_7_4,
                 dest_9_1, dest_9_2, dest_9_3, dest_9_4)
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
    @amphipods[[3,4]] = Amphipod.new(3,4, dest_3_3) if dest_3_3 != "."
    @amphipods[[3,5]] = Amphipod.new(3,5, dest_3_4) if dest_3_4 != "."
    @amphipods[[5,2]] = Amphipod.new(5,2, dest_5_1) if dest_5_1 != "."
    @amphipods[[5,3]] = Amphipod.new(5,3, dest_5_2) if dest_5_2 != "."
    @amphipods[[5,4]] = Amphipod.new(5,4, dest_5_3) if dest_5_3 != "."
    @amphipods[[5,5]] = Amphipod.new(5,5, dest_5_4) if dest_5_4 != "."
    @amphipods[[7,2]] = Amphipod.new(7,2, dest_7_1) if dest_7_1 != "."
    @amphipods[[7,3]] = Amphipod.new(7,3, dest_7_2) if dest_7_2 != "."
    @amphipods[[7,4]] = Amphipod.new(7,4, dest_7_3) if dest_7_3 != "."
    @amphipods[[7,5]] = Amphipod.new(7,5, dest_7_4) if dest_7_4 != "."
    @amphipods[[9,2]] = Amphipod.new(9,2, dest_9_1) if dest_9_1 != "."
    @amphipods[[9,3]] = Amphipod.new(9,3, dest_9_2) if dest_9_2 != "."
    @amphipods[[9,4]] = Amphipod.new(9,4, dest_9_3) if dest_9_3 != "."
    @amphipods[[9,5]] = Amphipod.new(9,5, dest_9_4) if dest_9_4 != "."

    if @amphipods.count != 16
      pp @amphipods
      pp "somehow created a node that was missing amphipods only had #{@amphipods.count} amphipods"
      pp dest_9_3
      pp dest_9_4
      exit
    end
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
        @amphipods[[3, 4]]&.label || ".",
        @amphipods[[3, 5]]&.label || ".",
        @amphipods[[5, 2]]&.label || ".",
        @amphipods[[5, 3]]&.label || ".",
        @amphipods[[5, 4]]&.label || ".",
        @amphipods[[5, 5]]&.label || ".",
        @amphipods[[7, 2]]&.label || ".",
        @amphipods[[7, 3]]&.label || ".",
        @amphipods[[7, 4]]&.label || ".",
        @amphipods[[7, 5]]&.label || ".",
        @amphipods[[9, 2]]&.label || ".",
        @amphipods[[9, 3]]&.label || ".",
        @amphipods[[9, 4]]&.label || ".",
        @amphipods[[9, 5]]&.label || "."]
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

    dest_y = 5

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
        (@amphipods[[x,3]].nil? || $destination_x[@amphipods[[x,3]].label] == x) &&
        (@amphipods[[x,4]].nil? || $destination_x[@amphipods[[x,4]].label] == x) &&
        (@amphipods[[x,5]].nil? || $destination_x[@amphipods[[x,5]].label] == x))
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
    highest_occupant = @amphipods[[x,2]] || @amphipods[[x,3]] || @amphipods[[x,4]] || @amphipods[[x,5]]
    return nil if highest_occupant.nil?
    return nil if highest_occupant.label == $destination_x[x]
    highest_occupant
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
    if my_diff.nil?
      pp "my diff was nil"
      pp "their diff: #{their_diff}"
      pp @amphipods
      pp other.amphipods
      exit
    end
    if their_diff.nil?
      pp "their diff was nil"
      pp "my diff: #{my_diff}"
      pp @amphipods
      pp other.amphipods
      exit
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
      # pp "all positions #{all_positions.count}"
      @node ||= Node.new(*all_positions)
      return @node
    end
    child = @children[key] ||= Trie.new(key)
    child.find_or_create_node(all_positions, current_positions)
  end
end

$trie = Trie.new

# start_node = $trie.find_or_create_node([".",".",".",".",".",".",".",
#                                         "B","D","D","A",
#                                         "C","C","B","D",
#                                         "B","B","A","C",
#                                         "D","A","C","A"]) #44169
start_node = $trie.find_or_create_node([".",".",".",".",".",".",".",
                                        "C","D","D","D",
                                        "A","C","B","D",
                                        "B","B","A","B",
                                        "C","A","C","A"]) #50190

 # start_node = $trie.find_or_create_node(["A",".",".","B",".",".",".",".","B",".","A","C","C","D","D"])
end_node = $trie.find_or_create_node([".",".",".",".",".",".",".",
                                      "A","A","A","A",
                                      "B","B","B","B",
                                      "C","C","C","C",
                                      "D","D","D","D"])

dijkstras_algorithm(start_node, end_node)

pp end_node.tentative_distance

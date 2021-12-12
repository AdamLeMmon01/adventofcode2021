file = File.read("day12_input.txt")

lines = file.split("\n")

class Cave
  attr_accessor :is_big, :is_small, :is_end, :is_start, :label
  def initialize(label)
    @is_start = label == "start"
    @is_end = label == "end"
    @connections = []
    @label = label
    @is_big = label == label.upcase
    @is_small = !@is_big #label == label.downcase
  end

  def add_connection_to(node)
    @connections << node if node.label != "start"
  end

  def all_paths(current_path, special_cave)
    if @is_small
      return (current_path + [@label]).join(",") if @is_end
      if current_path.include?(@label)
        if @label == special_cave
          @connections.flat_map do |connection|
            connection.all_paths(current_path + [@label], nil)
          end.compact
        else
          nil
        end
      else
        @connections.flat_map do |connection|
          connection.all_paths(current_path + [@label], special_cave)
        end.compact
      end
    else
      @connections.flat_map do |connection|
        connection.all_paths(current_path + [@label], special_cave)
      end.compact
    end
  end
end

all_nodes = {}

lines.each do |line|
  node1, node2 = line.split("-")
  all_nodes[node1] = all_nodes[node1] || Cave.new(node1)
  all_nodes[node2] = all_nodes[node2] || Cave.new(node2)
  all_nodes[node1].add_connection_to(all_nodes[node2])
  all_nodes[node2].add_connection_to(all_nodes[node1])
end

start = all_nodes["start"]
small_cave_keys = all_nodes.map do |k, v|
  k if v.is_small
end.compact

total_paths = []
small_cave_keys.each do |cave_key|
  all_paths = start.all_paths([], cave_key)
  total_paths += all_paths
end
total_paths.uniq!

# pp total_paths

pp total_paths.count
# pp all_paths.filter { |path| path.any? {|cave| cave.is_small } }.count


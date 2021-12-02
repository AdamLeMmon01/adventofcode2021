file = File.read("day2_input.txt")

lines = file.split("\n")

class SubCoordinate
  attr_accessor :horizontal_position, :depth

  def initialize
    @horizontal_position = 0
    @depth = 0
  end

  def move_up(value)
    @depth -= value
  end

  def move_down(value)
    @depth += value
  end

  def move_forward(value)
    @horizontal_position += value
  end
end

def update_coordinate(current_coordinate, direction_string, value)
  case direction_string
  when "forward"
    current_coordinate.move_forward(value)
  when "up"
    current_coordinate.move_up(value)
  when "down"
    current_coordinate.move_down(value)
  else
    raise StandardError, "invalid direction provided: #{direction_string}."
  end
  current_coordinate
end

moves = lines.map do |line|
  direction, count_str = line.split(" ")
  [direction, count_str.to_i]
end

coordinate = SubCoordinate.new
moves.each do |direction, value|
  coordinate = update_coordinate(coordinate, direction, value)
end

multiplied_result = coordinate.horizontal_position * coordinate.depth

pp "multiplied result"
pp multiplied_result



class SubCoordinateWithAim
  attr_accessor :horizontal_position, :depth

  def initialize
    @horizontal_position = 0
    @depth = 0
    @aim = 0
  end

  def move_up(value)
    @aim -= value
  end

  def move_down(value)
    @aim += value
  end

  def move_forward(value)
    @horizontal_position += value
    @depth += @aim * value
  end
end

coordinate = SubCoordinateWithAim.new
moves.each do |direction, value|
  coordinate = update_coordinate(coordinate, direction, value)
end

multiplied_result = coordinate.horizontal_position * coordinate.depth

pp "multiplied result 2"
pp multiplied_result




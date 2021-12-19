file = File.read("day18_input.txt")

lines = file.split("\n")
# pp lines

class SnailfishNumber
  attr_accessor :x, :y, :parent
  def initialize(x = nil, y = nil)
    @x = x
    @y = y
    @parent = nil
    @already_tried = {}
  end

  def add(other)
    result = SnailfishNumber.new(self, other)
    self.parent = result
    other.parent = result
    result.reduce
    result
  end

  def dig_right
    if @y.is_a?(Numeric)
      return [@y, self, :y=]
    end
    return @y.dig_right
  end

  def dig_left
    if @x.is_a?(Numeric)
      return [@x, self, :x=]
    end
    return @x.dig_left
  end

  def left
    return nil if parent.nil?
    if self == parent.y
      if parent.x.is_a?(Numeric)
        return [parent.x, parent, :x=]
      end
      parent.x.dig_right
    else
      parent.left
    end
  end

  def right
    return nil if parent.nil?
    if self == parent.x
      if parent.y.is_a?(Numeric)
        return [parent.y, parent, :y=]
      end
      parent.y.dig_left
    else
      parent.right
    end
  end

  def nodes_left_to_right
    result = []
    result += @x.nodes_left_to_right unless @x.is_a?(Numeric)
    result << self if @x.is_a?(Numeric) && @y.is_a?(Numeric)# && four_deep?
    result += @y.nodes_left_to_right unless @y.is_a?(Numeric)
    result.compact.flatten
  end

  def numbers_left_to_right
    result = []
    result += @x.numbers_left_to_right unless @x.is_a?(Numeric)
    if @x.is_a?(Numeric)
      # pp "adding x, self, :x="
      result << [@x, self, :x=]
    end
    if @y.is_a?(Numeric)
      # pp "adding y, self, :y="
      result << [@y, self, :y=]
    end
    result += @y.numbers_left_to_right unless @y.is_a?(Numeric)
    result = result.compact
    result
  end

  def reduce
    loop do
      # pp self.to_s
      if @already_tried.include?(self.to_s)
        pp "Ran into a loop. We've already been here before."
        return
      end
      @already_tried = self.to_s
      prior_state = self.to_s
      # pp nodes_left_to_right
      # pp numbers_left_to_right
      next if do_explosions(nodes_left_to_right)
      next if do_splits(numbers_left_to_right)
      # if explosions
      #   next
      # end
      # unless @x.is_a?(Numeric)
      #   next if @x.reduce_child_explosions
      # end
      # unless @y.is_a?(Numeric)
      #   next if @y.reduce_child_explosions
      # end
      # unless @x.is_a?(Numeric)
      #   # "not a numeric x #{@x}"
      #   next if @x.reduce_child_splits
      # end
      # next if splits
      # unless @y.is_a?(Numeric)
      #   next if @y.reduce_child_splits
      # end
      # pp self.to_s
      # pp "root was same: #{self.to_s == prior_state}"
      break if self.to_s == prior_state
    end
    return false
  end

  def do_splits(nodes)
    nodes.each do |value, node, operator|
      next if value < 10
      if node.splits
        # pp "found a split on value: #{value} node: #{node}, operator: #{operator}"
        # pp "out of set: #{nodes}"
        return true
      end
    end
    return false
  end

  def do_explosions(nodes)
    nodes.each do |node|
      return true if node.explosions
    end
    return false

    # loop do
    #   # pp "saving prior state"
    #   prior_state = self.to_s
    #   if self.explosions
    #     return true
    #   end
    #   unless @x.is_a?(Numeric)
    #     return true if @x.reduce_child_explosions
    #   end
    #   unless @y.is_a?(Numeric)
    #     return true if @y.reduce_child_explosions
    #   end
    #   # pp "explosions was same: #{self.to_s == prior_state}"
    #   break if self.to_s == prior_state
    # end
    # return false
  end

  def reduce_child_splits
    loop do
      prior_state = self.to_s
      unless @x.is_a?(Numeric)
        return true if @x.reduce_child_splits
      end
      if self.splits
        return true
      end
      unless @y.is_a?(Numeric)
        return true if @y.reduce_child_splits
      end
      break if self.to_s == prior_state
    end
    return false
  end

  def splits
    while(regular_number_is_10_or_greater?)
      if @x.is_a?(Numeric) && @x >= 10
        # pp "splitx"
        split_x(self)
        return true
      end

      if @y.is_a?(Numeric) && @y >= 10
        # pp "splity"
        split_y(self)
        return true
      end
    end
    return false
  end

  def explosions
    while(four_deep?)
      # pp "explode"
      explode(parent)
      return true
    end
    return false
  end

  def four_deep?
    # if @x == 6 && @y == 6
    #   pp depth
    # end
    depth >= 4
  end

  def depth
    return 0 if @parent.nil?
    1 + @parent.depth
  end

  def regular_number_is_10_or_greater?
    return true if @x.is_a?(Numeric) && @x >= 10
    return true if @y.is_a?(Numeric) && @y >= 10
    false
  end

  def explode(parent)
    left_value, left_node, left_which_side = left
    right_value, right_node, right_which_side = right
    left_node.public_send(left_which_side, @x + left_value) unless left_node.nil?
    right_node.public_send(right_which_side, @y + right_value) unless right_node.nil?
    # pp "parent #{parent} depth #{parent.depth} and I'm #{parent.x == self} #{parent.y == self}"
    parent.x = 0 if parent.x == self
    parent.y = 0 if parent.y == self
  end

  def split_x(parent)
    left_value = parent.x / 2
    right_value = (parent.x / 2.0).ceil
    parent.x = SnailfishNumber.new(left_value, right_value)
    parent.x.parent = parent
  end

  def split_y(parent)
    left_value = parent.y / 2
    right_value = (parent.y / 2.0).ceil
    parent.y = SnailfishNumber.new(left_value, right_value)
    parent.y.parent = parent
  end

  def self.parse(input)
    final_output = nil
    number = nil
    outer_number = []
    outer_comma = []
    input.split("").each do |char|
      case char
      when "["
        new_fish = SnailfishNumber.new
        unless number.nil?
          outer_number.push(number)
          if outer_comma.last == :first
            number.x = new_fish
          else
            number.y = new_fish
          end
        end
        outer_comma.push(:first)
        number = new_fish
      when "]"
        final_output = number
        number.parent = number = outer_number.pop
        outer_comma.pop
      when ","
        outer_comma.pop
        outer_comma.push(:second)
      else
        if outer_comma.last == :first
          number.x = char.to_i
        else
          number.y = char.to_i
        end
      end
    end
    final_output
  end

  def to_s
    "[#{@x}, #{@y}]"
  end

  def inspect
    [@x,@y]
  end

  def magnitude
    result = 0
    unless @x.is_a?(Numeric)
      @x = @x.magnitude
    end
    result += 3 * @x
    unless @y.is_a?(Numeric)
      @y = @y.magnitude
    end
    result += 2 * @y
    result
  end
end

# a = SnailfishNumber.new(1,1)
# b = SnailfishNumber.new(39,39)
# result = a.add(b)
# pp result

result = nil
lines.each do |line|
  previous_result = result
  result = SnailfishNumber.parse(line)
  result = previous_result.add(result) unless previous_result.nil?
end
pp result

pp result.magnitude

nums = lines.map do |line|
  SnailfishNumber.parse(line)
end

current_max = 0

(0..(nums.length - 1)).each do |i|
  (0..(nums.length - 1)).each do |j|
    nums = lines.map do |line|
      SnailfishNumber.parse(line)
    end
    pp "#{i},#{j}: #{current_max}"

    if i == j
      pp "skipping #{i},#{j}"
      next
    end
    magnitude = nums[i].add(nums[j]).magnitude
    current_max = magnitude if magnitude > current_max
  end
end

pp current_max
file = File.read("day16_input.txt")

bit_map = {
  "0" => "0000",
  "1" => "0001",
  "2" => "0010",
  "3" => "0011",
  "4" => "0100",
  "5" => "0101",
  "6" => "0110",
  "7" => "0111",
  "8" => "1000",
  "9" => "1001",
  "A" => "1010",
  "B" => "1011",
  "C" => "1100",
  "D" => "1101",
  "E" => "1110",
  "F" => "1111",
}

bits = file.to_s.split("").map do |char|
  bit_map[char]
end.join

class LiteralValuePacket
  attr_accessor :version, :binary_value, :leftover_input
  def initialize(version, input)
    @version = version
    @binary_value = ""
    while(input.length > 4)
      segment = input[0..4]

      input = input[5..(input.length - 1)]
      if segment.start_with?("1")
        @binary_value += segment[1..4]
      else # last segment
        @binary_value += segment[1..4]
        break
      end
    end
    @leftover_input = input
    # pp value
  end

  def value
    @binary_value.to_i(2)
  end

  def children
    []
  end

  def decimal_version
    @version.to_i(2)
  end
end

class OperatorPacket
  attr_accessor :version, :value, :leftover_input, :children
  def initialize(version, input)
    @version = version
    length_type_id = input[0]

    number_of_sub_packets = "11111111111"
    total_length_bits = "111111111111111"

    sub_packet_bits = if length_type_id == "0"
                        total_length_bits = input[1..15]
                        input[16..(input.length - 1)]
                      else
                        number_of_sub_packets = input[1..11]
                        input[12..(input.length - 1)]
                      end
    @children = []
    current_packet_count = 1
    child_length = 0
    while(!sub_packet_bits.nil? && !sub_packet_bits.empty?)
      break if current_packet_count > number_of_sub_packets.to_i(2)
      current_packet_count += 1
      packet = parse_packet(sub_packet_bits)
      break if packet.nil?
      @children << packet
      child_length += (sub_packet_bits.length - packet.leftover_input.length)
      sub_packet_bits = packet.leftover_input
      break if(child_length >= total_length_bits.to_i(2))
    end
    @leftover_input = sub_packet_bits
  end

  def decimal_version
    @version.to_i(2)
  end
end

class SumPacket < OperatorPacket
  def value
    result = @children.map(&:value).sum
    # pp "sum #{result}"
    result
  end
end
class ProductPacket < OperatorPacket
  def value
    result = 1
    @children.map(&:value).each do |v|
      result *= v
    end
    # pp "product #{result}"
    result
  end
end
class MinimumPacket < OperatorPacket
  def value
    result = @children.map(&:value).min
    # pp "min #{result}"
    result
  end
end
class MaximumPacket < OperatorPacket
  def value
    result = @children.map(&:value).max
    # pp "max #{result}"
    result
  end
end
class LessThanPacket < OperatorPacket
  def value
    first, second = @children.map(&:value)
    # pp "first: #{first} < second: #{second}"
    first < second ? 1 : 0
  end
end
class GreaterThanPacket < OperatorPacket
  def value
    first, second = @children.map(&:value)
    # pp "first: #{first} > second: #{second}"
    first > second ? 1 : 0
  end
end
class EqualToPacket < OperatorPacket
  def value
    first, second = @children.map(&:value)
    # pp "first: #{first} == second: #{second}"
    first == second ? 1 : 0
  end
end

def parse_packet(input)
  # pp input
  version = input[0..2]
  packet_type_id = input[3..5]
  rest_of_input = input[6..(input.length-1)]
  if rest_of_input.nil? || rest_of_input.empty?
    return nil
  end
  # pp packet_type_id
  if packet_type_id == "100"
    LiteralValuePacket.new(version, rest_of_input)
  elsif packet_type_id == "000"
    SumPacket.new(version, rest_of_input)
  elsif packet_type_id == "001"
    ProductPacket.new(version, rest_of_input)
  elsif packet_type_id == "010"
    MinimumPacket.new(version, rest_of_input)
  elsif packet_type_id == "011"
    MaximumPacket.new(version, rest_of_input)
  elsif packet_type_id == "101"
    GreaterThanPacket.new(version, rest_of_input)
  elsif packet_type_id == "110"
    LessThanPacket.new(version, rest_of_input)
  elsif packet_type_id == "111"
    EqualToPacket.new(version, rest_of_input)
  else
    pp "invalid packet type"
  end
end

root = parse_packet(bits)

def get_all_children_recursively(node)
  [node] + node.children.flat_map do |child|
    get_all_children_recursively(child)
  end
end

all_nodes = get_all_children_recursively(root)
pp "version sum: #{all_nodes.map(&:decimal_version).sum}"
pp "calculated value: #{root.value}"

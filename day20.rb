file = File.read("day20_input.txt")

lines = file.split("\n")

@algorithm = lines[0]

input_image = lines[2..(lines.length - 1)].filter { |line| !line.empty? }
                   .map do |line|
  line.split("")
end

def add_empty_ring(input, ring_char = ".")
  length = input[0].length
  top_row = (ring_char * (length + 2)).split("")
  middle_rows = input.map do |line|
    [ring_char] + line + [ring_char]
  end
  bottom_row = (ring_char * (length + 2)).split("")
  [top_row] + middle_rows + [bottom_row]
end

def chop_off_outer_ring(input)
  input[1..(input.length - 2)].map do |row|
    row[1..(row.length - 2)]
  end
end

def print_image(image)
  image.each do |row|
    row.each do |char|
      print char
    end
    print "\n"
  end
end

def count_lights(image)
  total = 0
  image.each do |row|
    row.each do |char|
      total += 1 if char == "#"
    end
  end
  total
end

def get_3x3(input, x, y)
  [
    [input[y - 1][x - 1], input[y - 1][x], input[y - 1][x + 1]],
    [input[y][x - 1], input[y][x], input[y][x + 1]],
    [input[y + 1][x - 1], input[y + 1][x], input[y + 1][x + 1]],
  ]
end

def append(row0, row1, row2)
  row0 + row1 + row2
end

def convert_to_binary(input)
  input.map do |char|
    case char
    when "."
      "0"
    when "#"
      "1"
    end
  end.join
end

def convert_to_number(input)
  convert_to_binary(input).to_i(2)
end

def enhance(input, ring_char = ".")
  input = add_empty_ring(input, ring_char)
  input = add_empty_ring(input, ring_char)

  output = (1..(input.length)).map do
    ("." * (input.length)).split("")
  end

  (1..(input.length - 2)).each do |y|
    (1..(input.length - 2)).each do |x|
      index = convert_to_number(append(*get_3x3(input, x, y)))
      # next if index == 0 # gives 5430 which is too low
      output[y][x] = @algorithm[index]

      # pp "for #{x},#{y} found #{index} which outputs #{@algorithm[index]}"
    end
  end
  output
end
# print_image(input_image)
# pp
# output_image = chop_off_outer_ring(enhance(input_image)) #5443 still not right - try 5479 next
# print_image(output_image)
# pp
# output_image = enhance(output_image, "#") # passing ring char "#" here results in 5687 which is too high
# # output_image = enhance(output_image, ".") # passing ring char "#" here results in 5687 which is too high
#
# print_image(output_image)
# pp "has #{count_lights(output_image)} light spots" # gives 5989 which is too high

(1..50).each do |i|
  ring_char = i % 2 == 1 ? "." : "#"
  input_image = enhance(input_image, ring_char)
  # input_image = enhance(input_image)
  if i % 2 == 1
    input_image = chop_off_outer_ring(input_image)
  end
end

# if count_lights(input_image) != 5479
#   pp "Wrong answer for part 1, so the algorithm is probably off"
# end

# print_image(input_image)
pp "after 50 times has #{count_lights(input_image)} light spots" # got 32996 - too high
file = File.read("day7_input.txt")

ints = file.split(",").map { |value| value.to_i }

# this method added for part 2
def fuel_per_step(num)
  total = 0
  (1..num).each do |step|
    total += step
  end
  total
end

def fuel_to_move_to(source, destination)
  fuel_per_step((source - destination).abs)
end

def fuel_to_move_all_to(ints, destination)
  total = 0
  ints.each do |int|
    total += fuel_to_move_to(int, destination)
  end
  total
end

result = ints.map do |int|
  fuel_to_move_all_to(ints, int)
end

pp "least fuel approach: #{result.min}"
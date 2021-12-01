file = File.read("day1_input.txt")

lines = file.split("\n")

ints = lines.map do |line|
  line.to_i
end

def count_increases(ints)
  previous_value = nil
  increasing_count = 0
  ints.each do |num|
    unless previous_value.nil?
      increasing_count += 1 if num > previous_value
    end

    previous_value = num
  end
  increasing_count
end

increasing_count = count_increases(ints)
pp "number of increases #{increasing_count}"

window_sums = (0..(ints.count - 3)).map do |index|
  ints[index] + ints[index + 1] + ints[index + 2]
end

increasing_windows_count = count_increases(window_sums)
pp "number of window sum increases #{increasing_windows_count}"



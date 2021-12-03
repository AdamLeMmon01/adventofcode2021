file = File.read("day3_input.txt")

lines = file.split("\n").map do |line|
  line.split("").map { |char| char.to_i }
end

def gamma_rate(rows)
  bits = calculate_gamma_bits(rows)
  binary_number = convert_to_binary_number(bits)
  convert_to_decimal_number(binary_number)
end

def epsilon_rate_shortcut(gamma_bits)
  bits = flip_bits(gamma_bits)
  binary_number = convert_to_binary_number(bits)
  convert_to_decimal_number(binary_number)
end

def epsilon_rate(rows)
  bits = calculate_epsilon_bits(rows)
  binary_number = convert_to_binary_number(bits)
  convert_to_decimal_number(binary_number)
end

def calculate_gamma_bits(rows)
  (0..rows[0].length - 1).map do |index|
    result = rows.each_with_object([0, 0]) do |row, counter|
      counter[row[index]] += 1
    end
    result[0] > result[1] ? 0 : 1
  end
end

def calculate_epsilon_bits(rows)
  (0..rows[0].length - 1).map do |index|
    result = rows.each_with_object([0, 0]) do |row, counter|
      counter[row[index]] += 1
    end
    result[0] > result[1] ? 1 : 0
  end
end

def convert_to_binary_number(row)
  row.join
end

def convert_to_decimal_number(binary_number)
  binary_number.to_i(2)
end

def flip_bits(bits)
  bits.map { |bit| bit == 1 ? 0 : 1 }
end

gamma_rate = gamma_rate(lines)
epsilon_rate = epsilon_rate(lines)
epsilon_rate_shortcut = epsilon_rate_shortcut(calculate_gamma_bits(lines))

result1 = gamma_rate(lines) * epsilon_rate(lines)

pp "gamma: #{gamma_rate}, epsilon: #{epsilon_rate}, shortcut: #{epsilon_rate_shortcut}, result: #{result1}"

def find_counts_for_nth_bit(rows, n)
  number_counts = { 0 => 0, 1=> 0}
  rows.each do |row|
    row.each_with_index do |bit, index|
      if index == n
        number_counts[bit] += 1
        break
      end
    end
  end

  number_counts
end

def filter_list(rows, index, expected_value)
  rows.filter do |row|
    row[index] == expected_value
  end
end
temp_lines = lines
(0..lines[0].length - 1).each do |n|
  counts = find_counts_for_nth_bit(temp_lines, n)
  expected_value = counts[0] <= counts[1] ? 0 : 1
  temp_lines = filter_list(temp_lines, n, expected_value)
  break if temp_lines.count == 1
end

pp "co2 temp lines: #{temp_lines} - should just be 1 - 01010"
co2_bits = temp_lines.first
co2_num = convert_to_decimal_number(convert_to_binary_number(co2_bits))

temp_lines = lines
(0..lines[0].length - 1).each do |n|
  counts = find_counts_for_nth_bit(temp_lines, n)
  # pp counts
  expected_value = counts[1] >= counts[0] ? 1 : 0
  temp_lines = filter_list(temp_lines, n, expected_value)
  break if temp_lines.count == 1
end
pp "oxygen temp lines: #{temp_lines} - should just be 1 - 10111"
oxygen_bits = temp_lines.first
oxygen_num = convert_to_decimal_number(convert_to_binary_number(oxygen_bits))

pp "oxygen: #{oxygen_num}, co2: #{co2_num}, and total: #{oxygen_num * co2_num}"

file = File.read("day14_input.txt")

lines = file.split("\n")

polymer_template = lines[0]

rules = {}
lines[2..(lines.length - 1)].each do |pair_insertion_rule|
  pattern, output = pair_insertion_rule.split(" -> ")
  rules[pattern] = output
end

def add_char(char_counts, char)
  initial_value = char_counts[char] || 0
  char_counts[char] = initial_value + 1
end

def evaluate_rules(input, rules)
  char_counts = {}
  output = ""
  input.split("")[0..(input.length - 2)].each_with_index do |letter, index|
    second_letter = input[index + 1]
    pattern = letter + second_letter
    middle_letter = rules[pattern] || ""
    add_char(char_counts, letter)
    add_char(char_counts, middle_letter)
    output += letter + middle_letter
  end
  add_char(char_counts, input[-1])
  [output + input[-1], char_counts]
end

def find_difference(input, rules, steps)
  char_counts = nil
  # pp "template: #{input}"
  (1..steps).each do |step|
    # pp step
    input, char_counts = evaluate_rules(input, rules)
    # pp "after step #{step}: #{input}"
  end

  pp char_counts
  pp char_counts.values.max - char_counts.values.min
end

find_difference(polymer_template, rules, 10)

def recurse(first_letter, second_letter, rules, depth, pre_calculated)
  pattern = first_letter + second_letter

  hash = pre_calculated.dig(pattern, depth)

  unless hash.nil?
    return hash
  end

  pre_calculated[pattern] ||= {}
  pre_calculated[pattern][depth] ||= Hash.new(0)
  hash = pre_calculated[pattern][depth]

  middle_letter = rules[pattern] || ""
  if depth == 1
    hash[first_letter] += 1
    hash[second_letter] += 1
    hash[middle_letter] += 1
    return hash
  end

  left_counts = recurse(first_letter, middle_letter, rules, depth - 1, pre_calculated)
  right_counts = recurse(middle_letter, second_letter, rules, depth - 1, pre_calculated)
  left_counts.each { |letter, count| hash[letter] += count }
  right_counts.each { |letter, count| hash[letter] += count }
  hash[middle_letter] -= 1
  hash
end

def evaluate_rules2(input, rules, depth)
  char_counts = Hash.new(0)
  pre_calculated = {}
  input.split("")[0..(input.length - 2)].each_with_index do |letter, index|
    second_letter = input[index + 1]
    # print letter
    counts = recurse(letter, second_letter, rules, depth, pre_calculated)
    counts.each { |letter, count| char_counts[letter] += count }
    char_counts[second_letter] -= 1
  end
  char_counts[input[-1]] += 1
  char_counts
end

char_counts = evaluate_rules2(polymer_template, rules, 10)
pp char_counts
pp char_counts.values.max - char_counts.values.min

char_counts = evaluate_rules2(polymer_template, rules, 40)
pp char_counts
pp char_counts.values.max - char_counts.values.min

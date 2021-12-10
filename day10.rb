file = File.read("day10_input.txt")

lines = file.split("\n")

def score(char)
  case char
  when ")"
    3
  when "]"
    57
  when "}"
    1197
  when ">"
    25137
  else
    0
  end
end

total_score = 0
incomplete_lines = lines.map do |line|
  # pp line
  loop do
    initial_line = line.dup
    line.gsub!("()", "")
    line.gsub!("[]", "")
    line.gsub!("{}", "")
    line.gsub!("<>", "")
    # pp line
    break if line == initial_line
  end

  if line != ""
    first_invalid_char = line[[line.index(">"), line.index(")"), line.index("}"), line.index("]")].compact.min || 0]
    # pp first_invalid_char
    score = score(first_invalid_char)
    total_score += score
    line if score == 0
  end
end.compact

pp total_score

completions = incomplete_lines.map { |line|
  line.gsub!("(", ")")
  line.gsub!("[", "]")
  line.gsub!("{", "}")
  line.gsub!("<", ">")
  line.reverse
}

def score_completion_char(char)
  case char
  when ")"
    1
  when "]"
    2
  when "}"
    3
  when ">"
    4
  else
    0
  end
end

def score_completion(str)
  score = 0
  str.split("").each do |char|
    score *= 5
    score += score_completion_char(char)
  end
  score
end

scores = completions.map { |completion| score_completion(completion) }.sort
middle_score = scores[(scores.length - 1)/2]
pp middle_score
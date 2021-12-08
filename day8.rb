file = File.read("day8_input.txt")

lines = file.split("\n")

class DigitDecoder
  attr_accessor :top, :top_left, :top_right, :middle, :bottom_left, :bottom_right, :bottom,
                :one, :two, :three, :four, :five, :six, :seven, :eight, :nine, :zero
  def initialize(signal_patterns)
    signal_patterns = signal_patterns.split
    @one = signal_patterns.filter { |pattern| pattern.length == 2 }.first
    @four = signal_patterns.filter { |pattern| pattern.length == 4 }.first
    @seven = signal_patterns.filter { |pattern| pattern.length == 3 }.first
    @eight = signal_patterns.filter { |pattern| pattern.length == 7 }.first
    # pp "one #{@one}"
    # pp "four #{@four}"
    # pp "seven #{@seven}"
    # pp "eight #{@eight}"
    five_options = two_options = three_options = signal_patterns.filter { |pattern| pattern.length == 5 }
    six_options = nine_options = zero_options = signal_patterns.filter { |pattern| pattern.length == 6 }

    @top = (@seven.split("") - @one.split("")).first
    # pp "top: #{@top}"
    top_left_options = middle_options = @four.split("") - @one.split("")
    bottom_options = bottom_left_options = (@eight.split("") - @four.split("")) - [@top]
    # pp "bottom left options #{bottom_left_options}"

    # 6, 9, and 0 will all have the top left but not the middle
    six_options.each do |pattern|
      chars = pattern.split("")
      middle = top_left_options - chars

      if middle != []
        # this is zero and the middle array contains the middle segment
        @zero = pattern
        @middle = middle.first
        @top_left = (top_left_options - middle).first
      end
    end

    # 5, 3 and 2 will all have the bottom but not the bottom_left
    five_options.each do |pattern|
      chars = pattern.split("")
      bottom_left = bottom_options - chars

      if bottom_left == []
        # this is zero and the middle array contains the middle segment
        @two = pattern
      else
        @bottom_left = bottom_left.first
        @bottom = (bottom_options - bottom_left).first
      end
    end
    @bottom_right = (@one.split("") - @two.split("")).first
    @top_right = (@one.split("") - [@bottom_right]).first

    @three = signal_patterns.filter { |pattern|
      pattern.include?(@top) &&
        pattern.include?(@middle) &&
        pattern.include?(@bottom) &&
        pattern.include?(@top_right) &&
        pattern.include?(@bottom_right) &&
        !pattern.include?(@top_left) &&
        !pattern.include?(@bottom_left)
    }.first

    @five = signal_patterns.filter { |pattern|
      pattern.include?(@top) &&
        pattern.include?(@middle) &&
        pattern.include?(@bottom) &&
        pattern.include?(@top_left) &&
        pattern.include?(@bottom_right) &&
        !pattern.include?(@top_right) &&
        !pattern.include?(@bottom_left)
    }.first

    @six = signal_patterns.filter { |pattern|
      pattern.include?(@top) &&
        pattern.include?(@middle) &&
        pattern.include?(@bottom) &&
        pattern.include?(@top_left) &&
        pattern.include?(@bottom_right) &&
        pattern.include?(@bottom_left) &&
        !pattern.include?(@top_right)
    }.first
    @nine = signal_patterns.filter { |pattern|
      pattern.include?(@top) &&
        pattern.include?(@middle) &&
        pattern.include?(@bottom) &&
        pattern.include?(@top_right) &&
        pattern.include?(@bottom_right) &&
        pattern.include?(@top_left) &&
        !pattern.include?(@bottom_left)
    }.first
    @one = @one.chars.sort.join
    @two = @two.chars.sort.join
    @three = @three.chars.sort.join
    @four = @four.chars.sort.join
    @five = @five.chars.sort.join
    @six = @six.chars.sort.join
    @seven = @seven.chars.sort.join
    @eight = @eight.chars.sort.join
    @nine = @nine.chars.sort.join
    @zero = @zero.chars.sort.join
  end

  def decode(pattern) # TODO: might have to sort the letters
    case pattern.chars.sort.join
    when @one
      1
    when @two
      2
    when @three
      3
    when @four
      4
    when @five
      5
    when @six
      6
    when @seven
      7
    when @eight
      8
    when @nine
      9
    when @zero
      0
    end
  end

end

class Digit
  attr_accessor :a, :b, :c, :d, :e, :f, :g
  def initialize(a: false, b: false, c: false, d: false, e: false, f: false, g: false)
    @a = a
    @b = b
    @c = c
    @d = d
    @e = e
    @f = f
    @g = g
  end

  def count_segments
    [@a, @b, @c, @d, @e, @f, @g].filter { |seg| seg == true }.count
  end

  def digit
    case count_segments
    when 2
      1
    when 3
      7
    when 4
      4
    when 7
      8
    else
      -1 # TODO: figure out other segments here.
    end
  end
end

total = 0
sum = 0
lines.each do |line|
  signal_patterns, outputs = line.split("|")
  decoder = DigitDecoder.new(signal_patterns)
  output_num = outputs.split.map do |output|
    # chars = output.split("")
    # hash  = chars.each_with_object({}) do |char, hash|
    #   hash[char.to_sym] = true
    # end
    # digit = Digit.new(hash).digit
    digit = decoder.decode(output)
    total += 1 if [1,4,7,8].include?(digit)
    digit
  end.join.to_i

  pp "output #{outputs} gave number #{output_num}"
  sum   += output_num
end

pp "found #{total} - 1,4,7,and 8s total"
pp "sum was #{sum} for decoded numbers"

file = File.read("day6_input.txt")

ints = file.split(",").map { |num| num.to_i }

class LanternFish
  attr_accessor :timer
  def initialize(int)
    @timer = int
  end

  def self.spawn
    LanternFish.new(8)
  end

  def pass_day
    @timer = @timer - 1
    if @timer < 0
      @timer = 6
      [LanternFish.spawn, self]
    else
      [self]
    end
  end
end

fish = ints.map do |int|
  LanternFish.new(int)
end
pp "initial state: #{fish.count}"
# pp "#{fish.map{|f| f.timer}.join(",")}"
(1..80).each do |i|
  fish = fish.flat_map do |one_fish|
    one_fish.pass_day
  end
  pp "after #{i} days: #{fish.count}"
  #pp "#{fish.map{|f| f.timer}.join(",")}"
end


class LanternFishSchool
  attr_accessor :school

  def initialize
    @school = {}
    (0..8).each do |index|
      @school[index] = 0
    end
  end

  def add_fish(int)
    @school[int] += 1
  end

  def pass_day
    parents = @school[0]
    (1..8).each do |index|
      @school[index - 1] = @school[index]
    end
    @school[8] = parents # new baby fish
    @school[6] += parents # parents resetting their timer
  end

  def count
    total = 0
    (0..8).each do |index|
      total += @school[index]
    end
    total
  end

end

school = LanternFishSchool.new

ints.each do |int|
  school.add_fish(int)
end
pp "initial state: #{school.count}"
# pp "#{fish.map{|f| f.timer}.join(",")}"
(1..256).each do |i|
  school.pass_day
  pp "after #{i} days: #{school.count}"
  #pp "#{fish.map{|f| f.timer}.join(",")}"
end
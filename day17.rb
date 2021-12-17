class Probe
  attr_accessor :peak_y
  def initialize(x_velocity, y_velocity)
    @x = 0
    @y = 0
    @peak_y = 0
    @x_velocity = x_velocity
    @y_velocity = y_velocity
  end

  def step
    @x += @x_velocity
    @y += @y_velocity
    @x_velocity -= 1 if @x_velocity > 0
    @y_velocity -= 1
  end

  def enters_target?(target_x, target_y)
    while(@y > target_y.min)
      step
      @peak_y = @y if @y > @peak_y
      return true if target_x.include?(@x) && target_y.include?(@y)
    end
  end
end

target_x=119..176
target_y=-141..-84

peaks = (0..200).flat_map do |initial_x|
  # pp initial_x
  (-200..1000).map do |initial_y|
    probe = Probe.new(initial_x, initial_y)
    # pp "#{initial_x},#{initial_y} reaches target with peak y of: #{probe.peak_y}"
    probe.peak_y if probe.enters_target?(target_x, target_y)
  end
end.compact
pp peaks.max
pp peaks.count
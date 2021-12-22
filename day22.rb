require "set"

file = File.read("day22_input.txt")

lines = file.split("\n")

reboot_steps = lines.map do |line|
  on_off, cuboid = line.split
  x_range, y_range, z_range = cuboid.split(",")
  x_begin, x_end = x_range[2..-1].split("..")
  y_begin, y_end = y_range[2..-1].split("..")
  z_begin, z_end = z_range[2..-1].split("..")
  [on_off == "on", ((x_begin.to_i)..(x_end.to_i)), ((y_begin.to_i)..(y_end.to_i)), ((z_begin.to_i)..(z_end.to_i))]
end

grid = Hash.new(0)
reboot_steps.each do |step|
  # pp step
  step[1].each do |x|
    step[2].each do |y|
      step[3].each do |z|
        grid[[x, y, z]] = (step[0] ? 1 : 0)
      end
    end
  end
  # pp "intermediate count: #{grid.values.sum}"
end

# pp "total cubes: #{all_cubes(cubes).count}"
pp "final count: #{grid.values.sum}"
# pp "expect 590784 for small sample data"
# pp "expect 2758514936282235 for sample data"



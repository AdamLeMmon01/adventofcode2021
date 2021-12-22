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

class Range
  def self.overlaps?(r1, r2)
    (r1.min >= r2.min && r1.min <= r2.max) ||
      (r1.max >= r2.min && r1.max <= r2.max) ||
      (r2.min >= r1.min && r2.min <= r1.max) ||
      (r2.min >= r1.min && r2.min <= r1.max)
  end

  def self.all_overlap?(x1, y1, z1, x2, y2, z2)
    x_overlaps = overlaps?(x1, x2)
    y_overlaps =  overlaps?(y1, y2)
    z_overlaps = overlaps?(z1, z2)
    x_overlaps && y_overlaps && z_overlaps
  end
end

class Cuboid
  attr_accessor :x_r, :y_r, :z_r, :removed_chunks

  def initialize(x,y,z)
    @x_r = x
    @y_r = y
    @z_r = z
    @removed_chunks = []
  end

  def remove_range(x,y,z)
    @removed_chunks << Cuboid.new(x,y,z)
  end

  def removed_chunk_area
    # naive approach - minus off removed chunk areas. There could be overlap though.
    total = 0
    @removed_chunks.each do |chunk|
      total += chunk.size
    end
    total
  end

  def size
    total = @x_r.size * @y_r.size * @z_r.size - removed_chunk_area
    total
  end

  def overlaps?(other)
    Range.all_overlap?(@x_r, @y_r, @z_r, other.x_r, other.y_r, other.z_r)
  end

  def remove_chunk(chunk)
    overlap = find_overlapped_ranges(chunk)
    @removed_chunks.each do |sub_chunk|
      sub_chunk.remove_chunk(chunk) if sub_chunk.overlaps?(chunk)
    end
    remove_range(*overlap)
  end

  def find_overlapped_ranges(other)
    [
      ([@x_r.min, other.x_r.min].max)..([@x_r.max, other.x_r.max].min),
      ([@y_r.min, other.y_r.min].max)..([@y_r.max, other.y_r.max].min),
      ([@z_r.min, other.z_r.min].max)..([@z_r.max, other.z_r.max].min),
    ]
  end
end

@chunks = []
start = Time.now
reboot_steps.each do |step|
  new_cuboid = Cuboid.new(step[1], step[2], step[3])

  @chunks.each do |chunk|
    if new_cuboid.overlaps?(chunk)
      chunk.remove_chunk(new_cuboid)
    end
  end

  if(step[0])
    @chunks << new_cuboid
  end

  # pp "intermediate count: #{@chunks.sum { |c| c.size }}"
end
end_time = Time.now
pp "final count: #{@chunks.sum { |c| c.size }} in #{end_time - start}"
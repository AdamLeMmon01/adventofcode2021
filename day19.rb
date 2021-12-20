file = File.read("day19_input.txt")

lines = file.split("\n")

@scanners = []
class Scanner
  attr_accessor :beacons, :orientation, :absolute_coordinates, :skipped_translations, :skipped_beacon_checks
  def initialize(scanners)
    @scanners = scanners
    @beacons = []
    @orientation = nil
    @absolute_coordinates = nil
    @saved_translated_points = {}
    @already_checked = {}
    @skipped_translations = 0
    @skipped_beacon_checks = 0
  end
  def add_beacon(x, y, z)
    @beacons << [x, y, z]
  end

  def find_matching_orientation(other)
    return unless other.orientation.nil?
    rotations = [0,1,2,3]
    facing_directions = [:x_positive, :x_negative, :y_positive, :y_negative, :z_positive, :z_negative]
    found_match = false
    facing_directions.each do |direction|
      rotations.each do |rotation|
        other.orientation = [direction, rotation]
        does_overlap, overlaps, all_absolute_positions, scanner_absolute_position = overlaps?(other)
        if does_overlap
          # pp "overlaps true for direction: #{direction} and rotation: #{rotation}"
          other.absolute_coordinates = scanner_absolute_position
          # pp overlaps
          pp scanner_absolute_position
          @beacons += (all_absolute_positions - overlaps)
          @scanners.delete(other)
          found_match = true
        end

        break if found_match
      end
      break if found_match
    end
    other.orientation = nil
  end

  def overlaps?(other)
    count, overlapped_beacons, all_absolute_positions, scanner_absolute_position = matching_coords(other)
    [count >= 12, overlapped_beacons, all_absolute_positions, scanner_absolute_position]
  end

  def matching_coords(other)
    # pp "called matching_coords (should only be called 24 times)"
    if @saved_translated_points.include?([other, other.orientation])
      translated_coordinates = @saved_translated_points[[other, other.orientation]]
      # pp "using cached translation"
      @skipped_translations += 1
    else
      translated_coordinates = other.beacons.map { |beacon| translate_coordinate(beacon, other.orientation) }
      @saved_translated_points[[other, other.orientation]] = translated_coordinates
    end
    # pp "translated coords: #{translated_coordinates}"
    best_overlapping_beacons_count = 0
    best_overlapping_beacons = nil
    best_coordinates_set = nil
    best_scanner_position = nil
    beacons.each do |beacon|
      if @already_checked.include?([beacon, other, other.orientation])
        # pp "skipping cached beacon comparison"
        @skipped_beacon_checks += 1
        next
      end
      translated_coordinates.each do |other_beacon|
        new_origin = [beacon[0] - other_beacon[0], beacon[1] - other_beacon[1], beacon[2] - other_beacon[2]]

        tentative_coords = translated_coordinates.map do |unshifted_beacon|
          # pp "new_origin #{new_origin}"
          # pp "unshifted_beacon #{unshifted_beacon}"
          [new_origin[0] + unshifted_beacon[0], new_origin[1] + unshifted_beacon[1], new_origin[2] + unshifted_beacon[2]]
        end

        overlapping_beacons = tentative_coords.filter do |tentative_coord|
          beacons.include?(tentative_coord)
        end
        if overlapping_beacons.count > best_overlapping_beacons_count
          best_overlapping_beacons_count = overlapping_beacons.count
          best_overlapping_beacons = overlapping_beacons
          best_coordinates_set = tentative_coords
          best_scanner_position = new_origin

          break if best_overlapping_beacons.count >= 12
        end
        # pp "overlapping beacon count: #{overlapping_beacons.count}" if overlapping_beacons.count > 4
        break if best_overlapping_beacons.count >= 12
      end
      @already_checked[[beacon, other, other.orientation]] = true
      break if best_overlapping_beacons.count >= 12
    end
    [best_overlapping_beacons_count, best_overlapping_beacons, best_coordinates_set, best_scanner_position]
  end

  def translate_coordinate(coord, orientation)
    direction, rotation = orientation
    x = coord[0]
    y = coord[1]
    z = coord[2]
    result = case direction
    when :x_positive
      case rotation
      when 0
        coord # no translation needed
      when 1
        [x, -z, y]
      when 2
        [x, -y, -z]
      when 3
        [x, z, -y]
      end
    when :x_negative
      case rotation
      when 0
        [-x, y, -z]
      when 1
        [-x, -z, -y]
      when 2
        [-x, -y, z]
      when 3
        [-x, z, y]
      end
    when :y_positive
      case rotation
      when 0
        [-y, x, z]
      when 1
        [z, x, y]
      when 2
        [y, x, -z]
      when 3
        [-z, x, -y]
      end
    when :y_negative
      case rotation
      when 0
        [y, -x, z]
      when 1
        [-z, -x, y]
      when 2
        [-y, -x, -z]
      when 3
        [z, -x, -y]
      end
    when :z_positive
      case rotation
      when 0
        [-z, y, x]
      when 1
        [-y, -z, x]
      when 2
        [z, -y, x]
      when 3
        [y, z, x]
      end
    when :z_negative
      case rotation
      when 0
        [z, y, -x]
      when 1
        [y, -z, -x]
      when 2
        [-z, -y, -x]
      when 3
        [-y, z, -x]
      end
             end
    pp "got nils #{result} for coord: #{coord} orientation #{orientation}" if result == [nil, nil, nil]
    result
  end

  def find_absolute_position(other)
    match = matching_coords(other).first
    # TODO: now using the orientation of the other node, and the set of matching coordinates, we can determine where the other node is.
    coord_from_0 = match[0]
    coord_from_other = match[1]

    [coord_from_0[0] + get_x(coord_from_other, other.orientation), # x
    coord_from_0[1] + get_y(coord_from_other, other.orientation),  # y
    coord_from_0[2] + get_z(coord_from_other, other.orientation)]  # z



  end

  def get_x(coordinate, orientation)
    translate_coordinate(coordinate, orientation)[0]
  end

  def get_y(coordinate, orientation)
    translate_coordinate(coordinate, orientation)[1]
  end

  def get_z(coordinate, orientation)
    translate_coordinate(coordinate, orientation)[2]
  end
end

lines.each do |line|
  next if line.empty?
  if line.start_with?("---")
    @scanners << Scanner.new(@scanners)
    next
  end
  x, y, z = line.split(",").map { |num| num.to_i }
  @scanners.last.add_beacon(x, y, z)
end

@scanners[0].orientation = [:x_positive, 0]
@scanners[0].absolute_coordinates = [0,0,0]

# pp scanners

all_scanners = @scanners.dup
while true
  pp "beginning of iterating the full list"
  @scanners.each_with_index do |other, index|
    next if index == 0
    pp "checking scanner #{index}/#{@scanners.count}"
    @scanners[0].find_matching_orientation(other)
    pp "total beacon count: #{@scanners[0].beacons.count} out of #{@scanners.flat_map(&:beacons).count}"
  end
  pp "skipped translations so far #{@scanners[0].skipped_translations}"
  pp "skipped beacon checks so far #{@scanners[0].skipped_beacon_checks}"
  all_beacons = @scanners.flat_map(&:beacons)
  break if (all_beacons - @scanners[0].beacons).empty?
end

pp "Final total beacon count: #{@scanners[0].beacons.count}"
pp "final skipped translations #{@scanners[0].skipped_translations}"
pp "final skipped beacon checks #{@scanners[0].skipped_beacon_checks}"
largest_distance = 0

def manhattan_distance(first, second)
  (first.absolute_coordinates[0] - second.absolute_coordinates[0]).abs +
    (first.absolute_coordinates[1] - second.absolute_coordinates[1]).abs +
    (first.absolute_coordinates[2] - second.absolute_coordinates[2]).abs
end

(0..(all_scanners.length - 2)).each do |i|
  ((i + 1)..(all_scanners.length - 1)).each do |j|
    new_distance = manhattan_distance(all_scanners[i], all_scanners[j])
    largest_distance = new_distance if new_distance > largest_distance
  end
end

pp "largest distance #{largest_distance}"

file = File.read("day13_input.txt")

lines = file.split("\n")

end_of_points = lines.index("")

points_input = lines[0..end_of_points-1]

# pp "points #{points}"

folds_input = lines[end_of_points + 1..lines.length - 1]

# pp "folds #{folds}"

points = points_input.map do |input|
  x, y = input.split(",")
  [x.to_i, y.to_i]
end

folds = folds_input.map do |input|
  axis, index = input.split.last.split("=")
  [axis, index.to_i]
end

count = 0
folds.each do |fold|
  result = if fold[0] == "y"
    points_above_fold = points.filter { |x, y|
      y < fold[1]
    }

    points_below_fold = points.filter { |x, y|
      y > fold[1]
    }

    folded_up_points = points_below_fold.map do |x, y|
      new_y = fold[1] - (y - fold[1])
      [x, new_y]
    end

    (points_above_fold + folded_up_points).uniq
  else

    points_to_left_of_fold = points.filter { |x, y|
      x < fold[1]
    }

    points_to_right_of_fold = points.filter { |x, y|
      x > fold[1]
    }

    folded_left_points = points_to_right_of_fold.map do |x, y|
      new_x = fold[1] - (x - fold[1])
      [new_x, y]
    end

    (points_to_left_of_fold + folded_left_points).uniq
  end

  points = result

  count += 1
  pp "points after #{count} fold #{points.count}"

  # pp points

  (0..5).each do |y|
    (0..40).each do |x|
      print points.include?([x,y]) ? "#" : "."
    end
    print "\n"
  end
end



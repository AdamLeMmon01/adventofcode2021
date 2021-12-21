@outcomes = {}

class Player
  attr_accessor :position, :score
  def initialize(score, position)
    @position = position
    @score = score
  end
  def move(moves)
    new_position = @position + moves
    while(new_position > 10)
      new_position -= 10
    end
    @position = new_position
    @score += new_position
  end

  def wins?
    @score >= 21
  end
end

def rolls(die)
  @rolls_result ||= rolls = {}
  die.roll.each do |roll1|
    die.roll.each do |roll2|
      die.roll.each do |roll3|
        total = roll1 + roll2 + roll3
        rolls[total] ||= 0
        rolls[total] += 1
      end
    end
  end
  rolls
end

class DiracDice
  attr_accessor :count
  def initialize
    @value = 0
  end
  def roll
    [1,2,3]
  end
end

die = DiracDice.new
@dice_map = rolls(die)
@outcomes = @dice_map.keys

def score_all(out, place1, place2, score1, score2, turn1, multiplier)
  @outcomes.each do |outcome|
    inner_score = score(place1, place2, score1, score2, outcome, turn1, multiplier * @dice_map[outcome])
    out[0] += inner_score[0]
    out[1] += inner_score[1]
  end
end

def score(place1, place2, score1, score2, roll, turn1, multiplier)
  out = [0, 0]

  if(turn1)
    place1 = (place1 - 1 + roll) % 10 + 1
    score1 += place1
  else
    place2 = (place2 - 1 + roll) % 10 + 1
    score2 += place2
  end

  if(score1 >= 21)
    out[0] = multiplier
    return out
  end
  if(score2 >= 21)
    out[1] = multiplier
    return out
  end

  score_all(out, place1, place2, score1, score2, !turn1, multiplier)

  out
end

out = [0,0]
place1 = 4
place2 = 1

score1 = 0
score2 = 0
turn1 = false

score_all(out, place1, place2, score1, score2, !turn1, 1)

pp out
pp "so the player with the most wins was #{out.index(out.max) == 0 ? "player 1" : "player 2"} with #{out.max}"
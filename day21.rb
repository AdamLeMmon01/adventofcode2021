class Player
  attr_accessor :name, :score, :position
  def initialize(name, position)
    @position = position
    @name = name
    @score = 0
  end
  def turn(die)
    moves = die.roll + die.roll + die.roll
    move(moves)
    @score += @position
  end
  def move(spaces)
    @position += spaces
    while(@position > 10)
      @position -= 10
    end
  end
  def wins?
    @score >= 1000
  end
end

class DeterministicDice
  attr_accessor :count
  def initialize
    @value = 0
    @count = 0
  end
  def roll
    @count += 1
    @value = 0 if @value == 100
    return @value += 1
  end
end

p1 = Player.new("Player 1", 4)
p2 = Player.new("Player 2", 1)
die = DeterministicDice.new

loop do
  p1.turn(die)
  if p1.wins?
    pp "#{p1.name} won. Loser had #{p2.score} points and die was rolled #{die.count} for total of #{p2.score * die.count}"
    break
  end
  p2.turn(die)
  if p2.wins?
    pp "#{p2.name} won. Loser had #{p1.score} points and die was rolled #{die.count} for total of #{p1.score * die.count}"
    break
  end
end




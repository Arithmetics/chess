class Game
  attr_accessor :pieces, :turn


  def initialize
    @turn = "white"
    @pieces = []
    row7 = [Rook,Knight,Bishop,Queen,King,Bishop,Knight,Rook]
    row6 = [Pawn,Pawn,Pawn,Pawn,Pawn,Pawn,Pawn,Pawn]
    row1 = [Pawn,Pawn,Pawn,Pawn,Pawn,Pawn,Pawn,Pawn]
    row0 = [Rook,Knight,Bishop,Queen,King,Bishop,Knight,Rook]

    column = 0
    row7.each do |piece|
      @pieces.push(piece.new([column,7], "black"))
      column += 1
    end

    column = 0
    row6.each do |piece|
      @pieces.push(piece.new([column, 6], "black"))
      column += 1
    end

    column = 0
    row1.each do |piece|
      @pieces.push(piece.new([column, 1], "white"))
      column += 1
    end

    column = 0
    row0.each do |piece|
      @pieces.push(piece.new([column, 0], "white"))
      column += 1
    end
  end


  def print
    squares_array = (" " * 64).split('')
    @pieces.each do |piece|
      x = piece.location[0]
      y = piece.location[1]
      index = (7-y) * 8 + x
      squares_array[index] = (piece.unicode)
    end
    line_1 = (" " + "_"*48 + "\n")
    line_2 = "|" + ("     |"*8 + "\n")
    line_3 = "|"
    8.times do |x|
      sample = squares_array[x]
      line_3 += ("  #{sample}  |")
    end
    line_3 += "\n"
    line_4 = "|" + ("_____|"*8)
    top_square = (line_1 + line_2 + line_3 + line_4)
    puts top_square
    7.times do |y|
      line_2 = "|" + ("     |"*8 + "\n")
      line_3 = "|"
      8.times do |x|
        sample = squares_array[(x+8)+(y*8)]
        line_3 += ("  #{sample}  |")
      end
      line_3 += "\n"
      line_4 = "|" + ("_____|"*8)
      mid_square = (line_2 + line_3 + line_4)
      puts mid_square
    end
  end

  def select_piece(x,y)
    @pieces.find { |piece| piece.location[0] == x && piece.location[1] == y }
  end

  def space_color(x,y)
    if select_piece(x,y)
      select_piece(x,y).color
    else
      nil
    end
  end

  def space_empty?(x,y)
    if !select_piece(x,y)
      true
    else
      false
    end
  end


end



class Piece
  attr_accessor :location, :moved, :shifts, :unicode

  def initialize(location, color)
    @location = location
    @color = color
    @moved = false
  end

  def moved?
    if @moved
      true
    else
      false
    end
  end

  def move(x,y)
    @location[0] = x
    @location[1] = y
  end



end


class Pawn < Piece
  attr_accessor :color

  def unicode
    if @color == "white"
      "\u{265F}"
    else
      "\u{2659}"
    end
  end

  def move(x,y)
    @location[0] = x
    @location[1] = y
  end

end


class Knight < Piece
  attr_accessor :color

  def unicode
    if @color == "white"
      "\u{265E}"
    else
      "\u{2658}"
    end
  end

  def allowed_moves(game)
    allowed_squares = []
    shifts = [[-2,1],[-1,2],[1,2],[2,1],[2,-1],[1,-2],[-1,-2],[-2,-1]]
    shifts.each do |x|
      x[0] += @location[0]
      x[1] += @location[1]
      if x[0] > -1 && x[0] < 8 && x[1] > -1 && x[1] < 9
        allowed_squares.push(x)
      end
    end
    allowed_squares.select! do |square|
      if game.select_piece(square[0],square[1]) == nil
        square
      else
        game.select_piece(square[0],square[1]).color != @color
      end
    end
    allowed_squares
  end




end


class Bishop < Piece
  attr_accessor :color

  def unicode
    if @color == "white"
      "\u{265D}"
    else
      "\u{2657}"
    end
  end

end


class Rook < Piece
  attr_accessor :color

  def unicode
    if @color == "white"
      "\u{265C}"
    else
      "\u{2656}"
    end
  end

end


class Queen < Piece
  attr_accessor :color

  def unicode
    if @color == "white"
      "\u{265B}"
    else
      "\u{2655}"
    end
  end

end


class King < Piece
  attr_accessor :color

  def unicode
    if @color == "white"
      "\u{265A}"
    else
      "\u{2654}"
    end
  end

end

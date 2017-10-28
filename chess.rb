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


  def draw
    squares_array = (" " * 64).split('')
    @pieces.each do |piece|
      x = piece.location[0]
      y = piece.location[1]
      index = (7-y) * 8 + x
      squares_array[index] = (piece.unicode)
    end
    line_1 = ("  " + "_"*48 + "\n")
    line_2 = "7|" + ("     |"*8 + "\n")
    line_3 = " |"
    8.times do |x|
      sample = squares_array[x]
      line_3 += ("  #{sample}  |")
    end
    line_3 += "\n"
    line_4 = " |" + ("_____|"*8)
    top_square = (line_1 + line_2 + line_3 + line_4)
    puts top_square
    7.times do |y|
      line_2 = "#{-y+6}|" + ("     |"*8 + "\n")
      line_3 = " |"
      8.times do |x|
        sample = squares_array[(x+8)+(y*8)]
        line_3 += ("  #{sample}  |")
      end
      line_3 += "\n"
      line_4 = " |" + ("_____|"*8)
      mid_square = (line_2 + line_3 + line_4)
      puts mid_square
    end
    puts "    0     1     2     3     4     5     6     7"
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


  def move_piece(x1,y1,x2,y2)
    #find out if target_square is an allowed move for specific piece
    if select_piece(x1,y1) && select_piece(x1,y1).allowed_moves.find {|move| move == [x2,y2]}
      #diff conditions for line of sight depending of what type of piece is being moved
      continue = false
      if select_piece(x1,y1).class == Pawn
        #pawn moving up and down, will be good
        if cross_view?(x1,y1,x2,y2)
          continue = true
        end
        #but can also take an opposite color piece diagonally
        if select_piece(x1,y1).color == "black"
          if black_pawn_helper(x1,y1,x2,y2)
            continue = true
          end
        #had to make a white method since white moves diff direction
        elsif select_piece(x1,y1).color == "white"
          if white_pawn_helper(x1,y1,x2,y2)
            continue = true
          end
        end


        end
      elsif select_piece(x1,y1).class == Knight
        continue = true
      elsif select_piece(x1,y1).class == Bishop
        if diagonal_view(x1,y1,x2,y2)
          continue = true
        end
      elsif select_piece(x1,y1).class == Rook
        if cross_view(x1,y1,x2,y2)
          continue = true
        end
      elsif select_piece(x1,y1).class == Queen
        if diagonal_view(x1,y1,x2,y2) || cross_view(x1,y1,x2,y2)
          continue = true
        end
      elsif select_piece(x1,y1).class == King
        if diagonal_view(x1,y1,x2,y2) || cross_view(x1,y1,x2,y2)
          continue = true
        end
      end

      #if piece is finally making a fully legal move according to the move rules of the piece
      #exception is for squares occupied by own color, covered here
      if continue
        #is square being moved to occupied? if so, if it's diff color, no move, else, take the piece there
        if !space_empty?(x2,y2)
          if space_color(x2,y2) != space_color(x1,y1)
            delete_piece(x2,y2)
            select_piece(x1,y1).moved = true
            select_piece(x1,y1).location = [x2,y2]
          end
        else
          select_piece(x1,y1).moved = true
          select_piece(x1,y1).location = [x2,y2]
        end
      end


  end #move_piece

  def delete_piece(x,y)
    i = @pieces.find_index { |piece| piece.location[0] == x && piece.location[1] == y }
    @pieces.delete_at(i)
  end #delete_piece

  def diagonal_view?(x1,y1,x2,y2)
    if (x2-x1).abs == (y2-y1).abs
      sight = true
      x_squares = []
      y_squares = []
      if x1 < x2
        ((x1+1)..(x2-1)).to_a.each {|r| x_squares.push(r)}
      else
        ((x2+1)..(x1-1)).to_a.each {|r| x_squares.push(r)}
      end
      if y1 < y2
        ((y1+1)..(y2-1)).to_a.each {|r| y_squares.push(r)}
      else
        ((y2+1)..(y1-1)).to_a.each {|r| y_squares.push(r)}
      end
      x_squares.each_with_index do |x,i|
        if select_piece(x,y_squares[i])
          sight = false
        end
      end
    else
      sight = false
    end
    sight
  end

  def cross_view?(x1,y1,x2,y2)
    if x2 == x1 || y2 == y1
      sight = true
      x_squares = []
      y_squares = []

      if x1 < x2
        ((x1+1)..(x2-1)).to_a.each do |r|
          x_squares.push(r)
          y_squares.push(y1)
        end
      elsif x2 < x1
        ((x2+1)..(x1-1)).to_a.each do |r|
          x_squares.push(r)
          y_squares.push(y1)
        end
      end

      if y1 < y2
        ((y1+1)..(y2-1)).to_a.each do |r|
          y_squares.push(r)
          x_squares.push(x1)
        end
      elsif y2 < y1
        ((y2+1)..(y1-1)).to_a.each do |r|
          y_squares.push(r)
          x_squares.push(x1)
        end
      end

      x_squares.each_with_index do |x,i|
        if select_piece(x,y_squares[i])
          sight = false
        end
      end
    else
      sight = false
    end
    sight
  end

  def white_pawn_helper(x1,y1,x2,y2)
    allowed = true
    if (x1 == (x2 + 1) && y1 == (y2 -1)) || (x1 == (x2 - 1) && y1 == (y2 -1))
      if select_piece(x2,y2) && select_piece(x2,y2).color == "black"
        allowed = true
      else
        allowed = false
      end
    end
  end #white_pawn_helper

  def black_pawn_helper(x1,y1,x2,y2)
    allowed = true
    if (x1 == (x2 - 1) && y1 == (y2 + 1)) || (x1 == (x2 + 1) && y1 == (y2 + 1))
      if select_piece(x2,y2) && select_piece(x2,y2).color == "white"
        allowed = true
      else
        allowed = false
      end
    end
  end #black_pawn_helper

end #GAME



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

  def allowed_moves
    allowed_squares = []

    #creates shifts for each color
    if @color == "black"
      shifts = [[-1,-1],[1,-1],[0,-1],[0,-2]]
    elsif @color == "white"
      shifts = [[1,1],[-1,1],[0,1],[0,2]]
    end
    #removes 2 move if piece has been moved
    if moved?
      shifts.pop
    end
    #find squares in those shift rays
    shifts.each do |r|
      r[0] += @location[0]
      r[1] += @location[1]
      if r[0] > -1 && r[0] < 8 && r[1] > -1 && r[1] < 8
        allowed_squares.push(r)
      end
    end
    allowed_squares
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

  def allowed_moves
    allowed_squares = []
    shifts = [[-2,1],[-1,2],[1,2],[2,1],[2,-1],[1,-2],[-1,-2],[-2,-1]]
    shifts.each do |r|
      r[0] += @location[0]
      r[1] += @location[1]
      if r[0] > -1 && r[0] < 8 && r[1] > -1 && r[1] < 8
        allowed_squares.push(r)
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


  def allowed_moves
    allowed_squares = []
    shifts = []
    #creates diagonal shifts
    8.times do |m|
      if m != 0
        shifts.push([-m,-m])
        shifts.push([-m,m])
        shifts.push([m,-m])
        shifts.push([m,m])
      end
    end
    #find squares in those shift rays
    shifts.each do |r|
      r[0] += @location[0]
      r[1] += @location[1]
      if r[0] > -1 && r[0] < 8 && r[1] > -1 && r[1] < 8
        allowed_squares.push(r)
      end
    end
    allowed_squares
  end

end #BISHOP


class Rook < Piece
  attr_accessor :color

  def unicode
    if @color == "white"
      "\u{265C}"
    else
      "\u{2656}"
    end
  end

  def allowed_moves
    allowed_squares = []
    shifts = []
    #creates diagonal shifts
    8.times do |m|
      if m != 0
        shifts.push([0,-m])
        shifts.push([0,m])
        shifts.push([-m,0])
        shifts.push([m,0])
      end
    end
    #find squares in those shift rays
    shifts.each do |r|
      r[0] += @location[0]
      r[1] += @location[1]
      if r[0] > -1 && r[0] < 8 && r[1] > -1 && r[1] < 8
        allowed_squares.push(r)
      end
    end
    allowed_squares
  end

end # ROOK


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

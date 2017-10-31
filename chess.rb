require 'yaml'

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

  def swap_turn
    if @turn == "black"
      @turn = "white"
    else
      @turn = "black"
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

  def list_all_legal_moves(x1,y1)
    if select_piece(x1,y1)
      piece_moves = select_piece(x1,y1).allowed_moves
      piece_moves.select do |r|
        view?(x1,y1,r[0],r[1]) && (space_color(r[0],r[1]) != space_color(x1,y1))
      end
    end
  end

  def move_piece(x1,y1,x2,y2)
    #find out if target_square is an allowed move for specific piece
    if select_piece(x1,y1) && select_piece(x1,y1).allowed_moves.find {|move| move == [x2,y2]}

      if view?(x1,y1,x2,y2)
        #is square being moved to occupied? if so, if it's diff color, no move, else, take the piece there
        if !space_empty?(x2,y2)
          if space_color(x2,y2) != space_color(x1,y1)
            if !puts_self_in_check?(x1,y1,x2,y2)
              delete_piece(x2,y2)
              select_piece(x1,y1).moved = true
              select_piece(x1,y1).location = [x2,y2]
            end
          end
        else
          if !puts_self_in_check?(x1,y1,x2,y2)
            select_piece(x1,y1).moved = true
            select_piece(x1,y1).location = [x2,y2]
          end
        end
      end
    end
  end #move_piece

  def move_piece_in_shadow_game(x1,y1,x2,y2)
    #find out if target_square is an allowed move for specific piece
    if select_piece(x1,y1) && select_piece(x1,y1).allowed_moves.find {|move| move == [x2,y2]}

      if view?(x1,y1,x2,y2)
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
    end
  end #move_piece

  def dummy_move(x1,y1,x2,y2)
    if select_piece(x1,y1) && select_piece(x1,y1).allowed_moves.find {|move| move == [x2,y2]}

      if view?(x1,y1,x2,y2)
        #is square being moved to occupied? if so, if it's diff color, no move, else, take the piece there
        if !space_empty?(x2,y2)
          if space_color(x2,y2) != space_color(x1,y1)
            deleted_piece = select_piece(x2,y2)
            move_successful = true
          end
        else
          move_successful = true
        end
      end
    end
    return [move_successful, deleted_piece]
  end #move_piece

  def view?(x1,y1,x2,y2)
    #diff conditions for line of sight depending of what type of piece is being moved
    continue = false

    if select_piece(x1,y1).class == Pawn

      #but can also take an opposite color piece diagonally
      if select_piece(x1,y1).color == "black"
        continue = false
        if black_pawn_helper(x1,y1,x2,y2)
          continue = true
        end
      #had to make a white method since white moves diff direction
      elsif select_piece(x1,y1).color == "white"
        continue = false
        if white_pawn_helper(x1,y1,x2,y2)
          continue = true
        end
      end

      #pawn moving up and down, will be good
      if !cross_view?(x1,y1,x2,y2) && !diagonal_view?(x1,y1,x2,y2)
        continue = false
      end

    elsif select_piece(x1,y1).class == Knight
      continue = true

    elsif select_piece(x1,y1).class == Bishop
      if diagonal_view?(x1,y1,x2,y2)
        continue = true
      end

    elsif select_piece(x1,y1).class == Rook
      if cross_view?(x1,y1,x2,y2)
        continue = true
      end

    elsif select_piece(x1,y1).class == Queen
      if diagonal_view?(x1,y1,x2,y2) || cross_view?(x1,y1,x2,y2)
        continue = true
      end

    elsif select_piece(x1,y1).class == King
      if diagonal_view?(x1,y1,x2,y2) || cross_view?(x1,y1,x2,y2)
        continue = true
      end
    end
    continue
  end

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
        swap1 = 1
      else
        ((x2+1)..(x1-1)).to_a.each {|r| x_squares.push(r)}
        swap1 = -1
      end
      if y1 < y2
        ((y1+1)..(y2-1)).to_a.each {|r| y_squares.push(r)}
        swap2 = 1
      else
        ((y2+1)..(y1-1)).to_a.each {|r| y_squares.push(r)}
        swap2 = -1
      end

      if swap1 * swap2 == -1
        y_squares.reverse!
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
    if x1 != x2
      if select_piece(x2,y2) && select_piece(x2,y2).color == "black"
        allowed = true
      else
        allowed = false
      end
    elsif x1 == x2
      if select_piece(x2,y2) && select_piece(x2,y2).color == "black"
        allowed = false
      else
        allowed = true
      end
    end
  end #white_pawn_helper

  def black_pawn_helper(x1,y1,x2,y2)
    allowed = true
    #only allow a diagonal move if space is occupied by piece of opposite color
    if x1 != x2
      if select_piece(x2,y2) && select_piece(x2,y2).color == "white"
        allowed = true
      else
        allowed = false
      end
      #only allow a straight move is space is unoccupied by piece of opposite color
    elsif x1 == x2
      if select_piece(x2,y2) && select_piece(x2,y2).color == "white"
        allowed = false
      else
        allowed = true
      end
    end
  end #black_pawn_helper

  def player_in_check?
    king_at_risk = false
    @pieces.each do |piece|
      if piece.color != @turn
        list_all_legal_moves(piece.location[0],piece.location[1]).each do |legal_move|
          move_check = dummy_move(piece.location[0],piece.location[1],legal_move[0],legal_move[1])
          if move_check[1].class == King
            king_at_risk = true
          end
        end
      end
    end
    king_at_risk
  end

  def puts_self_in_check?(x1,y1,x2,y2)
    potential_game = Game.new
    potential_game.turn = self.turn
    potential_game.pieces = []
    self.pieces.each do |piece|
      potential_game.pieces.push(piece.clone)
    end
    potential_game.move_piece_in_shadow_game(x1,y1,x2,y2)

    king_at_risk = false
    potential_game.pieces.each do |piece|
      if piece.color != @turn
        potential_game.list_all_legal_moves(piece.location[0],piece.location[1]).each do |legal_move|
          move_check = potential_game.dummy_move(piece.location[0],piece.location[1],legal_move[0],legal_move[1])
          if move_check[1].class == King
            king_at_risk = true
          end
        end
      end
    end
    king_at_risk
  end

  def player_in_checkmate?
    if player_in_check?
      checkmate = true
      @pieces.each do |piece|
        if piece.color == @turn
          list_all_legal_moves(piece.location[0],piece.location[1]).each do |legal_move|
            if !puts_self_in_check?(piece.location[0],piece.location[1],legal_move[0],legal_move[1])
              checkmate = false
            end
          end
        end
      end
    else
      checkmate = false
    end
    checkmate
  end

  def stalemate?
    if !player_in_check?
      stalemate = true
      @pieces.each do |piece|
        if piece.color == @turn
          list_all_legal_moves(piece.location[0],piece.location[1]).each do |legal_move|
            if !puts_self_in_check?(piece.location[0],piece.location[1],legal_move[0],legal_move[1])
              stalemate = false
            end
          end
        end
      end
    else
      stalemate = false
    end
    stalemate
  end

  def pawn_conversion
    #white pawns
    @pieces.select do |piece|
     if piece.class == Pawn && piece.color == "white" && piece.location[1] == 7
       x = piece.location[0]
       y = piece.location[1]
       delete_piece(x,y)
       choices = [Rook,Knight,Bishop,Queen]
       p choices
       pick = -1
       until pick > -1 && pick < choices.length
         puts 'pick with array number format what this piece is to become'
         pick = gets.chomp.to_i
       end
       @pieces.push(choices[pick].new([x,y],"white"))
     end
    end
    #black pawns
    @pieces.select do |piece|
     if piece.class == Pawn && piece.color == "black" && piece.location[1] == 0
       x = piece.location[0]
       y = piece.location[1]
       delete_piece(x,y)
       choices = [Rook,Knight,Bishop,Queen]
       p choices
       pick = -1
       until pick > -1 && pick < choices.length
         puts 'pick what this piece is to become'
         pick = gets.chomp.to_i
       end
       @pieces.push(choices[pick].new([x,y],"black"))
     end
    end
  end

  def castle_right_white
    allowed = false
    #no pieces in between
    if !select_piece(5,0) && !select_piece(6,0)
      #king and rook havnt been moved
      if !select_piece(4,0).moved? && !select_piece(7,0).moved?
        #check other color pieces to confirm the middle squares are not threatened
        allowed = true
        @pieces.each do |piece|
          if piece.color != @turn
            list_all_legal_moves(piece.location[0],piece.location[1]).each do |move|
              if move == [5,0] || move == [6,0]
                allowed = false
              end
            end
          end
        end
      end
    end
    if allowed && !player_in_check?
      select_piece(4,0).location = [6,0]
      select_piece(7,0).location = [5,0]
    end
  end

  def castle_left_white
    allowed = false
    #no pieces in between
    if !select_piece(1,0) && !select_piece(2,0) && !select_piece(3,0)
      #king and rook havnt been moved
      if !select_piece(0,0).moved? && !select_piece(4,0).moved?
        #check other color pieces to confirm the middle squares are not threatened
        allowed = true
        @pieces.each do |piece|
          if piece.color != @turn
            list_all_legal_moves(piece.location[0],piece.location[1]).each do |move|
              if move == [1,0] || move == [2,0] || move == [3,0]
                allowed = false
              end
            end
          end
        end
      end
    end
    #also cant castle if in check
    if allowed && !player_in_check?
      select_piece(4,0).location = [2,0]
      select_piece(0,0).location = [3,0]
    end
  end

  def castle_right_black
    allowed = false
    #no pieces in between
    if !select_piece(5,7) && !select_piece(6,7)
      #king and rook havnt been moved
      if !select_piece(4,7).moved? && !select_piece(7,7).moved?
        #check other color pieces to confirm the middle squares are not threatened
        allowed = true
        @pieces.each do |piece|
          if piece.color != @turn
            list_all_legal_moves(piece.location[0],piece.location[1]).each do |move|
              if move == [5,7] || move == [6,7]
                allowed = false
              end
            end
          end
        end
      end
    end
    #also cant castle if in check
    if allowed && !player_in_check?
      select_piece(4,7).location = [6,7]
      select_piece(7,7).location = [5,7]
    end
  end

  def castle_left_black
    allowed = false
    #no pieces in between
    if !select_piece(1,7) && !select_piece(2,7) && !select_piece(3,7)
      #king and rook havnt been moved
      if !select_piece(0,7).moved? && !select_piece(4,7).moved?
        #check other color pieces to confirm the middle squares are not threatened
        allowed = true
        @pieces.each do |piece|
          if piece.color != @turn
            list_all_legal_moves(piece.location[0],piece.location[1]).each do |move|
              if move == [1,7] || move == [2,7] || move == [3,7]
                allowed = false
              end
            end
          end
        end
      end
    end
    #also cant castle if in check
    if allowed && !player_in_check?
      select_piece(4,7).location = [2,7]
      select_piece(0,7).location = [3,7]
    end
  end

  def get_castle_direction
    puts "please choose left or right"
    x = ""
    until x == "left" || x == "right"
      x = gets.chomp.to_s
    end
    x
  end

  def make_player_castle
    success = false
    direction = get_castle_direction
    if @turn == "white"
      if direction == "right" && castle_right_white
        success = true
      elsif direction == "left" && castle_left_white
        success = true
      end
    elsif @turn == "black"
      if direction == "right" && castle_right_black
        success = true
      elsif direction == "left" && castle_left_black
        success = true
      end
    end
    success
  end

  def get_player_turn_input
    choices = ["move", "castle", "save game"]
    input = ""
    until choices.any? {|x| x == input}
      puts "please choose an option:"
      p choices
      input = gets.chomp.to_s
    end
    input
  end

  def get_player_move
    puts "create a move in format [x1,y1,x2,y2]"
    puts "enter x1"
    x1 = gets.chomp.to_i
    puts "enter y1"
    y1 = gets.chomp.to_i
    puts "enter x2"
    x2 = gets.chomp.to_i
    puts "enter y2"
    y2 = gets.chomp.to_i
    input = [x1,y1,x2,y2]
   until input.all? { |x| x.class == Fixnum && x > -1 && x < 9 }
     puts "create a move in format [x1,y1,x2,y2]"
     puts "enter x1"
     x1 = gets.chomp.to_i
     puts "enter y1"
     y1 = gets.chomp.to_i
     puts "enter x2"
     x2 = gets.chomp.to_i
     puts "enter y2"
     y2 = gets.chomp.to_i
     input = [x1,y1,x2,y2]
   end
   input
  end

  def make_player_move
    moved = false
    input = get_player_move
    if input.any? {|x| x != nil }
      if select_piece(input[0],input[1]).color == @turn && move_piece(input[0],input[1],input[2],input[3])
        moved = true
        pawn_conversion
      end
    end
    moved
  end

  def save
    puts "what should we name your saved game?"
    input = gets.chomp.to_s
    save_game(self,input)
  end

  def save_game(game, name)
    File.open("saved_games/#{name}.yaml", "w") do |file|
      file.puts YAML::dump(game)
    end
    puts "game saved, should be here for you when you come back!"
    puts "saved game with name #{name}"
  end

  def game_flow


    until player_in_checkmate? || stalemate?
      draw
      puts "\n It is #{@turn}'s turn \n"
      if player_in_check?
        puts "#{@turn} is in check!"
      end
      input = get_player_turn_input
      if input == "save game"
        save
      elsif input == "castle"
        if make_player_castle
          swap_turn
        else
          puts "not a legal move"
        end
      elsif input == "move"
        if make_player_move
          swap_turn
        else
          puts "not a legal move"
        end
      end
    end #checkmate or stalemate?

    if player_in_checkmate?
      puts "#{@turn} is in checkmate! game over"
      exit
    elsif stalemate?
      puts "that's stalemate! game over"
      exit
    end

  end #game_flow

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
    #creates cross shifts
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


  def allowed_moves
    allowed_squares = []
    shifts = []
    #creates cross shifts
    8.times do |m|
      if m != 0
        shifts.push([0,-m])
        shifts.push([0,m])
        shifts.push([-m,0])
        shifts.push([m,0])
      end
    end
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

  def allowed_moves
    allowed_squares = []
    shifts = [[0,1],[0,-1],[1,0],[1,-1],[1,1],[-1,0],[-1,1],[-1,-1]]
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

def startup_game
  puts 'hello, welcome to chess!'
  choice = 0
  until choice == 1 || choice == 2
    puts "Please select a choice"
    puts "1) New Game \n2) Load Game"
    choice = gets.chomp.to_i
  end
  if choice == 1
    game = Game.new
    game.game_flow
  elsif choice == 2
    chosen_game = -1
    until chosen_game > -1 && chosen_game < (list_saved_games.length + 1)
      puts "please choose a game"
      list_saved_games
      chosen_game = gets.chomp.to_i
    end
    chosen_game_string = list_saved_games[chosen_game-1]
    game = load_game(chosen_game_string)
    puts "nice, you loaded a game"
    game.game_flow
  end
end

def list_saved_games
  games = Dir["./saved_games/*.yaml"]
  games.map! { |x| x.scan(/(?<=saved_games\/)(.*)(?=\.yaml)/)  }
  games.flatten!
  games.each_with_index {|x,i| puts "#{i+1}) #{x} \n"}
end

def load_game(name)
  array = []
  $/="\n\n"
  File.open("saved_games/#{name}.yaml", "r").each do |object|
    array << YAML::load(object)
  end
  array[0]
end

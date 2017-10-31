require 'minitest/autorun'
require_relative 'chess'



class PawnTest < Minitest::Test

  def setup
    @game = Game.new
    @game.pieces = []
    @game.pieces.push(King.new([4,0], "white"))
    @game.pieces.push(Pawn.new([3,3], "white"))
    @game.pieces.push(Pawn.new([6,3], "white"))
    @game.pieces.push(Pawn.new([7,1], "white"))
    @game.pieces.push(Pawn.new([1,1], "white"))
    @game.pieces.push(Pawn.new([0,1], "white"))
    @game.pieces.push(King.new([4,7], "black"))
    @game.pieces.push(Pawn.new([6,4], "black"))
    @game.pieces.push(Pawn.new([4,4], "black"))
    @game.pieces.push(Pawn.new([1,2], "black"))
    @game.pieces.push(Pawn.new([6,1], "black"))
    @game.pieces.push(Pawn.new([0,3], "black"))
    @game.pieces.push(Pawn.new([0,6], "black"))
    @game.pieces.push(Pawn.new([1,5], "black"))
  end

  def test_move_one_square_forward_from_start_row
    assert @game.move_piece(7,1,7,2)
  end

  def test_move_two_square_forward_from_start_row
    assert @game.move_piece(7,1,7,3)
  end

  def test_no_double_move_after_moved
    assert @game.move_piece(7,1,7,2)
    refute @game.move_piece(7,2,7,4)
  end

  def test_no_double_through_piece
    refute @game.move_piece(1,1,1,3)
  end

  def test_no_double_into_piece
    refute @game.move_piece(0,1,0,3)
  end

  def test_no_taking_on_straight_away
    refute @game.move_piece(1,1,1,2)
  end

  def test_take_piece_on_diagonal
    assert @game.move_piece(3,3,4,4)
  end

  def test_no_move_diagonal
    refute @game.move_piece(3,3,2,4)
  end

  def test_no_double_move_diagonal
    refute @game.move_piece(3,3,1,5)
  end

  def test_no_take_own_pieces
    refute @game.move_piece(0,6,1,5)
  end

  def test_cant_move_backwards
    refute @game.move_piece(6,3,6,2)
    refute @game.move_piece(6,4,6,5)
  end


end

class KnightTest < Minitest::Test

  def setup
    @game = Game.new
    @game.pieces = []
    @game.pieces.push(King.new([4,0], "white"))
    @game.pieces.push(Pawn.new([3,3], "white"))
    @game.pieces.push(Pawn.new([6,3], "white"))
    @game.pieces.push(Pawn.new([7,1], "white"))
    @game.pieces.push(Pawn.new([1,1], "white"))
    @game.pieces.push(Pawn.new([0,1], "white"))
    @game.pieces.push(King.new([4,7], "black"))
    @game.pieces.push(Pawn.new([6,4], "black"))
    @game.pieces.push(Pawn.new([4,4], "black"))
    @game.pieces.push(Pawn.new([1,2], "black"))
    @game.pieces.push(Pawn.new([6,1], "black"))
    @game.pieces.push(Pawn.new([0,3], "black"))
    @game.pieces.push(Knight.new([3,4], "white"))
  end

  def test_basic_moves_8_directions
   assert @game.move_piece(3,4,1,5)
   assert @game.move_piece(1,5,3,4)
   assert @game.move_piece(3,4,2,6)
   assert @game.move_piece(2,6,3,4)
   assert @game.move_piece(3,4,4,6)
   assert @game.move_piece(4,6,3,4)
   assert @game.move_piece(3,4,5,5)
   assert @game.move_piece(5,5,3,4)
  end

  def test_jump_over_white_and_black
    assert @game.move_piece(3,4,4,2)
  end

  def test_dont_take_own_piece
    assert @game.move_piece(3,4,5,5)
  end

  def test_no_straight_moves
    refute @game.move_piece(3,4,5,4)
  end

  def test_take_other_color
    assert @game.move_piece(3,4,1,5)
    assert @game.move_piece(1,5,0,3)
  end



end

class BishopTest < Minitest::Test

  def setup
    @game = Game.new
    @game.pieces = []
    @game.pieces.push(King.new([4,0], "white"))
    @game.pieces.push(Pawn.new([6,3], "white"))
    @game.pieces.push(Pawn.new([7,1], "white"))
    @game.pieces.push(Pawn.new([0,1], "white"))
    @game.pieces.push(King.new([4,7], "black"))
    @game.pieces.push(Pawn.new([6,4], "black"))
    @game.pieces.push(Pawn.new([1,2], "black"))
    @game.pieces.push(Pawn.new([0,3], "black"))
    @game.pieces.push(Pawn.new([0,6], "black"))
    @game.pieces.push(Pawn.new([1,5], "black"))
    @game.pieces.push(Pawn.new([2,3], "black"))
    @game.pieces.push(Pawn.new([2,6], "black"))
    @game.pieces.push(Bishop.new([7,7], "white"))
    @game.pieces.push(Bishop.new([7,0], "black"))
  end

  def test_move_in_all_4_directions
    assert @game.move_piece(7,7,0,0)
    assert @game.move_piece(0,0,7,7)
    assert @game.move_piece(7,0,0,7)
    assert @game.move_piece(0,7,7,0)
  end

  def test_take_opposite_color
    assert @game.move_piece(1,2,1,1)
    assert @game.move_piece(7,7,1,1)
  end

  def test_dont_take_own_piece
    assert @game.move_piece(2,6,2,5)
    refute @game.move_piece(7,0,2,5)
  end

  def test_cant_move_if_path_blocked_own_piece
    assert @game.move_piece(2,6,2,5)
    refute @game.move_piece(7,0,7,7)
  end

  def test_cant_move_if_path_blocked_other_piece
    assert @game.move_piece(1,2,1,1)
    refute @game.move_piece(7,7,0,0)
  end


end

class RookTest < Minitest::Test

  def setup
    @game = Game.new
    @game.pieces = []
    @game.pieces.push(King.new([4,0], "white"))
    @game.pieces.push(Pawn.new([6,3], "white"))
    @game.pieces.push(Pawn.new([7,1], "white"))
    @game.pieces.push(Pawn.new([0,1], "white"))
    @game.pieces.push(King.new([4,7], "black"))
    @game.pieces.push(Pawn.new([6,4], "black"))
    @game.pieces.push(Pawn.new([1,2], "black"))
    @game.pieces.push(Pawn.new([0,3], "black"))
    @game.pieces.push(Pawn.new([0,6], "black"))
    @game.pieces.push(Pawn.new([1,5], "black"))
    @game.pieces.push(Pawn.new([2,3], "black"))
    @game.pieces.push(Pawn.new([2,6], "black"))
    @game.pieces.push(Bishop.new([7,7], "white"))
    @game.pieces.push(Bishop.new([7,0], "black"))
  end

  def test_move_in_all_4_directions

  end

  def test_take_opposite_color

  end

  def test_dont_take_own_piece

  end

  def test_cant_move_if_path_blocked_own_piece

  end

  def test_cant_move_if_path_blocked_other_piece

  end


end

class QueenTest < Minitest::Test

  def setup
    @game = Game.new
    @game.pieces = []
    @game.pieces.push(King.new([4,0], "white"))
    @game.pieces.push(Pawn.new([6,3], "white"))
    @game.pieces.push(Pawn.new([7,1], "white"))
    @game.pieces.push(Pawn.new([0,1], "white"))
    @game.pieces.push(King.new([4,7], "black"))
    @game.pieces.push(Pawn.new([6,4], "black"))
    @game.pieces.push(Pawn.new([1,2], "black"))
    @game.pieces.push(Pawn.new([0,3], "black"))
    @game.pieces.push(Pawn.new([0,6], "black"))
    @game.pieces.push(Pawn.new([1,5], "black"))
    @game.pieces.push(Pawn.new([2,3], "black"))
    @game.pieces.push(Pawn.new([2,6], "black"))
    @game.pieces.push(Bishop.new([7,7], "white"))
    @game.pieces.push(Bishop.new([7,0], "black"))
  end

  def test_move_in_all_4_directions

  end

  def test_take_opposite_color

  end

  def test_dont_take_own_piece

  end

  def test_cant_move_if_path_blocked_own_piece

  end

  def test_cant_move_if_path_blocked_other_piece

  end


end

class KingTest < Minitest::Test

  def setup
    @game = Game.new
    @game.pieces = []
    @game.pieces.push(King.new([4,0], "white"))
    @game.pieces.push(Pawn.new([6,3], "white"))
    @game.pieces.push(Pawn.new([7,1], "white"))
    @game.pieces.push(Pawn.new([0,1], "white"))
    @game.pieces.push(King.new([4,7], "black"))
    @game.pieces.push(Pawn.new([6,4], "black"))
    @game.pieces.push(Pawn.new([1,2], "black"))
    @game.pieces.push(Pawn.new([0,3], "black"))
    @game.pieces.push(Pawn.new([0,6], "black"))
    @game.pieces.push(Pawn.new([1,5], "black"))
    @game.pieces.push(Pawn.new([2,3], "black"))
    @game.pieces.push(Pawn.new([2,6], "black"))
    @game.pieces.push(Bishop.new([7,7], "white"))
    @game.pieces.push(Bishop.new([7,0], "black"))
  end

  def test_move_in_all_4_directions

  end

  def test_take_opposite_color

  end

  def test_dont_take_own_piece

  end

  def test_cant_move_if_path_blocked_own_piece

  end

  def test_cant_move_if_path_blocked_other_piece

  end


end

class CheckTest < Minitest::Test

  def setup
    @game = Game.new
    @game.pieces = []
    @game.pieces.push(King.new([4,0], "white"))
    @game.pieces.push(Pawn.new([6,3], "white"))
    @game.pieces.push(Pawn.new([7,1], "white"))
    @game.pieces.push(Pawn.new([0,1], "white"))
    @game.pieces.push(King.new([4,7], "black"))
    @game.pieces.push(Pawn.new([6,4], "black"))
    @game.pieces.push(Pawn.new([1,2], "black"))
    @game.pieces.push(Pawn.new([0,3], "black"))
    @game.pieces.push(Pawn.new([0,6], "black"))
    @game.pieces.push(Pawn.new([1,5], "black"))
    @game.pieces.push(Pawn.new([2,3], "black"))
    @game.pieces.push(Pawn.new([2,6], "black"))
    @game.pieces.push(Bishop.new([7,7], "white"))
    @game.pieces.push(Bishop.new([7,0], "black"))
  end

  def test_move_in_all_4_directions

  end

  def test_take_opposite_color

  end

  def test_dont_take_own_piece

  end

  def test_cant_move_if_path_blocked_own_piece

  end

  def test_cant_move_if_path_blocked_other_piece

  end


end

class CheckmateTest < Minitest::Test

  def setup
    @game = Game.new
    @game.pieces = []
    @game.pieces.push(King.new([4,0], "white"))
    @game.pieces.push(Pawn.new([6,3], "white"))
    @game.pieces.push(Pawn.new([7,1], "white"))
    @game.pieces.push(Pawn.new([0,1], "white"))
    @game.pieces.push(King.new([4,7], "black"))
    @game.pieces.push(Pawn.new([6,4], "black"))
    @game.pieces.push(Pawn.new([1,2], "black"))
    @game.pieces.push(Pawn.new([0,3], "black"))
    @game.pieces.push(Pawn.new([0,6], "black"))
    @game.pieces.push(Pawn.new([1,5], "black"))
    @game.pieces.push(Pawn.new([2,3], "black"))
    @game.pieces.push(Pawn.new([2,6], "black"))
    @game.pieces.push(Bishop.new([7,7], "white"))
    @game.pieces.push(Bishop.new([7,0], "black"))
  end

  def test_move_in_all_4_directions

  end

  def test_take_opposite_color

  end

  def test_dont_take_own_piece

  end

  def test_cant_move_if_path_blocked_own_piece

  end

  def test_cant_move_if_path_blocked_other_piece

  end


end

class CheckTest < Minitest::Test

  def setup
    @game = Game.new
    @game.pieces = []
    @game.pieces.push(King.new([4,0], "white"))
    @game.pieces.push(Pawn.new([6,3], "white"))
    @game.pieces.push(Pawn.new([7,1], "white"))
    @game.pieces.push(Pawn.new([0,1], "white"))
    @game.pieces.push(King.new([4,7], "black"))
    @game.pieces.push(Pawn.new([6,4], "black"))
    @game.pieces.push(Pawn.new([1,2], "black"))
    @game.pieces.push(Pawn.new([0,3], "black"))
    @game.pieces.push(Pawn.new([0,6], "black"))
    @game.pieces.push(Pawn.new([1,5], "black"))
    @game.pieces.push(Pawn.new([2,3], "black"))
    @game.pieces.push(Pawn.new([2,6], "black"))
    @game.pieces.push(Bishop.new([7,7], "white"))
    @game.pieces.push(Bishop.new([7,0], "black"))
  end

  def test_move_in_all_4_directions

  end

  def test_take_opposite_color

  end

  def test_dont_take_own_piece

  end

  def test_cant_move_if_path_blocked_own_piece

  end

  def test_cant_move_if_path_blocked_other_piece

  end


end

class StalemateTest < Minitest::Test

  def setup
    @game = Game.new
    @game.pieces = []
    @game.pieces.push(King.new([4,0], "white"))
    @game.pieces.push(Pawn.new([6,3], "white"))
    @game.pieces.push(Pawn.new([7,1], "white"))
    @game.pieces.push(Pawn.new([0,1], "white"))
    @game.pieces.push(King.new([4,7], "black"))
    @game.pieces.push(Pawn.new([6,4], "black"))
    @game.pieces.push(Pawn.new([1,2], "black"))
    @game.pieces.push(Pawn.new([0,3], "black"))
    @game.pieces.push(Pawn.new([0,6], "black"))
    @game.pieces.push(Pawn.new([1,5], "black"))
    @game.pieces.push(Pawn.new([2,3], "black"))
    @game.pieces.push(Pawn.new([2,6], "black"))
    @game.pieces.push(Bishop.new([7,7], "white"))
    @game.pieces.push(Bishop.new([7,0], "black"))
  end

  def test_move_in_all_4_directions

  end

  def test_take_opposite_color

  end

  def test_dont_take_own_piece

  end

  def test_cant_move_if_path_blocked_own_piece

  end

  def test_cant_move_if_path_blocked_other_piece

  end


end

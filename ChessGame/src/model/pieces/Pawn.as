package model.pieces 
{
	import model.pieces.Piece;
	import model.MatchMgr;
	
	public class Pawn extends Piece 
	{
		
		public function Pawn(team:int, x:int, y:int) 
		{
			super(team, x, y);
		}
		
		override public function GetType():int
		{
			return Constants.TYPE_PAWN;
		}
		
		//Pawns are special as they can only move diagonally if attacking
		override public function CanAttack(index:int):Boolean
		{
			var x:int = index % Constants.BOARD_SIZE;
			var y:int = index / Constants.BOARD_SIZE;
			var direction:int = (m_team == Constants.TEAM_WHITE) ? -1 : 1;
			
			if ( Math.abs(x - m_xPos) == 1
				&& y == (m_yPos + direction))
			{
				return true;
			}
			return false;
		}
		
		//Move is only called if the tile is empty
		override public function CanMove(index:int):Boolean
		{
			var x:int = index % Constants.BOARD_SIZE;
			
			if ( x == m_xPos)
			{
				return m_possibleTiles.indexOf(index) >= 0;
			}
			return false;
		}
		
		override protected function UpdateAvailableMoves():void
		{
			m_possibleTiles.splice(0, m_possibleTiles.splice);
			var direction:int = (m_team == Constants.TEAM_WHITE) ? -1 : 1;
			
			if (AddIfValidAttackOrMove(m_xPos, m_yPos + direction) && !m_hasMoved)
			{
				AddIfValidAttackOrMove(m_xPos, m_yPos + 2 * direction);
			}
			
			//Check attack moves
			AddIfValidAttackOrMove(m_xPos - 1, m_yPos + direction);
			AddIfValidAttackOrMove(m_xPos + 1, m_yPos + direction)
			
			//FIXME: En Passant Case
		}
		
	}

}
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
		
		override public function Clone():Piece
		{
			var copy:Pawn = new Pawn(m_team, m_xPos, m_yPos);
			copy.m_hasMoved = m_hasMoved;
			for (var i:int = 0; i < m_possibleTiles.length; i++)
			{
				copy.m_possibleTiles.push(m_possibleTiles[i]);
			}
			return copy;
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
			else if (MatchMgr.GetInstance().IsEnPassantAvailable(m_team) 
				&& m_possibleTiles.indexOf(index) >= 0
				&& MatchMgr.GetInstance().GetAvailableEnPassantSpace() == index)
			{
				//En passant case
				return true;
			}
			return false;
		}
		
		override protected function UpdateAvailableMoves():void
		{
			m_possibleTiles.splice(0, m_possibleTiles.length);
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
		
		override public function MovePiece(x:int, y:int):void
		{
			//The first leap is the only time when en passant may be triggered
			if (!m_hasMoved && Math.abs(y - m_yPos) > 1)
			{
				MatchMgr.GetInstance().SignalEnPassant(x, y);
			}
			super.MovePiece(x, y);
		}
		
		public function AddEnPassant(targetX:int, targetY:int):void 
		{
			m_possibleTiles.push(MatchMgr.GetInstance().GetTileIndex(targetX, targetY));
		}
		
	}

}
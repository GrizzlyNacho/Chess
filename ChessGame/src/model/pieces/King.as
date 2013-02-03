package model.pieces 
{
	import model.MatchMgr;
	
	public class King extends Piece 
	{
		private var m_watchTiles:Array = null;
		
		public function King(team:int, x:int, y:int) 
		{
			super(team, x, y);
			m_watchTiles = new Array();
		}
		
		override public function Clone():Piece
		{
			var copy:King = new King(m_team, m_xPos, m_yPos);
			copy.m_hasMoved = m_hasMoved;
			for (var i:int = 0; i < m_possibleTiles.length; i++)
			{
				copy.m_possibleTiles.push(m_possibleTiles[i]);
			}
			return copy;
		}
		
		override public function GetType():int
		{
			return Constants.TYPE_KING;
		}
		
		override public function MovePiece(x:int, y:int):void
		{
			if (!m_hasMoved && Math.abs(x - m_xPos) > 1)
			{
				//Castling is happening. Cue the Manager
				if (x > m_xPos)
				{
					MatchMgr.GetInstance().TriggerCastlingOnRook(
						MatchMgr.GetInstance().GetTileIndex(7, m_yPos), MatchMgr.GetInstance().GetTileIndex(x - 1, m_yPos));
				}
				else
				{
					MatchMgr.GetInstance().TriggerCastlingOnRook(
						MatchMgr.GetInstance().GetTileIndex(0, m_yPos), MatchMgr.GetInstance().GetTileIndex(x + 1, m_yPos));
				}
				
			}
			super.MovePiece(x, y);
		}
		
		//King also has to consider the watch list
		override public function CheckUpdate(movedFromIndex:int, movedToIndex:int):void
		{
			if ((m_possibleTiles && (m_possibleTiles.indexOf(movedFromIndex) >= 0 || m_possibleTiles.indexOf(movedToIndex) >= 0))
				|| (m_watchTiles && (m_watchTiles.indexOf(movedFromIndex) >= 0 || m_watchTiles.indexOf(movedToIndex) >= 0)))
			{
				UpdateAvailableMoves();
			}
		}
		
		override public function CanMove(index:int):Boolean
		{
			var x:int = index % Constants.BOARD_SIZE;
			//There are watch spaces in the king's possible tile list.
			//We have to filter those out when it comes to determining moves
			if (Math.abs(x - m_xPos) > 2)
			{
				return false;
			}
			return m_possibleTiles.indexOf(index) >= 0;
		}
		
		override protected function UpdateAvailableMoves():void
		{
			m_possibleTiles.splice(0, m_possibleTiles.length);
			m_watchTiles.splice(0, m_watchTiles.length);
			
			
			
			//Add one tile in each direction
			AddIfValidAttackOrMove(m_xPos + 1, m_yPos);
			AddIfValidAttackOrMove(m_xPos - 1, m_yPos);
			AddIfValidAttackOrMove(m_xPos, m_yPos + 1);
			AddIfValidAttackOrMove(m_xPos, m_yPos - 1);
			AddIfValidAttackOrMove(m_xPos + 1, m_yPos + 1);
			AddIfValidAttackOrMove(m_xPos + 1, m_yPos - 1);
			AddIfValidAttackOrMove(m_xPos - 1, m_yPos + 1);
			AddIfValidAttackOrMove(m_xPos - 1, m_yPos - 1);
			
			//Add teh castling options
			if (!m_hasMoved)
			{	
				//Watch the home row for updates for the king (as any updates may change the castling regs.
				for (var i:int = 0; i < Constants.BOARD_SIZE; i++)
				{
					m_watchTiles.push(MatchMgr.GetInstance().GetTileIndex(i, m_yPos));
				}
				
				AddCastlingToRookAt(0, m_yPos);
				AddCastlingToRookAt(7, m_yPos);
			}
		}
		
		private function AddCastlingToRookAt(x:int, y:int):void
		{
			//We don't need to check team as enemy rooks would have had to move
			if(!MatchMgr.GetInstance().GetTileHasMoved(x, y)
					&& MatchMgr.GetInstance().GetTileType(x, y) == Constants.TYPE_ROOK)
			{
				var direction:int = (x > m_xPos) ? 1 : -1;
				
				//Determine if the spaces between are empty
				var canCastle:Boolean = true;
				for (var i:int = m_xPos + direction; i < Constants.BOARD_SIZE && i >= 0; i += direction)
				{
					var tileType:int = MatchMgr.GetInstance().GetTileType(i, m_yPos);
					if (tileType != Constants.TYPE_NO_PIECE
						&& (tileType != Constants.TYPE_ROOK || MatchMgr.GetInstance().GetTileHasMoved(i, m_yPos)))
					{
						canCastle = false;
					}
				}
				
				//Are any of the spaces involved for the king in check?
				if (canCastle 
					&& !MatchMgr.GetInstance().IsTileInCheck(m_team, MatchMgr.GetInstance().GetTileIndex(m_xPos + direction, m_yPos))
					&& !MatchMgr.GetInstance().IsTileInCheck(m_team, MatchMgr.GetInstance().GetTileIndex(m_xPos + 2 * direction, m_yPos))
					&& !MatchMgr.GetInstance().IsTileInCheck(m_team, MatchMgr.GetInstance().GetTileIndex(m_xPos, m_yPos)))
				{
					m_possibleTiles.push(MatchMgr.GetInstance().GetTileIndex(m_xPos + 2 * direction, m_yPos));
				}
			}
		}
	}

}
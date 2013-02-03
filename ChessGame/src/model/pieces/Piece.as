package model.pieces 
{
	import model.MatchMgr;
	
	//Base class for all piece types
	public class Piece 
	{
		protected var m_hasMoved:Boolean = false;
		protected var m_team:int = Constants.TEAM_NONE;
		
		public function Piece(team:int) 
		{
			m_team = team;
		}
		
		public function GetType():int
		{
			//Override in children
			return Constants.TYPE_NO_PIECE;
		}
		
		public function GetAvailableMovesFrom(x:int, y:int):Array
		{
			//Override in children
			return null;
		}
		
		public function GetTeam():int 
		{
			return m_team;
		}
		
		
		//Determines if the move is possible or not and returns true if it is added.
		protected function AddIfValidAttackOrMove(x:int, y:int, outMoves:Array):Boolean
		{
			if (IsMoveInBounds(x, y))
			{
				var tileType:int =  MatchMgr.GetInstance().GetTileType(x, y);
				var tileTeam:int = MatchMgr.GetInstance().GetTileTeam(x, y);
				
				//Either unoccupied or occupied by an enemy piece
				if (tileType == Constants.TYPE_NO_PIECE 
					|| (tileType != Constants.TYPE_NO_PIECE && tileTeam != m_team))
				{
					outMoves.push(MatchMgr.GetInstance().GetTileIndex(x, y));
					return true;
				}
			}
			return false;
		}
		
		protected function IsMoveInBounds(x:int, y:int):Boolean
		{
			return (x >= 0 && y >= 0 && x < Constants.BOARD_SIZE && y < Constants.BOARD_SIZE);
		}
		
	}

}
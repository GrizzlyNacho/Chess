package model.pieces 
{
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
		
		
		protected function IsMoveInBounds(x:int, y:int):Boolean
		{
			return (x >= 0 && y >= 0 && x < Constants.BOARD_SIZE && y < Constants.BOARD_SIZE);
		}
		
	}

}
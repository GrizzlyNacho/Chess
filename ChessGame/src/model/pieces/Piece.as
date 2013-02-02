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
		
		public function GetTeam():int 
		{
			return m_team;
		}
		
	}

}
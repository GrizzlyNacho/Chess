package model.pieces 
{

	public class Rook extends Piece 
	{
		
		public function Rook(team:int, x:int, y:int) 
		{
			super(team, x, y);		
		}
		
		override public function Clone():Piece
		{
			var copy:Rook = new Rook(m_team, m_xPos, m_yPos);
			copy.m_hasMoved = m_hasMoved;
			for (var i:int = 0; i < m_possibleTiles.length; i++)
			{
				copy.m_possibleTiles.push(m_possibleTiles[i]);
			}
			return copy;
		}
		
		override public function GetType():int
		{
			return Constants.TYPE_ROOK;
		}
		
		override protected function UpdateAvailableMoves():void
		{
			m_possibleTiles.splice(0, m_possibleTiles.length);
			
			//Try each cardinal direction
			var i:int = 1;
			//Left
			for (i = 1;  AddIfValidAttackOrMove(m_xPos - i, m_yPos); i++)
			{ }
			
			//Right
			for (i = 1;  AddIfValidAttackOrMove(m_xPos + i, m_yPos); i++)
			{ }
			
			//Up
			for (i = 1;  AddIfValidAttackOrMove(m_xPos, m_yPos - i); i++)
			{ }
			
			//Down
			for (i = 1;  AddIfValidAttackOrMove(m_xPos, m_yPos + i); i++)
			{ }
		}
		
	}

}
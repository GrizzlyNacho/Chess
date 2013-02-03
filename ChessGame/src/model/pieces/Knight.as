package model.pieces 
{
	public class Knight extends Piece 
	{
		
		public function Knight(team:int, x:int, y:int) 
		{
			super(team, x, y);
		}
		
		override public function Clone():Piece
		{
			var copy:Knight = new Knight(m_team, m_xPos, m_yPos);
			copy.m_hasMoved = m_hasMoved;
			for (var i:int = 0; i < m_possibleTiles.length; i++)
			{
				copy.m_possibleTiles.push(m_possibleTiles[i]);
			}
			return copy;
		}
		
		override public function GetType():int
		{
			return Constants.TYPE_KNIGHT;
		}
		
		override protected function UpdateAvailableMoves():void
		{
			m_possibleTiles.splice(0, m_possibleTiles.length);
			
			//Try all possible knight movements
			AddIfValidAttackOrMove(m_xPos + 2, m_yPos + 1);
			AddIfValidAttackOrMove(m_xPos + 2, m_yPos - 1);
			AddIfValidAttackOrMove(m_xPos - 2, m_yPos + 1);
			AddIfValidAttackOrMove(m_xPos - 2, m_yPos - 1);
			AddIfValidAttackOrMove(m_xPos + 1, m_yPos + 2);
			AddIfValidAttackOrMove(m_xPos + 1, m_yPos - 2);
			AddIfValidAttackOrMove(m_xPos - 1, m_yPos + 2);
			AddIfValidAttackOrMove(m_xPos - 1, m_yPos - 2);
		}
	}

}
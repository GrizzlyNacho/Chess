package model.pieces 
{
	public class Bishop extends Piece 
	{
		
		public function Bishop(team:int, x:int, y:int) 
		{
			super(team, x, y);
		}
		
		override public function Clone():Piece
		{
			var copy:Bishop = new Bishop(m_team, m_xPos, m_yPos);
			copy.m_hasMoved = m_hasMoved;
			for (var i:int = 0; i < m_possibleTiles.length; i++)
			{
				copy.m_possibleTiles.push(m_possibleTiles[i]);
			}
			return copy;
		}
		
		override public function GetType():int
		{
			return Constants.TYPE_BISHOP;
		}
		
		
		override protected function UpdateAvailableMoves():void
		{
			m_possibleTiles.splice(0, m_possibleTiles.length);
			
			//Try each diagonal
			//South East
			var i:int = 1;
			while (AddIfValidAttackOrMove(m_xPos + i, m_yPos + i))
			{
				i++;
			}
			
			//North East
			i = 1;
			while (AddIfValidAttackOrMove(m_xPos + i, m_yPos - i))
			{
				i++;
			}
			
			//South West
			i = 1;
			while (AddIfValidAttackOrMove(m_xPos - i, m_yPos + i))
			{
				i++;
			}
			
			//North West
			i = 1;
			while (AddIfValidAttackOrMove(m_xPos - i, m_yPos - i))
			{
				i++;
			}
		}
		
	}

}
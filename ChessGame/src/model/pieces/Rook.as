package model.pieces 
{

	public class Rook extends Piece 
	{
		
		public function Rook(team:int, x:int, y:int) 
		{
			super(team, x, y);		
		}
		
		override public function GetType():int
		{
			return Constants.TYPE_ROOK;
		}
		
		override protected function UpdateAvailableMoves():void
		{
			m_possibleTiles.splice(0, m_possibleTiles.length);
			
			//Try each cardinal direction
			//Left
			var i:int = 1;
			while (AddIfValidAttackOrMove(m_xPos - i, m_yPos))
			{
				i++;
			}
			
			//Right
			i = 1;
			while (AddIfValidAttackOrMove(m_xPos + i, m_yPos))
			{
				i++;
			}
			
			//Up
			i = 1;
			while (AddIfValidAttackOrMove(m_xPos, m_yPos  - i))
			{
				i++;
			}
			
			//Down
			i = 1;
			while (AddIfValidAttackOrMove(m_xPos, m_yPos + i))
			{
				i++;
			}
		}
		
	}

}
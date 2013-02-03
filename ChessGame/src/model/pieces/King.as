package model.pieces 
{
	public class King extends Piece 
	{
		
		public function King(team:int, x:int, y:int) 
		{
			super(team, x, y);
		}
		
		override public function GetType():int
		{
			return Constants.TYPE_KING;
		}
		
		override public function MovePiece(x:int, y:int):void
		{
			if (!m_hasMoved && Math.abs(x - m_xPos) > 1)
			{
				//Castling is happening. 
				//Signal the associated Rook
			}
			super.MovePiece(x, y);
		}
		
		
		override protected function UpdateAvailableMoves():void
		{
			m_possibleTiles.splice(0, m_possibleTiles.length);
			
			//Add one tile in each direction
			AddIfValidAttackOrMove(m_xPos + 1, m_yPos);
			AddIfValidAttackOrMove(m_xPos - 1, m_yPos);
			AddIfValidAttackOrMove(m_xPos, m_yPos + 1);
			AddIfValidAttackOrMove(m_xPos, m_yPos - 1);
			AddIfValidAttackOrMove(m_xPos + 1, m_yPos + 1);
			AddIfValidAttackOrMove(m_xPos + 1, m_yPos - 1);
			AddIfValidAttackOrMove(m_xPos - 1, m_yPos + 1);
			AddIfValidAttackOrMove(m_xPos - 1, m_yPos - 1);
			
			//Castling can only happen if:
			// - Neither the rook nor the king have moved
			// - the tiles between the king and the rook are unoccupied 
			// - the tiles the king crosses would not place the king in check.
		}
	}

}
package model.pieces 
{

	public class Rook extends Piece 
	{
		
		public function Rook(team:int) 
		{
			super(team);		
		}
		
		override public function GetType():int
		{
			return Constants.TYPE_ROOK;
		}
		
		override public function GetAvailableMovesFrom(x:int, y:int):Array
		{
			var moves:Array = new Array();
			
			//Try each cardinal direction
			//Left
			var i:int = 1;
			while (AddIfValidAttackOrMove(x - i, y, moves))
			{
				i++;
			}
			
			//Right
			i = 1;
			while (AddIfValidAttackOrMove(x + i, y, moves))
			{
				i++;
			}
			
			//Up
			i = 1;
			while (AddIfValidAttackOrMove(x, y - i, moves))
			{
				i++;
			}
			
			//Down
			i = 1;
			while (AddIfValidAttackOrMove(x, y + i, moves))
			{
				i++;
			}
			
			return moves;
		}
		
	}

}
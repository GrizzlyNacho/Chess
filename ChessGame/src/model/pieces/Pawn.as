package model.pieces 
{
	import model.Pieces.Piece;
	
	public class Pawn extends Piece 
	{
		
		public function Pawn(team:int) 
		{
			super(team);
		}
		
		override public function GetType():int
		{
			return Constants.TYPE_PAWN;
		}
		
	}

}
package  
{
	//Class for declaring the embedded art assets
	//Embedded as there are not many images and there is no resource manager yet
	public class Resources 
	{
		//Pieces
		[Embed (source = "../assets/pawn.png")]
		public static const PawnImage:Class;
		
		[Embed (source = "../assets/rook.png")]
		public static const RookImage:Class;
		
		[Embed (source = "../assets/king.png")]
		public static const KingImage:Class;
		
		[Embed (source = "../assets/knight.png")]
		public static const KnightImage:Class;
		
		[Embed (source = "../assets/bishop.png")]
		public static const BishopImage:Class;
		
		[Embed (source = "../assets/queen.png")]
		public static const QueenImage:Class;
		
		//UI Elements
		[Embed (source = "../assets/selection.png")]
		public static const SelectionImage:Class;
		
		[Embed (source = "../assets/blackTurn.png")]
		public static const BlackTurnImage:Class;
		
		[Embed (source = "../assets/whiteTurn.png")]
		public static const WhiteTurnImage:Class;
	}

}
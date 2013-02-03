package  
{
	//Class for declaring the embedded art assets
	//Embedded as there are not many images and there is no resource manager yet
	public class Resources 
	{
		[Embed (source = "../assets/pawn.png")]
		public static const PawnImage:Class;
		
		[Embed (source = "../assets/rook.png")]
		public static const RookImage:Class;
		
		[Embed (source = "../assets/king.png")]
		public static const KingImage:Class;
		
		[Embed (source = "../assets/selection.png")]
		public static const SelectionImage:Class;
	}

}
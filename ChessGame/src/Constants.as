package  
{
	//Track all constants associated with a match of chess in one place
	public class Constants 
	{
		//Commoon Constants
		public static const BOARD_SIZE:int = 8;
		
		public static const TEAM_NONE:int = -1;
		public static const TEAM_WHITE:int = 0;
		public static const TEAM_BLACK:int = 1;
		
		public static const TYPE_NO_PIECE:int 	= 0;
		public static const TYPE_PAWN:int 		= 1;
		public static const TYPE_ROOK:int 		= 2;
		public static const TYPE_KNIGHT:int 	= 3;
		public static const TYPE_BISHOP:int 	= 4;
		public static const TYPE_QUEEN:int 		= 5;
		public static const TYPE_KING:int 		= 6;
		
		//UIConstants
		public static const TILE_SIZE_PIXELS:int = 75;
		public static const COLOUR_LIGHT_TILE:uint = 0xFFEBCD;
		public static const COLOUR_DARK_TILE:uint = 0x855E42;
	}

}
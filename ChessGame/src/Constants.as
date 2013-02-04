package  
{
	import flash.filters.ColorMatrixFilter;
	
	//Track all constants associated with a match of chess in one place
	public class Constants 
	{	
		//Common Constants
		public static const BOARD_SIZE:int = 8;
		
		public static const TEAM_NONE:int = -1;
		public static const TEAM_WHITE:int = 0;
		public static const TEAM_BLACK:int = 1;
		
		public static const TURNS_WITHOUT_EVENT_TO_DRAW:int = 50;
		
		public static const GAME_STATE_REG:int = 				0;
		public static const GAME_STATE_CHECK:int = 				1;
		public static const GAME_STATE_CHECKMATE:int = 			2;
		public static const GAME_STATE_DRAW_50:int = 			3;
		public static const GAME_STATE_DRAW_INSUF_MATERIAL:int = 4;
		public static const GAME_STATE_DRAW_3_REP:int = 		5;
		public static const GAME_STATE_DRAW_STALEMATE:int = 	6;
		public static const GAME_STATE_PROMOTE:int = 			7;
		
		public static const TYPE_NO_PIECE:int 	= 0;
		public static const TYPE_PAWN:int 		= 1;
		public static const TYPE_ROOK:int 		= 2;
		public static const TYPE_KNIGHT:int 	= 3;
		public static const TYPE_BISHOP:int 	= 4;
		public static const TYPE_QUEEN:int 		= 5;
		public static const TYPE_KING:int 		= 6;
		
		//UIConstants
		public static const TILE_SIZE_PIXELS:int = 75;
		public static const ROUND_RECT_ELIPSE_SIZE:int = 10;
		public static const COLOUR_LIGHT_TILE:uint = 0xFFEBCD;
		public static const COLOUR_DARK_TILE:uint = 0x855E42;
		public static const COLOUR_INFO_PANEL_BG:uint = 0x4682b4;
		public static const COLOUR_PROMOTION_BG:uint = 0xFFFFFF;
		public static function get WHITE_PIECE_FILTER():ColorMatrixFilter
		{
			return new ColorMatrixFilter([1.2, 0, 0, 0, 0,
										0, 1.2, 0, 0, 0,
										0, 0, 1.2, 0, 0,
										0, 0, 0, 1, 0]);
		}
		public static function get BLACK_PIECE_FILTER():ColorMatrixFilter
		{
			return new ColorMatrixFilter([0.5, 0, 0, 0, 0,
											0, 0.5, 0, 0, 0,
											0, 0, 0.5, 0, 0,
											0, 0, 0, 1, 0]);
		}
	}

}
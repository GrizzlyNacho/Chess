package viewController 
{
	import model.MatchMgr;
	
	public class ChessBoard extends View
	{
		private var m_tiles:Array = null;
		
		public function ChessBoard() 
		{
			super();
			
			//Add the background rectangle
			this.graphics.clear();
			this.graphics.beginFill(0x000000);
			this.graphics.drawRoundRect(5, 5, 10 + Constants.BOARD_SIZE * Constants.TILE_SIZE_PIXELS, 10 + Constants.BOARD_SIZE * Constants.TILE_SIZE_PIXELS, 10, 10);
			this.graphics.endFill();
			
			//Initialize the array of tiles
			//They are set up so that (0,0) is the top left, (1,0) is immediately to the right, and (0,1) is immediately below
			m_tiles = new Array();
			var lightTile:Boolean = true;
			for (var row:int = 0; row < Constants.BOARD_SIZE; row++)
			{
				for (var col:int = 0; col < Constants.BOARD_SIZE; col++)
				{
					var newTile:BoardTile = new BoardTile(col, row, lightTile);
					m_tiles.push(newTile);
					
					//Add the offset
					newTile.x += 10;
					newTile.y += 10;
					
					this.addChild(newTile);
					lightTile = !lightTile;
				}
				lightTile = !lightTile;
			}
			
			MatchMgr.GetInstance().RegisterView(this);
		}
		
		public function Cleanup():void
		{
			//Cleanup all the tiles
			for (var i:int = 0; i < Constants.BOARD_SIZE * Constants.BOARD_SIZE; i++)
			{
				(m_tiles[i] as BoardTile).Cleanup();
			}
			m_tiles.splice(0, m_tiles.length);
			m_tiles = null;
		}
		
		override public function UpdateView():void
		{
			//Update all of the tiles
			for (var i:int = 0; i < Constants.BOARD_SIZE * Constants.BOARD_SIZE; i++)
			{
				(m_tiles[i] as BoardTile).UpdateTile();
			}
		}
		
	}

}
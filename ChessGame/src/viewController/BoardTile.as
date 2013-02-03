package viewController 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import model.MatchMgr;
	
	public class BoardTile extends Sprite 
	{
		private var m_xInd:int = 0;
		private var m_yInd:int = 0;
		private var m_lightTile:Boolean = false;
		
		private var m_pieceImage:Bitmap = null;
		private var m_pieceTeam:int = Constants.TEAM_NONE;
		private var m_pieceType:int = Constants.TYPE_NO_PIECE;
		
		public function BoardTile(x:int, y:int, lightTile:Boolean) 
		{
			super();
			this.x = x * Constants.TILE_SIZE_PIXELS;
			this.y = y * Constants.TILE_SIZE_PIXELS;
			m_xInd = x;
			m_yInd = y;
			m_lightTile = lightTile;
			
			this.graphics.beginFill(lightTile ? Constants.COLOUR_LIGHT_TILE : Constants.COLOUR_DARK_TILE);
			this.graphics.drawRect(0, 0, Constants.TILE_SIZE_PIXELS, Constants.TILE_SIZE_PIXELS);
			this.graphics.endFill();
			this.buttonMode = true;
			this.useHandCursor = true;
			this.mouseChildren = false;
			this.addEventListener(MouseEvent.CLICK, TileClickedCB);
		}
		
		public function Cleanup():void
		{
			this.removeEventListener(MouseEvent.CLICK, TileClickedCB);
		}
		
		public function UpdateTile():void
		{
			var newTeam:int = MatchMgr.GetInstance().GetTileTeam(m_xInd, m_yInd);
			var newType:int = MatchMgr.GetInstance().GetTileType(m_xInd, m_yInd);
			
			//Update the image only if needed
			if (newType != m_pieceType)
			{
				m_pieceType = newType;
				
				//Clear the image
				if (m_pieceImage)
				{
					this.removeChild(m_pieceImage);
					m_pieceImage = null;
				}
				
				if (newType != Constants.TYPE_NO_PIECE)
				{
					m_pieceImage = GetBitmapByPieceType(newType);
					this.addChild(m_pieceImage);
				}
			}
			
			//Update the team filter if needed
			if (newTeam != m_pieceTeam && newTeam != Constants.TEAM_NONE)
			{
				m_pieceTeam = newTeam;
				
				m_pieceImage.filters = [(newTeam == Constants.TEAM_WHITE) ? 
						Constants.WHITE_PIECE_FILTER : Constants.BLACK_PIECE_FILTER];
			}
		}
		
		private function GetBitmapByPieceType(type:int):Bitmap
		{
			switch(type)
			{
				case Constants.TYPE_PAWN:
					return new Resources.PawnImage();
				case Constants.TYPE_ROOK:
					return new Resources.RookImage();
				default:
					return null;
			}
		}
		
		private function TileClickedCB(e:MouseEvent):void
		{
			trace('Tile (' + m_xInd + ',' + m_yInd + ') was clicked.');
			MatchMgr.GetInstance().SelectTile(m_xInd, m_yInd);
		}
		
	}

}
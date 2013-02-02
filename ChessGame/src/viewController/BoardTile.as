package viewController 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class BoardTile extends Sprite 
	{
		private var m_xInd:int = 0;
		private var m_yInd:int = 0;
		private var m_lightTile:Boolean = false;
		
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
			//Update the piece currently on this title if it is different
		}
		
		
		private function TileClickedCB(e:MouseEvent):void
		{
			trace('Tile (' + m_xInd + ',' + m_yInd + ') was clicked.');
		}
		
	}

}
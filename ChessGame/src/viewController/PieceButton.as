package viewController 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import model.MatchMgr;
	
	public class PieceButton extends Sprite 
	{
		private var m_pieceType:int = Constants.TYPE_NO_PIECE;
		
		public function PieceButton(pieceType:int) 
		{
			m_pieceType = pieceType;
			super();
			
			this.buttonMode = true;
			this.useHandCursor = true;
			this.mouseChildren = false;
			
			this.graphics.clear();
			this.graphics.beginFill(Constants.COLOUR_DARK_TILE);
			this.graphics.drawRoundRect(0, 0, Constants.TILE_SIZE_PIXELS, Constants.TILE_SIZE_PIXELS, 
				Constants.ROUND_RECT_ELIPSE_SIZE, Constants.ROUND_RECT_ELIPSE_SIZE);
			this.graphics.endFill();
			
			//Add the graphic
			var image:Bitmap = null;
			switch(pieceType)
			{
				case Constants.TYPE_QUEEN:
					image = new Resources.QueenImage();
					break;
				case Constants.TYPE_ROOK:
					image = new Resources.RookImage();
					break;
				case Constants.TYPE_BISHOP:
					image = new Resources.BishopImage();
					break;
				case Constants.TYPE_KNIGHT:
					image = new Resources.KnightImage();
					break;
			}
			image.x = Constants.TILE_SIZE_PIXELS / 2 - image.width / 2;
			image.y = Constants.TILE_SIZE_PIXELS / 2 - image.height / 2;
			this.addChild(image);
			
			this.addEventListener(MouseEvent.CLICK, PieceClickedCB);
		}
		
		private function PieceClickedCB(e:MouseEvent):void
		{
			MatchMgr.GetInstance().SelectPromotion(m_pieceType);
		}
		
	}

}
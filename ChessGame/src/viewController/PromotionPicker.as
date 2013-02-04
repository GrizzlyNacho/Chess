package viewController 
{
	import flash.display.Sprite;
	
	public class PromotionPicker extends Sprite 
	{
		private const c_size:int = 200;
		private const c_borderOffset:int = 15;
		private var m_buttonRook:PieceButton = null;
		private var m_buttonKnight:PieceButton = null;
		private var m_buttonBishop:PieceButton = null
		private var m_buttonQueen:PieceButton = null;
		
		public function PromotionPicker() 
		{
			super();
			
			//Background
			this.graphics.clear();
			this.graphics.beginFill(Constants.COLOUR_PROMOTION_BG);
			this.graphics.drawRoundRect(0, 0, c_size, c_size, 10, 10);
			this.graphics.endFill();
			
			m_buttonRook = new PieceButton(Constants.TYPE_ROOK);
			m_buttonKnight = new PieceButton(Constants.TYPE_KNIGHT);
			m_buttonBishop = new PieceButton(Constants.TYPE_BISHOP);
			m_buttonQueen = new PieceButton(Constants.TYPE_QUEEN);
			
			//Position all of them around the border.
			m_buttonQueen.x = c_borderOffset;
			m_buttonQueen.y = c_borderOffset;
			m_buttonRook.x = c_size - m_buttonRook.width - c_borderOffset;
			m_buttonRook.y = c_borderOffset;
			m_buttonBishop.x = c_borderOffset;
			m_buttonBishop.y = c_size - m_buttonBishop.height - c_borderOffset;
			m_buttonKnight.x = c_size - m_buttonKnight.width - c_borderOffset;
			m_buttonKnight.y = c_size - m_buttonKnight.height - c_borderOffset;
			
			this.addChild(m_buttonBishop);
			this.addChild(m_buttonKnight);
			this.addChild(m_buttonQueen);
			this.addChild(m_buttonRook);
		}
		
	}

}
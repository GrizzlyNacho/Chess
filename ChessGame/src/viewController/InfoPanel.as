package viewController 
{
	import flash.display.Bitmap;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import model.MatchMgr;
	
	public class InfoPanel extends View 
	{	
		private const c_drawWidth:int = 250;
		private const c_drawHeight:int = 610;
		
		private var m_turnIndicators:Array = null;
		private var m_checkImage:Bitmap = null;
		private var m_checkMateImage:Bitmap = null;
		private var m_drawImage:Bitmap = null;
		private var m_drawExplainText:TextField = null;
		private var m_textFormat:TextFormat = null;
		
		public function InfoPanel(x:int, y:int) 
		{
			this.x = x;
			this.y = y;
			super();
			
			//Draw the backdrop for the whole panel
			this.graphics.clear();
			this.graphics.beginFill(Constants.COLOUR_INFO_PANEL_BG);
			this.graphics.drawRoundRect(0, 0, c_drawWidth, c_drawHeight, 10, 10);
			this.graphics.endFill();
			
			//Add the turn indicators
			m_turnIndicators = new Array();
			
			var newBitmap:Bitmap = new Resources.BlackTurnImage();
			newBitmap.x = (c_drawWidth / 2) - (newBitmap.width / 2);
			newBitmap.y = 0;
			newBitmap.visible = false;
			m_turnIndicators[Constants.TEAM_BLACK] = newBitmap;
			this.addChild(newBitmap);
			
			newBitmap = new Resources.WhiteTurnImage();
			newBitmap.x = (c_drawWidth / 2) - (newBitmap.width / 2);
			newBitmap.y = c_drawHeight - newBitmap.height;
			m_turnIndicators[Constants.TEAM_WHITE] = newBitmap;
			this.addChild(newBitmap);
			
			//Add the end-game images
			m_checkImage = new Resources.CheckImage();
			m_checkImage.x = c_drawWidth / 2 - m_checkImage.width / 2;
			m_checkImage.y = 200;
			m_checkImage.visible = false;
			this.addChild(m_checkImage);
			
			m_checkMateImage = new Resources.CheckMateImage();
			m_checkMateImage.x = c_drawWidth / 2 - m_checkImage.width / 2;
			m_checkMateImage.y = 320;
			m_checkMateImage.visible = false;
			this.addChild(m_checkMateImage);
			
			m_drawImage = new Resources.DrawImage();
			m_drawImage.x = c_drawWidth / 2 - m_drawImage.width / 2;
			m_drawImage.y = 260;
			m_drawImage.visible = false;
			this.addChild(m_drawImage);
			
			m_textFormat = new TextFormat();
			m_textFormat.font = "Arial";
			m_textFormat.size = 16;
			m_textFormat.align = "center";
			
			m_drawExplainText = new TextField();
			m_drawExplainText.x = 0;
			m_drawExplainText.y = m_drawImage.y + 69;
			m_drawExplainText.width = c_drawWidth;
			this.addChild(m_drawExplainText);
			
			MatchMgr.GetInstance().RegisterView(this);
		}
		
		override public function UpdateView():void
		{
			//Update the turn indicator
			var team:int = MatchMgr.GetInstance().GetCurrentTeam();
			if (team != Constants.TEAM_NONE)
			{
				(m_turnIndicators[team] as Bitmap).visible = true;
				(m_turnIndicators[1 - team] as Bitmap).visible = false;
			}
			
			var gameState:int = MatchMgr.GetInstance().GetGameState();
			m_checkImage.visible = false;
			m_checkMateImage.visible = false;
			m_drawImage.visible = false;
			m_drawExplainText.text = "";
			switch(gameState)
			{
				case Constants.GAME_STATE_CHECK:
					m_checkImage.visible = true;
					break;
				case Constants.GAME_STATE_CHECKMATE:
					m_checkImage.visible = true;
					m_checkMateImage.visible = true;
					break;
				case Constants.GAME_STATE_DRAW_3_REP:
					m_drawImage.visible = true;
					m_drawExplainText.text = "Same board state 3 times!";
					break;
				case Constants.GAME_STATE_DRAW_50:
					m_drawImage.visible = true;
					m_drawExplainText.text = "50 moves without event!";
					break;
				case Constants.GAME_STATE_DRAW_INSUF_MATERIAL:
					m_drawImage.visible = true;
					m_drawExplainText.text = "Not enough pieces to win left!";
					break;
				case Constants.GAME_STATE_DRAW_STALEMATE:
					m_drawImage.visible = true;
					m_drawExplainText.text = "Stalemate!";
					break;
			}
			m_drawExplainText.setTextFormat(m_textFormat);
		}
		
		public function Cleanup():void
		{
			m_turnIndicators.splice(0, m_turnIndicators.length);
			m_turnIndicators = null;
		}
		
	}

}
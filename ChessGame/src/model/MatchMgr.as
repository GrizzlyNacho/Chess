package model 
{
	import flash.display.Sprite;
	import model.pieces.Piece;
	import viewController.View;
	//Singleton class to track the state of the match
	
	public class MatchMgr 
	{
		private static var s_Instance:MatchMgr = null;
		
		private var m_boardState:Array = null;
		private var m_currentTeam:int = Constants.TEAM_NONE;
		private var m_currentSelectedPiece:Piece = null;
		private var m_turnCounter:int = 0;
		private var m_views:Array = null;
		
		
		public function MatchMgr() 
		{
			m_views = new Array();
			//Initialize the board state to full null.
			m_boardState = new Array();
			for (var i:int = 0; i < Constants.BOARD_SIZE * Constants.BOARD_SIZE; i++)
			{
				m_boardState.push(null);
			}
		}
		
		public static function GetInstance():MatchMgr
		{
			if (s_Instance == null)
			{
				s_Instance = new MatchMgr();
			}
			return s_Instance;
		}
		
		public function RegisterView(view:View):void
		{
			m_views.push(view);
			view.UpdateView();
		}
		
		public function StartNewGame():void
		{
			m_currentTeam = Constants.TEAM_WHITE;
			m_turnCounter = 0;
			
			//Place starting pieces into the board state
			
			UpdateAllViews();
		}
		
		private function GetTileIndex(x:int, y:int):int
		{
			return x + y * Constants.BOARD_SIZE;
		}
		
		private function UpdateAllViews():void
		{
			for (var i:int = 0; i < m_views.length; i++)
			{
				(m_views[i] as View).UpdateView();
			}
		}
		
	}

}
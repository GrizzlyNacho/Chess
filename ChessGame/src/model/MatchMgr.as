package model 
{
	import flash.display.Sprite;
	import model.pieces.Pawn;
	import model.pieces.Piece;
	import viewController.View;
	//Singleton class to track the state of the match
	
	public class MatchMgr 
	{
		private static var s_Instance:MatchMgr = null;
		
		private var m_boardState:Array = null;
		private var m_turnCounter:int = 0;
		private var m_views:Array = null;
		
		private var m_currentTeam:int = Constants.TEAM_NONE;
		private var m_currentSelectedPiece:Piece = null;
		private var m_currentSelectionLocation:int = -1;
		private var m_validMovesForSelected:Array = null;
		
		
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
			for (var i:int = 0; i < Constants.BOARD_SIZE; i++)
			{
				m_boardState[GetTileIndex(i, 1)] = new Pawn(Constants.TEAM_BLACK);
				m_boardState[GetTileIndex(i, Constants.BOARD_SIZE - 2)] = new Pawn(Constants.TEAM_WHITE);
			}
			
			UpdateAllViews();
		}
		
		public function SelectTile(x:int, y:int):void
		{
			var selectedPiece:Piece = m_boardState[GetTileIndex(x, y)];
			//Determine if the unit is owned by the player
			if (selectedPiece != null && m_currentTeam == selectedPiece.GetTeam())
			{
				trace('Piece selected.');
				m_currentSelectedPiece = selectedPiece;
				m_currentSelectionLocation = GetTileIndex(x, y);
				m_validMovesForSelected = selectedPiece.GetAvailableMovesFrom(x,y);
			}
			else if (m_currentSelectedPiece != null && IsValidMoveForCurrentPiece(x,y))
			{
				if (selectedPiece != null && selectedPiece.GetTeam() != m_currentTeam)
				{
					//Capture the piece
					m_boardState[GetTileIndex(x,y)] = null;
				}
				
				//Move the current piece there.
				m_boardState[GetTileIndex(x, y)] = m_boardState[m_currentSelectionLocation];
				//Remove the piece from its previous space
				m_boardState[m_currentSelectionLocation] = null;
				
				EndTurn();
			}
			UpdateAllViews();
		}
		
		public function EndTurn():void
		{
			m_turnCounter ++;
			
			m_currentTeam = 1 - m_currentTeam;
			m_currentSelectedPiece = null;
			m_currentSelectionLocation = -1;
			if (m_validMovesForSelected)
			{
				m_validMovesForSelected.splice(0, m_validMovesForSelected.length);
				m_validMovesForSelected = null;
			}
		}
		
		public function GetTileTeam(x:int, y:int):int
		{
			if (x >= 0 && x < Constants.BOARD_SIZE && y < Constants.BOARD_SIZE && y >= 0)
			{
				var piece:Piece = m_boardState[GetTileIndex(x, y)] as Piece;
				if (piece != null)
				{
					return piece.GetTeam();
				}
			}
			return Constants.TEAM_NONE;
		}
		
		public function GetTileType(x:int, y:int):int
		{
			var piece:Piece = m_boardState[GetTileIndex(x, y)] as Piece;
			if (piece != null)
			{
				return piece.GetType();
			}
			return Constants.TYPE_NO_PIECE;
		}
		
		public function GetCurrentTeam():int 
		{
			return m_currentTeam;
		}
		
		public function GetTileIndex(x:int, y:int):int
		{
			return x + y * Constants.BOARD_SIZE;
		}

		
		private function IsValidMoveForCurrentPiece(x:int, y:int):Boolean
		{
			return (m_validMovesForSelected != null &&
					m_validMovesForSelected.indexOf(GetTileIndex(x, y)) >= 0);
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
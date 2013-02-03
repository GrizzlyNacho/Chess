package model 
{
	import model.pieces.King;
	import model.pieces.Pawn;
	import model.pieces.Piece;
	import model.pieces.Rook;
	import viewController.View;

	/*
	 * Singleton class to track the state of the match.
	 * The pieces are tracked in a grid for access by location on the board,
	 * as well as in lists for each team in order to avoid having to scan the board for pieces by team.
	 */
	
	public class MatchMgr 
	{
		private static var s_Instance:MatchMgr = null;
		
		private var m_boardState:Array = null;
		private var m_turnCounter:int = 0;
		private var m_views:Array = null;
		
		private var m_currentTeam:int = Constants.TEAM_NONE;
		
		private var m_currentSelectedPiece:Piece = null;
		
		//Track all pieces for each player
		private var m_whitePieces:Array;
		private var m_blackPieces:Array;
		
		public function MatchMgr() 
		{
			m_views = new Array();
			m_whitePieces = new Array();
			m_blackPieces = new Array();
			
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
			
			AddStandardBoardSetup();
			
			//FIXME: Can combine the following two loops if same length is guaranteed, but it isn't for testing
			for (var i:int = 0; i < m_blackPieces.length; i++)
			{
				(m_blackPieces[i] as Piece).Setup();
			}
			for (i = 0; i < m_whitePieces.length; i++)
			{
				(m_whitePieces[i] as Piece).Setup();
			}
			
			UpdateAllViews();
		}
		
		public function SelectTile(x:int, y:int):void
		{
			var selectedPiece:Piece = m_boardState[GetTileIndex(x, y)];
			//Determine if the unit is owned by the player
			if (selectedPiece != null && m_currentTeam == selectedPiece.GetTeam()
				&& selectedPiece != m_currentSelectedPiece)
			{
				trace('Piece selected.');
				m_currentSelectedPiece = selectedPiece;
			}
			else if (m_currentSelectedPiece != null && IsValidMoveForCurrentPiece(x,y))
			{
				if (selectedPiece != null && selectedPiece.GetTeam() != m_currentTeam)
				{
					CapturePiece(x, y);
				}
				
				//Move the current piece and remove it from its previous space
				var origin:int = m_currentSelectedPiece.GetLocation();
				m_boardState[GetTileIndex(x, y)] = m_currentSelectedPiece;
				m_boardState[origin] = null;
				m_currentSelectedPiece.MovePiece(x,y);
				
				//Update the remaining pieces
				UpdateMoves(Constants.TEAM_BLACK, origin, GetTileIndex(x, y));
				UpdateMoves(Constants.TEAM_WHITE, origin, GetTileIndex(x, y));
				
				EndTurn();
			}
			
			UpdateAllViews();
		}
		
		public function EndTurn():void
		{
			m_turnCounter ++;
			
			m_currentTeam = 1 - m_currentTeam;
			m_currentSelectedPiece = null;
			
			//End of game conditions should probably sit here.
			//Check-Mate
			//Check
			//Draw
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
		
		public function GetIsSelectedLocation(x:int, y:int):Boolean
		{
			if (m_currentSelectedPiece != null)
			{
				return m_currentSelectedPiece.GetLocation() == GetTileIndex(x, y);
			}
			return false;
		}
		
		public function GetTileIndex(x:int, y:int):int
		{
			return x + y * Constants.BOARD_SIZE;
		}
		
		
		private function UpdateMoves(team:int, fromIndex:int, toIndex:int):void
		{
			var pieces:Array;
			if (team == Constants.TEAM_WHITE)
			{
				pieces = m_whitePieces;
			}
			else if (team == Constants.TEAM_BLACK)
			{
				pieces = m_blackPieces;
			}
			
			for (var i:int = 0; i < pieces.length; i++)
			{
				(pieces[i] as Piece).CheckUpdate(fromIndex, toIndex);
			}
		}
		
		private function IsValidMoveForCurrentPiece(x:int, y:int):Boolean
		{
			var targetTeam:int = GetTileTeam(x, y);
			var targetIsPiece:Boolean = GetTileType(x, y) != Constants.TYPE_NO_PIECE;
			
			//Can't move onto teammates
			if (targetIsPiece && targetTeam == m_currentTeam)
			{
				return false;
			}
			
			//FIXME: Consider placing yourself in check
			
			if (targetIsPiece)
			{
				return m_currentSelectedPiece.CanAttack(GetTileIndex(x, y));
			}
			else //The distinction between move and attack is relevant for the pawn
			{
				return m_currentSelectedPiece.CanMove(GetTileIndex(x, y));
			}
		}
		
		private function UpdateAllViews():void
		{
			for (var i:int = 0; i < m_views.length; i++)
			{
				(m_views[i] as View).UpdateView();
			}
		}
		
		private function AddStandardBoardSetup():void
		{			
			for (var i:int = 0; i < Constants.BOARD_SIZE; i++)
			{
				AddPieceToBoard(Constants.TYPE_PAWN, Constants.TEAM_BLACK, i, 1);
				AddPieceToBoard(Constants.TYPE_PAWN, Constants.TEAM_WHITE, i, 6);
			}
			
			AddPieceToBoard(Constants.TYPE_ROOK, Constants.TEAM_BLACK, 0, 0);
			AddPieceToBoard(Constants.TYPE_ROOK, Constants.TEAM_BLACK, 7, 0);
			AddPieceToBoard(Constants.TYPE_ROOK, Constants.TEAM_WHITE, 0, 7);
			AddPieceToBoard(Constants.TYPE_ROOK, Constants.TEAM_WHITE, 7, 7);
			AddPieceToBoard(Constants.TYPE_KING, Constants.TEAM_BLACK, 4, 0);
			AddPieceToBoard(Constants.TYPE_KING, Constants.TEAM_WHITE, 4, 7);
		}
		
		private function AddPieceToBoard(type:int, team:int, x:int, y:int):void
		{
			var newPiece:Piece = null;
			switch(type)
			{
				case Constants.TYPE_PAWN:
					newPiece = new Pawn(team, x, y);
					break;
				case Constants.TYPE_ROOK:
					newPiece = new Rook(team, x, y);
					break;
				case Constants.TYPE_KING:
					newPiece = new King(team, x, y);
					break;
				default:
					newPiece = null;
					break;
			}
			
			m_boardState[GetTileIndex(x, y)] = newPiece;
			if (team == Constants.TEAM_WHITE)
			{
				m_whitePieces.push(newPiece);
			}
			else if (team == Constants.TEAM_BLACK)
			{
				m_blackPieces.push(newPiece);
			}
		}
		
		private function CapturePiece(x:int, y:int):void
		{
			var capturedPiece:Piece = m_boardState[GetTileIndex(x, y)] as Piece;
			var index:int = -1;
			var pieceList:Array = null;
			
			if (capturedPiece.GetTeam() == Constants.TEAM_WHITE)
			{
				pieceList = m_whitePieces;
			}
			else if (capturedPiece.GetTeam() == Constants.TEAM_BLACK)
			{
				pieceList = m_blackPieces;
			}
			
			index = pieceList.indexOf(capturedPiece);
			if (index >= 0)
			{
				pieceList.splice(index, 1);
			}
		
			capturedPiece.Cleanup();
			capturedPiece = null;
		}
		
	}

}
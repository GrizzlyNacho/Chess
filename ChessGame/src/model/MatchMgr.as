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
		private var m_whitePieces:Array = null;
		private var m_blackPieces:Array = null;
		private var m_whiteKing:King = null;
		private var m_blackKing:King = null;
		
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
			var targetedPiece:Piece = m_boardState[GetTileIndex(x, y)];
			//Determine if the unit is owned by the player
			if (targetedPiece != null && m_currentTeam == targetedPiece.GetTeam()
				&& targetedPiece != m_currentSelectedPiece)
			{
				trace('Piece selected.');
				m_currentSelectedPiece = targetedPiece;
			}
			else if (m_currentSelectedPiece != null && IsValidMoveForCurrentPiece(x,y))
			{
				var origin:int = m_currentSelectedPiece.GetLocation();
				ExecuteMove(targetedPiece, origin, x, y);
				
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
			
			if (IsTeamInCheck(m_currentTeam))
			{
				trace('Team ' + m_currentTeam + ' is in CHECK!');
			}
			
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
			
			if (targetIsPiece && m_currentSelectedPiece.CanAttack(GetTileIndex(x, y)))
			{
				
				return !IsSelfHarmingMove(x,y);
			}

			if(!targetIsPiece && m_currentSelectedPiece.CanMove(GetTileIndex(x, y)))
			{
				return !IsSelfHarmingMove(x,y);
			}
			return false
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
					if (team == Constants.TEAM_WHITE)
					{
						m_whiteKing = newPiece as King;
					}
					else if (team == Constants.TEAM_BLACK)
					{
						m_blackKing = newPiece as King;
					}
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
		
		private function ExecuteMove(selectedPiece:Piece, origin:int, x:int, y:int):void 
		{
			if (selectedPiece != null && selectedPiece.GetTeam() != m_currentTeam)
			{
				CapturePiece(x, y);
			}
			
			//Move the current piece and remove it from its previous space
			m_boardState[GetTileIndex(x, y)] = m_currentSelectedPiece;
			m_boardState[origin] = null;
			m_currentSelectedPiece.MovePiece(x, y);
		}
		
		//Tests if moving the currently selected piece to the target location would put the moving player in check
		//Assumes that the move is otherwise perfectly valid
		private function IsSelfHarmingMove(x:int, y:int):Boolean
		{
			//Grab backups of any data that could be lost
			var origin:int = m_currentSelectedPiece.GetLocation();
			var selectedCopy:Piece = m_currentSelectedPiece.Clone();
			var pieceAtDestinationCopy:Piece = null;
			if (m_boardState[GetTileIndex(x, y)] != null)
			{
				pieceAtDestinationCopy = (m_boardState[GetTileIndex(x, y)] as Piece).Clone();
			}
			
			//Perform the action to test
			ExecuteMove(pieceAtDestinationCopy, origin, x, y);
			var opposingTeam:int = 1 - m_currentTeam;
			UpdateMoves(opposingTeam, origin, GetTileIndex(x, y));
			
			//Determine check
			var inCheck:Boolean = IsTeamInCheck(m_currentTeam);

			//Reset the position and state of the selected piece
			//possible moves weren't updated for the current team, so everything should be consistent
			m_currentSelectedPiece.SetFlagsTo(selectedCopy);
			selectedCopy.Cleanup();
			selectedCopy = null;
			m_boardState[origin] = m_currentSelectedPiece;
			if (pieceAtDestinationCopy == null) //It was just a move. Not a capture
			{
				m_boardState[GetTileIndex(x, y)] = null;
			}
			else //An enemy piece was captured. We need to restore it both to its list and to the board
			{
				m_boardState[GetTileIndex(x, y)] = pieceAtDestinationCopy;
				if (pieceAtDestinationCopy.GetTeam() == Constants.TEAM_WHITE)
				{
					m_whitePieces.push(pieceAtDestinationCopy);
				}
				else if (pieceAtDestinationCopy.GetTeam() == Constants.TEAM_BLACK)
				{
					m_blackPieces.push(pieceAtDestinationCopy);
				}
			}
			
			//Update the enemy moves again to keep them consistent
			UpdateMoves(opposingTeam, origin, GetTileIndex(x, y));
			
			return inCheck;
		}
		
		private function IsTeamInCheck(team:int):Boolean
		{
			var allyKingLocation:int = -1;
			var enemyTeamList:Array = null;
			if (team == Constants.TEAM_WHITE)
			{
				enemyTeamList = m_blackPieces;
				allyKingLocation = m_whiteKing.GetLocation();
			}
			else if (team == Constants.TEAM_BLACK)
			{
				enemyTeamList = m_whitePieces;
				allyKingLocation = m_blackKing.GetLocation();
			}
			
			for (var i:int = 0; enemyTeamList != null && i < enemyTeamList.length; i++)
			{
				if ((enemyTeamList[i] as Piece).CanAttack(allyKingLocation))
				{
					return true;
				}
			}
			return false;
		}
		
	}

}
package model 
{
	import model.pieces.Bishop;
	import model.pieces.King;
	import model.pieces.Knight;
	import model.pieces.Pawn;
	import model.pieces.Piece;
	import model.pieces.Queen;
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
		
		private var m_teamInCheck:int = Constants.TEAM_NONE;
		private var m_teamWithNoMoves:int = Constants.TEAM_NONE;
		
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
			else if (m_currentSelectedPiece != null && IsValidMove(m_currentSelectedPiece, x, y))
			{
				var origin:int = m_currentSelectedPiece.GetLocation();
				ExecuteMove(m_currentSelectedPiece, targetedPiece, origin, x, y);
				
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
			
			//Determine Check (we only care about the current team)
			m_teamInCheck = Constants.TEAM_NONE;
			if (IsTeamInCheck(m_currentTeam))
			{
				m_teamInCheck = m_currentTeam;
				trace('Team ' + m_currentTeam + ' is in CHECK!');
			}
			
			//Determine number of available moves
			var noMoves:Boolean = AreNoMovesAvailable();
			m_teamWithNoMoves = Constants.TEAM_NONE;
			if (noMoves)
			{
				m_teamWithNoMoves = m_currentTeam;
				trace('Team ' + m_currentTeam + ' has no moves!');
			}
			
			//Draw conditions 
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
		
		public function GetTileHasMoved(x:int, y:int):Boolean 
		{
			var piece:Piece = (m_boardState[GetTileIndex(x, y)] as Piece);
			if (piece != null)
			{
				return piece.GetHasMoved();
			}
			return false;
		}
		
		public function IsTileInCheck(owningTeam:int, tile:int):Boolean
		{
			var enemyTeamList:Array = null;
			if (owningTeam == Constants.TEAM_WHITE)
			{
				enemyTeamList = m_blackPieces;
			}
			else if (owningTeam == Constants.TEAM_BLACK)
			{
				enemyTeamList = m_whitePieces;
			}
			
			for (var i:int = 0; enemyTeamList != null && i < enemyTeamList.length; i++)
			{
				if ((enemyTeamList[i] as Piece).CanAttack(tile))
				{
					return true;
				}
			}
			return false;
		}
		
		public function TriggerCastlingOnRook(rookIndex:int, rookDestination:int):void 
		{
			var rook:Rook = m_boardState[rookIndex] as Rook;
			if (rook == null)
			{
				//Bail out. This can be a result of the preemptive checking on moves
				return;
			}
			
			var destinationX:int = rookDestination % Constants.BOARD_SIZE;
			var destinationY:int = rookDestination / Constants.BOARD_SIZE;
			rook.MovePiece(destinationX, destinationY);
			m_boardState[rook.GetLocation()] = rook;
			m_boardState[rookIndex] = null;
		}
		
		public function IsInCheck():Boolean 
		{
			return m_teamInCheck != Constants.TEAM_NONE;
		}
		
		//Assumes current team
		//This has the potential to be computationally expensive so use it sparingly when possible.
		public function IsValidMove(selectedPiece:Piece, x:int, y:int):Boolean
		{
			var targetTeam:int = GetTileTeam(x, y);
			var targetIsPiece:Boolean = GetTileType(x, y) != Constants.TYPE_NO_PIECE;
			
			//Can't move onto teammates
			if (targetIsPiece && targetTeam == m_currentTeam)
			{
				return false;
			}
			
			if (targetIsPiece && selectedPiece.CanAttack(GetTileIndex(x, y)))
			{
				
				return !IsSelfHarmingMove(selectedPiece, x, y);
			}

			if(!targetIsPiece && selectedPiece.CanMove(GetTileIndex(x, y)))
			{
				return !IsSelfHarmingMove(selectedPiece, x, y);
			}
			return false
		}
		
		public function IsInCheckMate():Boolean 
		{
			return m_teamInCheck != Constants.TEAM_NONE
				&& m_teamWithNoMoves != Constants.TEAM_NONE;
		}
		
		
		
		private function AreNoMovesAvailable():Boolean 
		{
			var teamArray:Array = null;
			if (m_currentTeam == Constants.TEAM_WHITE)
			{
				teamArray = m_whitePieces;
			}
			else if (m_currentTeam == Constants.TEAM_BLACK)
			{
				teamArray = m_blackPieces;
			}
			
			//Cycle all pieces and test each possible move.
			for (var i:int = 0; i < teamArray.length; i++)
			{
				var currentPiece:Piece = teamArray[i] as Piece;
				if (currentPiece.HasValidMove())
				{
					return false;
				}
			}
			return true;
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
			AddPieceToBoard(Constants.TYPE_KNIGHT, Constants.TEAM_BLACK, 1, 0);
			AddPieceToBoard(Constants.TYPE_BISHOP, Constants.TEAM_BLACK, 2, 0);
			AddPieceToBoard(Constants.TYPE_QUEEN, Constants.TEAM_BLACK, 3, 0);
			AddPieceToBoard(Constants.TYPE_KING, Constants.TEAM_BLACK, 4, 0);
			AddPieceToBoard(Constants.TYPE_BISHOP, Constants.TEAM_BLACK, 5, 0);
			AddPieceToBoard(Constants.TYPE_KNIGHT, Constants.TEAM_BLACK, 6, 0);
			AddPieceToBoard(Constants.TYPE_ROOK, Constants.TEAM_BLACK, 7, 0);
			
			AddPieceToBoard(Constants.TYPE_ROOK, Constants.TEAM_WHITE, 0, 7);
			AddPieceToBoard(Constants.TYPE_KNIGHT, Constants.TEAM_WHITE, 1, 7);
			AddPieceToBoard(Constants.TYPE_BISHOP, Constants.TEAM_WHITE, 2, 7);
			AddPieceToBoard(Constants.TYPE_QUEEN, Constants.TEAM_WHITE, 3, 7);
			AddPieceToBoard(Constants.TYPE_KING, Constants.TEAM_WHITE, 4, 7);
			AddPieceToBoard(Constants.TYPE_BISHOP, Constants.TEAM_WHITE, 5, 7);
			AddPieceToBoard(Constants.TYPE_KNIGHT, Constants.TEAM_WHITE, 6, 7);
			AddPieceToBoard(Constants.TYPE_ROOK, Constants.TEAM_WHITE, 7, 7);
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
				case Constants.TYPE_KNIGHT:
					newPiece = new Knight(team, x, y);
					break;
				case Constants.TYPE_BISHOP:
					newPiece = new Bishop(team, x, y);
					break;
				case Constants.TYPE_QUEEN:
					newPiece = new Queen(team, x, y);
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
		
		private function ExecuteMove(selectedPiece:Piece, targetedPiece:Piece, origin:int, x:int, y:int):void 
		{
			if (targetedPiece != null && targetedPiece.GetTeam() != m_currentTeam)
			{
				CapturePiece(x, y);
			}
			
			//Move the current piece and remove it from its previous space
			m_boardState[GetTileIndex(x, y)] = selectedPiece;
			m_boardState[origin] = null;
			selectedPiece.MovePiece(x, y);
		}
		
		//Tests if moving the currently selected piece to the target location would put the moving player in check
		//Assumes that the move is otherwise perfectly valid
		private function IsSelfHarmingMove(selectedPiece:Piece, x:int, y:int):Boolean
		{
			//Grab backups of any data that could be lost
			var origin:int = selectedPiece.GetLocation();
			var selectedCopy:Piece = selectedPiece.Clone();
			var pieceAtDestinationCopy:Piece = null;
			if (m_boardState[GetTileIndex(x, y)] != null)
			{
				pieceAtDestinationCopy = (m_boardState[GetTileIndex(x, y)] as Piece).Clone();
			}
			
			//Perform the action to test
			ExecuteMove(selectedPiece, pieceAtDestinationCopy, origin, x, y);
			var opposingTeam:int = 1 - m_currentTeam;
			UpdateMoves(opposingTeam, origin, GetTileIndex(x, y));
			
			//Determine check
			var inCheck:Boolean = IsTeamInCheck(m_currentTeam);

			//Reset the position and state of the selected piece
			//possible moves weren't updated for the current team, so everything should be consistent
			selectedPiece.SetFlagsTo(selectedCopy);
			selectedCopy.Cleanup();
			selectedCopy = null;
			m_boardState[origin] = selectedPiece;
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
			if (team == Constants.TEAM_WHITE)
			{
				return IsTileInCheck(team, m_whiteKing.GetLocation());
			}
			else if (team == Constants.TEAM_BLACK)
			{
				return IsTileInCheck(team, m_blackKing.GetLocation());
			}
			return false;
		}
		
	}

}
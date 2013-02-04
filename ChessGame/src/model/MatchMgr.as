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
	import flash.utils.Dictionary;

	/*
	 * Singleton class to track the state of the match.
	 * The pieces are tracked in a grid for access by location on the board,
	 * as well as in lists for each team in order to avoid having to scan the board for pieces by team.
	 */
	
	public class MatchMgr 
	{
		private static var s_Instance:MatchMgr = null;
		
		private var m_boardState:Array = null;
		private var m_views:Array = null;
		
		private var m_currentTeam:int = Constants.TEAM_NONE;
		private var m_currentSelectedPiece:Piece = null;
		
		private var m_pawnPendingPromotion:Piece = null;
		
		private var m_gameState:int = Constants.GAME_STATE_REG;
		private var m_turnsSincePawnOrCapture:int = 0;
		
		//A dictionary keyed by the board state representation with the number of times encountered saved
		private var m_gameStateHistory:Dictionary = null; 
		private var m_gameStateHistoryMap:Array = null; //An array of the keys in the dictionary for use in cleanup
		
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
			m_gameStateHistory = new Dictionary();
			m_gameStateHistoryMap = new Array();
			
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
			m_gameState = Constants.GAME_STATE_REG;
			m_currentTeam = Constants.TEAM_WHITE;
			m_turnsSincePawnOrCapture = 0;
			
			ClearStateHistory();
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
			if (m_gameState != Constants.GAME_STATE_CHECK && m_gameState != Constants.GAME_STATE_REG)
			{
				//Don't allow tile actions when the game is over.
				return;
			}
			
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
				if (GetTileType(x, y) != Constants.TYPE_NO_PIECE || m_currentSelectedPiece.GetType() == Constants.TYPE_PAWN)
				{
					//We set to -1 as end turn decrements every turn and after this method we lose sight of what happened in the move
					m_turnsSincePawnOrCapture = -1;
				}
				
				if (GetTileType(x, y) != Constants.TYPE_NO_PIECE)
				{
					//We can't have the same game state again if a piece is captured.
					//Helps keep the amount being tracked down.
					ClearStateHistory();
				}
				
				var origin:int = m_currentSelectedPiece.GetLocation();
				ExecuteMove(m_currentSelectedPiece, targetedPiece, origin, x, y);
				
				//Update the remaining pieces
				UpdateMoves(Constants.TEAM_BLACK, origin, GetTileIndex(x, y));
				UpdateMoves(Constants.TEAM_WHITE, origin, GetTileIndex(x, y));
				
				if (CheckForPendingPromotion())
				{
					m_gameState = Constants.GAME_STATE_PROMOTE;
				}
				else
				{
					EndTurn();
				}
			}
			
			UpdateAllViews();
		}
		
		public function EndTurn():void
		{
			m_turnsSincePawnOrCapture ++;
			m_currentTeam = 1 - m_currentTeam;
			m_currentSelectedPiece = null;
			
			m_gameState = Constants.GAME_STATE_REG;
			var noMoves:Boolean = AreNoMovesAvailable();
			var inCheck:Boolean = IsTeamInCheck(m_currentTeam);
			var enoughMaterials:Boolean = HasEnoughPiecesToWin(m_whitePieces) || HasEnoughPiecesToWin(m_blackPieces);
			var sameStateSeenThrice:Boolean = false;
			
			//Check for repeated board layouts.
			var boardStateKey:String = CreateCurrentStateRep();
			var keyIndex:int = m_gameStateHistoryMap.indexOf(boardStateKey);
			//State has occurred before so increment it.
			if (keyIndex >= 0)
			{
				m_gameStateHistory[boardStateKey] += 1;
				if (m_gameStateHistory[boardStateKey] >= 3)
				{
					sameStateSeenThrice = true;
				}
			}
			else //Log it as occurred and create an entry
			{
				m_gameStateHistory[boardStateKey] = 1;
				m_gameStateHistoryMap.push(boardStateKey);
			}
			
			if (noMoves && inCheck)
			{
				m_gameState = Constants.GAME_STATE_CHECKMATE;
			}
			else if (sameStateSeenThrice)
			{
				m_gameState = Constants.GAME_STATE_DRAW_3_REP;
			}
			else if (m_turnsSincePawnOrCapture >= Constants.TURNS_WITHOUT_EVENT_TO_DRAW)
			{
				m_gameState = Constants.GAME_STATE_DRAW_50;
			}
			else if (!enoughMaterials)
			{
				m_gameState = Constants.GAME_STATE_DRAW_INSUF_MATERIAL;
			}
			else if (noMoves)
			{
				//Stalemate (no moves, but not in check)
				m_gameState = Constants.GAME_STATE_DRAW_STALEMATE;
			}
			else if (inCheck)
			{
				m_gameState = Constants.GAME_STATE_CHECK;
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
		
		public function GetGameState():int 
		{
			return m_gameState;
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
		
		public function SelectPromotion(pieceTypeChosen:int):void
		{
			if (m_pawnPendingPromotion != null)
			{
				var teamPieces:Array = null;
				if (m_currentTeam == Constants.TEAM_WHITE)
				{
					teamPieces = m_whitePieces;
				}
				else
				{
					teamPieces = m_blackPieces;
				}
				
				//Generate the new piece
				var promotedPiece:Piece = null;
				var x:int = m_pawnPendingPromotion.GetLocation() % Constants.BOARD_SIZE;
				var y:int = m_pawnPendingPromotion.GetLocation() / Constants.BOARD_SIZE;
				switch (pieceTypeChosen)
				{
					case Constants.TYPE_QUEEN:
						promotedPiece = new Queen(m_currentTeam, x, y);
						break;
					case Constants.TYPE_ROOK:
						promotedPiece = new Rook(m_currentTeam, x, y);
						break;
					case Constants.TYPE_BISHOP:
						promotedPiece = new Bishop(m_currentTeam, x, y);
						break;
					case Constants.TYPE_KNIGHT:
						promotedPiece = new Knight(m_currentTeam, x, y);
						break;
				}
				promotedPiece.MovePiece(x, y);
				promotedPiece.Setup();
				
				//Adjust the board and team rosters
				var teamIndex:int = teamPieces.indexOf(m_pawnPendingPromotion);
				teamPieces.splice(teamIndex, 1);
				m_pawnPendingPromotion.Cleanup();
				m_pawnPendingPromotion = null;
				
				m_boardState[GetTileIndex(x, y)] = promotedPiece;
				teamPieces.push(promotedPiece);
			}
			
			EndTurn();
			UpdateAllViews();
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
		
		private function HasEnoughPiecesToWin(teamPieces:Array):Boolean 
		{
			var spacesCovered:int = 0;
			for (var i:int = 0; i < teamPieces.length; i++)
			{
				var pieceType:int = (teamPieces[i] as Piece).GetType();
				if (pieceType == Constants.TYPE_PAWN
					|| pieceType == Constants.TYPE_ROOK
					|| pieceType == Constants.TYPE_QUEEN)
				{
					return true;
				}
				else if (pieceType == Constants.TYPE_BISHOP
					|| pieceType == Constants.TYPE_KNIGHT)
				{
					spacesCovered++;
					
					//The king can cover two spaces, but a minimum of 4 covered spaces are required for a checkmate.
					//4 = The space the enemy king is on and the minimum case of the corner where there are only 3 other moves
					if (spacesCovered >= 2)
					{
						return true;
					}
				}
			}
			return false;
		}
		
		private function CreateCurrentStateRep():String
		{
			var rep:String = new String();
			for (var i:int = 0; i < Constants.BOARD_SIZE * Constants.BOARD_SIZE; i++)
			{
				if (m_boardState[i] == null)
				{
					rep += "n";
				}
				else
				{
					var piece:Piece = m_boardState[i] as Piece;
					rep += piece.GetTeam() + piece.GetType();
				}
			}
			return rep;
		}
		
		private function ClearStateHistory():void
		{
			for (var i:int = 0; i < m_gameStateHistoryMap.length; i++)
			{
				delete m_gameStateHistory[m_gameStateHistoryMap[i]];
			}
			m_gameStateHistoryMap.splice(0, m_gameStateHistoryMap.length);
		}
		
		private function CheckForPendingPromotion():Boolean
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
			
			for (var i:int = 0; i < teamArray.length; i++)
			{
				var pawn:Pawn = teamArray[i] as Pawn;
				//See if the pawn has reached the edge of the board
				if (pawn != null)
				{
					var y:int = pawn.GetLocation() / Constants.BOARD_SIZE;
					if (y == 0 || y == Constants.BOARD_SIZE - 1)
					{
						m_pawnPendingPromotion = pawn;
						return true;
					}
				}
			}
			return false;
		}
		
	}

}
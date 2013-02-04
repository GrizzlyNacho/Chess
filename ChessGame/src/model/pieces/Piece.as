package model.pieces 
{
	import model.MatchMgr;
	
	/*
	 * Base class for all piece types
	 * Pieces track their location and an array of all positions they can affect.
	 * They update the list of positions they can affect only when there is a change in that list.
	 * This way, only relevant pieces go through the process of computing new positions each time a piece is moved.
	 */
	
	public class Piece 
	{
		protected var m_hasMoved:Boolean = false;
		protected var m_team:int = Constants.TEAM_NONE;
		protected var m_xPos:int = -1;
		protected var m_yPos:int = -1;
		
		//All tiles that the piece need be aware of
		//Includes possible moves, captures, and pieces this piece is defending
		protected var m_possibleTiles:Array = null;
		
		public function Piece(team:int, x:int, y:int) 
		{
			m_team = team;
			m_xPos = x;
			m_yPos = y;
			m_possibleTiles = new Array();
		}
		
		public function Clone():Piece
		{
			//Override in children to produce the same sub-class content
			return null;
		}
		
		public function Cleanup():void
		{
			m_possibleTiles.splice(0, m_possibleTiles.length);
			m_possibleTiles = null;
		}
		
		public function SetFlagsTo(piece:Piece):void
		{
			m_hasMoved = piece.m_hasMoved;
			m_xPos = piece.m_xPos;
			m_yPos = piece.m_yPos;
		}
		
		public function GetType():int
		{
			//Override in children
			return Constants.TYPE_NO_PIECE;
		}
		
		//This is only to be called on empty tiles
		public function CanMove(index:int):Boolean
		{
			return m_possibleTiles && m_possibleTiles.indexOf(index) >= 0;
		}
		
		//Only to be called on tiles with enemy pieces
		public function CanAttack(index:int):Boolean
		{
			return CanMove(index);
		}
		
		//Test if this index is within the possible moves list and update the possible moves list if it is
		public function CheckUpdate(movedFromIndex:int, movedToIndex:int):void
		{
			if (m_possibleTiles && (m_possibleTiles.indexOf(movedFromIndex) >= 0
				|| m_possibleTiles.indexOf(movedToIndex) >= 0))
			{
				UpdateAvailableMoves();
			}
		}
		
		//To be used just after the board is set up and before any player's turn
		public function Setup():void
		{
			m_hasMoved = false;
			UpdateAvailableMoves();
		}
		
		public function MovePiece(x:int, y:int):void
		{
			m_hasMoved = true;
			m_xPos = x;
			m_yPos = y;
			
			//This piece's possible moves will update with the rest of the pieces when checkUpdate is called
		}
		
		public function GetTeam():int 
		{
			return m_team;
		}
		
		public function GetLocation():int 
		{
			return MatchMgr.GetInstance().GetTileIndex(m_xPos, m_yPos);
		}
		
		public function GetHasMoved():Boolean 
		{
			return m_hasMoved;
		}
		
		public function HasValidMove():Boolean 
		{
			for (var move:int = 0; move < m_possibleTiles.length; move++)
			{
				var x:int = m_possibleTiles[move] % Constants.BOARD_SIZE;
				var y:int = m_possibleTiles[move] / Constants.BOARD_SIZE;
				if (MatchMgr.GetInstance().IsValidMove(this, x, y))
				{
					return true;
				}
			}
			return false;
		}
		
		
		//Add all spaces that can be moved to, defended, or captured to possible moves
		protected function UpdateAvailableMoves():void
		{
			//Override in children
		}
		
		//Determines if the move is possible or not, and adds it if it is
		//Will return true if the case is added and the space is empty
		protected function AddIfValidAttackOrMove(x:int, y:int):Boolean
		{
			if (IsMoveInBounds(x, y))
			{
				var tileType:int =  MatchMgr.GetInstance().GetTileType(x, y);
				var tileTeam:int = MatchMgr.GetInstance().GetTileTeam(x, y);
				
				//Either unoccupied or occupied by an enemy piece
				if (tileType == Constants.TYPE_NO_PIECE)
				{
					m_possibleTiles.push(MatchMgr.GetInstance().GetTileIndex(x, y));
					return true;
				}
				else if (tileType != Constants.TYPE_NO_PIECE)
				{
					m_possibleTiles.push(MatchMgr.GetInstance().GetTileIndex(x, y));
					return false;
				}
				
			}
			return false;
		}
		
		protected function IsMoveInBounds(x:int, y:int):Boolean
		{
			return (x >= 0 && y >= 0 && x < Constants.BOARD_SIZE && y < Constants.BOARD_SIZE);
		}
		
	}

}
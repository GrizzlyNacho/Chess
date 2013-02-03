package model.pieces 
{
	import model.pieces.Piece;
	import model.MatchMgr;
	
	public class Pawn extends Piece 
	{
		
		public function Pawn(team:int) 
		{
			super(team);
		}
		
		override public function GetType():int
		{
			return Constants.TYPE_PAWN;
		}
		
		override public function GetAvailableMovesFrom(x:int, y:int):Array
		{
			var moves:Array = new Array();
			var direction:int = (m_team == Constants.TEAM_WHITE) ? -1 : 1;
			
			//Test the basic move (x, y+direction) into an unoccupied space
			AddValidUnoccupiedMove(x, y + direction, moves);
			
			//Test the special first move (x, y + 2*direction) into an unoccupied space
			AddValidUnoccupiedMove(x, y + 2 * direction, moves);
			
			//Check attack moves
			AddValidPawnAttackMove(x - 1, y + direction, moves);
			AddValidPawnAttackMove(x + 1, y + direction, moves);
			
			//FIXME: En Passant Case
			
			return moves;
		}
		
		private function AddValidUnoccupiedMove(x:int, y:int, outMoves:Array):void
		{
			if (IsMoveInBounds(x, y) && MatchMgr.GetInstance().GetTileType(x, y) == Constants.TYPE_NO_PIECE)
			{
				outMoves.push(MatchMgr.GetInstance().GetTileIndex(x, y));
			}
		}
		
		private function AddValidPawnAttackMove(x:int, y:int, outMoves:Array):void
		{
			if (IsMoveInBounds(x, y) 
				&& MatchMgr.GetInstance().GetTileType(x, y) != Constants.TYPE_NO_PIECE
				&& MatchMgr.GetInstance().GetTileTeam(x, y) != m_team)
			{
				outMoves.push(MatchMgr.GetInstance().GetTileIndex(x, y));
			}
		}
		
	}

}
package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import model.MatchMgr;
	import viewController.ChessBoard;
	
	public class Main extends Sprite 
	{

		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//Force initialization of MatchMgr
			MatchMgr.GetInstance();
			
			//Create the board
			var chessBoard:ChessBoard = new ChessBoard();
			this.addChild(chessBoard);
			
			MatchMgr.GetInstance().StartNewGame();
		}
		
	}
	
}
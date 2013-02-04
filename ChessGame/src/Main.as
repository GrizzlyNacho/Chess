package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import model.MatchMgr;
	import viewController.ChessBoard;
	import viewController.InfoPanel;
	
	
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
			
			//Create the Turn Display
			var turnDisplay:InfoPanel = new InfoPanel(Constants.BOARD_SIZE * Constants.TILE_SIZE_PIXELS + 20, 5);
			this.addChild(turnDisplay);
			
			MatchMgr.GetInstance().StartNewGame();
		}
		
	}
	
}
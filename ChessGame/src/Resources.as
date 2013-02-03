package  
{
	//Class for declaring the embedded art assets
	//Embedded as there are not many images and there is no resource manager yet
	public class Resources 
	{
		[Embed (source = "../assets/pawn.png")]
		public static const PawnImage:Class;
	}

}
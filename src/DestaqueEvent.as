package  
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class DestaqueEvent extends Event 
	{
		static const DESTAQUE:String = "destaque";
		static const APAGA:String = "apaga";
		public var destaque:String;
		
		public function DestaqueEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) 
		{
			super(type, bubbles, cancelable);
			
		}
		
	}

}
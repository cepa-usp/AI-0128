package  
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class TimeLineEvent extends Event 
	{
		static const REMOVE:String = "remove";
		static const BLOCK:String = "blockSelection";
		static const UNBLOCK:String = "unblockSelection";
		private var _obj:DisplayObject;
		
		public function TimeLineEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) 
		{
			super(type, bubbles, cancelable);
			
		}
		
		public function get obj():DisplayObject 
		{
			return _obj;
		}
		
		public function set obj(value:DisplayObject):void 
		{
			_obj = value;
		}
		
	}

}
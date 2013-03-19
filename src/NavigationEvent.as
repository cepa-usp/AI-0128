package  
{
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class NavigationEvent extends Event 
	{
		static const ADJUST_NAVIGATION:String = "navigation";
		static const ADJUST_TIMELINE:String = "timeline";
		static const ADD_POINT:String = "addpoint";
		static const REMOVE_POINT:String = "removepoint";
		
		private var _position:Number;
		private var _point:Point;
		
		public function NavigationEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) 
		{
			super(type, bubbles, cancelable);
			
		}
		
		public function get position():Number 
		{
			return _position;
		}
		
		public function set position(value:Number):void 
		{
			_position = value;
		}
		
		public function get point():Point 
		{
			return _point;
		}
		
		public function set point(value:Point):void 
		{
			_point = new Point(value.x, value.y);
		}
		
	}

}
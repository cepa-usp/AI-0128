package  
{
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class AddObjCmd extends Event 
	{
		static const ADD:String = "add";
		
		private var _position:Point;
		private var _index:String;
		private var _classe:String;
		private var _pai:int;
		
		public function AddObjCmd(type:String, bubbles:Boolean = false, cancelable:Boolean = false) 
		{
			super(type, bubbles, cancelable);
			
		}
		
		public function get position():Point 
		{
			return _position;
		}
		
		public function set position(value:Point):void 
		{
			_position = new Point(value.x, value.y);
		}
		
		public function get index():String 
		{
			return _index;
		}
		
		public function set index(value:String):void 
		{
			_index = value;
		}
		
		public function get classe():String 
		{
			return _classe;
		}
		
		public function set classe(value:String):void 
		{
			_classe = value;
		}
		
		public function get pai():int 
		{
			return _pai;
		}
		
		public function set pai(value:int):void 
		{
			_pai = value;
		}
		
	}

}
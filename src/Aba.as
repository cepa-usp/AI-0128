package  
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Aba extends MovieClip
	{
		private var _itens:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		
		public function Aba() 
		{
			this.mouseChildren = false;
		}
		
		public function addItem(item:DisplayObject):void
		{
			itens.push(item);
		}
		
		public function get itens():Vector.<DisplayObject> 
		{
			return _itens;
		}
		
		public function gotoLayer(layerNumber:int):void
		{
			this.gotoAndStop(layerNumber);
		}
		
		public function getFrame():int
		{
			return this.currentFrame;
		}
	}

}
package 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * - Criar a barra
	 * - Criar a janela de arraste
	 * - Enviar posição 
	 * - Receber marcações
	 * 
	 * @author Brunno
	 */
	public class Navigation extends MovieClip 
	{
		private var col:int;
		private var lin:int;
		private var width_bar:Number;
		private var height_bar:Number;
		private var baseBar:Sprite;
		private var slider:MarcadorTimeline;
		private var shadow:Sombra;
		private var lineCron:LinhaCron;
		private var maskBar:Sprite;
		private var label_global:Sprite;
		
		private var width_slider:Number = 100;
		private var height_slider:Number = 25;
		private var target:Object;
		private var clickDown:Point = new Point(0,0);
		private var grid:Array;
		
		/**
		 * Contrutor da barra de navegação
		 * @param	W: lagura desejada para a barra 
		 * @param	H: altura desejada para a barra
		 * @param	C: quantidade de colunas que será dividida a barra
		 * @param	L: quantidade de linhas que será dividida a barra
		 */
		public function Navigation(W:Number = 1024, H:Number = 65, C:int = 54, L:int = 3)
		{
			shadow = new Sombra();
			shadow.x = -12;
			shadow.y = 0;
			addChild(shadow);
			
			label_global = new Sprite();
			addChild(label_global);
			
			width_bar = W;
			height_bar = H;
			
			width_slider = width_bar * width_bar / 10786.95;
			height_slider = height_bar;
			
			col = C;
			lin = L;
			
			lineCron = new LinhaCron();
			lineCron.x = 0;
			lineCron.y = 0;
			label_global.addChild(lineCron);
			
			drawBar();
			drawGrid();
			drawMask();
			drawSlider();
			
			label_global.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void { 
					while (label_global.alpha > 0.2) { label_global.alpha -= 0.1; } 
					shadow.rotation = 0;
					shadow.x = -12;
					shadow.y = 0;
				} );
			label_global.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void { 
					while (label_global.alpha < 1) { label_global.alpha += 0.1; } 
					shadow.rotation = 180;
					shadow.x = -12+shadow.width;
					shadow.y = 2*shadow.height;
				} );
		}
		
		private function drawGrid():void 
		{
			var aux = new Array();
			
			grid = new Array();
			for (var i = 0; i < col; i++) {
				aux[i] = new Array();
				grid[i] = new Array();
				for (var j = 0; j < lin; j++) {
					grid[i][j] = new Sprite();
					grid[i][j].graphics.beginFill(0xFF0000, 0);
					grid[i][j].graphics.drawRect(i * width_bar / col, j * height_bar / lin, width_bar / col, height_bar / lin);
					grid[i][j].alpha = 0;
					label_global.addChild(grid[i][j]);
					
					aux[i][j] = new Sprite();
					if (j == 0) aux[i][j].graphics.beginFill(0x0000A0, 0.8);
					if (j == 1) aux[i][j].graphics.beginFill(0xFF0000, 0.8);
					if (j == 2) aux[i][j].graphics.beginFill(0x008000, 0.8);
					aux[i][j].graphics.drawRect(i * width_bar / col+1, j * height_bar / lin+1, width_bar / col-2, height_bar / lin-2);
					grid[i][j].addChild(aux[i][j]);
				}
			}
		}
		
		private function drawBar():void
		{
			baseBar = new Sprite();
			baseBar.graphics.beginFill(0xFFCC00, 0.2);
			baseBar.graphics.lineStyle(1, 0x000000, 1);
			baseBar.graphics.moveTo(0, 0);
			baseBar.graphics.drawRect(0, 0, width_bar, height_bar);
			label_global.addChild(baseBar);
		}
		
		private function drawMask():void
		{
			maskBar = new Sprite();
			maskBar.graphics.beginFill(0xFFCC00, 0);
			maskBar.graphics.moveTo(0, 0);
			maskBar.graphics.drawRect(0, 0, width_bar, 68);
			maskBar.addEventListener(MouseEvent.CLICK, maskBarMouseClick);
			label_global.addChild(maskBar);
		}
		
		private function drawSlider():void
		{
			slider = new MarcadorTimeline();
			//slider.graphics.beginFill(0x000000, 0.1);
			//slider.graphics.lineStyle(1, 0x000000, 1);
			//slider.graphics.moveTo(0, 0);
			//slider.graphics.drawRect(0, 0, width_slider, height_slider);
			slider.x = 0;
			slider.y = 0;
			slider.width = width_slider;
			slider.height = height_slider;
			label_global.addChild(slider);
			
			slider.addEventListener(MouseEvent.MOUSE_DOWN, sliderMouseDown);
		}
		
		private function maskBarMouseClick(e:MouseEvent):void 
		{
			if (e.target.mouseX > slider.width / 2 && e.target.mouseX < width_bar-slider.width / 2)
			{
				slider.x = e.target.mouseX - slider.width / 2;
			}else {
				if (e.target.mouseX <= slider.width / 2) slider.x = 0;
				
				if (e.target.mouseX >= width_bar-slider.width / 2) slider.x = width_bar-slider.width;
			}			
			var aux:NavigationEvent = new NavigationEvent(NavigationEvent.ADJUST_TIMELINE);
			aux.position = sendLocation();
			dispatchEvent(aux);
		}
		
		private function sliderMouseDown(e:MouseEvent):void 
		{
			target = e.target;
			clickDown.x = slider.mouseX;
			clickDown.y = slider.mouseY;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, sliderMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, sliderMouseUp);
		}
		
		private function sliderMouseMove(e:MouseEvent):void 
		{
			if(this.mouseX - clickDown.x > 0 && this.mouseX -clickDown.x + slider.width < width_bar){
				target.x = this.mouseX - clickDown.x;
			}else {
				if (this.mouseX - clickDown.x <= 0) target.x = 0;
				
				if (this.mouseX - clickDown.x + slider.width >= width_bar) target.x = width_bar - slider.width;
			}
			
			var aux:NavigationEvent = new NavigationEvent(NavigationEvent.ADJUST_TIMELINE);
			aux.position = sendLocation();
			dispatchEvent(aux);
		}
		
		private function sliderMouseUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, sliderMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, sliderMouseUp);
		}
		
		public function sendLocation():Number
		{
			var aux:Number;
			aux = slider.x / (width_bar - slider.width);
			return aux;
		}
		
		public function adjustNavigation(value:Number)
		{
			slider.x = (width_bar - slider.width) * value;
		}
		
		public function addPoint(p:Point)
		{
			grid[p.x][p.y].alpha = 1;
		}
		
		public function removePoint(p:Point)
		{
			grid[p.x][p.y].alpha = 0;
		}
		
	}
	
}
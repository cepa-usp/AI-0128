package  
{
	import com.eclecticdesignstudio.motion.Actuate;
	import com.eclecticdesignstudio.motion.easing.Elastic;
	import com.eclecticdesignstudio.motion.easing.Linear;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class TimeLine extends Sprite
	{
		private var w:Number;
		private var h:Number;
		private var dX:Number;
		private var dY:Number;
		private var ySpace:Number;
		private var backgroundLayer:Sprite;
		private var objLayer:Sprite;
		private var legendasLayer:Sprite;
		private var linhadoTempoLayer:Sprite;
		private var timeLineBackground:TimeLineBackground;
		public var legenda:Legendas;
		private var objects:Vector.<Vector.<DisplayObject>>;
		private var colX:Number;
		private var colY:Number;
		private var dictIndexY:Dictionary = new Dictionary(true);
		private var answer:Dictionary = new Dictionary();
		private var excludedX:Vector.<int> = new Vector.<int>();
		
		public function TimeLine(w:Number, h:Number, colX:Number, colY:Number, ySpace:Number = 0) 
		{
			this.w = w;
			this.h = h;
			this.dX = w/colX;
			this.dY = (h - ySpace)/colY;
			this.ySpace = ySpace;
			this.colX = colX;
			this.colY = colY;
			
			
			createLayers();
			createObjectsVector(colX, colY);
			createBackground();
			createDirectionBars();
			createAnswer();
			addExcludedX();
			
			//addEventListener(Event.ENTER_FRAME, adjustTimelinePosition);
			this.addEventListener(MouseEvent.MOUSE_OVER, addAdjustListener);
			this.addEventListener(MouseEvent.MOUSE_OUT, removeAdjustListener);
			this.addEventListener(MouseEvent.MOUSE_MOVE, bringObjectsToFront);
		}
		
		private function createLayers():void 
		{
			backgroundLayer = new Sprite();
			addChild(backgroundLayer);
			
			legendasLayer = new Sprite();
			addChild(legendasLayer);
			
			objLayer = new Sprite();
			addChild(objLayer);
			
			linhadoTempoLayer = new Sprite();
			addChild(linhadoTempoLayer);
		}
		
		private function bringObjectsToFront(e:MouseEvent):void 
		{
			if(draggingObject == null){
				var index:Point = getFloorIndex(new Point(stage.mouseX, stage. mouseY));
				//var index:Point = getIndex(new Point(stage.mouseX, stage.mouseY));
				
				if (index.x >= 0 && index.x < colX && index.y >= 0 && index.y < colY) {
					if (objects[index.y][index.x] != null) {
						objLayer.setChildIndex(objects[index.y][index.x], objLayer.numChildren - 1);
					}
				}
			}
		}
		
		private function addExcludedX():void 
		{
			excludedX.push(40);
			excludedX.push(41);
			excludedX.push(58);
			excludedX.push(59);
		}
		
		private function createAnswer():void 
		{
			answer["Mom1Big"] = new Point(0, 31); //Grécia antiga
			answer["Mom2Big"] = new Point(50, 63); //Idade média
			answer["Mom3Big"] = new Point(60, 71); //Renascimento
			answer["Mom4Big"] = new Point(68, 79); //Reforma protestante
			answer["Mom5Big"] = new Point(76, 83); //Contra reforma
			answer["Mom6Big"] = new Point(76, 91); //Iluminismo
			answer["Mom7Big"] = new Point(97, 107); //Pedagogia nova
			
			answer["Per1Big"] = new Point(0, 2);//Grécia antiga: Sofistas
			answer["Per2Big"] = new Point(50, 63);//Idade média
			answer["Per3Big"] = new Point(66, 71);//Renascimento:Rabelais
			answer["Per4Big"] = new Point(68, 75);//Reforma protestante
			answer["Per5Big"] = new Point(76, 83);//Contrareforma
			answer["Per6Big"] = new Point(76, 91);//Iluminismo
			answer["Per7Big"] = new Point(97, 107);//Pedagogia nova
			answer["Per8Big"] = new Point(3, 7);//Grácia antiga: Sócrates
			answer["Per9Big"] = new Point(10, 16);//Grácia antiga: Platão
			answer["Per10Big"] = new Point(64, 70);//Renascimento: Erasmo
			
			answer["Item0Big"] = new Point(10, 16); //Platão
			answer["Item1Big"] = new Point(3, 7);   //Sócrates
			answer["Item2Big"] = new Point(99, 104);//Freinet
			answer["Item3Big"] = new Point(86, 92); //Kant
			answer["Item4Big"] = new Point(66, 71); //Lutero
			answer["Item5Big"] = new Point(83, 87); //Montesquieu
			answer["Item6Big"] = new Point(79, 85); //Newton
			answer["Item7Big"] = new Point(99, 102); //Vygotsky
			answer["Item8Big"] = new Point(83, 90); //Voltaire
			answer["Item9Big"] = new Point(50, 57); //Carlos Magno
			answer["Item10Big"] = new Point(64, 70);//Erasmo
			answer["Item11Big"] = new Point(79, 83);//Locke
			answer["Item12Big"] = new Point(66, 71);//Rabelais
			answer["Item13Big"] = new Point(85, 90);//Rousseau
			answer["Item14Big"] = new Point(98, 103);//Montessori
			answer["Item15Big"] = new Point(99, 106);//Piaget
			answer["Item16Big"] = new Point(0, 2);//Sofistas
			answer["Item17Big"] = new Point(72, 75);//Jesuitas

		}
		
		private function createObjectsVector(colX:Number, colY:Number):void 
		{
			objects = new Vector.<Vector.<DisplayObject>>();
			
			for (var i:int = 0; i < colY; i++) 
			{
				objects[i] = new Vector.<DisplayObject>(colX);
			}
		}
		
		private function addAdjustListener(e:MouseEvent):void 
		{
			stage.addEventListener(Event.ENTER_FRAME, adjustTimelinePosition);
		}
		
		private function removeAdjustListener(e:MouseEvent):void
		{
			stage.removeEventListener(Event.ENTER_FRAME, adjustTimelinePosition);
			leftBar.visible = false;
			rightBar.visible = false;
		}
		
		private var stageWidth:Number = 1024;
		
		private function adjustTimelinePosition(e:Event):void 
		{
			if (this.hitTestPoint(stage.mouseX, stage.mouseY)) {
				var mousePosGlobal:Point = new Point(stage.mouseX, stage.mouseY);
				var diff:Number = w - stageWidth;
				if (mousePosGlobal.x < 50) {
					leftBar.visible = true;
					objLayer.x = Math.max( -diff, Math.min(0, objLayer.x + 5));
					linhadoTempoLayer.x = objLayer.x;
					backgroundLayer.x = objLayer.x;
					adjustNavigation();
				}else if (mousePosGlobal.x > stageWidth - 50) {
					rightBar.visible = true;
					objLayer.x = Math.max( -diff, Math.min(0, objLayer.x - 5));
					linhadoTempoLayer.x = objLayer.x;
					backgroundLayer.x = objLayer.x;
					adjustNavigation();
				}else {
					leftBar.visible = false;
					rightBar.visible = false;
				}
			}else {
				leftBar.visible = false;
				rightBar.visible = false;
			}
		}
		
		private function adjustNavigation():void
		{
			var posScreen:Point = objLayer.globalToLocal(new Point(0, 0));
			var event:NavigationEvent = new NavigationEvent(NavigationEvent.ADJUST_NAVIGATION, true);
			event.position = posScreen.x / (w - stageWidth);
			dispatchEvent(event);
		}
		
		public function adjustTimeline(pos:Number):void
		{
			objLayer.x = -(w - stageWidth) * pos;
			linhadoTempoLayer.x = objLayer.x;
			backgroundLayer.x = objLayer.x;
		}
		
		private var leftBar:LeftBar;
		private var rightBar:RightBar;
		private function createDirectionBars():void 
		{
			leftBar = new LeftBar();
			//leftBar = new Sprite();
			//leftBar.graphics.beginFill(0x000000, 0.5);
			//leftBar.graphics.drawRect(0, 0, 50, h);
			//leftBar.graphics.lineStyle(5, 0x000000);
			//leftBar.graphics.moveTo(50 / 3, h / 2);
			//leftBar.graphics.lineTo(2 * (50 / 3), (h / 2) - 50);
			//leftBar.graphics.moveTo(50 / 3, h / 2);
			//leftBar.graphics.lineTo(2 * (50 / 3), (h / 2) + 50);
			addChild(leftBar);
			leftBar.visible = false;
			
			rightBar = new RightBar();
			//rightBar = new Sprite();
			//rightBar.graphics.beginFill(0x000000, 0.5);
			//rightBar.graphics.drawRect(0, 0, 50, h);
			//rightBar.graphics.lineStyle(5, 0x000000);
			//rightBar.graphics.moveTo(2 * (50 / 3), h / 2);
			//rightBar.graphics.lineTo(50 / 3, (h / 2) - 50);
			//rightBar.graphics.moveTo(2 * (50 / 3), h / 2);
			//rightBar.graphics.lineTo(50 / 3, (h / 2) + 50);
			addChild(rightBar);
			rightBar.x = 1024 - 55.96;
			rightBar.visible = false;
		}
		
		private function createBackground():void 
		{
			//this.graphics.lineStyle(1, 0x400000);
			//this.graphics.beginFill(0xC0C0C0, 0);
			//this.graphics.drawRect(0, 0, w, h);
			/*
			if(ySpace == 0){
				this.graphics.lineStyle(1, 0x00FF00);
				this.graphics.moveTo(0, h / 3);
				this.graphics.lineTo(w, h / 3);
				this.graphics.moveTo(0, 2 * (h / 3));
				this.graphics.lineTo(w, 2 * (h / 3));
			}else {
				this.graphics.lineStyle(1, 0x00FF00);
				this.graphics.moveTo(0, (h - ySpace) / 3);
				this.graphics.lineTo(w, (h - ySpace) / 3);
				this.graphics.moveTo(0, 2 * ((h - ySpace) / 3));
				this.graphics.lineTo(w, 2 * ((h - ySpace) / 3));
				this.graphics.moveTo(0, (2 * ((h - ySpace) / 3)) + ySpace);
				this.graphics.lineTo(w, (2 * ((h - ySpace) / 3)) + ySpace);
			}
			*/
			timeLineBackground = new TimeLineBackground();
			backgroundLayer.addChild(timeLineBackground);
			backgroundLayer.addEventListener(MouseEvent.MOUSE_DOWN, initDragBackground);
			
			legenda = new Legendas();
			legendasLayer.addChild(legenda);
			legenda.y = - 67;
			legendasLayer.addEventListener(MouseEvent.MOUSE_DOWN, initDragBackground);
			
			var linhaDoTempo:LinhaTempo = new LinhaTempo();
			linhadoTempoLayer.addChild(linhaDoTempo);
			linhadoTempoLayer.addEventListener(MouseEvent.MOUSE_DOWN, initDragBackground);
			
			//drawGrid(linhadoTempoLayer.graphics);
		}
		
		private var posClickGlobal:Point;
		private function initDragBackground(e:MouseEvent):void 
		{
			posClickGlobal = new Point(stage.mouseX, stage.mouseY);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, movingBackground);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopMovingBackground);
		}
		
		private function movingBackground(e:MouseEvent):void 
		{
			var mousePosGlobal:Point = new Point(stage.mouseX, stage.mouseY);
			var diff:Number = w - stageWidth;
			
			objLayer.x = Math.max( -diff, Math.min(0, objLayer.x + (mousePosGlobal.x - posClickGlobal.x)));
			linhadoTempoLayer.x = objLayer.x;
			backgroundLayer.x = objLayer.x;
			adjustNavigation();
			
			posClickGlobal = new Point(mousePosGlobal.x, mousePosGlobal.y);
		}
		
		private function stopMovingBackground(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, movingBackground);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopMovingBackground);
			
			movingBackground(null);
			posClickGlobal = null;
		}
		
		/*private function drawGrid(spr:Graphics):void 
		{
			spr.lineStyle(2, 0x000000);
			
			spr.moveTo(0, h / 3);
			spr.lineTo(w, h / 3);
			
			spr.moveTo(0, 2 * (h / 3));
			spr.lineTo(w, 2 * (h / 3));
			
			for (var i:int = 0; i < colX; i++) 
			{
				spr.moveTo(dX * i, 0);
				spr.lineTo(dX * i, h);
			}
		}*/
		
		private function getFloorIndex(pos:Point):Point
		{
			pos = objLayer.globalToLocal(pos);
			var index:Point = new Point(Math.floor(pos.x / dX), Math.floor(pos.y / dY));
			if (index.y >= colY - 1 && ySpace != 0) {
				index = new Point(Math.floor(pos.x / dX), Math.floor((pos.y - ySpace) / dY));
			}
			return index;
		}
		
		public function getIndex(pos:Point):Point
		{
			pos = objLayer.globalToLocal(pos);
			var index:Point = new Point(Math.round(pos.x / dX), Math.round(pos.y / dY));
			//var index:Point = new Point(Math.floor(pos.x / dX), Math.floor(pos.y / dY));
			if (index.y >= colY - 1 && ySpace != 0) {
				index = new Point(Math.round(pos.x / dX), Math.round((pos.y - ySpace) / dY));
			}
			return index;
		}
		
		private function getInternalIndex(pos:Point):Point
		{
			var index:Point = new Point(Math.round(pos.x / dX), Math.round(pos.y / dY));
			//var index:Point = new Point(Math.floor(pos.x / dX), Math.floor(pos.y / dY));
			if (index.y >= colY - 1 && ySpace != 0) {
				index = new Point(Math.round(pos.x / dX), Math.round((pos.y - ySpace) / dY));
			}
			return index;
		}
		
		public function getNearestPosition(pos:Point):Point
		{
			var index:Point = getIndex(pos);
			var nearestPos:Point = new Point(index.x * dX, index.y * dY + (index.y >= colY - 1 ? ySpace : 0));
			return nearestPos;
		}
		
		public function addObject(classe:String, nome:String, pos:Point, indexY:int):void
		{
			if (answered) {
				resetFilters();
				answered = false;
			}
			//pos = objLayer.globalToLocal(pos);
			var index:Point = getIndex(pos);
			var obj:DisplayObject = new (getDefinitionByName(classe));
			obj.name = nome;
			
			if (index.y < 0 || index.y > colY - 1 || indexY != index.y || index.x < 0 || index.x > colX - 1 || objects[index.y][index.x] != null || excludedX.indexOf(int(index.x)) != -1) {
				var newPos:Point = objLayer.globalToLocal(pos)
				obj.x = newPos.x;
				obj.y = newPos.y;
				objLayer.addChild(obj);
				draggingObject = obj;
				tweenToRemove();
			}else {
				dictIndexY[obj] = indexY;
				var position:Point = getNearestPosition(pos);
				obj.x = position.x;
				obj.y = position.y;
				objLayer.addChild(obj);
				objects[index.y][index.x] = DisplayObject(obj);
				obj.addEventListener(MouseEvent.MOUSE_DOWN, initDragObject);
				dispatchAddPoint(index);
			}
		}
		
		public function addObjectIndex(classe:String, nome:String, index:Point, indexY:int):void
		{
			var posPixel:Point = objLayer.localToGlobal(new Point(index.x * dX, index.y * dY));
			addObject(classe, nome, posPixel, indexY);
		}
		
		private function dispatchAddPoint(point:Point):void 
		{
			var addPoint:NavigationEvent = new NavigationEvent(NavigationEvent.ADD_POINT, true);
			addPoint.point = point;
			dispatchEvent(addPoint);
		}
		
		private function dispatchRemovePoint(point:Point):void 
		{
			var removePoint:NavigationEvent = new NavigationEvent(NavigationEvent.REMOVE_POINT, true);
			removePoint.point = point;
			dispatchEvent(removePoint);
		}
		
		private var draggingObject:DisplayObject;
		private var diffToDrag:Point;
		
		private function initDragObject(e:MouseEvent):void 
		{
			if (draggingObject == null) {
				if (answered) {
					resetFilters();
					answered = false;
				}
				draggingObject = DisplayObject(e.target);
				objLayer.setChildIndex(draggingObject, objLayer.numChildren - 1);
				diffToDrag = new Point(draggingObject.mouseX, draggingObject.mouseY);
				
				var index:Point = getIndex(objLayer.localToGlobal(new Point(draggingObject.x, draggingObject.y)));
				dispatchRemovePoint(index);
				objects[index.y][index.x] = null;
				
				stage.addEventListener(MouseEvent.MOUSE_MOVE, movingObj);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopDragObject);
			}
		}
		
		private function movingObj(e:MouseEvent):void 
		{
			draggingObject.x = objLayer.mouseX - diffToDrag.x;
			draggingObject.y = objLayer.mouseY - diffToDrag.y;
		}
		
		private function stopDragObject(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, movingObj);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragObject);
			
			var index:Point = getIndex(objLayer.localToGlobal(new Point(draggingObject.x, draggingObject.y)));
			if (index.y > colY - 1 || index.y < 0 || index.y != dictIndexY[draggingObject] || index.x < 0 || index.x > colX - 1 || objects[index.y][index.x] != null || excludedX.indexOf(int(index.x)) != -1) {
				tweenToRemove();
			}else{
				var position:Point = getNearestPosition(objLayer.localToGlobal(new Point(draggingObject.x, draggingObject.y)));
				
				draggingObject.x = position.x;
				draggingObject.y = position.y;
				objects[index.y][index.x] = DisplayObject(draggingObject);
				draggingObject = null;
				dispatchAddPoint(index);
			}
			diffToDrag = null;
		}
		
		private function tweenToRemove():void
		{
			dispatchEvent(new TimeLineEvent(TimeLineEvent.BLOCK, true));
			var posTween:Point = objLayer.globalToLocal(new Point(500, 700));
			Actuate.tween(draggingObject, 0.5, { x:posTween.x, y:posTween.y, width:10, height:10, alpha:0.1 } ).onComplete(sendEventToRemove).ease(Linear.easeNone);
		}
		
		private function sendEventToRemove(obj:DisplayObject = null):void
		{
			var evt:TimeLineEvent = new TimeLineEvent(TimeLineEvent.REMOVE, true);
			if (obj != null) evt.obj = obj;
			else evt.obj = draggingObject;
			dispatchEvent(evt);
		}
		
		public function removeObj(obj:DisplayObject):void
		{
			var index:Point = getIndex(objLayer.localToGlobal(new Point(obj.x, obj.y)));
			objLayer.removeChild(obj);
			if ((index.y < colY && index.y >= 0) && (index.x >= 0 && index.x < colX)) objects[index.y][index.x] = null;
			dictIndexY[obj] = null;
			draggingObject = null;
			dispatchEvent(new TimeLineEvent(TimeLineEvent.UNBLOCK, true));
		}
		
		public function reset():void
		{
			for (var i:int = objects.length - 1; i >= 0; i--) 
			{
				for (var j:int = objects[i].length - 1; j >= 0; j--) 
				{
					if (objects[i][j] != null) {
						sendEventToRemove(objects[i][j]);
						dispatchRemovePoint(new Point(j, i));
					}
				}
			}
			//createObjectsVector(colX, colY);
			dictIndexY = new Dictionary(true);
		}
		
		public function getState():Array
		{
			var objectsState:Array = [];
			
			for (var i:int = 0; i < objects.length; i++) 
			{
				for (var j:int = 0; j < objects[i].length; j++) 
				{
					if (objects[i][j] != null) {
						var pos:Point = getInternalIndex(new Point(objects[i][j].x, objects[i][j].y));
						//var object:DisplayObject = objects[i][j];
						
						var obj:Object = {
							classe: getQualifiedClassName(objects[i][j]),
							nome: objects[i][j].name,
							posX: Number(pos.x),
							posY: Number(pos.y),
							indexY: int(dictIndexY[objects[i][j]])
						}
						//trace(obj.classe);
						//trace(obj.nome);
						//trace(obj.posX);
						//trace(obj.posY);
						//trace(obj.indexY);
						objectsState.push(obj);
					}
				}
			}
			
			return objectsState;
		}
		
		private var totalObjects:int = 35;
		private var answered:Boolean = false;
		
		public function getAnswer():Number
		{
			var score:Number = 0;
			
			for (var i:int = 0; i < objects.length; i++) 
			{
				for (var j:int = 0; j < objects[i].length; j++) 
				{
					if (objects[i][j] != null) {
						var classe:String = getQualifiedClassName(objects[i][j]);
						var xmin:int = answer[classe].x;
						var xmax:int = answer[classe].y;
						if (j >= xmin && j <= xmax) {
							score += 100 / totalObjects;
							DisplayObject(objects[i][j]).filters = [new GlowFilter(0x008000, 1, 6, 6, 5, 1, true)];
						}else {
							DisplayObject(objects[i][j]).filters = [new GlowFilter(0xFF0000, 1, 6, 6, 5, 1, true)];
						}
					}
				}
			}
			
			answered = true;
			
			return score;
		}
		
		private function resetFilters():void
		{
			for (var i:int = 0; i < objects.length; i++) 
			{
				for (var j:int = 0; j < objects[i].length; j++) 
				{
					if (objects[i][j] != null) {
						DisplayObject(objects[i][j]).filters = [];
					}
				}
			}
		}
		
	}

}
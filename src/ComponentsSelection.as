package  
{
	import cepa.utils.Cronometer;
	import cepa.utils.MouseMotionData;
	import com.eclecticdesignstudio.motion.Actuate;
	import fl.transitions.easing.None;
	import fl.transitions.Tween;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class ComponentsSelection extends MovieClip
	{
		private var abas:Vector.<Aba> = new Vector.<Aba>();
		private var containers:Vector.<Sprite> = new Vector.<Sprite>();
		private var dict:Dictionary = new Dictionary();
		private var inicialAbaPosition:Number = 5;
		private var abasDistance:Number = 3;
		private var abasLayer:Sprite;
		private var currentSelection:Sprite;
		private var currentAba:Aba;
		private var backgroundContainer:Sprite;
		private var mouseMotion:MouseMotionData = MouseMotionData.instance;
		private const widthStage:Number = 1024 - 120;
		
		public function ComponentsSelection() 
		{
			//var rect:Sprite = new Sprite();
			//rect.graphics.beginFill(0xC0C0C0);
			//rect.graphics.drawRect(0, 0, this.width - 120, this.height + 20);
			//addChild(rect);
			//rect.y = -20;
			//this.mask = DisplayObject(rect);
			createLayers();
		}
		
		private function createLayers():void 
		{
			backgroundContainer = new Sprite();
			addChild(backgroundContainer);
			abasLayer = new Sprite();
			addChild(abasLayer);
			setChildIndex(abasLayer, 0);
			currentSelection = new Sprite();
			addChild(currentSelection);
		}
		
		public function addAba(label:String):void
		{
			var aba:Aba = new Aba();
			aba.label.text = label;
			aba.buttonMode = true;
			aba.name = label;
			
			aba.x = inicialAbaPosition + abas.length * aba.width + abas.length * abasDistance;
			aba.addEventListener(MouseEvent.CLICK, selectAba);
			
			var container:Sprite = new Sprite();
			backgroundContainer.addChild(container);
			container.addEventListener(MouseEvent.MOUSE_DOWN, initDragObject);
			
			dict[aba] = container;
			
			abas.push(aba);
			if (abas.length == 1) {
				currentAba = aba;
				currentSelection.addChild(aba);
			}else {
				abasLayer.addChild(aba);
				container.visible = false;
			}
			aba.gotoLayer(abas.length);
		}
		
		private function selectAba(e:MouseEvent):void 
		{
			stage.removeEventListener(Event.ENTER_FRAME, continueDraggingAll);
			if (tweenX != null) {
				if (tweenX.isPlaying) {
					tweenX.stop();
					tweenX = null;
				}
			}
			var widthAba:Number = dict[currentAba].width;
			var diff:Number = widthAba - widthStage;
			
			if(widthAba > widthStage){
				if (dict[currentAba].x < -diff) {
					dict[currentAba].x = -diff;
				}else if (dict[currentAba].x > 0) {
					dict[currentAba].x = 0;
				}
			}
			
			var abaClick:Aba = Aba(e.target);
			if (abaClick != currentAba) {
				abasLayer.addChild(currentAba);
				currentSelection.addChild(abaClick);
				dict[currentAba].visible = false;
				dict[abaClick].visible = true;
				currentAba = abaClick;
			}
			
			fundo.gotoAndStop(currentAba.getFrame());
		}
		
		private var objName:int = 0;
		
		public function setNobjects(n:int):void
		{
			objName = n;
		}
		
		public function getState():Array
		{
			var state:Array = getObjectsState();
			
			return state;
		}
		
		private function getObjectsState():Array
		{
			var objState:Array = [];
			
			for (var i:int = 0; i < abas.length; i++) 
			{
				objState[i] = new Array();
				for (var j:int = 0; j < abas[i].itens.length; j++) 
				{
					if (MovieClip(abas[i].itens[j]).currentFrame == 2) objState[i][j] = true;
					else objState[i][j] = false;
				}
			}
			
			return objState;
		}
		
		public function setObjectState(state:Array):void
		{
			for (var i:int = 0; i < state.length; i++) 
			{
				for (var j:int = 0; j < state[i].length; j++) 
				{
					if (state[i][j]) greyscale(abas[i].itens[j]);
				}
			}
		}
		
		public function addItemToAba(item:DisplayObject, name:String):void
		{
			var abaToAdd:Aba = getAba(name);
			if (abaToAdd == null) return;
			
			dict[abaToAdd].addChild(item);
			item.y = 10;
			item.x = getXposition(abaToAdd);
			item.name = String(objName);
			objName++;
			
			abaToAdd.addItem(item);
			drawBackground(dict[abaToAdd]);
		}
		
		private function drawBackground(spr:Sprite):void 
		{
			spr.graphics.clear();
			spr.graphics.beginFill(0xFF8080, 0);
			spr.graphics.drawRect(0, 0, spr.width + 20, 80);
		}
		
		private function getXposition(aba:Aba):Number
		{
			var dist:Number = 10;
			var inicialXpos:Number = 10;
			var xPos:Number = inicialXpos;
			
			if(aba.itens.length > 0){
				for (var i:int = 0; i < aba.itens.length; i++) 
				{
					xPos += aba.itens[i].width;
					xPos += dist;
				}
			}
			
			return xPos;
		}
		
		private var draggingObject:DisplayObject;
		private var posClick:Point;
		private var objClicked:MovieClip;
		private var diffToDrag:Point;
		public var allowDRag:Boolean = true;
		
		private function initDragObject(e:MouseEvent):void 
		{
			if(allowDRag){
				posClick = new Point(stage.mouseX, stage.mouseY);
				
				if(e.target is MovieClip){
					draggingObject = new (getDefinitionByName(getQualifiedClassName(e.target)));
					objClicked = MovieClip(e.target);
					draggingObject.name = objClicked.name;
					diffToDrag = new Point(objClicked.mouseX, objClicked.mouseY);
					draggingObject.x = stage.mouseX - diffToDrag.x;
					draggingObject.y = stage.mouseY - diffToDrag.y;
				}
				
				stage.addEventListener(MouseEvent.MOUSE_MOVE, verifyDirection);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopDragObject);
			}
		}
		
		//private function initDrag(e:MouseEvent):void
		//{
			//draggingObject = DisplayObject(e.target);
			//objClicked = MovieClip(getObjectInAba(draggingObject));
			//diffToDrag = new Point(draggingObject.mouseX, draggingObject.mouseY);
			//draggingObject.x = stage.mouseX - diffToDrag.x;
			//draggingObject.y = stage.mouseY - diffToDrag.y;
			//
			//stage.addEventListener(MouseEvent.MOUSE_MOVE, movingObj);
			//stage.addEventListener(MouseEvent.MOUSE_UP, stopDragObject);
		//}
		
		private function getObjectInAba(outObj:DisplayObject):DisplayObject 
		{
			for each(var aba:Aba in abas) {
				for each(var obj:DisplayObject in aba.itens) {
					if (obj.name == outObj.name) return obj;
				}
			}
			
			return null;
		}
		
		private function verifyDirection(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, verifyDirection);
			var mousePos:Point = new Point(stage.mouseX, stage.mouseY);
			var angle:Number = Math.atan2(mousePos.y - posClick.y, mousePos.x - posClick.x) * 180/Math.PI;
			if (Math.abs(angle) < 10 || Math.abs(angle - 180) < 10) {
				draggingObject = null;
				if (dict[currentAba].width > widthStage) stage.addEventListener(MouseEvent.MOUSE_MOVE, movingAllObj);
			}else {
				if(draggingObject != null){
					stage.addChild(draggingObject);
					greyscale(objClicked);
					var destaqueEvent:DestaqueEvent = new DestaqueEvent(DestaqueEvent.DESTAQUE, true);
					destaqueEvent.destaque = currentAba.name;
					dispatchEvent(destaqueEvent);
					//MovieClip(objClicked).mouseEnabled = false;
					stage.addEventListener(MouseEvent.MOUSE_MOVE, movingObj);
				}
			}
		}
		
		private function movingAllObj(e:MouseEvent):void 
		{
			var widthAba:Number = dict[currentAba].width;
			var diff:Number = widthAba - widthStage;
			var diffClickX:Number = stage.mouseX - posClick.x;
			posClick.x = stage.mouseX;
			
			dict[currentAba].x = Math.max(-diff - 10, Math.min(10, dict[currentAba].x + diffClickX));
		}
		
		private function movingObj(e:MouseEvent):void 
		{
			draggingObject.x = stage.mouseX - diffToDrag.x;
			draggingObject.y = stage.mouseY - diffToDrag.y;
		}
		
		private function stopDragObject(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, verifyDirection);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, movingObj);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, movingAllObj);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragObject);
			
			if (draggingObject != null) {
				//if (verifyHitTest(draggingObject)) {
					//if(stage.contains(draggingObject)){
						//colour(objClicked);
						//objClicked.mouseEnabled = true;
						//stage.removeChild(draggingObject);
					//}
				//}else {
					var destaqueEvent:DestaqueEvent = new DestaqueEvent(DestaqueEvent.APAGA, true);
					dispatchEvent(destaqueEvent);
					var addObj:AddObjCmd = new AddObjCmd(AddObjCmd.ADD, true);
					addObj.position = new Point(draggingObject.x, draggingObject.y);
					addObj.index = draggingObject.name;
					addObj.classe = getQualifiedClassName(draggingObject) + "Big";
					addObj.pai = getPai();
					dispatchEvent(addObj);
					//draggingObject.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
					if(stage.contains(draggingObject)) stage.removeChild(draggingObject);
				//}
			}else {
				var widthAba:Number = dict[currentAba].width;
				if(widthAba > widthStage){
					if (mouseMotion.speed.x != 0) {
						A = Math.abs(mouseMotion.speed.x);
						vel = mouseMotion.speed.x;
						cron.stop();
						cron.reset();
						cron.start();
						if (vel > 0) velPos = true;
						else velPos = false;
						stage.addEventListener(Event.ENTER_FRAME, continueDraggingAll);
					} else {
						var diff:Number = widthAba - widthStage;
						if (dict[currentAba].x < -Math.abs(diff)) {
							tweenX = new Tween(dict[currentAba], "x", None.easeNone, dict[currentAba].x, -diff, 0.4, true);
						}else if (dict[currentAba].x > 0) {
							tweenX = new Tween(dict[currentAba], "x", None.easeNone, dict[currentAba].x, 0, 0.4, true);
						}
					}
				}
			}
			
			posClick = null;
			draggingObject = null;
			objClicked = null;
			diffToDrag = null;
		}
		
		private function getPai():int 
		{
			return abas.indexOf(currentAba);
		}
		
		public function removeObj(obj:DisplayObject):void
		{
			var objClicked:DisplayObject = getObjectInAba(obj);
			colour(objClicked);
			//MovieClip(objClicked).mouseEnabled = true;
			//stage.removeChild(obj);
		}
		
		private var vel:Number;
		private var velPos:Boolean;
		private var cron:Cronometer = new Cronometer();
		private var tweenX:Tween;
		
		private function continueDraggingAll(e:Event):void 
		{
			var widthAba:Number = dict[currentAba].width;
			var diff:Number = widthAba - widthStage;
			
			var dt:Number = cron.read() / 1000;
			//trace("getV: " + getV(vel));
			vel += getV(vel) * dt;
			//trace("dt: " + dt);
			//trace("vel : " + vel);
			dict[currentAba].x += vel * dt;
			//trace("posX: " + dict[currentAba].x);
			//trace(vel);
			//if(dict[currentAba].x > 
			
			if (dict[currentAba].x < -diff || dict[currentAba].x > 0) {
				vel = vel / 5;
			}
			
			//if (Math.abs(Math.round(vel)) == 0) {
			if ((velPos && vel < 0) || (!velPos && vel >0)) {
				stage.removeEventListener(Event.ENTER_FRAME, continueDraggingAll);
				if (dict[currentAba].x < -diff) {
					tweenX = new Tween(dict[currentAba], "x", None.easeNone, dict[currentAba].x, -diff, 0.4, true);
				}else if (dict[currentAba].x > 0) {
					tweenX = new Tween(dict[currentAba], "x", None.easeNone, dict[currentAba].x, 0, 0.4, true);
				}
			}
			cron.reset();
		}
		
		private var A:Number = 200;
		
		private function getV(v:Number):Number 
		{
			return A * (v < 0 ? 1: -1);
		}
		
		private function verifyHitTestAbas(obj:DisplayObject):Boolean 
		{
			for each (var aba:Aba in abas) {
				if (aba.hitTestObject(obj)) return true;
			}
			
			return false;
		}
		
		public function verifyHitTest(obj:DisplayObject):Boolean
		{
			if (obj.hitTestObject(dict[currentAba]) || verifyHitTestAbas(objClicked)) return true;
			
			return false;
		}
		
		private function getAba(name:String):Aba
		{
			for each (var aba:Aba in abas) {
				if (aba.label.text == name) {
					return aba;
				}
			}
			
			return null;
		}
		
		//public function blockObj(obj:DisplayObject):void
		//{
			//
		//}
		
		private function greyscale(obj:DisplayObject){
			//var b:Number = 1 / 3;
			//var c:Number = 1 - (b * 2);
			//var matrix:Array = [c, b, b, 0, 0,
								//b, c, b, 0, 0,
								//b, b, c, 0, 0,
								//0, 0, 0, 1, 0];
			//var matrixFilter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			//obj.filters = [matrixFilter];
			MovieClip(obj).gotoAndStop(2);
			MovieClip(obj).mouseEnabled = false;
		}
		
		private function colour(obj:DisplayObject){
			//obj.filters = [];
			MovieClip(obj).gotoAndStop(1);
			MovieClip(obj).mouseEnabled = true;
		}
		
	}

}
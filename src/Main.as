package  
{
	import cepa.utils.ToolTip;
	import com.adobe.serialization.json.JSONDecoder;
	import com.adobe.serialization.json.JSONEncoder;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	
	import pipwerks.SCORM;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends Sprite
	{
		private var compSel:ComponentsSelection;
		private var navigation:Navigation;
		private var objectsOnStage:Array = [];
		private var timeLine:TimeLine;
		private var moldura:Moldura;
		private var btAval:BtAval;
		private var answerScreen:AnswerScreen;
		private var aboutScreen:AboutScreen;
		private var infoScreen:InfoScreen;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.scrollRect = new Rectangle(0, 0, 1024, 768);
			
			createComponents();
			addAbas();
			addItens();
			
			//stage.addEventListener(KeyboardEvent.KEY_UP, bindKeys);
			//stage.addEventListener(MouseEvent.MOUSE_DOWN, clickTarget);
			//setChildIndex(legendas, numChildren - 1);
			
			if(ExternalInterface.available) initLMSConnection();
		}
		
		//private function clickTarget(e:MouseEvent):void 
		//{
			//trace(e.target);
			//trace(e.currentTarget);
		//}
		
		private function bindKeys(e:KeyboardEvent):void 
		{
			//trace("code: " + e.charCode);
			switch(e.charCode) {
				//case 127: // delete
					//break;
				//case 122: //ctrl+z
					//if (e.ctrlKey) {
					//}
					//break;
				//case 109: //m
				//case 77:  //M
					//trace(timeLine.getAnswer());
					//break;
				//case 65:
				//case 97:
					//break;
				case 82: //R
				case 114://r
					timeLine.reset();
					break;
				case 83: //S
				case 115://s
					mementoSerialized = marshalObjects();
					break;
				case 87: //W
				case 119://w
					unmarshalObjects(mementoSerialized);
					break;
				//case 50: //2
				//
					//addAnswerEx2();
					//break;
				
			}
		}
		
		private function createComponents():void 
		{
			navigation = new Navigation(1000, 45, 2 * 54);
			
			navigation.x = 12;
			navigation.addEventListener(NavigationEvent.ADJUST_TIMELINE, adjustTimeline);
			
			compSel = new ComponentsSelection();
			compSel.y = 768 - 80;
			
			compSel.addEventListener(AddObjCmd.ADD, addObj);
			compSel.addEventListener(DestaqueEvent.DESTAQUE, destacaCamada);
			compSel.addEventListener(DestaqueEvent.APAGA, apagaCamadaDestaque);
			
			timeLine = new TimeLine(10786.95, 600, 2 * 54, 3);
			timeLine.y = 67;
			timeLine.addEventListener(TimeLineEvent.REMOVE, removeObj);
			timeLine.addEventListener(TimeLineEvent.BLOCK, blockSelection);
			timeLine.addEventListener(TimeLineEvent.UNBLOCK, unblockSelection);
			timeLine.addEventListener(NavigationEvent.ADJUST_NAVIGATION, adjustNavigation);
			timeLine.addEventListener(NavigationEvent.ADD_POINT, addPointToNavigation);
			timeLine.addEventListener(NavigationEvent.REMOVE_POINT, removePointFromNavigation);
			
			timeLine.legenda.momento.visible = false;
			timeLine.legenda.expoente.visible = false;
			timeLine.legenda.pensamento.visible = false;
			
			moldura = new Moldura();
			//moldura.btDownload.visible = false;
			//moldura.btDownload.addEventListener(MouseEvent.CLICK, downloadJPG);
			btAval = new BtAval();
			btAval.x = 1024 - 150;
			btAval.y = 667;
			
			answerScreen = new AnswerScreen();
			answerScreen.visible = false;
			answerScreen.closeButton.addEventListener(MouseEvent.CLICK, closeAnswerScreen);
			answerScreen.downButton.addEventListener(MouseEvent.CLICK, downloadJPG);
			
			aboutScreen = new AboutScreen();
			aboutScreen.visible = false;
			aboutScreen.closeButton.addEventListener(MouseEvent.CLICK, closeAboutScreen);
			
			infoScreen = new InfoScreen();
			infoScreen.visible = false;
			infoScreen.closeButton.addEventListener(MouseEvent.CLICK, closeInfoScreen);
			
			addChild(timeLine);
			addChild(compSel);
			addChild(navigation);
			addChild(btAval);
			addChild(moldura);
			addChild(answerScreen);
			addChild(aboutScreen);
			addChild(infoScreen);
			
			
			moldura.btAbout.addEventListener(MouseEvent.CLICK, openAbout);
			moldura.btReset.addEventListener(MouseEvent.CLICK, reset);
			moldura.infoButton.addEventListener(MouseEvent.CLICK, openInfoScreen);
			
			var ttReset:ToolTip = new ToolTip(moldura.btReset, "Reiniciar", 10, 0.8, 100, 0.6, 0.6);
			var ttCC:ToolTip = new ToolTip(moldura.btAbout, "Créditos", 10, 0.8, 100, 0.6, 0.6);
			var ttInfo:ToolTip = new ToolTip(moldura.infoButton, "Ajuda", 10, 0.8, 100, 0.6, 0.6);
			
			addChild(ttReset);
			addChild(ttCC);
			addChild(ttInfo);
			
			btAval.addEventListener(MouseEvent.CLICK, aval);
		}
		
		private function destacaCamada(e:DestaqueEvent):void 
		{
			switch(e.destaque) {
				case aba1Name:
					timeLine.legenda.momento.visible = true;
					break;
				case aba2Name:
					timeLine.legenda.expoente.visible = true;
					break;
				case aba3Name:
					timeLine.legenda.pensamento.visible = true;
					break;
			}
			
		}
		
		private function apagaCamadaDestaque(e:DestaqueEvent):void 
		{
			timeLine.legenda.momento.visible = false;
			timeLine.legenda.expoente.visible = false;
			timeLine.legenda.pensamento.visible = false;
		}
		
		private function downloadJPG(e:MouseEvent):void 
		{
			var urlRequest:URLRequest = new URLRequest("http://midia.atp.usp.br/atividades-interativas/AI-0128/images/linha_tempo.jpg");
			//navigateToURL(urlRequest, "new");
			var file:FileReference = new FileReference();
			file.download(urlRequest, "LinhaCompleta.jpg");
		}
		
		private function closeAboutScreen(e:MouseEvent):void 
		{
			aboutScreen.visible = false;
		}
		
		private function closeAnswerScreen(e:MouseEvent):void 
		{
			answerScreen.visible = false;
		}
		
		private function closeInfoScreen(e:MouseEvent):void 
		{
			infoScreen.visible = false;
		}
		
		private function openAbout(e:MouseEvent):void 
		{
			aboutScreen.visible = true;
		}
		
		private function openInfoScreen(e:MouseEvent):void 
		{
			infoScreen.visible = true;
		}
		
		private function reset(e:MouseEvent):void 
		{
			timeLine.reset();
		}
		
		private function aval(e:MouseEvent):void 
		{
			var acertos:Number = timeLine.getAnswer();
			//trace(acertos);
			if(ExternalInterface.available){
				if (!completed) {
					score = acertos;
					completed = true;
					commit();
				} else {
					saveStatus();
				}
			}
			answerScreen.acerto.text = "Você acertou " + acertos.toFixed(2).replace(".", ",") + "%";
			answerScreen.visible = true;
			//moldura.btDownload.visible = true;
		}
		
		private function addPointToNavigation(e:NavigationEvent):void 
		{
			navigation.addPoint(e.point);
			//saveStatus();
		}
		
		private function removePointFromNavigation(e:NavigationEvent):void 
		{
			navigation.removePoint(e.point);
			//saveStatus();
		}
		
		private function adjustNavigation(e:NavigationEvent):void 
		{
			navigation.adjustNavigation(e.position);
		}
		
		private function adjustTimeline(e:NavigationEvent):void 
		{
			timeLine.adjustTimeline(e.position);
		}
		
		private function blockSelection(e:TimeLineEvent):void 
		{
			compSel.allowDRag = false;
		}
		
		private function unblockSelection(e:TimeLineEvent):void 
		{
			compSel.allowDRag = true;
		}
		
		private var aba1Name:String = "MomentoHistórico";
		private var aba2Name:String = "Expoente";
		private var aba3Name:String = "Pensamento";
		
		private function addAbas():void 
		{
			compSel.addAba(aba1Name);
			compSel.addAba(aba2Name);
			compSel.addAba(aba3Name);
		}
		
		private function addItens():void 
		{
			//Itens aba1:
			compSel.addItemToAba(new Mom1(), aba1Name);
			compSel.addItemToAba(new Mom2(), aba1Name);
			compSel.addItemToAba(new Mom3(), aba1Name);
			compSel.addItemToAba(new Mom4(), aba1Name);
			compSel.addItemToAba(new Mom5(), aba1Name);
			compSel.addItemToAba(new Mom6(), aba1Name);
			compSel.addItemToAba(new Mom7(), aba1Name);
			
			//Itens aba2:
			compSel.addItemToAba(new Item0(), aba2Name);
			compSel.addItemToAba(new Item1(), aba2Name);
			compSel.addItemToAba(new Item2(), aba2Name);
			compSel.addItemToAba(new Item3(), aba2Name);
			compSel.addItemToAba(new Item4(), aba2Name);
			compSel.addItemToAba(new Item5(), aba2Name);
			compSel.addItemToAba(new Item6(), aba2Name);
			compSel.addItemToAba(new Item7(), aba2Name);
			compSel.addItemToAba(new Item8(), aba2Name);
			compSel.addItemToAba(new Item9(), aba2Name);
			compSel.addItemToAba(new Item10(), aba2Name);
			compSel.addItemToAba(new Item11(), aba2Name);
			compSel.addItemToAba(new Item12(), aba2Name);
			compSel.addItemToAba(new Item13(), aba2Name);
			compSel.addItemToAba(new Item14(), aba2Name);
			compSel.addItemToAba(new Item15(), aba2Name);
			compSel.addItemToAba(new Item16(), aba2Name);
			compSel.addItemToAba(new Item17(), aba2Name);
			
			//Itens aba3:
			compSel.addItemToAba(new Per1(), aba3Name);
			compSel.addItemToAba(new Per2(), aba3Name);
			compSel.addItemToAba(new Per3(), aba3Name);
			compSel.addItemToAba(new Per4(), aba3Name);
			compSel.addItemToAba(new Per5(), aba3Name);
			compSel.addItemToAba(new Per6(), aba3Name);
			compSel.addItemToAba(new Per7(), aba3Name);
			compSel.addItemToAba(new Per8(), aba3Name);
			compSel.addItemToAba(new Per9(), aba3Name);
			compSel.addItemToAba(new Per10(), aba3Name);
			
		}
		
		private function removeObj(e:TimeLineEvent):void 
		{
			compSel.removeObj(e.obj);
			timeLine.removeObj(e.obj);
			saveStatus();
		}
		
		private function addObj(e:AddObjCmd):void 
		{
			timeLine.addObject(e.classe, e.index, e.position, e.pai);
			saveStatus();
		}
		
		public function marshalObjects():String {
			var a:Array = new Array();
			
			var json:JSONEncoder;
			
			a[0] = timeLine.getState();
			a[1] = compSel.getState();
			//trace(a);
			
			json = new JSONEncoder(a);
			return json.getString();
		}
		
		public function unmarshalObjects(str:String):void {
			if (str == null || str == "") return;
			var a:Array;
			var json:JSONDecoder = new JSONDecoder(str, false);
			a = json.getValue();
			//trace(a);
			//var obj:Object = {
							//classe:String =,
							//nome:String = ,
							//posX:Number = ,
							//posY:Number = ,
							//indexY:int = ,
						//}
			
			for (var i:int = 0; i < a[0].length; i++) 
			{
				var obj:Object = a[0][i];
				timeLine.addObjectIndex(obj.classe, obj.nome, new Point(obj.posX, obj.posY), obj.indexY);
			}
			
			compSel.setObjectState(a[1]);
			
		}
		
		/*------------------------------------------------------------------------------------------------*/
		//SCORM:
		
		private const PING_INTERVAL:Number = 5 * 60 * 1000; // 5 minutos
		private var completed:Boolean;
		private var scorm:SCORM;
		private var scormExercise:int;
		private var connected:Boolean;
		private var score:int;
		private var pingTimer:Timer;
		private var mementoSerialized:String = "";
		
		/**
		 * @private
		 * Inicia a conexão com o LMS.
		 */
		private function initLMSConnection () : void
		{
			completed = false;
			connected = false;
			scorm = new SCORM();
			
			pingTimer = new Timer(PING_INTERVAL);
			pingTimer.addEventListener(TimerEvent.TIMER, pingLMS);
			
			connected = scorm.connect();
			
			if (connected) {
				// Verifica se a AI já foi concluída.
				var status:String = scorm.get("cmi.completion_status");	
				mementoSerialized = String(scorm.get("cmi.suspend_data"));
				var stringScore:String = scorm.get("cmi.score.raw");
			 
				switch(status)
				{
					// Primeiro acesso à AI
					case "not attempted":
					case "unknown":
					default:
						completed = false;
						break;
					
					// Continuando a AI...
					case "incomplete":
						completed = false;
						break;
					
					// A AI já foi completada.
					case "completed":
						completed = true;
						//setMessage("ATENÇÃO: esta Atividade Interativa já foi completada. Você pode refazê-la quantas vezes quiser, mas não valerá nota.");
						break;
				}
				
				unmarshalObjects(mementoSerialized);
				scormExercise = 1;
				score = Number(stringScore.replace(",", "."));
				if(completed) moldura.btDownload.visible = true;
				
				var success:Boolean = scorm.set("cmi.score.min", "0");
				if (success) success = scorm.set("cmi.score.max", "100");
				
				if (success)
				{
					scorm.save();
					pingTimer.start();
				}
				else
				{
					//trace("Falha ao enviar dados para o LMS.");
					connected = false;
				}
			}
			else
			{
				trace("Esta Atividade Interativa não está conectada a um LMS: seu aproveitamento nela NÃO será salvo.");
			}
			
			//reset();
		}
		
		/**
		 * @private
		 * Salva cmi.score.raw, cmi.location e cmi.completion_status no LMS
		 */ 
		private function commit()
		{
			if (connected)
			{
				// Salva no LMS a nota do aluno.
				var success:Boolean = scorm.set("cmi.score.raw", score.toString());

				// Notifica o LMS que esta atividade foi concluída.
				success = scorm.set("cmi.completion_status", (completed ? "completed" : "incomplete"));

				// Salva no LMS o exercício que deve ser exibido quando a AI for acessada novamente.
				success = scorm.set("cmi.location", scormExercise.toString());
				
				// Salva no LMS a string que representa a situação atual da AI para ser recuperada posteriormente.
				mementoSerialized = marshalObjects();
				success = scorm.set("cmi.suspend_data", mementoSerialized.toString());

				if (success)
				{
					scorm.save();
				}
				else
				{
					pingTimer.stop();
					//setMessage("Falha na conexão com o LMS.");
					connected = false;
				}
			}
		}
		
		/**
		 * @private
		 * Mantém a conexão com LMS ativa, atualizando a variável cmi.session_time
		 */
		private function pingLMS (event:TimerEvent)
		{
			//scorm.get("cmi.completion_status");
			commit();
		}
		
		private function saveStatus():void
		{
			if(ExternalInterface.available){
				mementoSerialized = marshalObjects();
				scorm.set("cmi.suspend_data", mementoSerialized);
			}
		}
		
	}

}
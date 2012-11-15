package com.zutalor.application 
{
	import com.zutalor.air.AirStatus;
	import com.zutalor.controllers.DialogController;
	import com.zutalor.events.AppEvent;
	import com.zutalor.loaders.URL;
	import com.zutalor.plugin.Plugins;
	import com.zutalor.ui.Dialog;
	import flash.desktop.NativeApplication;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	
	public class AbstractApplication extends Sprite
	{		
		private var _appController:AppController;
		private var _ip:String;
		
		public function start(bootXmlUrl:String, splashEmbedClassName:String=null):void
		{
			var paramObj:Object
			var url:String;
			
			parent.root.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, 
																							onUncaughtError);
			try {
				paramObj = LoaderInfo(this.root.loaderInfo).parameters;
				url = String(paramObj["url"]);
				_ip = String(paramObj["ip"]);
			} catch (e:*) { }
		
			if (url != "undefined" && url != "/" && url != null) 
				URL.open("/#/" + url.substring(1), "_self");
			else
			{
				AirStatus.initialize();
				AppRegistry.initialize();
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
				Plugins.registerClassAndCreateCachedInstance(DialogController);
				_appController = new AppController(bootXmlUrl, splashEmbedClassName);
			}
		}
		
		private function onAddedToStage(e:Event):void
		{
			
			stage.stageFocusRect = false;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			for (var i:int = 0; i < stage.numChildren; i++)
				stage.getChildAt(i).visible = false;	
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_appController.addEventListener(AppEvent.INITIALIZED, onInitialized);
			_appController.init(stage, _ip);	
		}
	
		private function onInitialized(e:Event):void
		{
			_appController.removeEventListener(AppEvent.INITIALIZED, onInitialized);
			dispatchEvent(new AppEvent(AppEvent.INITIALIZED));
		}
			
		private function onUncaughtError(e:UncaughtErrorEvent):void
		{
			e.preventDefault();
			trace("uncaught error", e.error);
			Dialog.show(Dialog.ALERT, e.error, onConfirm);
			
			function onConfirm():void
			{
				if (AirStatus.isNativeApplication)
					NativeApplication.nativeApplication.exit(); 
			}
		}
	}
}
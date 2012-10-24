package com.zutalor.propertyManagers 
{
	import com.zutalor.controllers.UIController;
	import com.zutalor.loaders.URLLoaderG;
	import com.zutalor.properties.ApplicationProperties;
	import com.zutalor.properties.BitmapGroupItemProperties;
	import com.zutalor.properties.BitmapGroupProperties;
	import com.zutalor.properties.BitmapProperties;
	import com.zutalor.properties.FiltersItemProperties;
	import com.zutalor.properties.FiltersProperties;
	import com.zutalor.properties.GraphicItemProperties;
	import com.zutalor.properties.GraphicProperties;
	import com.zutalor.properties.PlaylistItemProperties;
	import com.zutalor.properties.PlaylistProperties;
	import com.zutalor.properties.SequenceItemProperties;
	import com.zutalor.properties.SequenceProperties;
	import com.zutalor.properties.TranslateItemProperties;
	import com.zutalor.properties.TranslateProperties;
	import com.zutalor.properties.ViewItemProperties;
	import com.zutalor.properties.ViewProperties;
	import com.zutalor.text.StyleSheetUtils;
	import com.zutalor.text.TextUtil;
	import com.zutalor.utils.Path;
	import com.zutalor.utils.StringUtils;
	import flash.events.Event;
	import flash.events.IOErrorEvent;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Props
	{
		public static var ap:ApplicationProperties;
		public static var pr:Presets;
		
		public static var sequences:NestedPropsManager;
		public static var playlists:NestedPropsManager;
		public static var views:NestedPropsManager;
		public static var graphics:NestedPropsManager;
		public static var filters:NestedPropsManager;
		public static var translations:NestedPropsManager;
		public static var bitmaps:PropertyManager;
		public static var bitmapGroups:NestedPropsManager;
		
		public static var uiController:UIController;		
		
		private static var _xmlFiles:int;
		private static var _xmlFilesProcessed:int;
		private static var _loaders:Array;
		private static var _onComplete:Function;
		private static var _initialized:Boolean;
		
		public static function init(bootXmlUrl:String, onComplete:Function):void
		{
			if (_initialized)
			{
				if (onComplete != null)
					onComplete();
				return;
			}
			
			_onComplete = onComplete;
			_loaders = [];		
			pr = Presets.gi();	
			ap = ApplicationProperties.gi();
			sequences = new NestedPropsManager();
			views = new NestedPropsManager();
			filters = new NestedPropsManager();
			graphics = new NestedPropsManager();
			playlists = new NestedPropsManager();
			translations = new NestedPropsManager();
			bitmaps = new PropertyManager(BitmapProperties);
			bitmapGroups = new NestedPropsManager();
			loadBootXml(bootXmlUrl);
		}
		private static function loadBootXml(url:String):void
		{
			var loaderG:URLLoaderG = new URLLoaderG();
			loaderG.addEventListener(Event.COMPLETE, onBootLoaded, false, 0, true);
			loaderG.load(url);
		}
		
		private static function onBootLoaded(e:Event):void
		{
			var xml:XML = XML(e.target.data);
			ap.parseXML(xml.appSettings);
			parseProps(xml); // in case other settings are included, afterall, the whole xml package could be inside of boot xml rather than separate files.
			e.target.dispose();
			loadXml();
		}
		
		private static function loadXml():void
		{
			var urls:Array = [];
			var path:String;
			
			if (ap.systemXmlUrls)
			{
				urls = ap.systemXmlUrls.split(",");
				path = Path.getPath("systemXml")
				addPath(path, urls);
			}	
			
			if (ap.appXmlUrls)
			{
				path = Path.getPath("appXml");
				urls = urls.concat(addPath(path, ap.appXmlUrls.split(",")));
			}
			_xmlFiles = urls.length;
			_xmlFilesProcessed = 0;
			
			for (var i:int = 0; i < _xmlFiles; i++)
			{
				_loaders[i] = new URLLoaderG();
				_loaders[i].addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
				_loaders[i].load(urls[i]);
			}
			
			function addPath(path:String, a:Array):Array
			{
				for (var i:int = 0; i < a.length; i++)
					a[i] = path + StringUtils.stripLeadingSpaces(a[i]);
				
				return a;	
			}
		}
		
		private static function onLoadComplete(e:Event):void
		{
			_xmlFilesProcessed++;
			parseProps(XML(e.target.data));
			
			if (_xmlFilesProcessed == _xmlFiles)
			{
				for (var i:int = 0; i < _xmlFiles; i++)
				{
					_loaders[i].removeEventListener(Event.COMPLETE, onLoadComplete);
					_loaders[i].dispose();
					_loaders[i] = null;
				}
				 _loaders = null;

				StyleSheetUtils.loadCss(onCssLoaded);			
				function onCssLoaded():void
				{
					_onComplete();
				}
			}
		}
		
		private static function parseProps(xml:XML):void
		{	
			sequences.parseXML(SequenceProperties, SequenceItemProperties, xml.sequences, "sequence", xml.sequence, "props");
			views.parseXML(ViewProperties, ViewItemProperties, xml.views, "view", xml.view, "props");
			playlists.parseXML(PlaylistProperties, PlaylistItemProperties, xml.playlists, "playlist", xml.playlist, "props");						
			pr.parseXML(xml);		
			translations.parseXML(TranslateProperties, TranslateItemProperties, xml.translations, "language", xml.language,"props");
			graphics.parseXML(GraphicProperties, GraphicItemProperties, xml.graphics, "graphic", xml.graphic, "props");
			filters.parseXML(FiltersProperties, FiltersItemProperties, xml.filters, "filter", xml.filter, "props");
			bitmaps.parseXML(xml.bitmaps, "props");
			bitmapGroups.parseXML(BitmapGroupProperties, BitmapGroupItemProperties, xml.bitmapGroups, "bitmapGroup", xml.bitmapGroup, "props"); 
		}
	}
}
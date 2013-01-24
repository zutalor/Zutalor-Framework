package com.zutalor.view.navigator 
{
	import com.zutalor.translate.TranslateItemProperties;
	import com.zutalor.utils.gDictionary;
	/**
	 * ...
	 * @author Geoff
	 */
	public class NavigatorProperties 
	{
		public var id:String;
		public var tip:TranslateItemProperties;
		public var curAnswerKey:String;
		public var history:Array;
		public var answers:gDictionary;
		public var data:String;
		public var transitionNext:String;
		public var transitionBack:String;
		public var curTransitionType:String;
		public var promptState:String;
		public var promptStateTip:TranslateItemProperties;
		public var soundPath:String;
		public var soundExt:String;
		public var keyboardAnswers:String;
		public var inTransition:Boolean;
		
		public function NavigatorProperties() { }
	}
}
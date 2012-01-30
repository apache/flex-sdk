////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.automation.delegates.components
{
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationObjectHelper;
	import mx.core.mx_internal;
	
	import spark.automation.delegates.components.supportClasses.SparkSkinnableComponentAutomationImpl;
	import spark.components.VideoPlayer;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  VideoPlayer control.
	 * 
	 *  @see spark.components.VideoPlayer 
	 *
	 */
	public class SparkVideoPlayerAutomationImpl extends SparkSkinnableComponentAutomationImpl
	{
		
		include "../../../core/Version.as";
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Registers the delegate class for a component class with automation manager.
		 *  
		 *  @param root The SystemManger of the application.
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(spark.components.VideoPlayer, SparkVideoPlayerAutomationImpl);
		}   
		
		/**
		 *  Constructor.
		 * @param obj VideoPlayer object to be automated.     
		 */
		public function SparkVideoPlayerAutomationImpl(obj:spark.components.VideoPlayer)
		{
			super(obj);
			
		}
		
		/**
		 *  @private
		 */
		protected function get sparkVideoPlayer():spark.components.VideoPlayer
		{
			return uiComponent as spark.components.VideoPlayer;   
		}
		
		
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ESCAPE)
				recordAutomatableEvent(event);
		}
		
		
		override public function get numAutomationChildren():int
		{ 
			
			var objArray:Array = getAutomationChildren();
			return (objArray?objArray.length:0);
		}
		
		
		override public function getAutomationChildAt(index:int):IAutomationObject
		{
			var arr:Array = getAutomationChildren();
			if (arr && (arr.length < index))
				arr[index];
			
			return null;
		}
		
		
		override public function getAutomationChildren():Array
		{
			
			var chilArray:Array = new Array();
			if(sparkVideoPlayer.currentTimeDisplay)
				chilArray.push(sparkVideoPlayer.currentTimeDisplay);
			
			if(sparkVideoPlayer.fullScreenButton)
				chilArray.push(sparkVideoPlayer.fullScreenButton);
			
			if(sparkVideoPlayer.muteButton)
				chilArray.push(sparkVideoPlayer.muteButton);
			
			if(sparkVideoPlayer.pauseButton)
				chilArray.push(sparkVideoPlayer.pauseButton);
			
			if(sparkVideoPlayer.playButton)
				chilArray.push(sparkVideoPlayer.playButton);
			
			
			if(sparkVideoPlayer.playPauseButton)
				chilArray.push(sparkVideoPlayer.playPauseButton);
			
			if(sparkVideoPlayer.scrubBar)
				chilArray.push(sparkVideoPlayer.scrubBar);
			
			if(sparkVideoPlayer.stopButton)
				chilArray.push(sparkVideoPlayer.stopButton);
			
			if(sparkVideoPlayer.durationDisplay)
				chilArray.push(sparkVideoPlayer.durationDisplay);
			
			
			if(sparkVideoPlayer.volumeBar)
				chilArray.push(sparkVideoPlayer.volumeBar);
			
			return chilArray;
		}
		
		
		
		override public function createAutomationIDPart(child:IAutomationObject):Object
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return help.helpCreateIDPart(uiAutomationObject, child);
		}
		
		
		override public function resolveAutomationIDPart(part:Object):Array
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return help.helpResolveIDPart(uiAutomationObject, part);
		}
		
		
		override public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return help.helpCreateIDPartWithRequiredProperties(uiAutomationObject, child,properties);
			
		}
		
		
		
	}
	
}
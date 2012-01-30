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

package mx.automation.delegates.controls
{
	import flash.display.DisplayObject;
	
	import mx.automation.Automation; 
	import mx.automation.delegates.core.UIComponentAutomationImpl;
	import mx.controls.VideoDisplay
		
		[Mixin]
		/**
		 * 
		 *  Defines methods and properties required to perform instrumentation for the 
		 *  VideoDisplay control.
		 * 
		 *  @see mx.controls.VideoDisplay 
		 *
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public class VideoDisplayAutomationImpl extends UIComponentAutomationImpl
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
			 *  
			 *  @langversion 3.0
			 *  @playerversion Flash 9
			 *  @playerversion AIR 1.1
			 *  @productversion Flex 3
			 */
			public static function init(root:DisplayObject):void
			{
				Automation.registerDelegateClass(VideoDisplay, VideoDisplayAutomationImpl);
			}   
			
			//--------------------------------------------------------------------------
			//
			//  Constructor
			//
			//--------------------------------------------------------------------------
			
			/**
			 *  Constructor.
			 * @param obj VideoDisplay object to be automated.     
			 *  
			 *  @langversion 3.0
			 *  @playerversion Flash 9
			 *  @playerversion AIR 1.1
			 *  @productversion Flex 3
			 */
			public function VideoDisplayAutomationImpl(obj:VideoDisplay)
			{
				super(obj);
				
				recordClick = true;
			}
			
		}
		
}
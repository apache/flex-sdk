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
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.ui.Keyboard;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationObjectHelper;
	import mx.automation.events.AutomationRecordEvent;
	import mx.automation.events.TextSelectionEvent;
	import mx.core.EventPriority;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	
	import spark.automation.events.SparkValueChangeAutomationEvent;
	import spark.components.NumericStepper;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  NumericStepper control.
	 * 
	 *  @see spark.components.NumericStepper 
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	public class SparkNumericStepperAutomationImpl extends SparkSpinnerAutomationImpl 
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
		 *  @productversion Flex 4
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(spark.components.NumericStepper, SparkNumericStepperAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * @param obj NumericStepper object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function SparkNumericStepperAutomationImpl(obj:spark.components.NumericStepper)
		{
			super(obj);
			obj.addEventListener(MouseEvent.CLICK, mouseClickHandler,false,0,true);
			
		}
		
		
		/**
		 *  @private
		 *  
		 */
		private function mouseClickHandler(event:MouseEvent):void
		{
			// we dont want to record click on the numeric stepper
			;
		}
		/**
		 *  @private
		 *  
		 */
		protected function get ns():spark.components.NumericStepper
		{
			return uiComponent as spark.components.NumericStepper;   
		}
		
		//----------------------------------
		//  automationValue
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get automationValue():Array
		{
			//return [ ns.value.toString() ];
			return super.automationValue;
			
		}
		
		/**
		 *  @private
		 */
		override public function replayAutomatableEvent(event:Event):Boolean
		{
			
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			// we have tried to do this in the numeric stepper instead of the spinner
			//http://bugs.adobe.com/jira/browse/FLEXENT-1072
			// it was observed that if the previous operation was a string maninpulation
			// on the textField of the numeric stepper, the changes made to the string
			// is not reflected even to the RichEditableText's text property. so setting 
			// a value to the numeric stepper using the new string never happens. Hence
			// before the next change event replay, instead of using the value of the numeric stepper
			// we need to use the text value to compare the current vs new value.
			if (event is SparkValueChangeAutomationEvent)
			{
				var nsEvent:SparkValueChangeAutomationEvent = SparkValueChangeAutomationEvent(event);
				// here we need a Button Down event to be replayed, as the mouse down does not trigger
				// button down. However we are still replaying the mouse events also to make the
				//  handlers for those events to happen.
				var buttonDownEvent:FlexEvent = new FlexEvent(FlexEvent.BUTTON_DOWN);
				
				var number:Number = Number(ns.textDisplay.textDisplay.text);
				if(nsEvent.value > number)
				{
					nSpinner.incrementButton.dispatchEvent(buttonDownEvent);
					help.replayClick(nSpinner.incrementButton);
				}
				else if(nsEvent.value < number)
				{
					nSpinner.decrementButton.dispatchEvent(buttonDownEvent);
					help.replayClick(nSpinner.decrementButton);
				}
				else if(ns.value !=  number)
					ns.value = number;
				// no event if the value was the same as before
			}
			else if (event is KeyboardEvent)
			{
				
				if ((event as KeyboardEvent).keyCode == Keyboard.HOME ||
					(event as KeyboardEvent).keyCode == Keyboard.END ||
					(event as KeyboardEvent).keyCode == Keyboard.UP ||
					(event as KeyboardEvent).keyCode == Keyboard.DOWN)
				{
					help.replayKeyboardEvent(ns.textDisplay,
						KeyboardEvent(event));
				}
				else
					ns.textDisplay.replayAutomatableEvent(event);
				
				// we observed that after the key replay the stepper value was not
				// getiing reset.so let us set the value if the string is not empty
				// when empty,we setting this will cause string to have value '0' which is not
				// exptected.
				if(ns.textDisplay.text.length)
					ns.value = Number(ns.textDisplay.text);
			}
			else if (event is TextEvent || event is TextSelectionEvent)
			{
				
				(ns.textDisplay as IAutomationObject).replayAutomatableEvent(event);
				ns.textDisplay.invalidateProperties();
				ns.textDisplay.validateNow();
				
				
				// it was observerd that after the complete element delete or back space
				// the chars were not getting replayed on numeric stepper as it was expected.
				// only the next operation on the numeric stepper
				// tries to get the value of the text filed, so here we try to do that
				// by adding the following hack
				if(event is TextEvent)
				{
					ns.textDisplay.insertText("");
				}
				
				
				// we saw that the ns value was not getting refreshed after the text changes
				// so till the issue is resolved, we are resetting the value to the stepper.
				ns.value = Number(ns.textDisplay.text);
			}
			else
			{
				return super.replayAutomatableEvent(event);
			}
			
			return true;
		}
		
		/**
		 *  Method which gets called after the component has been initialized. 
		 *  This can be used to access any sub-components and act on the component.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		override protected function componentInitialized():void
		{
			super.componentInitialized();
			
			
			ns.textDisplay.addEventListener(KeyboardEvent.KEY_DOWN, 
				inputField_keyDownHandler, false, EventPriority.DEFAULT+1, true); 
			
			// let us listen to the text record event coming from the textInput.
			// refer the even dispatch in the textBaseAutomationImpl during replay
			ns.textDisplay.addEventListener(AutomationRecordEvent.RECORD,
				inputField_recordHandler1, false, 0, true);
			
			
		}
		
		private function inputField_keyDownHandler(event:KeyboardEvent):void
		{
			
			if (event.keyCode == Keyboard.HOME ||
				event.keyCode == Keyboard.END ||
				event.keyCode == Keyboard.UP ||
				event.keyCode == Keyboard.DOWN)
			{
				recordAutomatableEvent(event);
			}
			// this variable is used in the spinner delegate to differentiate whehter the current event happend
			// by keydown or not.
			// so after recording the current event, we need to set this to false
			// so that only the changes corresponds to mouse interaction will be captured by the
			// change event.
			keyDownHappened = false;
		}
		
		
		
		private function inputField_recordHandler1(event1:AutomationRecordEvent):void
		{
			// We get this handler for events from ns.textDisplay.textDisplay also.
			// i.e., for the same user interaction, ns.textDisplay (which is the TextInput
			// of NumericStepper) and ns.textDisplay.textDisplay (which is the RichEditableText of
			// NumericStepper's TextInput) will try to record the details. We need to handle the one
			// from TextInput
			if(event1.automationObject == ns.textDisplay)
			{// the text event coming from the textInput, let us handle it
				// and record as our own events.
				
				// enter key is recorded by the base class.
				// prevent its recording
				var re:Object = event1.replayableEvent;
				if (re is KeyboardEvent && re.keyCode == Keyboard.ENTER)
					return;
				recordAutomatableEvent(event1.replayableEvent);
				
				// this variable is used in the spinner delegate to differentiate whehter the current event happend
				// by keydown or not.
				// so after recording the current event, we need to set this to false
				// so that only the changes corresponds to mouse interaction will be captured by the
				// change event.
				keyDownHappened = false;
			}
		}
		
	}
}
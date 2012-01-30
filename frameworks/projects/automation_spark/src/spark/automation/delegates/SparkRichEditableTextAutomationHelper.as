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

package spark.automation.delegates
{
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.ui.Keyboard;
	
	import flashx.textLayout.operations.CutOperation;
	import flashx.textLayout.operations.PasteOperation;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationObjectHelper;
	import mx.automation.events.AutomationEvent;
	import mx.automation.events.TextSelectionEvent;
	import mx.core.EventPriority;
	import mx.core.mx_internal;
	import mx.events.SandboxMouseEvent;
	import mx.managers.IFocusManager;
	import mx.managers.IFocusManagerComponent;
	import mx.managers.IFocusManagerContainer;
	import mx.managers.ISystemManager;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import spark.components.RichEditableText;
	import spark.events.TextOperationEvent;
	
	use namespace mx_internal;
	
	[ResourceBundle("automation")]
	
	/** 
	 * Utility class that facilitates replay of text input and selection.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	public class SparkRichEditableTextAutomationHelper 
	{
		include "../../core/Version.as";
		
		//--------------------------------------------------------------------------
		//
		//  Constructors
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 *  
		 * @param owner The UIComponent that is using the TextField. For example, if a 
		 * TextArea is using the TextField, then the TextArea is the owner.
		 *  
		 * @param replayer The IAutomationObject of the component.
		 *  
		 * @param richEditableText The TextField object inside the component.
		 *  
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function SparkRichEditableTextAutomationHelper(owner:IEventDispatcher,
															  replayer:IAutomationObject,
															  richEditableText:spark.components.RichEditableText)
		{
			super();
			
			// for spark, we will be called by the RicheEditableText only.
			// we could have moved this code to the delegate itself
			// to have the similar work flow for the halo, we kept the helper class
			
			// storing the passed variable.
			this.owner = owner;
			this.replayer = replayer;
			this.richEditableText = richEditableText;
			
			// adding the focus in handler so that we can add the appropriate 
			// listeneres.
			this.owner.addEventListener(FocusEvent.FOCUS_IN, 
				focusInHandler, 
				false, 
				EventPriority.DEFAULT-100, true);
			this.richEditableText.addEventListener(MouseEvent.MOUSE_DOWN, 
				mouseDownHandler, false, EventPriority.DEFAULT, true);
			
			// capture the slection
			captureSelection();
			oldSelection = currentSelection;
			hasSelectionChanged = false;
			
			// capture the focus details
			if(recording)
				checkInitialFocus();
			else
				Automation.automationManager.addEventListener(AutomationEvent.BEGIN_RECORD, 
					beginRecordingHandler, false, 0 , true);
			
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */ 
		private var stringBuffer:String;
		
		/**
		 *  @private
		 */ 
		private var owner:IEventDispatcher;
		
		/**
		 *  @private
		 */ 
		private var replayer:IAutomationObject;
		
		/**
		 *  @private
		 */ 
		private var richEditableText:spark.components.RichEditableText;
		
		/**
		 *  @private
		 */ 
		private var currentSelection:Array = null;
		
		/**
		 * @private
		 */
		private var oldSelection:Array = null;
		
		/**
		 *  @private
		 */ 
		private var hasSelectionChanged:Boolean = false;
		
		/**
		 *  @private
		 */ 
		private var isWatchingFocus:Boolean = false;
		
		/**
		 *  @private
		 */ 
		private var isInInsertMode:Boolean = false;
		
		/**
		 *  @private
		 *  Used for accessing localized Error messages.
		 */
		private var resourceManager:IResourceManager =
			ResourceManager.getInstance();
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  recording
		//----------------------------------
		
		/**
		 *  @private
		 */ 
		private function get recording():Boolean
		{
			return Automation.automationManager &&
				(Automation.automationManager as IAutomationManager).recording;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */ 
		private function flushCharacterBuffer():void
		{
			// this methods is called whenever the focus on the text is changed
			// so if the text value is changed, the change will be recorded here.
			// unlike other normal classes, we are not recording the changes as
			// and when the change happens.
			// reason is that we want one record for the multiple inputs, instead 
			// of recording for each input.
			if (stringBuffer != null)
			{
				flushSelection();
				var e:TextEvent = new TextEvent(TextEvent.TEXT_INPUT);
				if(stringBuffer)
					e.text = stringBuffer.toString();
				else
					e.text="";
				stringBuffer = null;
				recordAutomatableEvent(e);
			}
		}
		
		/**
		 *  @private
		 */ 
		private function captureSelection():void
		{
			// capture the selectio details and when the focus changes
			// if the selection details are changed, it will be recorded.
			currentSelection = [ richEditableText.selectionAnchorPosition, richEditableText.selectionActivePosition ];
			hasSelectionChanged =  oldSelection == null || oldSelection[0] != currentSelection[0] || oldSelection[1] != currentSelection[1];
			
		}
		
		/**
		 *  @private
		 */ 
		private function flushSelection():void
		{
			// when the focus 
			if (!hasSelectionChanged)
				return;
			
			// recording the details of the selection change.
			if (currentSelection && currentSelection[0] >= 0 && currentSelection[1] >= 0)
			{
				var e:TextSelectionEvent = new TextSelectionEvent();
				e.beginIndex = currentSelection[0];
				e.endIndex = currentSelection[1];
				oldSelection = currentSelection;
				currentSelection = null;
				recordAutomatableEvent(e);
				
			}
		}
		
		/**
		 *  @private
		 */ 
		private function get hasSelection():Boolean
		{
			// checking whether a content is selected.
			return (richEditableText.selectionActivePosition != richEditableText.selectionAnchorPosition);
		}
		
		/**
		 *  @private
		 */
		protected function checkInitialFocus():void
		{
			//check whether we have already focus so that we can prepare for user input
			var o:DisplayObject = DisplayObject(richEditableText) ;
			
			while (o)
			{
				if (o is IFocusManagerContainer)
					break ; 
				
				o = o.parent;
			}
			
			if (o)
			{
				var focusManager:IFocusManager = IFocusManagerContainer(o).focusManager;        
				var focusObj:DisplayObject = focusManager ?
					DisplayObject(focusManager.getFocus()) :
					null;
				if (focusObj == owner)
					focusInHandler(null);
			}
		}
		
		/**
		 *  Records the user interaction with the text control.
		 *  
		 *  @param interaction The event to record.
		 * 
		 *  @param cacheable Contains <code>true</code> if this is a cacheable event, and <code>false</code> if not.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */ 
		public function recordAutomatableEvent(interaction:Event, 
											   cacheable:Boolean = false):void
		{
			var am:IAutomationManager = Automation.automationManager;
			am.recordAutomatableEvent(replayer, interaction, cacheable); 
		}
		
		/**
		 *  Replays TextEvens, Selection Event, and type events. TypeEvents  and Text events are replayed
		 *  depending on the character typed.  Both  dispatches the origin keystrokes.
		 *  This is necessary to mimic the original behavior, in case any components are
		 *  listening to keystroke events (for example, DataGrid listens to itemRenderer events,
		 *  or if a custom component is trying to do key masking).  In Halo, the text events were changing
		 *  the contents using the text related methods as the flash player was ignoring the key evens.
		 *  In Gumbo this is not the case, so for the text and type events, we need only to send the key strokes.
		 *  dispatch the original keystrokes, but the Flash Player richEditableText ignores
		 *  the events we are sending it.
		 *
		 * @param event Event to replay.
		 * 
		 * @return If true, replay the event.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function replayAutomatableEvent(event:Event):Boolean
		{
			var changeEvent:TextOperationEvent = new TextOperationEvent(TextOperationEvent.CHANGE);
			
			var sm:ISystemManager = Automation.getMainApplication().systemManager;
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			
			var ke:KeyboardEvent;
			
			if (event is MouseEvent &&
				event.type == MouseEvent.CLICK)
				return help.replayClick(owner, event as MouseEvent);
			else if (event is TextSelectionEvent)
			{
				
				// we should reply click, as click is not recorded during selection.
				// so if anybody listening to the click event, they should get it.
				help.replayClick(owner);
				
				if(owner as  IFocusManagerComponent)
					IFocusManagerComponent(owner).setFocus();
				else
					richEditableText.setFocus();
				
				// selection replay is done by calling the underlying select method.
				// recorded value is anchorPosition and active position in order.
				// Since we have used the existing TextSelection
				var selectionEvent:TextSelectionEvent = 
					TextSelectionEvent(event);
				richEditableText.selectRange(selectionEvent.beginIndex, 
					selectionEvent.endIndex);
				
				
				return true;
			}
			else if (event is TextEvent)
			{
				
				// need to set focus in order for the uirichEditableText to behave correctly
				if(owner as  IFocusManagerComponent)
					IFocusManagerComponent(owner).setFocus();
				else
					richEditableText.setFocus();
				
				var textEvent:TextEvent = TextEvent(event);
				var text:String = textEvent.text;
				var n:int = textEvent.text.length;
				if(n == 0)
				{
					// if there is any selection we want
					// to clear it, as this recording would have
					// been resulted from cut operation. 
					richEditableText.insertText("");
				}
				
				// it was seen that at times event dispathing does not change
				// the string and at times it changes.
				// refer http://bugs.adobe.com/jira/browse/FLEXENT-1179
				// We need to insert the text if the change has not happened.
				// for this we need to find the string before and after the event dispatch.
				// but the text does not display the correct value after the event dispatch. It shows
				// only after we do an insert operation on the text after the same.
				// but to do the inser operation, we need to find the active and anchor position also.
				// this also does not change when the value is dispatched and still is at the beginning of the string.
				// so we need to calcualte it. Here we need to consider the direction.
				var stringBeforeChange:String = richEditableText.text;
				var insertPos:int = richEditableText.selectionActivePosition;
				var activePos:int = insertPos;
				var anchorPos:int = richEditableText.selectionAnchorPosition;
				var direction:int = -1;
				if(richEditableText && richEditableText.textFlow && richEditableText.textFlow.computedFormat &&
					richEditableText.textFlow.computedFormat.direction)
				{
					if (richEditableText.textFlow.computedFormat.direction=="ltr")
						direction = 1;
				}
				richEditableText.selectRange(anchorPos, activePos);
				for (var i:uint = 0; i < n; i++)
				{
					ke = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
					ke.charCode = text.charCodeAt(i);
					ke.keyCode = text.charCodeAt(i);
					richEditableText.dispatchEvent(ke);
					
					// we dont need any special handling on the string.
					// replaying the key board events takes care of the needed.
					// however when there is a line feed or carriage return , we need to handle it specially
					if((text.charAt(i) == "\n") || (text.charAt(i) == "\r"))
						richEditableText.insertText(text.charAt(i));
					
					var te:TextEvent = new TextEvent(TextEvent.TEXT_INPUT);
					te.text = String(text.charAt(i)); 
					// ref. http://bugs.adobe.com/jira/browse/FLEXENT-838 - charcode vs charAt
					richEditableText.dispatchEvent(te);
					// we dont need to select as the previous selection would have taken care of the 
					// requried selection
					
					ke = new KeyboardEvent(KeyboardEvent.KEY_UP);
					ke.charCode = text.charCodeAt(i);
					ke.keyCode = text.charCodeAt(i);
					richEditableText.dispatchEvent(ke);
					
					// dispatch a change event to indicate that the value is changed.
					richEditableText.dispatchEvent(changeEvent);
					// calculate the new insert position.
					insertPos += direction*1;
				
				}
				
				if(text.length > 0)
				{
					// do the operation to reflect the text value
					richEditableText.selectRange(insertPos,insertPos);
					richEditableText.insertText("");
					
					// check whethr the string is changed after the event dispatch
					// refer http://bugs.adobe.com/jira/browse/FLEXENT-1179
					var stringAfterChange:String = richEditableText.text;
					
					if(stringBeforeChange == stringAfterChange)
					{
						richEditableText.insertText(text);
					}
				}
				
				
				return true;
			}
			else if (event is KeyboardEvent)
			{
				var kbEvent:KeyboardEvent = KeyboardEvent(event);
				var keyCode:int = kbEvent.keyCode;
				switch (keyCode)
				{
					case Keyboard.HOME:
					{
						break;
					}
					case Keyboard.END:
					{
						break;
					}
						
					case Keyboard.ENTER:
					{
						// replaying the keyboard events will do the needful
						// we dont need to handle this.
						// replace the selected text with newline
						//if (richEditableText.multiline)
						//	richEditableText.insertText("\n");
						
						break;
					}
						
					case Keyboard.BACKSPACE:
					{
						// we dont need a manual handling here.
						// replaying the key up and down will do the needfule
						break;
					}
						
					case Keyboard.DELETE:
					{
						// we dont need a manual handling here.
						// replaying the key up and down will do the needfule
						break;
					}
						
					case Keyboard.INSERT:
					{
						isInInsertMode = !isInInsertMode;
						break;
					}
					case Keyboard.ESCAPE:
					{
						break;
					}
						
					default:
					{
						var message:String = resourceManager.getString(
							"automation", "notReplayable", [keyCode]);
						throw new Error(message);
					}
				}
				
				ke = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
				ke.charCode = keyCode;
				ke.keyCode = keyCode;
				ke.ctrlKey = kbEvent.ctrlKey;
				ke.shiftKey = kbEvent.shiftKey;
				ke.altKey = kbEvent.altKey;
				
				richEditableText.dispatchEvent(ke);
				
				ke = new KeyboardEvent(KeyboardEvent.KEY_UP);
				ke.charCode = keyCode;
				ke.keyCode = keyCode;
				ke.ctrlKey = kbEvent.ctrlKey;
				ke.shiftKey = kbEvent.shiftKey;
				ke.altKey = kbEvent.altKey;
				
				richEditableText.dispatchEvent(ke);
				
				richEditableText.dispatchEvent(changeEvent);
				return true;
			}
			return false;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function focusInHandler(event:FocusEvent):void
		{
			if (!recording)
				return;
			
			if (!isWatchingFocus)
			{
				isWatchingFocus = true;
				
				//Add the focus change listeners as low priority
				//so that any code that may prevent default (prevent
				//the focus change) gets a chance to execute before
				//getting to us.  We only want to process the event
				//if the focus really is going to change.
				richEditableText.addEventListener(FocusEvent.KEY_FOCUS_CHANGE,
					focusOutHandler,
					false,
					EventPriority.DEFAULT-1000, true);
				//Use FOCUS_OUT instead of MOUSE_FOCUS_CHANGE never
				//really gets fired because the player doesn't initiate
				//mouse focus changes (except when a text field gets
				//focus).  Our mouseDownOutside handler should take
				//care of flushing events before a new item gets focus
				//and we may not even need this event handler
				richEditableText.addEventListener(FocusEvent.FOCUS_OUT,
					focusOutHandler,
					false, EventPriority.DEFAULT, true);
				
				//In case someone clicks elsewhere but we don't loose the focus
				//we need to flush, i.e. they click a button that generates a click
				//we need to beat them and record our events first
				//var sm:ISystemManager = Application.application.systemManager;
				var sm:ISystemManager =  Automation.getMainApplication().systemManager;
				sm.getSandboxRoot().addEventListener(MouseEvent.MOUSE_DOWN,
					mouseDownOutsideHandler,
					true, EventPriority.DEFAULT, true);
				sm.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE,
					mouseDownOutsideHandler,
					true, EventPriority.DEFAULT, true);
				
				
				
				sm.addEventListener(Event.DEACTIVATE,
					stageEventHandler,
					false,
					EventPriority.DEFAULT+1, true);
				sm.getSandboxRoot().addEventListener(Event.MOUSE_LEAVE,
					stageEventHandler,
					false,
					EventPriority.DEFAULT+1, true);
				
				sm.getSandboxRoot().addEventListener(MouseEvent.MOUSE_DOWN,
					stageEventHandler,
					true,
					EventPriority.DEFAULT+1, true);
				
				sm.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE,
					stageEventHandler,
					true,
					EventPriority.DEFAULT+1, true);
				
				richEditableText.addEventListener(TextEvent.TEXT_INPUT, 
					textInputHandler, 
					false, 
					EventPriority.DEFAULT+100, true);
				
				richEditableText.addEventListener(TextOperationEvent.CHANGING, 
					changingTimeDataCapturer, 
					false, 
					EventPriority.DEFAULT+50, true);
				
				richEditableText.addEventListener(TextOperationEvent.CHANGE, 
					changeHandler, 
					false, 
					EventPriority.DEFAULT+50, true);
				richEditableText.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, false, EventPriority.DEFAULT, true);
				richEditableText.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false, EventPriority.DEFAULT, true);
				//need to cache selection so it is not recorded unless it changes
				captureSelection();
				oldSelection = currentSelection;
				hasSelectionChanged = false;
			}
		}
		
		/**
		 *  @private
		 */
		private function stageEventHandler(event:Event):void
		{
			//Don't call focusOutHandler, that would remove our event listeners
			//which would be bad because a deactive and mouse leave doesn't mean
			//the framework thinks we lost focus, framework should call focus out
			//if it does intend to remove focus during a deactive
			flushSelection();
			flushCharacterBuffer();
		}
		
		
		/**
		 *  @private
		 */
		private function mouseDownOutsideHandler(event:Event):void
		{
			if (event.target != richEditableText)
			{
				//Don't call focusOutHandler, that would remove our event listeners
				//which would be bad because it's possible for someone to click outside 
				//of the richEditableText but not have the focus change.  Just flush the 
				//event buffers in case that mouse down outside causes an event to be recorded
				flushSelection();
				flushCharacterBuffer();
			}
		}
		
		/**
		 *  @private
		 */
		private function focusOutHandler(event:Event):void
		{
			if (isWatchingFocus && !event.isDefaultPrevented())
			{
				isWatchingFocus = false;
				
				if (richEditableText)
				{
					richEditableText.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE,
						focusOutHandler,
						false);
					richEditableText.removeEventListener(FocusEvent.FOCUS_OUT,
						focusOutHandler,
						false);
				}
				var sm:ISystemManager = Automation.getMainApplication().systemManager;
				sm.removeEventListener(MouseEvent.MOUSE_DOWN,
					mouseDownOutsideHandler,
					true);
				sm.removeEventListener(Event.DEACTIVATE,
					stageEventHandler,
					false);
				sm.getSandboxRoot().removeEventListener(Event.MOUSE_LEAVE,
					stageEventHandler,
					false);
				sm.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_DOWN,
					stageEventHandler,
					true);
				
				sm.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE,
					stageEventHandler,
					true);
				richEditableText.removeEventListener(TextOperationEvent.CHANGE,changeHandler);
				richEditableText.removeEventListener(TextOperationEvent.CHANGING,changingTimeDataCapturer );
				richEditableText.removeEventListener(TextEvent.TEXT_INPUT, textInputHandler);
				richEditableText.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
				richEditableText.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
				
				flushSelection();
				flushCharacterBuffer();
				
			}
		}
		
		/**
		 *  @private
		 */
		private function mouseDownHandler(event:MouseEvent):void
		{
			if (!recording)
				return;
			
			richEditableText.systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, 
				mouseUpHandler, false, EventPriority.DEFAULT, true);
			richEditableText.systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, 
				mouseUpHandler, false, EventPriority.DEFAULT, true);
			richEditableText.addEventListener(MouseEvent.DOUBLE_CLICK,
				mouseDoubleClickHandler, false, EventPriority.DEFAULT-1, true);
			
		}
		
		/**
		 *  @private
		 */
		private function mouseClickHandler(event:MouseEvent):void
		{
			if (!recording)
				return;
			richEditableText.removeEventListener(MouseEvent.CLICK, 
				mouseClickHandler);
			
			recordAutomatableEvent(event);
		}
		
		private function mouseDoubleClickHandler(event:MouseEvent):void
		{
			if (!recording)
				return;
			captureSelection();
		}
		
		
		/**
		 *  @private
		 */
		private function mouseUpHandler(event:Event):void
		{
			if (!recording)
				return;
			richEditableText.systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, 
				mouseUpHandler);
			richEditableText.systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, 
				mouseUpHandler);
			
			flushCharacterBuffer();
			captureSelection();
			hasSelectionChanged = true;
		}
		
		/**
		 *  @private
		 */
		private function keyDownHandler(event:KeyboardEvent):void
		{
			if (!recording)
				return;
			
			//arrow and navigation keys should dispatch whatever was last typed
			//backspace, delete, and enter are dispatched
			switch (event.keyCode)
			{
				case Keyboard.CONTROL:
				{
					flushCharacterBuffer();
					break;
				}
				case Keyboard.SHIFT:
				{
					break;
				}
				case Keyboard.DOWN:
				case Keyboard.END:
				case Keyboard.HOME:
				case Keyboard.LEFT:
				case Keyboard.PAGE_DOWN:
				case Keyboard.PAGE_UP:
				case Keyboard.RIGHT:
				case Keyboard.UP:
				{
					flushCharacterBuffer();
					break;
				}
					
				case Keyboard.INSERT:
				case Keyboard.BACKSPACE:
				case Keyboard.DELETE:
				case Keyboard.ENTER:
				{
					flushSelection();
					flushCharacterBuffer();
					recordAutomatableEvent(event);
					oldSelection = null;
					break;
				}
					
				case Keyboard.ESCAPE:
				{
					recordAutomatableEvent(event);
					break;
				}
					
				default:
				{
					break;
				}
			}
		}
		
		/**
		 *  @private
		 */
		private function keyUpHandler(event:KeyboardEvent):void
		{
			
			if (!recording)
				return;
			
			//arrow and navigation keys should dispatch whatever was last typed
			//backspace, delete, and enter are dispatched
			switch (event.keyCode)
			{
				case Keyboard.TAB:
				{
					break;
				}
					
				case Keyboard.SHIFT:
				{
					break;
				}
					
				case Keyboard.DOWN:
				case Keyboard.END:
				case Keyboard.HOME:
				case Keyboard.LEFT:
				case Keyboard.PAGE_DOWN:
				case Keyboard.PAGE_UP:
				case Keyboard.RIGHT:
				case Keyboard.UP:
				{
					captureSelection();
					break;
				}
					
				case Keyboard.BACKSPACE:
				case Keyboard.DELETE:
				case Keyboard.ENTER:
				{
					break;
				}
					
				case Keyboard.CONTROL:
				{
					captureSelection();
					break;
				}
				default:
				{
					if (event.ctrlKey)
					{
						flushSelection();
						flushCharacterBuffer();
					}
					break;
				}
			}
		}
		
		
		
		
		/**
		 *  @private
		 */
		private function textInputHandler(event:TextEvent):void
		{
			if (!recording)
				return;
			
			// The \n will be caught by the ENTER capture
			if ((event.text == "\n")||(event.text == "\r")) 
				return;
			
			if (!stringBuffer)
			{
				flushSelection();
				stringBuffer = "";
			}
			
			// TextField allows a script to enter more text to be inserted than maxChars.
			// Hence we have to prevent the recording of more characters than maxChars. 
			// Without this check playback will add more characters than maxChars leading to errors.
			if (richEditableText.maxChars == 0 || richEditableText.text.length < richEditableText.maxChars)
			{   
				stringBuffer += event.text;
				oldSelection = null;
			}
			
			
		}
		
		private var currentActivePos:int = -1;
		private var currentLength:int = -1;
		private function changingTimeDataCapturer(event:TextOperationEvent):void
		{
			// we need to capture the details before the change
			// as we dont have a straight forward way of getting the change
			currentActivePos = richEditableText.selectionActivePosition;
			currentLength = richEditableText.text.length;
			
		}
		
		/**
		 *  @private
		 */
		private function changeHandler(event:TextOperationEvent):void
		{
			if (!recording)
				return;
			
			var operation:Object = event.operation;
			if(operation is PasteOperation)
			{
				var newLength:int = richEditableText.text.length;
				// get the additional string 
				// TBD once we have a correct understanding about the rtl, we need to decide
				// what text to obtain for the rtl case.
				var additionalString:String = richEditableText.text.substr(currentActivePos,newLength-currentLength);
				if (!stringBuffer)
				{
					stringBuffer = "";
				}
				stringBuffer += additionalString;
				// we need the charbuffer to be flushed 
				// as the selection details can change after the same
				flushCharacterBuffer();
			}
			else if(operation is  CutOperation)
			{
				// we need to record an empty string here so that the current selection will be removed
				stringBuffer = "";
				flushCharacterBuffer();
			}
			
		}
		/**
		 *  @private
		 */
		private function beginRecordingHandler(event:Event):void
		{
			checkInitialFocus();
		}
		
	}
	
}

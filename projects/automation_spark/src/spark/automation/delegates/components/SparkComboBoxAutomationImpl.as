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
    import flash.events.TextEvent;
    import flash.ui.Keyboard;
    
    import mx.automation.Automation;
    import mx.automation.IAutomationObject;
    import mx.automation.IAutomationObjectHelper;
    import mx.automation.events.AutomationRecordEvent;
    import mx.automation.events.TextSelectionEvent;
    import mx.core.mx_internal;
    
    import spark.automation.delegates.components.supportClasses.SparkDropDownListBaseAutomationImpl;
    import spark.components.ComboBox;
    import spark.components.RichEditableText;
    import spark.events.TextOperationEvent;
    
    use namespace mx_internal;
    
    [Mixin]
    
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  ComboBox control.
     * 
     *  @see spark.components.ComboBox 
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    
    public class SparkComboBoxAutomationImpl extends SparkDropDownListBaseAutomationImpl
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
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public static function init(root:DisplayObject):void
        {
            Automation.registerDelegateClass(spark.components.ComboBox, SparkComboBoxAutomationImpl);
        }   
        
        /**
         *  Constructor.
         * @param obj ComboBox object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkComboBoxAutomationImpl(obj:spark.components.ComboBox)
        {
            super(obj);
            
        }
        
        override protected function componentInitialized():void 
        {
            sparkComboBox.textInput.addEventListener(KeyboardEvent.KEY_DOWN, textKeyDownHandler, false, 0 , true);
            sparkComboBox.textInput.addEventListener(AutomationRecordEvent.RECORD,
                textInput_recordHandler, false, 0, true);
        }
        
        /**
         *  @private
         *  storage for the owner component
         */
        protected function get sparkComboBox():spark.components.ComboBox
        {
            return uiComponent as spark.components.ComboBox;
            
        }   
        
        /**
         * @private
         * Keyboard events like up/down/page_up/page_down/enter are
         * recorded here. They are not recorded by textInput control but
         * we require them to be recorded.
         */    
        private function textKeyDownHandler(event:KeyboardEvent):void
        {
            // we do not record key events with modifiers
            // open/close events with ctrl key are recorded seperately.
            if (event.ctrlKey)
                return;
            // record keys which are of used for navigation in the dropdown list
            if (event.keyCode == Keyboard.UP ||
                event.keyCode == Keyboard.DOWN ||
                event.keyCode == Keyboard.PAGE_UP ||
                event.keyCode == Keyboard.PAGE_DOWN ||
                event.keyCode == Keyboard.ESCAPE ||
                event.keyCode == Keyboard.ENTER ||
                event.keyCode == Keyboard.HOME ||
                event.keyCode == Keyboard.END
            )
                
                recordAutomatableEvent(event);
            else    //Pressing any key other than the above keys opens dropDown automatically.
                    // So we need not record the open event in that case as replay of the input character
                    // automatically opens the dropDown 
                isKeyTypeEvent = true;
        }
        
        /**
         *  @private
         *  textInput is a automationComposite. Hence its own recording is skipped by AT.
         *  We need to handle this specifically.
         */
        private function textInput_recordHandler(event:AutomationRecordEvent):void
        {
            if(event.automationObject == sparkComboBox.textInput)
            {
                var re:Object = event.replayableEvent;
                if (re is KeyboardEvent && (re.keyCode == Keyboard.ENTER || re.keyCode == Keyboard.ESCAPE))
                    return;
                recordAutomatableEvent(event.replayableEvent);
            }
        }
        
        /**
         * @private
         * Replays a text event by delegating responsibility to the text input.,
         */
        override public function replayAutomatableEvent(event:Event):Boolean
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            var ke:KeyboardEvent;
            if (event is KeyboardEvent)
            {
                var kbEvent:KeyboardEvent = KeyboardEvent(event);
                var keyCode:int = kbEvent.keyCode;
                switch (keyCode)
                {
                    case Keyboard.BACKSPACE:
                    {
                        // Processing of Key events in EditManager looks for charCode in case of
                        // Backspace but we are not storing charCode in our scripts. So redispatching the events
                        // after setting char code for Backspace. 
                        // AutomationManager's replayKeyBoardEvent also doesn't help because we do not consider
                        // charCode there also.
                        ke = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
                        ke.charCode = keyCode;
                        ke.keyCode = keyCode;
                        ke.ctrlKey = kbEvent.ctrlKey;
                        ke.shiftKey = kbEvent.shiftKey;
                        ke.altKey = kbEvent.altKey;
                        
                        sparkComboBox.textInput.textDisplay.dispatchEvent(ke);
                        
                        ke = new KeyboardEvent(KeyboardEvent.KEY_UP);
                        ke.charCode = keyCode;
                        ke.keyCode = keyCode;
                        ke.ctrlKey = kbEvent.ctrlKey;
                        ke.shiftKey = kbEvent.shiftKey;
                        ke.altKey = kbEvent.altKey;
                        
                        sparkComboBox.textInput.textDisplay.dispatchEvent(ke);
                        return true;
                    }
                    case Keyboard.DELETE:
                    {
                        return RichEditableText(sparkComboBox.textInput.textDisplay).replayAutomatableEvent(event);
                    }
                    default:
                    {
                        break;
                    }
                }
                return help.replayKeyboardEvent(sparkComboBox.textInput.textDisplay,
                    KeyboardEvent(event));
            }
            else if (event is TextEvent)
            {               
                // Instead of replaying it on textDisplay, we handle it explicitly here
                // because Change event need not be fired in this case like we do in RichEditableText.
                // Firing that would change the anchor and active positions which causes problem due
                // to auto-filling behavior of ComboBox.
                var changeEvent:TextOperationEvent = new TextOperationEvent(TextOperationEvent.CHANGE);
                
                // need to set focus in order for the uirichEditableText to behave correctly
                sparkComboBox.textInput.textDisplay.setFocus();
                
                var textEvent:TextEvent = TextEvent(event);
                var text:String = textEvent.text;
                var n:int = textEvent.text.length;
                
                for (var i:uint = 0; i < n; i++)
                {
                    ke = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
                    ke.charCode = text.charCodeAt(i);
                    ke.keyCode = text.charCodeAt(i);
                    sparkComboBox.textInput.textDisplay.dispatchEvent(ke);
                    var pos:int ;
                    
                    // we dont need any special handling on the string.
                    // replaying the key board events takes care of the needed.
                    // however when there is a line feed or carriage return , we need to handle it specially
                    if((text.charAt(i) == "\n") || (text.charAt(i) == "\r"))
                        sparkComboBox.textInput.textDisplay.insertText(text.charAt(i));
                    
                    
                    var te:TextEvent = new TextEvent(TextEvent.TEXT_INPUT);
                    te.text = String(text.charAt(i)); 
                    // ref. http://bugs.adobe.com/jira/browse/FLEXENT-838 - charcode vs charAt
                    sparkComboBox.textInput.textDisplay.dispatchEvent(te);
                    
                    ke = new KeyboardEvent(KeyboardEvent.KEY_UP);
                    ke.charCode = text.charCodeAt(i);
                    ke.keyCode = text.charCodeAt(i);
                    sparkComboBox.textInput.textDisplay.dispatchEvent(ke);
                }
                sparkComboBox.textInput.textDisplay.dispatchEvent(changeEvent);
            }
            else if (event is TextSelectionEvent)
            {
                var replayer:IAutomationObject = 
                    sparkComboBox.textInput as IAutomationObject;
                return (replayer ? replayer.replayAutomatableEvent(event): false);
            }
            return super.replayAutomatableEvent(event);
        }
        
        /**
         * @private
         */
        override protected function keyDownHandler(event:KeyboardEvent):void
        {
            
        }
    }
}
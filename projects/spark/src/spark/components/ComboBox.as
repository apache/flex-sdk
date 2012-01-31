////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{
import adobe.utils.CustomActions;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import mx.core.mx_internal;
import mx.styles.StyleProxy;

import spark.core.NavigationUnit;
import spark.components.supportClasses.ListBase;
import spark.events.DropDownEvent;
import spark.events.TextOperationEvent;
import spark.utils.LabelUtil;
 
use namespace mx_internal;

/*
TODO (jszeto)

X Implement labelToItemFunction
X Implement committing input string to selectedItem
X Keep track of selectedIndex state
- Implement caret and selection states
- Implement user interaction behaviors
X Implement openOnInput
X Implement TextInput proxy properties
X Implement itemMatchingFunction property
X Implement restrict
X Implement maxChars

X Add wireframe skins

X Support padding styles in TextInput

- Make setting custom selectedItem cancellable
- Refactor DropDownList into DropDownList and DropDownListBase

B-Feature
- Add filtering support
- Add allowCustomSelectedItem support
- Prompt support

*/

/**
 *  Botttom inset in pixels for the textInput
 * 
 *  @default 3
 */
[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]

/**
 *  Left inset in pixels for the textInput
 * 
 *  @default 3
 */
[Style(name="paddingLeft", type="Number", format="Length", inherit="no")]

/**
 *  Right inset in pixels for the textInput
 * 
 *  @default 3
 */
[Style(name="paddingRight", type="Number", format="Length", inherit="no")]

/**
 *  Top inset in pixels for the textInput
 * 
 *  @default 5
 */
[Style(name="paddingTop", type="Number", format="Length", inherit="no")]

// TODO Fill out ASDoc
/**
 *  ComboBox
 */
public class ComboBox extends DropDownList
{
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------    
    /**
     *  Optional skin part that holds the input text or the selectedItem text 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart(required="false")]
    public var textInput:TextInput;
    
    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function ComboBox()
    {
        super();
        
        addEventListener(KeyboardEvent.KEY_DOWN, capture_keyDownHandler, true);
        
        // TODO (jszeto) Add a property to toggle this behavior
        allowCustomSelectedItem = true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Static Variables
    //
    //--------------------------------------------------------------------------
    /**
     *  Static constant representing the value "custom selectedItem"
     */
    public static const CUSTOM_SELECTED_ITEM:int = ListBase.CUSTOM_SELECTED_ITEM;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private var isTextInputInFocus:Boolean;
    
    private var actualProposedSelectedIndex:Number = -1;  
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------
    //  itemMatchingFunction
    //--------------------------------------------------------------------------
    
    /**
     *  The function referenced by this property takes an input string and returns
     *  the items in the dataProvider that match the input. 
     *  The items are returned as a Vector of indicies in the dataProvider. 
     * 
     *  The function signature is this:
     * 
     *  <pre>function myMatchingFunction(comboBox:ComboBox, inputText:String):Vector</pre>
     * 
     *  If the value is null, the ComboBox will find matches using the following algorithm:
     * 
     *  If an input string of length n is equivalent to the first n characters 
     *  of an item (ignoring case), then it is a match to that item. For example, 'aRiz' 
     *  is a match to "Arizona" while 'riz' is not.
     * 
     *  @default null
     */ 
    public var itemMatchingFunction:Function = null;
    
    //--------------------------------------------------------------------------
    //  labelToItemFunction
    //--------------------------------------------------------------------------
    private var _labelToItemFunction:Function;
    private var labelToItemFunctionChanged:Boolean = false;
    
    /**
     *  The function referenced by this propery is called when textInput's text
     *  is committed and is not found in the dataProvider. 
     * 
     *  The function signature is this:
     * 
     *  function myLabelToItem(value:String):Object
     * 
     *  The function returns an Object that should be the same type as the items 
     *  in the dataProvider.
     * 
     *  The default function returns the parameter. 
     */ 
    public function set labelToItemFunction(value:Function):void
    {
        if (value == _labelToItemFunction)
            return;
        
        _labelToItemFunction = value;
        labelToItemFunctionChanged = true;
        invalidateProperties();
    }
    
    /**
     *  @private 
     */
    public function get labelToItemFunction():Function
    {
        return _labelToItemFunction;
    }
    
    //--------------------------------------------------------------------------
    //  maxChars
    //--------------------------------------------------------------------------
    
    private var _maxChars:int = 0;
    private var maxCharsChanged:Boolean = false;
    
    /**
     *  The maximum number of characters that the textInput can contain, as entered by a user.   
     * 
     *  @default 0
     */ 
    public function set maxChars(value:int):void
    {
        if (value == _maxChars)
            return;
        
        _maxChars = value;
        maxCharsChanged = true;
        invalidateProperties();
    }
    
    /**
     *  @private 
     */
    public function get maxChars():int
    {
        return _maxChars;
    }
    
    //--------------------------------------------------------------------------
    //  openOnInput
    //--------------------------------------------------------------------------
    
    /**
     *  If true, the dropDown will open whenever the user edits the textInput.
     * 
     *  @default true 
     */ 
    public var openOnInput:Boolean = true;
    
    //--------------------------------------------------------------------------
    //  restrict
    //--------------------------------------------------------------------------
    
    private var _restrict:String;
    private var restrictChanged:Boolean;
    
    /**
     *  Indicates the set of characters that a user can enter into the textInput.  
     * 
     *  @default ""
     */ 
    public function set restrict(value:String):void
    {
        if (value == _restrict)
            return;
        
        _restrict = value;
        restrictChanged = true;
        invalidateProperties();
    }
    
    /**
     *  @private 
     */
    public function get restrict():String
    {
        return _restrict;
    }
 
    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     */
    override mx_internal function set userProposedSelectedIndex(value:Number):void
    {
        super.userProposedSelectedIndex = value;
        actualProposedSelectedIndex = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     */ 
    private function processInputField():void
    {
        var matchingItems:Vector.<int>;
        
        //trace("CB.processInputField input string",textInput.text);
        
        // If the textInput has been changed, then use the input string as the selectedItem
        actualProposedSelectedIndex = CUSTOM_SELECTED_ITEM; 
        
        
        if (textInput.text != "")
        {
            if (itemMatchingFunction != null)
                matchingItems = itemMatchingFunction(this, textInput.text);
            else
                matchingItems = findMatchingItems(textInput.text);
            
            //trace("CB.processInputField matchingItems:");
           // for (var i:int = 0; i < matchingItems.length; i++)
                //trace("    ["+i+"]",matchingItems[i]);
            
            if (matchingItems.length > 0)
            {
                itemSelected(userProposedSelectedIndex, false);
                super.userProposedSelectedIndex = matchingItems[0];
                ensureIndexIsVisible(userProposedSelectedIndex);
                itemSelected(userProposedSelectedIndex, true);
            }
        }
        else
        {
            // If the input string is empty, then don't select anything
            itemSelected(userProposedSelectedIndex, false);
            super.userProposedSelectedIndex = NO_SELECTION;  
        }
    }
    
    /**
     *  @private 
     */ 
    // Returns an array of possible values
    private function findMatchingItems(input:String):Vector.<int>
    {
        
        // For now, just select the first match
        var startIndex:int;
        var stopIndex:int;
        var retVal:int;  
        var retVector:Vector.<int> = new Vector.<int>;
                
        if (selectedIndex == NO_SELECTION || selectedIndex == CUSTOM_SELECTED_ITEM)
        {
            startIndex = 0;
            stopIndex = dataProvider.length; 
            retVal = findStringLoop(input, startIndex, stopIndex);
        }
        else
        {
            startIndex = selectedIndex + 1; 
            stopIndex = dataProvider.length; 
            retVal = findStringLoop(input, startIndex, stopIndex); 
            // We didn't find the item, loop back to the top 
            if (retVal == -1)
            {
                retVal = findStringLoop(input, 0, selectedIndex); 
            }
        }
        
        if (retVal != -1)
            retVector.push(retVal);
        return retVector;
    }
    
    /**
     *  @private 
     */ 
    private function getCustomSelectedItem():*
    {
        // Grab the text from the textInput and process it through labelToItemFunction
        var input:String = textInput.text;
        if (input == "")
            return undefined;
        else if (labelToItemFunction != null)
            return _labelToItemFunction(input);
        else
            return input;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    override protected function commitProperties():void
    {
        //trace("CB.commitProperties selectedIndex",selectedIndex,"input string", textInput.text);
        
        // Keep track of whether selectedIndex was programmatically changed
        var selectedIndexChanged:Boolean = _proposedSelectedIndex != NO_PROPOSED_SELECTION;
        
        // If selectedIndex was set to CUSTOM_SELECTED_ITEM, and no selectedItem was specified,
        // then don't change the selectedIndex
        if (_proposedSelectedIndex == CUSTOM_SELECTED_ITEM && 
            !_pendingSelectedItem)
        {
            _proposedSelectedIndex = NO_PROPOSED_SELECTION;
        }
                
        super.commitProperties();
        
        if (textInput)
        {
            if (maxCharsChanged)
            {
                textInput.maxChars = _maxChars;
                maxCharsChanged = false;
            }
            
            if (restrictChanged)
            {
                textInput.restrict = _restrict;
                restrictChanged = false;
            }
        }
        
        // Clear the TextInput because we were programmatically set to NO_SELECTION
        // We call this after super.commitProperties because commitSelection might have
        // changed the value to NO_SELECTION
        if (selectedIndexChanged && selectedIndex == NO_SELECTION)
            textInput.text = "";
    }
    
    /**
     *  @private 
     */ 
    override mx_internal function updateLabelDisplay():void
    {
        super.updateLabelDisplay();
        
        if (textInput)
        {
            if (selectedItem != null && selectedItem != undefined)
            {
                //trace("CB.updateLabelDisplay",LabelUtil.itemToLabel(selectedItem, labelField, labelFunction));
                textInput.text = LabelUtil.itemToLabel(selectedItem, labelField, labelFunction);
            }
        }
    }
    
    /**
     *  @private 
     */     
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == textInput)
        {
            updateLabelDisplay();
            textInput.addEventListener(TextOperationEvent.CHANGE, textInput_changeHandler);
            textInput.addEventListener(FocusEvent.FOCUS_IN, textInput_focusInHandler, true);
            textInput.addEventListener(FocusEvent.FOCUS_OUT, textInput_focusOutHandler, true);
            textInput.maxChars = maxChars;
            textInput.restrict = restrict;
            textInput.focusEnabled = false;
        }
    }
    
    // If the TextInput is in focus, listen for keyDown events in the capture phase so that 
    // we can process the navigation keys (UP/DOWN, PGUP/PGDN, HOME/END). If the ComboBox is in 
    // focus, just handle keyDown events in the bubble phase
    
    /**
     *  @private 
     */ 
    override protected function keyDownHandler(event:KeyboardEvent) : void
    {
        if (!isTextInputInFocus)
        {
            //trace("ComboBox.keyDownHandler code",event.keyCode,"IGNORED");
            super.keyDownHandler(event);
        }
        
        // No op. ComboBox listens for keyboard events in the capture phase
    }
    
    /**
     *  @private 
     */ 
    protected function capture_keyDownHandler(event:KeyboardEvent):void
    {
        if (isTextInputInFocus)
        {
            //trace("ComboBox.capture_keyDownHandler code",event.keyCode);
            super.keyDownHandler(event);
        }
    }
    
    /**
     *  @private
     */
    override public function setFocus():void
    {
        if (stage)
        {
            stage.focus = textInput.textDisplay;
            
            // Since the API ignores the visual editable and selectable 
            // properties make sure the selection should be set first.
            if (textInput.textDisplay && 
                (textInput.textDisplay.editable || textInput.textDisplay.selectable))
            {
                textInput.textDisplay.selectAll();
            }
        }
    }
    
    /**
     *  @private
     */
    override protected function isOurFocus(target:DisplayObject):Boolean
    {
        return target == textInput.textDisplay;
    }
    
    /**
     *  @private 
     */ 
    override protected function dropDownController_closeHandler(event:DropDownEvent):void
    {
        super.dropDownController_closeHandler(event);
        
        if (!event.isDefaultPrevented())
        {
            if (actualProposedSelectedIndex == CUSTOM_SELECTED_ITEM)
            {
                var itemFromInput:* = getCustomSelectedItem();
                if (itemFromInput != undefined)
                    selectedItem = itemFromInput;
                else
                    selectedIndex = NO_SELECTION;
            }
            else
            {
                selectedIndex = actualProposedSelectedIndex;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     */ 
    private function textInput_focusInHandler(event:FocusEvent):void
    {
        isTextInputInFocus = true;
    }
    
    /**
     *  @private 
     */ 
    private function textInput_focusOutHandler(event:FocusEvent):void
    {
        isTextInputInFocus = false;
    }
    
    /**
     *  @private 
     */ 
    protected function textInput_changeHandler(event:Event):void
    {   
        // Ignore the ENTER key
        /*if (isEnterKeyDown)
            return;*/
        //trace("CB.textInput_changeHandler");
        /* TODO (jszeto) Figure out how to find the new text
        
        Two ways of doing the interaction:
        
        1. DropDown shows set of possible choices  
        
        - Behavior as defined in XD spec
        - Create new function that takes an input string and returns the array of data items
        that match string
        - Figure out how to only display a subset of the dataProvider. Use collection filters?
        
        2. DropDown highlights first match
        
        - DropDown opens if we find a match
        - Match is highlighted, but not selected until Enter or mouse click selects the item
        - Can use arrows to change selection
        - Behavior of Halo ComboBox
        
        */
       
        
        // Open the dropDown if it isn't already open
        if (openOnInput)
        {
            if (!isDropDownOpen)
            {
                openDropDown();
                addEventListener(DropDownEvent.OPEN, editingOpenHandler);
                return;
            }   
            
            processInputField();
        }
    }
    
    /**
     *  @private 
     */ 
    private function editingOpenHandler(event:DropDownEvent):void
    {
        removeEventListener(DropDownEvent.OPEN, editingOpenHandler);
        processInputField();
    }
    
    
    
    
        
}
}
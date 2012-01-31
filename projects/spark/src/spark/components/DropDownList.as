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

/*  NOTES

Keyboard Interaction
- List current dispatches selectionChanged on arrowUp/Down. Should we subclass List
and change behavior to commit value only on ENTER, SPACE, or CTRL-UP?

- Add typicalItem support for measuredSize (lower priority) 

*  @langversion 3.0
*  @playerversion Flash 10
*  @playerversion AIR 1.5
*  @productversion Flex 4

*/

package spark.components
{

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.collections.IList;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.DropdownEvent;
import mx.events.FlexEvent;

import spark.components.Button;
import spark.components.supportClasses.ButtonBase;
import spark.components.supportClasses.ListBase;
import spark.primitives.supportClasses.TextGraphicElement;
import spark.utils.LabelUtil;


/**
 *  Dispatched when the dropDown is dismissed for any reason such when 
 *  the user:
 *  <ul>
 *      <li>selects an item in the dropDown</li>
 *      <li>clicks outside of the dropDown</li>
 *      <li>clicks the dropDown button while the dropDown is 
 *  displayed</li>
 *  </ul>
 *
 *  @eventType mx.events.DropdownEvent.CLOSE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="close", type="mx.events.DropdownEvent")]

/**
 *  Dispatched when the user clicks the dropDown button
 *  to display the dropDown.  It is also dispatched if the user
 *  uses the keyboard and types Ctrl-Down to open the dropDown.
 *
 *  @eventType mx.events.DropdownEvent.OPEN
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="open", type="mx.events.DropdownEvent")]

/**
 *  Open State of the DropDown component
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("open")]


//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="allowMultipleSelection", kind="property")]
[Exclude(name="selectedIndices", kind="property")]
[Exclude(name="selectedItems", kind="property")]


/**
 *  DropDownList control contains a drop-down list
 *  from which the user can select a single value.
 *  Its functionality is very similar to that of the
 *  SELECT form element in HTML.
 * 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class DropDownList extends List
{
 
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------	
    /**
     *  An optional skin part that holds the prompt or the text of the selectedItem 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart(required="false")]
    public var labelElement:TextGraphicElement;
	
	/**
     *  A skin part that defines the anchor button.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart(required="true")]
    public var button:ButtonBase;
	
	
	/**
     *  A skin part that defines the dropDown area. When the DropDownList is open,
     *  clicking anywhere outside of the dropDown skin part will close the   
     *  DropDownList. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart(required="false")]
    public var dropDown:DisplayObject;
    	
	/**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
	public function DropDownList()
	{
		super();
		super.allowMultipleSelection = false;
	}
	
	//--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
	
    private var labelChanged:Boolean = false;
	
	//--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
	
	//----------------------------------
    //  isOpen
    //----------------------------------
    
    /**
     *  @private 
     */
    private var _isOpen:Boolean = false;
    
    /**
     *  Whether the dropDown is open or not.   
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */  
    public function get isOpen():Boolean
    {
    	return _isOpen;
    }

	//----------------------------------
    //  prompt
    //----------------------------------

    private var _prompt:String = "";

    /**
     *  The prompt for the DropDownList control. A prompt is
     *  a String that is displayed in the TextInput portion of the
     *  DropDownList when <code>selectedIndex</code> = -1.  It is usually
     *  a String like "Select one...".  If there is no
     *  prompt, the DropDownList control sets <code>selectedIndex</code> to 0
     *  and displays the first item in the <code>dataProvider</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get prompt():String
    {
        return _prompt;
    }

    /**
     *  @private
     */
    public function set prompt(value:String):void
    {
    	if (_prompt == value)
    		return;
    		
    	_prompt = value;
        labelChanged = true;
        invalidateProperties();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  allowMultipleSelection
    //----------------------------------
    
    /**
     *  @private
     */
    override public function set allowMultipleSelection(value:Boolean):void
    {
    	// Don't allow this value to be set
        return;
    }
    
    //----------------------------------
    //  baselinePosition
    //----------------------------------
    
    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
    	if (button)
    		return button.baselinePosition;
    	else
    		return NaN;
    }
    
    //----------------------------------
    //  dataProvider
    //----------------------------------
    
    /**
     *  @private
     *  Update the label if the dataProvider has changed
     */
    override public function set dataProvider(value:IList):void
    {	
    	if (dataProvider === value)
    		return;
    		
    	super.dataProvider = value;
    	labelChanged = true;
    	invalidateProperties();
    }
    
    //----------------------------------
    //  enabled
    //----------------------------------
    
    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
    	if (value == enabled)
    		return;
    	
    	super.enabled = value;
    	if (button)
    		button.enabled = value;
    }
    
    //----------------------------------
    //  labelField
    //----------------------------------
    
     /**
     *  @private
     */
    override public function set labelField(value:String):void
    {
    	if (labelField == value)
    		return;
    		
    	super.labelField = value;
    	labelChanged = true;
    	invalidateProperties();
    }
    
    //----------------------------------
    //  labelFunction
    //----------------------------------
    
     /**
     *  @private
     */
    override public function set labelFunction(value:Function):void
    {
    	if (labelFunction == value)
    		return;
    		
    	super.labelFunction = value;
    	labelChanged = true;
    	invalidateProperties();
    }
    
    //----------------------------------
    //  selectedIndices
    //----------------------------------
    
    /**
     *  @private
     */
    override public function set selectedIndices(value:Array):void
    {
    	// TODO (jszeto) This needs to be localized
    	throw new Error("The selectedIndices property is not supported in DropDownList");
    }
    
    //----------------------------------
    //  selectedItems
    //----------------------------------
    
    /**
     *  @private
     */
    override public function set selectedItems(value:Array):void
    {
    	// TODO (jszeto) This needs to be localized
    	throw new Error("The selectedItems property is not supported in DropDownList");
    }
    
    
 	//--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------   

	/**
     *  Initializes the dropDown and changes the skin state to open. 
     * 
     *  It should not be necessary to override this function. Instead, override the
     *  initializeDropDown function. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function openDropDown():void
    {
		//trace("DDL.openDropDown isOpen",isOpen);
    	if (!isOpen)
    	{
    		// TODO (jszeto) Change these to be marshall plan compliant
    		systemManager.addEventListener(MouseEvent.MOUSE_DOWN, systemManager_mouseDownHandler);
    		systemManager.addEventListener(Event.RESIZE, systemManager_resizeHandler, false, 0, true);
    		
    		_isOpen = true;
    		button.mx_internal::keepDown = true; // Force the button to stay in the down state
    		skin.currentState = getCurrentSkinState();
    		
    		dispatchEvent(new DropdownEvent(DropdownEvent.OPEN));
    	}
    }
	
	 /**
     *  Changes the skin state to normal, commits the data from the dropDown and 
     *  performs some cleanup.  
     * 
     *  The user can close the dropDown either in a committing or non-committing manner 
     *  based on their interaction gesture. If the user has performed a committing 
     *  gesture, then set commitData to true. 
     *   
     *  @param commitData Flag indicating if the component should commit the selected
     *  data from the dropDown. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function closeDropDown(commitData:Boolean):void
    {
    	//trace("DDL.closeDropDown isOpen",isOpen);
    	if (isOpen)
    	{
    		// TODO (jszeto) Add logic to check for commitData
    		/*if (commitData)
        		commitDropDownData();*/	
	
			_isOpen = false;
			button.mx_internal::keepDown = false;
	       	skin.currentState = getCurrentSkinState();
        	
        	dispatchEvent(new DropdownEvent(DropdownEvent.CLOSE));
        	
        	// TODO (jszeto) Change these to be marshall plan compliant
        	systemManager.removeEventListener(MouseEvent.MOUSE_DOWN, systemManager_mouseDownHandler);
        	systemManager.removeEventListener(Event.RESIZE, systemManager_resizeHandler);
    	}
    }
	
	/**
     *  @private
     *  Called whenever we need to update the text passed to the labelElement skin part
     */
    // TODO (jszeto) Make this protected and make the name more generic (passing data to skin) 
	private function updateLabelElement():void
	{
		if (labelElement)
    	{
    		if (selectedItem)
    			labelElement.text = LabelUtil.itemToLabel(selectedItem, labelField, labelFunction);
	    	else
	    		labelElement.text = prompt;
    	}	
	}
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
	
	/**
	 *  @private
	 */ 
	override protected function commitSelectedIndex():Boolean
    {
    	var result:Boolean = super.commitSelectedIndex();
       	updateLabelElement();
   
    	return result;   	
    }
    
    /**
 	 *  @private
 	 */ 
	override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (labelChanged)
		{
			labelChanged = false;
        	updateLabelElement();
  		}
    }
    
    /**
 	 *  @private
 	 */ 
    override protected function dataProvider_collectionChangeHandler(event:Event):void
    {    	
    	super.dataProvider_collectionChangeHandler(event);
    	
    	if (event is CollectionEvent)
        {
			labelChanged = true;
			invalidateProperties();        	
        }
    }
       
    /**
 	 *  @private
 	 */ 
    override protected function getCurrentSkinState():String
    {
		return !enabled ? "disabled" : isOpen ? "open" : "normal";
    }   
       
    /**
	 *  @private
	 */ 
    override protected function partAdded(partName:String, instance:Object):void
    {
    	super.partAdded(partName, instance);
 
 		if (instance == button)
    	{
    		// TODO (jszeto) Change this to be mouseDown. Figure out how to not 
    		// trigger systemManager_mouseDown.
    		button.addEventListener(FlexEvent.BUTTON_DOWN, button_buttonDownHandler);
    		button.enabled = enabled;
    	}
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
    	if (instance == button)
    	{
    		button.removeEventListener(FlexEvent.BUTTON_DOWN, button_buttonDownHandler);
    	}
        
        super.partRemoved(partName, instance);
    }
    
    /**
     *  @private
     */
    override protected function item_clickHandler(event:MouseEvent):void
	{
		//trace("DDL.item_clickHandler mouse event",event.type);
		super.item_clickHandler(event);
		closeDropDown(true);
	}
    
    /**
     *  @private
     */
    // TODO (jszeto) Workaround for now until we can fix List so that it 
    // doesn't listen for keyDown events in the capture phase 
    override protected function keyDownHandler(event:KeyboardEvent) : void
	{
		//trace("DropDownList.keyDownHandler key",event.keyCode);
		list_keyDownHandler(event);
	}
        
    /**
	 *  @private
	 */
	override protected function list_keyDownHandler(event:KeyboardEvent) : void
	{
		//trace("DropDownList.list_keyDownHandler key",event.keyCode);
		if(!enabled)
            return;
        
        if (event.ctrlKey && event.keyCode == Keyboard.DOWN)
        {
            openDropDown();
            event.stopPropagation();
        }
        else if (event.ctrlKey && event.keyCode == Keyboard.UP)
        {
            closeDropDown(true);
            event.stopPropagation();
        }    
        else if (event.keyCode == Keyboard.ENTER)
        {
            // Close the dropDown and eat the event if appropriate.
            if (isOpen)
            {
                closeDropDown(true);
                event.stopPropagation();
            }
        }
        else if (event.keyCode == Keyboard.ESCAPE)
        {
            // Close the dropDown and eat the event if appropriate.
            if (isOpen)
            {
                closeDropDown(false);
                event.stopPropagation();
            }
        }
        else 
        {
        	//trace("DropDownList.keyDownHandler arrow key isOpen",isOpen);
        	// TODO (jszeto) Check if we need dataGroup skin during this event
        	super.list_keyDownHandler(event);
        }         
	}
	
	/**
     *  @private
     */
    override protected function focusOutHandler(event:FocusEvent):void
    {
        // Note: event.relatedObject is the object getting focus.
        // It can be null in some cases, such as when you open
        // the dropdown and then click outside the application.

        // If the dropdown is open...
        if (isOpen)
        {
            // If focus is moving outside the dropdown...
            // TODO (jszeto) Should we compare to the whole skin or just the dataGroup?
            if (!event.relatedObject ||
                !dataGroup.contains(event.relatedObject))
            {
                // Close the dropdown.
                //trace("DDL.focusOutHandler");
                closeDropDown(false);
            }
        }

        super.focusOutHandler(event);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------
    
	 /**
 	 *  Called when the buttonDown event is dispatched. This function opens or closes
 	 *  the dropDown depending upon the dropDown state. 
 	 *  
 	 *  @langversion 3.0
 	 *  @playerversion Flash 10
 	 *  @playerversion AIR 1.5
 	 *  @productversion Flex 4
 	 */ 
    protected function button_buttonDownHandler(event:Event):void
    {
    	//trace("DDL.button_buttonDownHandler");
        if (isOpen)
            closeDropDown(true);
        else
            openDropDown();
    }
    
    /**
     *  Called when the systemManager receives a mouseDown event. In the base class 
     *  implementation, this closes the dropDown.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */     
    protected function systemManager_mouseDownHandler(event:MouseEvent):void
    {
    	//trace("DropDownBase.systemManager_mouseDownHandler, hit dropDown?",dropDown.hitTestPoint(event.stageX, event.stageY));
    	// TODO (jszeto) Make marshall plan compliant
     	if ((dropDown && !dropDown.hitTestPoint(event.stageX, event.stageY) || !dropDown))
        {
            closeDropDown(true);
        }
    }
    
    /**
     *  @private
     *  Close the dropDown if the stage has been resized. Don't commit the data.
     */
    private function systemManager_resizeHandler(event:Event):void
    {
    	closeDropDown(false);
    }

}
}

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

TODO List

- implicitSelectedIndex
- Handle stage resize, focus in/out
- add enabled/disabled
- Add type assist
- Add typicalItem support for measuredSize (lower priority) 
- Change button to be a ToggleButton so we stay down when dropdown is open
- No prompt should set selectedIndex = 0?

BUGS
- Setting selectedItem to undefined doesn't set selectedIndex to -1

*  @langversion 3.0
*  @playerversion Flash 10
*  @playerversion AIR 1.5
*  @productversion Flex 4

*/

package spark.components
{

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.collections.IList;
import mx.events.CollectionEvent;
import mx.events.DropdownEvent;
import mx.events.FlexEvent;

import spark.components.Button;
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
    // TODO!!! (jszeto) Replace with a toggle button 
    [SkinPart(required="true")]
    public var button:Button;
	
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
     */
     // TODO (jszeto) Check if we really need this
    override public function set dataProvider(value:IList):void
    {
    	super.dataProvider = value;
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
		//trace("DropDownBase.openDropDown isOpen",isOpen);
    	if (!isOpen)
    	{
    		// TODO (jszeto) Change this to be marshall plan compliant
    		systemManager.addEventListener(MouseEvent.MOUSE_DOWN, systemManager_mouseDownHandler);
    		
    		_isOpen = true;
    		skin.currentState = getCurrentSkinState();
    		
    		// TODO (jszeto) How to handle animations in the skin?
    		dispatchEvent(new DropdownEvent(DropdownEvent.OPEN));
	    	
	    	// Save the original selectedIndex
			//previousSelectedIndex = selectedIndex;
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
    	//trace("DropDownBase.closeDropDown isOpen",isOpen,"inKey",inKeyNavigation);
    	if (isOpen)
    	{
    		// TODO (jszeto) Add logic to check for commitData
    		/*if (commitData)
        		commitDropDownData();*/	
	
			_isOpen = false;
	       	skin.currentState = getCurrentSkinState();
        	
        	// TODO (jszeto) How to handle animations in the skin?
        	dispatchEvent(new DropdownEvent(DropdownEvent.CLOSE));
        	
        	// TODO (jszeto) Change this to be marshall plan compliant
        	systemManager.removeEventListener(MouseEvent.MOUSE_DOWN, systemManager_mouseDownHandler);
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
	
	// TODO (jszeto) Add measure implementation that uses the longest string in the data provider as 
    // the label and calls super.measure().
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
    		instance.addEventListener(FlexEvent.BUTTON_DOWN, buttonDownHandler);
    	}
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
    	if (instance == button)
    	{
    		instance.removeEventListener(FlexEvent.BUTTON_DOWN, buttonDownHandler);
    	}
        
        super.partRemoved(partName, instance);
    }
    
    /**
     *  @private
     */
    override protected function item_clickHandler(event:MouseEvent):void
	{
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
        
        /*
        if (event.keyCode == Keyboard.UP ||
                event.keyCode == Keyboard.DOWN ||
                event.keyCode == Keyboard.LEFT ||
                event.keyCode == Keyboard.RIGHT ||
                event.keyCode == Keyboard.PAGE_UP ||
                event.keyCode == Keyboard.PAGE_DOWN)
        {	
        	if (isOpen)
        	{
        		// TODO (jszeto) Clean this up once we have List support for 
        		// not sending selection_change on keydown.
        		inKeyNavigation = true;
        		// TODO (jszeto) Clean this up when SDK-19738 is fixed
        		if (dropDown.numChildren > 0)
        			dropDown.getChildAt(0).dispatchEvent(event.clone());
        			
        		inKeyNavigation = false;	
        	}
        	else
        	{
        		var nextSelectedIndex:int = selectedIndex;
        		if (event.keyCode == Keyboard.UP)
        		{
        			nextSelectedIndex = Math.max(0, nextSelectedIndex - 1);
        		}
        		else if (event.keyCode == Keyboard.DOWN)
        		{
        			nextSelectedIndex = Math.min(collection.length - 1, nextSelectedIndex + 1); 
        		}
        		else if (event.keyCode == Keyboard.PAGE_UP)
        		{
        			nextSelectedIndex = Math.max(0, nextSelectedIndex - PAGE_SIZE);
        		}
        		else if (event.keyCode == Keyboard.PAGE_DOWN)
        		{
        			nextSelectedIndex = Math.min(collection.length - 1, nextSelectedIndex + PAGE_SIZE); 
        		}
        		
        		if (nextSelectedIndex != selectedIndex)
        		{
	        		selectedIndex = nextSelectedIndex;
        		
        			dispatchEvent(new Event(Event.CHANGE));
        		}
        	}*/
        	
        	
        	
        	
        	/*var e:KeyboardEvent = event.clone();
        	e.eventPhase = EventPhase.CAPTURING_PHASE;*/
        	
        	/*dropDown.addEventListener(IndexChangedEvent.SELECTION_CHANGED, dropDown_selectionChangedHandler);
        	
        	if (dropDown.numChildren > 0)
        		dropDown.getChildAt(0).dispatchEvent(event.clone());
        	
        	dropDown.removeEventListener(IndexChangedEvent.SELECTION_CHANGED, dropDown_selectionChangedHandler);*/
        	
        	
        	
            /*var oldIndex:int = selectedIndex;

			

            // Make sure we know we are handling a keyDown,
            // so if the dropdown sends out a "change" event
            // (like when an up-arrow or down-arrow changes
            // the selection) we know not to close the dropdown.
            bInKeyDown = _showingDropdown;
            // Redispatch the event to the dropdown
            // and let its keyDownHandler() handle it.

            dropdown.dispatchEvent(event.clone());
            event.stopPropagation();
            bInKeyDown = false;*/

          
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
    protected function buttonDownHandler(event:Event):void
    {
    	//trace("DropDownBase.buttonDownHandler ", isOpen ? "[CLOSE]" : "[OPEN]");
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
    	// TODO (jszeto) Make marshall plan compliant
    	// TODO (jszeto) Figure a better way to handle this
     	if ((dataGroup && !dataGroup.hitTestPoint(event.stageX, event.stageY)) &&
     	    (button && !button.hitTestPoint(event.stageX, event.stageY)))
        {
        	//trace("DropDownBase.systemManager_mouseDownHandler  [CLOSE]");
            closeDropDown(true);
        }
    }

}
}
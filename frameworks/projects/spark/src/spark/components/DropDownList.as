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

- Handle commitData 
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

import spark.components.supportClasses.DropDownController;

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
		
		if (_dropDownControllerClass)
		{
			_dropDownController = new _dropDownControllerClass();
			initializeDropDownController();
		}
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
    //  dropDownController
    //----------------------------------
	
	private var _dropDownController:DropDownController;	
	
	/**
     *  Instance of the helper class that handles all of the mouse, keyboard 
     *  and focus user interactions. The type of this class is determined by the
     *  <code>dropDownControllerClass</code> property. 
     * 
     *  The <code>initializeDropDownController()</code> function is called after 
     *  the dropDownController is created in the constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
	protected function get dropDownController():DropDownController
	{
		return _dropDownController;
	}

	//----------------------------------
    //  dropDownControllerClass
    //----------------------------------
	
	private var _dropDownControllerClass:Class = DropDownController;	

	/**
     *  The class used to create an instance for the <code>dropDownController</code> 
     *  property. Set this property if you want to use a 
     *  <code>DropDownController</code> subclass to modify the default mouse, 
     *  keyboard and focus user interactions.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
	public function set dropDownControllerClass(value:Class):void
	{
		if (_dropDownControllerClass == value)
			return;
			
		_dropDownControllerClass = value;
		_dropDownController = new _dropDownControllerClass();
		initializeDropDownController();
	}
	
	/**
     *  @private
     */
	public function get dropDownControllerClass():Class
	{
		return _dropDownControllerClass;
	}


	//----------------------------------
    //  prompt
    //----------------------------------

    private var _prompt:String = "";

    /**
     *  The prompt for the DropDownList control. A prompt is
     *  a String that is displayed in the TextInput portion of the
     *  DropDownList when <code>selectedIndex</code> = -1.  It is usually
     *  a String like "Select one...". 
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
    	throw new Error(resourceManager.getString("components", "selectedIndicesDropDownListError"));
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
    	throw new Error(resourceManager.getString("components", "selectedItemsDropDownListError"));
    }
    
    
 	//--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------   

	/**
     *  Opens the dropDown. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function openDropDown():void
    {
    	dropDownController.openDropDown();
    }
	
	 /**
     *  Closes the dropDown. 
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
    	dropDownController.closeDropDown(commitData);
    }
	
	/**
     *  Initializes the <code>dropDownController</code> after it has been created. 
     *  Override this function if you create a <code>DropDownController</code> subclass 
     *  and need to perform additional initialization.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4 
     */
	protected function initializeDropDownController():void
	{		
		if (dropDownController)
		{
			dropDownController.addEventListener(DropdownEvent.OPEN, dropDownController_openHandler);
			dropDownController.addEventListener(DropdownEvent.CLOSE, dropDownController_closeHandler);
			
			if (button)
				dropDownController.button = button;
			if (dropDown)
				dropDownController.dropDown = dropDown;
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
		return !enabled ? "disabled" : dropDownController.isOpen ? "open" : "normal";
    }   
       
    /**
	 *  @private
	 */ 
    override protected function partAdded(partName:String, instance:Object):void
    {
    	super.partAdded(partName, instance);
 
 		if (instance == button)
    	{
    		if (dropDownController)
    			dropDownController.button = button;
    		button.enabled = enabled;
    	}
    	
    	if (instance == dropDown && dropDownController)
    		dropDownController.dropDown = dropDown;
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
    	if (dropDownController)
    	{
    		if (instance == button)
	    		dropDownController.button = null;
    	
    		if (instance == dropDown)
    			dropDownController.dropDown = null;
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
		list_keyDownHandler(event);
	}
        
    /**
	 *  @private
	 */
	override protected function list_keyDownHandler(event:KeyboardEvent) : void
	{
		if(!enabled)
            return;
        
        if (!dropDownController.keyDownHandler(event))
        	super.list_keyDownHandler(event);

	}
	
	/**
     *  @private
     */
    override protected function focusOutHandler(event:FocusEvent):void
    {
		dropDownController.focusOutHandler(event);

        super.focusOutHandler(event);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Event handler for the <code>dropDownController</code> 
     *  <code>DropdownEvent.OPEN</code> event. Updates the skin's state and 
     *  ensures that the selectedItem is visible. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function dropDownController_openHandler(event:DropdownEvent):void
    {
    	invalidateSkinState();
    	
    	ensureItemIsVisible(selectedIndex);
    	
    	dispatchEvent(event);
    }
    
    /**
     *  Event handler for the <code>dropDownController</code> 
     *  <code>DropdownEvent.CLOSE</code> event. Updates the skin's state.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function dropDownController_closeHandler(event:DropdownEvent):void
    {
    	invalidateSkinState();
    	
    	// TODO!! Add logic to handle commitData
    	//if (event.isDefaultPrevented())
    	
    	dispatchEvent(event);
    }

}
}

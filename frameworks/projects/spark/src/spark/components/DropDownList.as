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

- value property is removed since it is legecy and using selectedItem is preferable

- Do we include these proxy properties (dataRenderer, labelField, labelFunction, rowCount)
- Do we need selectedLabel and itemToLabel (which uses labelField and labelFunction)
- Don't need restrict since we don't support editing
- Don't need dropDownWidth since that is controlled by skin?
- Do we need inline-renderer properties (data, listData)?

Keyboard Interaction
- FxList current dispatches selectionChanged on arrowUp/Down. Should we subclass FxList
and change behavior to commit value only on ENTER, SPACE, or CTRL-UP?

*  

*  @langversion 3.0

*  @playerversion Flash 10

*  @playerversion AIR 1.5

*  @productversion Flex 4

*/

package mx.components
{

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import mx.collections.IList;
import mx.components.baseClasses.DropDownBase;
import mx.components.baseClasses.FxListBase;
import mx.core.IFactory;
import mx.events.IndexChangedEvent;
import mx.graphics.baseClasses.TextGraphicElement;

/**
 *  Dispatched when the FxComboBox contents changes as a result of user
 *  interaction, when the <code>selectedIndex</code> or
 *  <code>selectedItem</code> property changes.
 *
 *  @eventType mx.events.ListEvent.CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Event(name="change", type="flash.events.Event")]

[DefaultProperty("dataProvider")]

/**
 *  FxComboBox control contains a drop-down list
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
public class DropDownList extends DropDownBase
{
	
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
     *  A skin part that is the instance of the dropDown list
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
     
     // TODO (jszeto) We want this to be required. But when the skin part is in a state,
     // it hasn't been created yet and we get an RTE.
	[SkinPart(required="false")]
	public var dropDown:FxListBase;
	
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
	}
	
	//--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
	
	// TODO (jszeto) Add logic to handle the IList changed events
	private var _dataProvider:IList;
	
	/**
	 *  The set of items this component displays.
	 * 
	 *  <p>Setting this property will adjust the <code>selectedIndex</code>
     *  property (and therefore the <code>selectedItem</code> property) if 
     *  the <code>selectedIndex</code> property has not otherwise been set. 
     *  If there is no <code>prompt</code> property, the <code>selectedIndex</code>
     *  property will be set to 0; otherwise it will remain at -1,
     *  the index used for the prompt string.  
     *  If the <code>selectedIndex</code> property has been set and
     *  it is out of range of the new data provider, unexpected behavior is
     *  likely to occur.</p> 
     * 
     *  @default null
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
	public function get dataProvider():IList
	{
		return _dataProvider;
	}
	
	public function set dataProvider(value:IList):void
	{
		if (_dataProvider != value)
		{
			_dataProvider = value;
		}
	}
	
    //----------------------------------
    //  itemRenderer
    //----------------------------------
    
    private var _itemRenderer:IFactory;
    
    /**
     *  @copy mx.components.DataGroup#itemRenderer
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get itemRenderer():IFactory
    {
        return _itemRenderer;
    }
    
    /**
     *  @private
     */
    public function set itemRenderer(value:IFactory):void
    {
        if (value != _itemRenderer)
        {
        	_itemRenderer = value;
        }
    }
    
    //----------------------------------
    //  labelField
    //----------------------------------
   	private var labelFunctionChanged:Boolean;
	private var _labelField:String = ""; 
   
    /**
     *  The name of the field in the data provider items to display as the label.
     
     * @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get labelField():String
    {
    	return _labelField;
    }
    
    public function set labelField(value:String):void
    {
    	if (value != _labelField)
    	{
    		_labelField = value;
    		labelFunctionChanged = true;
    		invalidateProperties();
    	}
    }
    
    //----------------------------------
    //  labelField
    //----------------------------------
    private var _labelFunction:Function; 
    
    /**
     *  A user-supplied function to run on each item to determine its label.
     * 
     *  The method signature for labelFunction should be:
     *  <pre>myLabelFunction(item:Object):String</pre> 
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get labelFunction():Function
    {
    	return _labelFunction;
    }
    
    /**
     *  @private
     */
    public function set labelFunction(value:Function):void
    {
    	if (value != _labelFunction)
    	{
    		_labelFunction = value;
    		labelFunctionChanged = true;
    		invalidateProperties();
    	}
    }

	//----------------------------------
    //  prompt
    //----------------------------------

    private var promptChanged:Boolean = false;
    private var _prompt:String;

    /**
     *  The prompt for the FxComboBox control. A prompt is
     *  a String that is displayed in the TextInput portion of the
     *  FxComboBox when <code>selectedIndex</code> = -1.  It is usually
     *  a String like "Select one...".  If there is no
     *  prompt, the FxComboBox control sets <code>selectedIndex</code> to 0
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
        promptChanged = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  selectedIndex
    //----------------------------------
    
    private var _selectedIndex:int = -1;
    private var selectedIndexChanged:Boolean = true;
    
    [Bindable("change")]
    
     /**
     *  The index in the data provider of the selected item.
     *  If there is a <code>prompt</code> property, the <code>selectedIndex</code>
     *  value can be set to -1 to show the prompt.
     *  If there is no <code>prompt</code>, property then <code>selectedIndex</code>
     *  will be set to 0 once a <code>dataProvider</code> is set.
     *
     *  <p>Unlike many other Flex properties that are invalidating (setting
     *  them does not have an immediate effect), the <code>selectedIndex</code> and
     *  <code>selectedItem</code> properties are synchronous; setting one immediately 
     *  affects the other.</p>
     *
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectedIndex():int
    {
        return _selectedIndex;
    }
    
    public function set selectedIndex(value:int):void
    {
        if (value == _selectedIndex)
            return;
        
        _selectedIndex = value;
        selectedIndexChanged = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  selectedItem
    //----------------------------------

    private var _selectedItem:Object;

	[Bindable("change")]

    /**
     *  The item in the data provider at the selectedIndex.
     *
     *  <p>If the data is an object or class instance, modifying
     *  properties in the object or instance modifies the 
     *  <code>dataProvider</code> object but may not update the views  
     *  unless the instance is Bindable or implements IPropertyChangeNotifier
     *  or a call to dataProvider.itemUpdated() occurs.</p>
     *
     *  Setting the <code>selectedItem</code> property causes the
     *  FxComboBox control to select that item (display it in the text field and
     *  set the <code>selectedIndex</code>) if it exists in the data provider.
     *
     *  <p>Unlike many other Flex properties that are invalidating (setting
     *  them does not have an immediate effect), <code>selectedIndex</code> and
     *  <code>selectedItem</code> are synchronous; setting one immediately 
     *  affects the other.</p>
     *
     *  @default null;
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectedItem():Object
    {
    	// TODO (jszeto) Return _selectedItem first if it hasn't been committed yet
        return dataProvider.getItemAt(selectedIndex);
    }

    /**
     *  @private
     */
    public function set selectedItem(data:Object):void
    {
    	// TODO (jszeto) Tie this in with selectedIndex
        _selectedItem = data;
        invalidateProperties();
    }
    
 	//--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------   
    /**
	 *  @private
	 */
    private function applyDataToLabelElement(data:Object):void
    {
    	// TODO!!! Call FxList.itemToData with labelField, labelFunction and data. 
    	if (labelElement)
    		labelElement.text = data.toString();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
	
	// TODO (jszeto) Add measure implementation that uses the longest string in the data provider as 
    // the label and calls super.measure().
	/**
	 *  @private
	 */ 
	override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (selectedIndexChanged)
        {
            // TODO: Currently hard-coded to require a selection. This should be fixed.
            if (selectedIndex == -1)
            {
                selectedIndex = 0;
            }
            
            if (dataProvider)
                applyDataToLabelElement(dataProvider.getItemAt(selectedIndex));
            selectedIndexChanged = false;
            
            dispatchEvent(new Event("change"));
        }
        
        if (labelFunctionChanged)
        {
        	// TODO!! Update the label element 
        	labelFunctionChanged = false;
        	applyDataToLabelElement(dataProvider.getItemAt(selectedIndex));
        }

    }
    
    /**
	 *  @private
	 */ 
    override protected function initializeDropDown():void
    {
    	super.initializeDropDown();
    	
		dropDown.dataProvider = dataProvider;
		dropDown.selectedIndex = selectedIndex;
		if (itemRenderer)
			dropDown.itemRenderer = itemRenderer;
	
		// TODO!! We force validation because when we set the selectedIndex, 
		// the list doesn't commit the value until it calls commitProperties. 
		// By this time, we are already listening for selection changed events.
		dropDown.validateNow();
	
		// Wait for creationComplete before listening to selectionChanged events from the dropDown. 
		//dropDown.addEventListener("creationComplete", dropDown_creationCompleteHandler);
		dropDown.addEventListener(IndexChangedEvent.SELECTION_CHANGED, dropDown_selectionChangedHandler);
    }
       
    /**
	 *  @private
	 */ 
    override protected function partAdded(partName:String, instance:Object):void
    {
    	super.partAdded(partName, instance);
 
 		if (partName == "dropDown")
 			dropDownInstance = dropDown;
    }
    
    /**
	 *  @private
	 */ 
    override protected function destroyDropDown():void
    {
    	super.destroyDropDown();
    	
    	dropDown.removeEventListener(IndexChangedEvent.SELECTION_CHANGED, dropDown_selectionChangedHandler);
    }
    
    /**
	 *  @private
	 */
    override protected function commitDropDownData():void
    {
    	selectedIndex = dropDown.selectedIndex;
        applyDataToLabelElement(dataProvider.getItemAt(selectedIndex));
    }
    
	override protected function keyDownHandler(event:KeyboardEvent) : void
	{
		if(!enabled)
            return;
            
        if (event.keyCode == Keyboard.ENTER)
        {
            if (isOpen)
            {
            	// Close the dropDown and eat the event
                closeDropDown(true);
                event.stopPropagation();
            }
        }
        else if (event.keyCode == Keyboard.ESCAPE)
        {
            if (isOpen)
            {
            	// Close the dropDown and eat the event
                closeDropDown(false);
                event.stopPropagation();
            }
        }
        else if (event.keyCode == Keyboard.UP ||
                event.keyCode == Keyboard.DOWN ||
                event.keyCode == Keyboard.PAGE_UP ||
                event.keyCode == Keyboard.PAGE_DOWN)
        {
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
		
		// Call super at the end because we might override its functionality 
		super.keyDownHandler(event);
	}
    
    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------
    
    /**
	 *  Called when the dropDown dispatches a selectionChanged event. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
    protected function dropDown_selectionChangedHandler(event:IndexChangedEvent):void
    {
    	//trace("DropDownList.dropDown_selectionChangedHandler [CLOSE]");
        
        closeDropDown(true);
    }
    
    /**
     *  @private
     */  
    /*private function dropDown_creationCompleteHandler(event:FlexEvent):void
    {
    	trace("DropDownList.dropDown_creationCompleteHandler called");
		dropDown.removeEventListener("creationComplete", dropDown_creationCompleteHandler);	
    	dropDown.addEventListener(IndexChangedEvent.SELECTION_CHANGED, dropDown_selectionChangedHandler);
    }*/
	
}
}
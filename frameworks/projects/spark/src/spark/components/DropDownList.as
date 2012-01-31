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

TODO List

- finish collection_changeHandler
- event dispatching
- prompt
- implicitSelectedIndex
- expose List.layout?
- pass styles to dropDown
- propagate List events
- Handle stage resize, focus in/out
- add baseline support
- add enabled/disabled
- Add type assist
- Add typicalItem support for measuredSize (lower priority) 
- Change button to be a ToggleButton so we stay down when dropdown is open

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
import mx.core.mx_internal;
import mx.events.IndexChangedEvent;
import mx.graphics.baseClasses.TextGraphicElement;
import mx.events.CollectionEvent;
import mx.collections.ListCollectionView;
import mx.collections.CursorBookmark;
import mx.events.FlexEvent;
import mx.collections.ICollectionView;
import mx.events.CollectionEventKind;
import mx.collections.IViewCursor;
import mx.utils.LabelUtil;

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
    //  Variables
    //
    //--------------------------------------------------------------------------
	 /**
     *  @private
     *  A flag indicating that selection has changed
     */
    private var selectionChanged:Boolean = false;
    private var labelChanged:Boolean = false;
	private const PAGE_SIZE:int = 5;
	
	//--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
	
	//----------------------------------
    //  collection
    //----------------------------------
	
	/**
     *  The ICollectionView of items this component displays.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var collection:ICollectionView;

	//----------------------------------
    //  dataProvider
    //----------------------------------
	
	// TODO (jszeto) Add logic to handle the IList changed events
	
	private var dataProviderChanged:Boolean = false;
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
			
			if (_dataProvider)
			{
				// TODO (jszeto) Change to match FxList implementation
				collection = new ListCollectionView(IList(value));
				collection.addEventListener(CollectionEvent.COLLECTION_CHANGE, collection_changeHandler, false, 0, true);
				iterator = collection.createCursor();
				dataProviderChanged = true;		
				
				var event:CollectionEvent =
			            new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
		        event.kind = CollectionEventKind.RESET;
		        collection_changeHandler(event);
		  	}
		  	
		  	invalidateProperties();
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
    //  itemRendererFunction
    //----------------------------------
    
    private var _itemRendererFunction:Function;
    
    /**
     *  @copy mx.components.DataGroup#itemRendererFunction
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get itemRendererFunction():Function
    {
        return _itemRendererFunction;
    }
    
    /**
     *  @private
     */
    public function set itemRendererFunction(value:Function):void
    {
        if (value != _itemRendererFunction)
        {
        	_itemRendererFunction = value;
        }
    }
    
    //----------------------------------
    //  iterator
    //----------------------------------
    
    /**
     *  The main IViewCursor used to fetch items from the
     *  dataProvider and pass the items to the renderers.
     *  At the end of any sequence of code, it must always be positioned
     *  at the topmost visible item on screen.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var iterator:IViewCursor;
    
    //----------------------------------
    //  labelField
    //----------------------------------
	private var _labelField:String = "label"; 
   
    /**
     *  The name of the field in the data provider items to display as the label.
     
     * @default "label"
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
    		labelChanged = true;
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
    		labelChanged = true;
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
    private var selectedIndexChanged:Boolean = false;
    
    [Bindable("change")]
    [Bindable("collectionChange")]
    [Bindable("valueCommit")]
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
    
    /**
     *  @private
     */  
    public function set selectedIndex(value:int):void
    {
    	// TODO (jszeto) Change selectedIndex/Item to match FxListBase implementation
    	// We want the selectedIndex to be committed as soon as possible. 
    	// If we have a collection, then update the selectedIndex
    	 
    	_selectedIndex = value;
    	if (value == -1)
        {
            _selectedItem = null;
        }
    	
    	//2 code paths: one for before collection, one after
        if (!collection || collection.length == 0)
        {
            selectedIndexChanged = true;
            invalidateProperties();
        }
        else
        {
            if (value != -1)
            {
                value = Math.min(value, collection.length - 1);
                var bookmark:CursorBookmark = iterator.bookmark;
                var len:int = value;
                iterator.seek(CursorBookmark.FIRST, len);
                var data:Object = iterator.current;
                iterator.seek(bookmark, 0);
                _selectedIndex = value;
                _selectedItem = data;
                labelChanged = true;
                invalidateProperties();
            }
        }
        
        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }
    
    //----------------------------------
    //  selectedItem
    //----------------------------------

	private var selectedItemChanged:Boolean = false;

    private var _selectedItem:Object;

	[Bindable("change")]
    [Bindable("collectionChange")]
    [Bindable("valueCommit")]
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
        return _selectedItem;
    }

    /**
     *  @private
     */
    public function set selectedItem(data:Object):void
    {	
        //2 code paths: one for before collection, one after
        if (!collection || collection.length == 0)
        {
          	_selectedItem = data;
            selectedItemChanged = true;
            invalidateProperties();
        }
		else
		{
	        var found:Boolean = false;
	        var listCursor:IViewCursor = collection.createCursor();
	        var i:int = 0;
	        do
	        {
	            if (data == listCursor.current)
	            {
	                _selectedIndex = i;
	                _selectedItem = data;
	                selectionChanged = true;
	                found = true;
	                break;
	            }
	            i++;
	        }
	        while (listCursor.moveNext());
	
	        if (!found)
	        {
	            selectedIndex = -1;
	            _selectedItem = null;
	        }
	        
	        labelChanged = true;
	        invalidateProperties();
		}        
    }
    
 	//--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------   

    
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
        
		if (selectedItemChanged)
        {
        	// Retry applying the value in case the dataProvider is set
            selectedItem = selectedItem;
            selectedItemChanged = false;
            selectedIndexChanged = false;
        }

        if (selectedIndexChanged)
        {
        	// Retry applying the value in case the dataProvider is set
            selectedIndex = selectedIndex;
            selectedIndexChanged = false;
        }   
        
        if (labelChanged)
		{
			labelChanged = false;
			if (labelElement)
	    	{
	    		if (selectedItem)
	    			labelElement.text = LabelUtil.itemToLabel(selectedItem, labelField, labelFunction);
	    		else
	    			labelElement.text = "";
	    	}
		}
        
        // TODO (jszeto) Add call to valueCommit after selection changed

    }
                                                
    
    /**
	 *  @private
	 */ 
    override protected function initializeDropDown():void
    {
    	super.initializeDropDown();
    	
    	// TODO (jszeto) Look at FxDataContainer to see pattern for passing
    	// these values
		dropDown.dataProvider = dataProvider;
		dropDown.selectedIndex = selectedIndex;
		dropDown.labelField = labelField;
		dropDown.labelFunction = labelFunction;
		
		if (itemRenderer != null)
			dropDown.itemRenderer = itemRenderer;
	
		if (itemRendererFunction != null)
			dropDown.itemRendererFunction = itemRendererFunction;
	
		// TODO!! We force validation because when we set the selectedIndex, 
		// the list doesn't commit the value until it calls commitProperties. 
		// By this time, we are already listening for selection changed events.
		//dropDown.validateNow();
		/*dropDown.validateProperties();
		dropDown.validateSize();*/
	
		// Wait for creationComplete before listening to selectionChanged events from the dropDown. 
		//dropDown.addEventListener("creationComplete", dropDown_creationCompleteHandler);
		//dropDown.addEventListener(IndexChangedEvent.SELECTION_CHANGED, dropDown_selectionChangedHandler);
    }
    
    /**
     *  @private 
     */ 
    override protected function addListenersToDropDown():void
    {
    	dropDown.addEventListener(IndexChangedEvent.SELECTION_CHANGED, dropDown_selectionChangedHandler);
    }
       
    /**
	 *  @private
	 */ 
    override protected function partAdded(partName:String, instance:Object):void
    {
    	super.partAdded(partName, instance);
 
 		if (instance == dropDown)
 			dropDownInstance = dropDown;
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == dropDown)
    	{
    		dropDownInstance = null;
    	}
        
        super.partRemoved(partName, instance);
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
    	if (dropDown.selectedIndex != selectedIndex)
    	{
    		selectedIndex = dropDown.selectedIndex;
    		dispatchEvent(new Event(Event.CHANGE));
    	}
    }
        
    /**
	 *  @private
	 */
	override protected function keyDownHandler(event:KeyboardEvent) : void
	{

		//trace("DropDownList.keyDownHandler key",event.keyCode);
		if(!enabled)
            return;

		super.keyDownHandler(event);
        
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
        else if (event.keyCode == Keyboard.UP ||
                event.keyCode == Keyboard.DOWN ||
                event.keyCode == Keyboard.LEFT ||
                event.keyCode == Keyboard.RIGHT ||
                event.keyCode == Keyboard.PAGE_UP ||
                event.keyCode == Keyboard.PAGE_DOWN)
        {
        	//trace("DropDownList.keyDownHandler arrow key isOpen",isOpen);
        	
        	if (isOpen)
        	{
        		// TODO (jszeto) Clean this up once we have FxList support for 
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
        	}
        	
        	
        	
        	
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
	 *  Called when the dataProvider changes 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
    protected function collection_changeHandler(event:CollectionEvent):void
    {
    	// TODO (jszeto) Change this to use FxListBase implementation
    	
        var requiresValueCommit:Boolean = false;

        if (event.kind == CollectionEventKind.ADD)
        {
        	// Don't send a value commit. selectedItem remains the same
            if (selectedIndex >= event.location)
                _selectedIndex++;
        }
        else if (event.kind == CollectionEventKind.REMOVE)
        {
            for (var i:int = 0; i < event.items.length; i++)
            {
            	// TODO (jszeto) Do we need to use UID instead?
                //var uid:String = itemToUID(ce.items[i]);
                if (selectedItem == event.items[i])
                {
                    selectionChanged = true;
                }
            }
            if (selectionChanged)
            {
                if (_selectedIndex >= collection.length)
                    _selectedIndex = collection.length - 1;

                selectedIndexChanged = true;
                requiresValueCommit = true;
                invalidateProperties();
            }
            else if (selectedIndex >= event.location)
            {
                _selectedIndex--;
                selectedIndexChanged = true;
                requiresValueCommit = true;
                invalidateProperties();
            }
        
        }
        else if (event.kind == CollectionEventKind.REFRESH)
        {
            selectedItemChanged = true;
            // Sorting always changes the selection array
            requiresValueCommit = true;
            invalidateProperties();
        }
        else if (event.kind == CollectionEventKind.UPDATE)
        {
            if (event.location == selectedIndex ||
                event.items[0].source == selectedItem)
            {
            	selectedItem = event.items[0].source;
            }
        }
        else if (event.kind == CollectionEventKind.RESET)
        {
           /* collectionChanged = true;
            if (!selectedIndexChanged && !selectedItemChanged)
                selectedIndex = prompt ? -1 : 0;
            invalidateProperties();*/
            if (!selectedIndexChanged && !selectedItemChanged)
            	selectedIndex = 0;
        }
        
        if (requiresValueCommit)
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
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
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
- List current dispatches change on arrowUp/Down. Should we subclass List
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

import mx.collections.IList;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.FlexEvent;

import spark.components.supportClasses.ButtonBase;
import spark.components.supportClasses.DropDownController;
import spark.core.NavigationUnit;
import spark.events.DropDownEvent;
import spark.components.supportClasses.TextBase;
import spark.utils.LabelUtil;

use namespace mx_internal;

use namespace mx_internal;

/**
 *  Dispatched when the drop-down list closes for any reason, such when 
 *  the user:
 *  <ul>
 *      <li>Selects an item in the drop-down list.</li>
 *      <li>Clicks outside of the drop-down list.</li>
 *      <li>Clicks the anchor button while the drop-down list is 
 *  displayed.</li>
 *  </ul>
 *
 *  @eventType spark.events.DropDownEvent.CLOSE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="close", type="spark.events.DropDownEvent")]

/**
 *  Dispatched when the user clicks the anchor button
 *  to display the drop-down list.  
 *  It is also dispatched if the user
 *  uses Control-Down to open the dropDown.
 *
 *  @eventType spark.events.DropDownEvent.OPEN
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="open", type="spark.events.DropDownEvent")]

/**
 *  Skin state for the open state of the DropDownList control.
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
 *  The DropDownList control contains a drop-down list
 *  from which the user can select a single value.
 *  Its functionality is very similar to that of the
 *  SELECT form element in HTML.
 *
 *  <p>The DropDownList control consists of the anchor button, 
 *  prompt area, and drop-down-list, 
 *  Use the anchor button to open and close the drop-down-list. 
 *  The prompt area displays a prompt String, or the selected item 
 *  in the drop-down-list.</p>
 *
 *  <p>When the drop-down list is open:</p>
 *  <ul>
 *    <li>Clicking the anchor button closes the drop-down list 
 *      and commits the currently selected data item.</li>
 *    <li>Clicking outside of the drop-down list closes the drop-down list 
 *      and commits the currently selected data item.</li>
 *    <li>Clicking on a data item selects that item and closes the drop-down list.</li>
 *    <li>If the <code>requireSelection</code> property is <code>false</code>, 
 *      clicking on a data item while pressing the Control key deselects 
 *      the item and closes the drop-down list.</li>
 *  </ul>
 *
 *  @mxml <p>The <code>&lt;s:DropDownList&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:DropDownList 
 *    <strong>Properties</strong>
 *    prompt=""
 * 
 *    <strong>Events</strong>
 *    closed="<i>No default</i>"
 *    open="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.skins.spark.DropDownListSkin
 *  @see spark.components.supportClasses.DropDownController
 *
 *  @includeExample examples/DropDownListExample.mxml
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
     *  An optional skin part that holds the prompt or the text of the selected item. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart(required="false")]
    public var labelDisplay:TextBase;
    
    /**
     *  A skin part that defines the drop-down list area. When the DropDownList is open,
     *  clicking anywhere outside of the dropDown skin part closes the   
     *  drop-down list. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart(required="false")]
    public var dropDown:DisplayObject;
    
    /**
     *  A skin part that defines the anchor button.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart(required="true")]
    public var openButton:ButtonBase;
        
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
        
        dropDownController = new DropDownController();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private var labelChanged:Boolean = false;
    // Stores the user selected index until the dropDown closes
    mx_internal var userProposedSelectedIndex:Number = -1;
    mx_internal static var PAGE_SIZE:int = 5;
    
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
     *  Instance of the DropDownController class that handles all of the mouse, keyboard 
     *  and focus user interactions. 
     * 
     *  Flex calls the <code>initializeDropDownController()</code> method after 
     *  the DropDownController instance is created in the constructor.
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
    
    protected function set dropDownController(value:DropDownController):void
    {
        if (_dropDownController == value)
            return;
            
        _dropDownController = value;
            
        _dropDownController.addEventListener(DropDownEvent.OPEN, dropDownController_openHandler);
        _dropDownController.addEventListener(DropDownEvent.CLOSE, dropDownController_closeHandler);
            
        if (openButton)
            _dropDownController.openButton = openButton;
        if (dropDown)
            _dropDownController.dropDown = dropDown;    
    }
    
    //----------------------------------
    //  isDropDownOpen
    //----------------------------------
    
    /**
     *  @copy spark.components.supportClasses.DropDownController#isOpen
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get isDropDownOpen():Boolean
    {
        if (dropDownController)
            return dropDownController.isOpen;
        else
            return false;
    }

    //----------------------------------
    //  prompt
    //----------------------------------

    private var _prompt:String = "";

    /**
     *  The prompt for the DropDownList control. 
     *  The prompt is a String that is displayed in the
     *  DropDownList when <code>selectedIndex</code> = -1.  
     *  It is usually a String such as "Select one...". 
     *  Selecting an item in the drop-down list replaces the 
     *  prompt with the text from the selected item.
     *  
     *  @default ""
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
        // Don't allow this value to be set. If the multiple
        // selection related properties are set and 
        // allowMultipleSelection is false, List will
        // select the first item passed in. 
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
        if (openButton)
            return openButton.baselinePosition;
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
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------   

    /**
     *  Open the drop-down list and dispatch 
     *  a <code>DropdownEvent.OPEN</code> event.
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
     *  Close the drop-down list and dispatch a <code>DropDownEvent.CLOSE</code> event. 
     *   
     *  @param commit If <code>true</code>, commit the selected
     *  data item. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function closeDropDown(commit:Boolean):void
    {
        dropDownController.closeDropDown(commit);
    }
    
    /**
     *  @private
     *  Called whenever we need to update the text passed to the labelDisplay skin part
     */
    // TODO (jszeto): Make this protected and make the name more generic (passing data to skin) 
    mx_internal function updateLabelDisplay():void
    {
        if (labelDisplay)
        {
            if (selectedItem != null && selectedItem != undefined)
                labelDisplay.text = LabelUtil.itemToLabel(selectedItem, labelField, labelFunction);
            else
                labelDisplay.text = prompt;
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
    override protected function commitSelection(dispatchChangedEvents:Boolean = true):Boolean
    {
        var retVal:Boolean = super.commitSelection(dispatchChangedEvents);
        updateLabelDisplay();
        return retVal; 
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
            updateLabelDisplay();
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
 
        if (instance == openButton)
        {
            if (dropDownController)
                dropDownController.openButton = openButton;
        }
        
        if (instance == labelDisplay)
        {
            labelChanged = true;
            invalidateProperties();
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
            if (instance == openButton)
                dropDownController.openButton = null;
        
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
        userProposedSelectedIndex = selectedIndex;
        closeDropDown(true);
    }
            
    /**
     *  @private
     */
    override protected function keyDownHandler(event:KeyboardEvent) : void
    {
        if(!enabled)
            return; 
        
        if (!dropDownController.processKeyDown(event))
        {
            var navigationUnit:uint = event.keyCode;
            if (!NavigationUnit.isNavigationUnit(navigationUnit))
                return;

            var proposedNewIndex:int = -1;
            
            if (dropDownController.isOpen)
            {   
                proposedNewIndex = layout.getNavigationDestinationIndex(userProposedSelectedIndex, navigationUnit, arrowKeysWrapFocus);
                
                if (proposedNewIndex != -1)
                {
                    // Store the selection in userProposedSelectedIndex because we 
                    // don't want to update selectedIndex until the dropdown closes
                    itemSelected(userProposedSelectedIndex, false);
                    userProposedSelectedIndex = proposedNewIndex;
                    itemSelected(userProposedSelectedIndex, true);
                    ensureIndexIsVisible(userProposedSelectedIndex);
                }
            }
            else if (dataProvider)
            {
                switch (navigationUnit)
                {
                    case NavigationUnit.UP:
                       proposedNewIndex = selectedIndex - 1;  
                       break;
        
                    case NavigationUnit.DOWN: 
                       proposedNewIndex = selectedIndex + 1;  
                       break;
                     
                    case NavigationUnit.PAGE_UP:
                       proposedNewIndex = selectedIndex == -1 ? 
                                            -1 : Math.max(selectedIndex - PAGE_SIZE, 0);  
                       break;
                    
                    case NavigationUnit.PAGE_DOWN:
                       proposedNewIndex = selectedIndex + PAGE_SIZE;  
                       break;
                       
                    case NavigationUnit.HOME:
                       proposedNewIndex = 0;  
                       break;

                    case NavigationUnit.END:
                       proposedNewIndex = dataProvider.length - 1;  
                       break;
                       
                       
                }
                
                proposedNewIndex = Math.min(proposedNewIndex, dataProvider.length - 1);
                
                if (proposedNewIndex >= 0)
                    selectedIndex = proposedNewIndex;
            }
        }

    }
    
    /**
     *  @private
     */
    override protected function focusOutHandler(event:FocusEvent):void
    {
        if (event.target == this)
            dropDownController.processFocusOut(event);

        super.focusOutHandler(event);
    }
    
    /**
     *  @private
     *  In updateRenderer, we want to select the proposedSelectedIndex
     */
    override mx_internal function isItemIndexSelected(index:int):Boolean
    {
        return userProposedSelectedIndex == index;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Event handler for the <code>dropDownController</code> 
     *  <code>DropDownEvent.OPEN</code> event. Updates the skin's state and 
     *  ensures that the selectedItem is visible. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal function dropDownController_openHandler(event:DropDownEvent):void
    {
        addEventListener(FlexEvent.UPDATE_COMPLETE, open_updateCompleteHandler);
        userProposedSelectedIndex = selectedIndex;
        invalidateSkinState();  
    }
    
    /**
     *  @private
     */
    mx_internal function open_updateCompleteHandler(event:FlexEvent):void
    {   
        removeEventListener(FlexEvent.UPDATE_COMPLETE, open_updateCompleteHandler);
        ensureIndexIsVisible(selectedIndex);
        
        dispatchEvent(new DropDownEvent(DropDownEvent.OPEN));
    }
    
    /**
     *  @private
     *  Event handler for the <code>dropDownController</code> 
     *  <code>DropDownEvent.CLOSE</code> event. Updates the skin's state.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function dropDownController_closeHandler(event:DropDownEvent):void
    {
        addEventListener(FlexEvent.UPDATE_COMPLETE, close_updateCompleteHandler);
        invalidateSkinState();
        
        if (!event.isDefaultPrevented())
        {
            selectedIndex = userProposedSelectedIndex;  
        }
    }

    /**
     *  @private
     */
    private function close_updateCompleteHandler(event:FlexEvent):void
    {   
        removeEventListener(FlexEvent.UPDATE_COMPLETE, close_updateCompleteHandler);
        
        dispatchEvent(new DropDownEvent(DropDownEvent.CLOSE));
    }
    
}
}

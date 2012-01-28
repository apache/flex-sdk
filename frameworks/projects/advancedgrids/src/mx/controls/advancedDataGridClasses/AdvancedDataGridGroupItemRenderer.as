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

package mx.controls.advancedDataGridClasses
{

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.getDefinitionByName;

import mx.controls.AdvancedDataGrid;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.core.IDataRenderer;
import mx.core.IFlexDisplayObject;
import mx.core.IFlexModuleFactory;
import mx.core.IFontContextComponent;
import mx.core.ILayoutDirectionElement;
import mx.core.IToolTip;
import mx.core.IUITextField;
import mx.core.SpriteAsset;
import mx.core.UIComponent;
import mx.core.UITextField;
import mx.core.mx_internal;
import mx.events.AdvancedDataGridEvent;
import mx.events.FlexEvent;
import mx.events.ToolTipEvent;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the <code>data</code> property changes.
 *
 *  <p>When you use a component as an item renderer,
 *  the <code>data</code> property contains the data to display.
 *  You can listen for this event and update the component
 *  when the <code>data</code> property changes.</p>
 * 
 *  @eventType mx.events.FlexEvent.DATA_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  Text color of a component label.
 *  The default value is <code>0x0B333C</code>.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="color", type="uint", format="Color", inherit="yes")]

/**
 *  Color of the component if it is disabled.
 *  The default value is <code>0xAAB3B3</code>.
 *
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="disabledColor", type="uint", format="Color", inherit="yes")]

/**
 *  The AdvancedDataGridGroupItemRenderer class defines the default item renderer for  
 *  the nodes of the navigation tree.
 *  By default, the item renderer draws the text associated with each node in the tree, 
 *  an optional icon, and an optional disclosure icon.
 *
 *  <p>You can override the default item renderer by creating a custom item renderer.</p>
 *
 *  @see mx.controls.AdvancedDataGrid
 *  @see mx.core.IDataRenderer
 *  @see mx.controls.listClasses.IDropInListItemRenderer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class AdvancedDataGridGroupItemRenderer extends UIComponent
       implements IDataRenderer, IDropInListItemRenderer, IListItemRenderer,
                  IFontContextComponent
{
    include "../../core/Version.as";   
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function AdvancedDataGridGroupItemRenderer()
    {
        super();
        
        // InteractiveObject variables.
        mouseEnabled = false;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var listOwner:AdvancedDataGrid;
    
    /**
     *  The internal IFlexDisplayObject that displays the icon in this renderer.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var icon:IFlexDisplayObject;

    /**
     *  The internal UITextField that displays the text in this renderer.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var label:IUITextField;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  data
    //----------------------------------

    /**
     *  @private
     *  Storage for the data property.
     */
    private var _data:Object;

    [Bindable("dataChange")]

    /**
     *  The implementation of the <code>data</code> property as 
     *  defined by the IDataRenderer interface.
     *
     *  @see mx.core.IDataRenderer
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get data():Object
    {
        return _data;
    }

    /**
     *  @private
     */
    public function set data(value:Object):void
    {
        _data = value;
        
        invalidateProperties();

        dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
    }
    
    //----------------------------------
    //  disclosureIcon
    //----------------------------------

    /**
     *  The internal IFlexDisplayObject that displays the disclosure icon
     *  in this renderer.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var disclosureIcon:IFlexDisplayObject;
    
    //----------------------------------
    //  fontContext
    //----------------------------------
    
    /**
    * @private
    */
    public function get fontContext():IFlexModuleFactory
    {
        return moduleFactory;
    }

    /**
    * @private
    */
    public function set fontContext(moduleFactory:IFlexModuleFactory):void
    {
        this.moduleFactory = moduleFactory;
    }
    
    //----------------------------------
    //  listData
    //----------------------------------

    /**
     *  @private
     *  Storage for the listData property.
     */
    private var _listData:AdvancedDataGridListData;

    [Bindable("dataChange")]

    /**
     *  The implementation of the <code>listData</code> property as 
     *  defined by the IDropInListItemRenderer interface.
     *
     *  @see mx.controls.listClasses.IDropInListItemRenderer
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get listData():BaseListData
    {
        return _listData;
    }

    /**
     *  @private
     */
    public function set listData(value:BaseListData):void
    {
        _listData = AdvancedDataGridListData(value);
        
        invalidateProperties();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();

        createLabel(-1);

        addEventListener(ToolTipEvent.TOOL_TIP_SHOW, toolTipShowHandler);
    }

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        // if the font changed and we already created the label, we will need to 
        // destory it so it can be re-created, possibly in a different swf context.
        if (hasFontContextChanged() && label != null)
        {
            var index:int = getChildIndex(DisplayObject(label));
            removeLabel();
            createLabel(index);
        }
        
        // we need to save the x values,
        // when containers are used as item renderers then there
        // might be a delay between the call to commitProperties() and
        // updateDisplayList(). The icons will shift to the left during that time.
        // positioning them again will avoid the shifting.
        var oldIconX:Number;
        var oldDisclosureIconX:Number;

        if (icon)
        {
            // save the x position
            oldIconX = icon.x;
            removeChild(DisplayObject(icon));
            icon = null;
        }

        if (disclosureIcon)
        {
            // save the x position
            oldDisclosureIconX = disclosureIcon.x;
            disclosureIcon.removeEventListener(MouseEvent.MOUSE_DOWN, 
                                               disclosureMouseDownHandler);
            removeChild(DisplayObject(disclosureIcon));
            disclosureIcon = null;
        }

        if (_data != null)
        {
            listOwner = AdvancedDataGrid(_listData.owner);
            
            var column:AdvancedDataGridColumn =
                listOwner.columns[_listData.columnIndex];

            if (_listData.disclosureIcon)
            {
                var disclosureIconClass:Class = _listData.disclosureIcon;
                var disclosureInstance:* = new disclosureIconClass();
                
                // If not already an interactive object, then we'll wrap 
                // in one so we can dispatch mouse events.
                if (!(disclosureInstance is InteractiveObject))
                {
                    var wrapper:SpriteAsset = new SpriteAsset();
                    wrapper.addChild(disclosureInstance as DisplayObject);
                    disclosureIcon = wrapper as IFlexDisplayObject;
                }
                else
                {
                    disclosureIcon = disclosureInstance;
                }
				
				// Let the disclosureIcon inherit the layoutDirection
				if (disclosureIcon is ILayoutDirectionElement)
					ILayoutDirectionElement(disclosureIcon).layoutDirection = null;
				

                addChild(disclosureIcon as DisplayObject);
                // set the x position
                if (oldDisclosureIconX)
                    disclosureIcon.x = oldDisclosureIconX;
                
                disclosureIcon.addEventListener(MouseEvent.MOUSE_DOWN,
                                                disclosureMouseDownHandler);
            }
            
            if (_listData.icon)
            {
                var iconClass:Class = _listData.icon;
                icon = new iconClass();

                addChild(DisplayObject(icon));
                // set the x position
                if (oldIconX)
                    icon.x = oldIconX;
            }
            
            label.text = _listData.label;
            label.multiline = listOwner.variableRowHeight;
            label.wordWrap = listOwner.columnWordWrap(column);
            
             var dataTips:Boolean = listOwner.showDataTips;
             if (column.showDataTips == true)
             	dataTips = true;
             if (column.showDataTips == false)
                dataTips = false;
            if (dataTips)
            {
                if (!(_data is AdvancedDataGridColumn) && (label.textWidth > label.width
                	|| column.dataTipFunction || column.dataTipField 
                    || listOwner.dataTipFunction || listOwner.dataTipField))
                {
                    toolTip = column.itemToDataTip(_data);
                }
                else
                {
                    toolTip = null;
                }
            }
            else
            {
                toolTip = null;
            }
        }
        else
        {
            label.text = " ";
            toolTip = null;
        }

        invalidateDisplayList();
    }

    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();

        var w:Number = _data ? _listData.indent : 0;

        if (disclosureIcon)
            w += disclosureIcon.width;

        if (icon)
            w += icon.measuredWidth;

        // guarantee that label width isn't zero because it messes up ability to measure
        if (label.width < 4 || label.height < 4)
        {
            label.width = 4;
            label.height = 16;
        }

        if (isNaN(explicitWidth))
        {
            w += label.getExplicitOrMeasuredWidth();    
            measuredWidth = w;
        }
        else
        {
            label.width = Math.max(explicitWidth - w, 4);
        }
        
        measuredHeight = label.getExplicitOrMeasuredHeight();
        if (icon && icon.measuredHeight > measuredHeight)
            measuredHeight = icon.measuredHeight;
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        var startx:Number = _data ? _listData.indent : 0;
        
        if (disclosureIcon)
        {
            disclosureIcon.x = startx;

            startx = disclosureIcon.x + disclosureIcon.width;
            
            disclosureIcon.setActualSize(disclosureIcon.width,
                                         disclosureIcon.height);
            
            disclosureIcon.visible = _data ?
                                     _listData.hasChildren :
                                     false;
            
            // dont display disclosure icon if the column width is 
            // less than the start of the disclosure icon's x
            if(disclosureIcon.visible)
                disclosureIcon.visible = startx < unscaledWidth;
        }
        
        if (icon)
        {
            icon.x = startx;
            startx = icon.x + icon.measuredWidth;
            icon.setActualSize(icon.measuredWidth, icon.measuredHeight);            
            
            // dont display icon if the column width is less then the start of the icon's x
            // else set the width of the item according to column's width
            if (icon.x > unscaledWidth)
            {
                icon.visible = false;
            }
            else if (startx > unscaledWidth)
            {
                icon.setActualSize(unscaledWidth - icon.x, icon.measuredHeight);
            }
        }
        
        label.x = startx;
        label.setActualSize(unscaledWidth - startx, unscaledHeight);

        var verticalAlign:String = getStyle("verticalAlign");
        if (verticalAlign == "top")
        {
            label.y = 0;
            if (icon)
                icon.y = 0;
            if (disclosureIcon)
                disclosureIcon.y = 0;
        }
        else if (verticalAlign == "bottom")
        {
            label.y = unscaledHeight - label.height + 2; // 2 for gutter
            if (icon)
                icon.y = unscaledHeight - icon.height;
            if (disclosureIcon)
                disclosureIcon.y = unscaledHeight - disclosureIcon.height;
        }
        else
        {
            label.y = (unscaledHeight - label.height) / 2;
            if (icon)
                icon.y = (unscaledHeight - icon.height) / 2;
            if (disclosureIcon)
                disclosureIcon.y = (unscaledHeight - disclosureIcon.height) / 2;
        }

        var labelColor:Number;

        if (data && parent)
        {
            if (!enabled)
                labelColor = getStyle("disabledColor");
            else if (listOwner.isItemHighlighted(listData.uid))
                labelColor = getStyle("textRollOverColor");
            else if (listOwner.isItemSelected(listData.uid))
                labelColor = getStyle("textSelectedColor");
            else
                labelColor = getStyle("color");

            label.setColor(labelColor);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
    * @private
    * 
    * Create the label child and add it as a child of this component.
    * 
    * @param childIndex index of where to add the child. If -1, the text field is
    *                  appended to the end of the list.
    */
    protected function createLabel(childIndex:int):void
    {
        if (!label)
        {
            label = IUITextField(createInFontContext(UITextField));
            label.styleName = this;
            
            if (childIndex == -1)
                addChild(DisplayObject(label));
            else 
                addChildAt(DisplayObject(label), childIndex);
        }
    }

    /**
    * @private
    * 
    * Remove the label from this component.
    */
    protected function removeLabel():void
    {
        if (label != null)
        {
            removeChild(DisplayObject(label));
            label = null;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function toolTipShowHandler(event:ToolTipEvent):void
    {            
        var toolTip:IToolTip = event.toolTip;
		var xPos:int = DisplayObject(systemManager).mouseX + 11;
        var yPos:int = DisplayObject(systemManager).mouseY + 22;
        // Calculate global position of label.
        var pt:Point = new Point(xPos, yPos);
        pt = DisplayObject(systemManager).localToGlobal(pt);
        pt = DisplayObject(systemManager.getSandboxRoot()).globalToLocal(pt);           
        
        toolTip.move(pt.x, pt.y + (height - toolTip.height) / 2);
            
        var screen:Rectangle = toolTip.screen;
        var screenRight:Number = screen.x + screen.width;
        if (toolTip.x + toolTip.width > screenRight)
            toolTip.move(screenRight - toolTip.width, toolTip.y);
    }

    /**
     *  @private
     */
    private function disclosureMouseDownHandler(event:Event):void
    {
        event.stopPropagation();
        
        if (listOwner.isOpening || !listOwner.enabled)
            return;

        var open:Boolean = _listData.open;
        _listData.open = !open;
        
        listOwner.dispatchAdvancedDataGridEvent(AdvancedDataGridEvent.ITEM_OPENING,
                                _listData.item, //item
                                this,   //renderer
                                event,  //trigger
                                !open,  //opening
                                true,   //animate
                                true)   //dispatch
    }
    
    /**
     *  @private
     */
    mx_internal function getLabel():IUITextField
    {
        return label;
    }
    
    /**
     *  @private
     */
    mx_internal function getDisclosureIcon():IFlexDisplayObject
    {
        return disclosureIcon;
    }
}

}
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

package mx.controls.olapDataGridClasses
{

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.getDefinitionByName;

import mx.controls.OLAPDataGrid;
import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.core.IDataRenderer;
import mx.core.IFlexDisplayObject;
import mx.core.IToolTip;
import mx.core.SpriteAsset;
import mx.core.UIComponent;
import mx.core.IUITextField;
import mx.core.UITextField;
import mx.events.FlexEvent;
import mx.events.ToolTipEvent;

import mx.olap.IOLAPAxisPosition;
import mx.olap.IOLAPMember;

import mx.core.mx_internal;

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
 *  Color of the component if it is disabled.
 *  The default value is <code>0xAAB3B3</code>.
 *
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="horizontalAlign", type="String", inherit="no")]


/**
 *  The OLAPDataGridGroupRenderer class defines the default item renderer for a group renderer for
 *  the OLAPDataGrid control. An instance of this class is the default value of the
 *  <code>OLAPDataGrid.groupItemRenderer</code> property.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPDataGridGroupRenderer extends UIComponent
       implements IDataRenderer, IDropInListItemRenderer, IListItemRenderer
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
    public function OLAPDataGridGroupRenderer()
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
    private var listOwner:OLAPDataGrid;

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
    //  label
    //----------------------------------

    /**
     *  The internal UITextField that displays the text in this renderer.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var label:IUITextField;
    
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

        if (!label)
        {
            label = IUITextField(createInFontContext(UITextField));
            label.styleName = this;
            addChild(DisplayObject(label));
        }

        addEventListener(ToolTipEvent.TOOL_TIP_SHOW, toolTipShowHandler);
    }

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();

        if (_data)
        {
            listOwner = OLAPDataGrid(_listData.owner);

            label.text = _listData.label;
            label.multiline = listOwner.variableRowHeight;
            label.wordWrap = listOwner.wordWrap;
            
            if (_data is AdvancedDataGridColumn)
                label.wordWrap = listOwner.columnHeaderWordWrap(_data as AdvancedDataGridColumn);
            else
                label.wordWrap = listOwner.rowHeaderWordWrap(_data.members[_listData.columnIndex] as IOLAPMember);

            label.multiline = listOwner.variableRowHeight;
            
            if (listOwner.showDataTips)
            {
                if (label.textWidth > label.width ||
                    listOwner.dataTipFunction != null)
                {
                    toolTip = listOwner.itemToDataTip(_data);
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
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        var startx:Number = _data ? _listData.indent : 0;
        
        var horizontalAlign:String = getStyle("horizontalAlign");
        if (horizontalAlign == "left")
        {
            label.x = startx;
        }
        else if (horizontalAlign == "right")
        {
            label.x = unscaledWidth - label.width + 2; // 2 for gutter
        }
        else
        {
            label.x = (unscaledHeight - label.height) / 2 + startx;
        }
        label.setActualSize(unscaledWidth - label.x, unscaledHeight);

		//label.x = startx;

        var verticalAlign:String = getStyle("verticalAlign");
        if (verticalAlign == "top")
        {
            label.y = 0;
        }
        else if (verticalAlign == "bottom")
        {
            label.y = unscaledHeight - label.height + 2; // 2 for gutter
        }
        else
        {
            label.y = (unscaledHeight - label.height) / 2;
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
     *  @private
     */
    mx_internal function getLabel():IUITextField
    {
        return label;
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
}

}
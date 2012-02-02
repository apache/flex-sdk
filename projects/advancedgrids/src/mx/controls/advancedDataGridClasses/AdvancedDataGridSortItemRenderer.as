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
import flash.text.TextLineMetrics;
import mx.controls.AdvancedDataGrid;
import mx.controls.advancedDataGridClasses.SortInfo;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.core.IUIComponent;
import mx.core.IUITextField;
import mx.core.UIComponent;
import mx.core.UITextField;
import mx.core.IFlexDisplayObject;
import mx.styles.ISimpleStyleClient;

import mx.core.mx_internal;
use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../../styles/metadata/PaddingStyles.as";

/**
 *  Gap between the label and icon, in pixels.
 *
 *  @default 2
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="horizontalGap", type="Number", format="Length", inherit="no")]

/**
 *  Number of pixels between the column header's bottom border
 *  and the bottom of the sort item renderer.
 *
 *  @default 3
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]

/**
 *  Number of pixels between the column header's top border
 *  and the top of the sort item renderer.
 *
 *  @default 3
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="paddingTop", type="Number", format="Length", inherit="no")]

/**
 *
 * Color of text when the sort is a proposed sort.
 *
 * @default 0x999999
 *
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="proposedColor", type="uint", format="Color", inherit="yes")]

//--------------------------------------
//  Skins
//--------------------------------------

/**
 *  The class to use as the skin for the arrow that indicates the column sort
 *  direction.
 * 
 *  <p>The default skin class is based on the theme. For example, with the Halo theme,
 *  the default skin class is <code>mx.skins.halo.DataGridSortArrow</code>. For the Spark theme, the default skin
 *  class is <code>mx.skins.spark.DataGridSortArrow</code>.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="icon", type="Class", inherit="no")]

/** 
 *  The AdvancedDataGridSortItemRenderer class defines the item renderer for 
 *  the sort icon and text field in the column header of the AdvancedDataGrid control.
 *  A sort item contains a text field to display the sort number when sorting by multiple columns, 
 *  and uses the mx.skins.halo.DataGridSortArrow skin class to display the sort arrow graphic.
 *
 *  <p> You can override the default sort item renderer by creating a custom
 *  sort item renderer. 
 *  There are no special requirements for the sort item renderer, but Adobe 
 *  suggests that the sort item renderer call the <code>getFieldSortInfo()</code> method  
 *  in the override of the <code>commitProperties()</code> method 
 *  to fetch the sort information so that it can display the icon and text appropriately. </p>
 *
 *  <p> You can customize when the sorting gets triggered by dispatching the
 *  <code>AdvancedDataGridEvent.SORT</code> event. </p>
 *
 *  @see mx.controls.AdvancedDataGrid
 *  @see mx.controls.advancedDataGridClasses.SortInfo
 *  @see mx.skins.halo.DataGridSortArrow
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class AdvancedDataGridSortItemRenderer extends UIComponent
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
    public function AdvancedDataGridSortItemRenderer()
    {
        super();
        visible = false;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  A reference to the current icon.
     *  Set by viewIcon().
     */
    mx_internal var icon:IFlexDisplayObject;

    /**
     *  @private
     *  Icon names.
     *  Allows subclasses to re-define the icon property names.
     */
    mx_internal var iconName:String = "icon";

    /**
     *  The internal UITextField object that renders the label of this Button.
     *
     *  @default null
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
    //  descending
    //----------------------------------

    /**
     *  @private
     *  Storage for descending property.
     *
     *  @default false
     */
    private var _descending:Boolean = false;

    /**
     *  @private
     */
    public function get descending():Boolean
    {
        return _descending;
    }

    /**
     *  @private
     */
    public function set descending(value:Boolean):void
    {
        if (_descending != value)
        {
            _descending = value;

            invalidateDisplayList();
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
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

        if (!icon)
        {
            var iconClass:Class = Class(getStyle(iconName));
            if (iconClass)
            {
                icon = new iconClass();
                icon.name = iconName;
                if (icon is ISimpleStyleClient)
                    ISimpleStyleClient(icon).styleName = this;
                addChild(DisplayObject(icon));
            }
        }
    }

    /**
     * @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();

        // Font styles
        getFontStyles();

        // Whether the current column is sorted or not, and if so what info to
        // display
        var sortInfo:SortInfo = getFieldSortInfo();
        if (sortInfo)
        {
            visible = true;

            label.text = (sortInfo.sequenceNumber).toString();

            if (sortInfo.status == SortInfo.PROPOSEDSORT)
                label.setColor( getStyle("proposedColor") !== undefined
                                    ? getStyle("proposedColor") : 0x999999 );
            else
                label.setColor( getStyle("color") !== undefined
                                    ? getStyle("color") : 0x000000 );

            descending = sortInfo.descending;
        }
        else
        {
            visible = false;
        }
    }

    /**
     * @private
     */
    override protected function measure():void
    {
        super.measure();

        // Cache padding values
        var paddingLeft:int   = getStyle("paddingLeft");
        var paddingRight:int  = getStyle("paddingRight");
        var paddingTop:int    = getStyle("paddingTop");
        var paddingBottom:int = getStyle("paddingBottom");

        // Measure label
        // if text is empty string, use '2' as default text for measuring
        // for empty string, measureText() returns height as 15
        var lineMetrics:TextLineMetrics = measureText(label.length == 0 ? "2" : label.text);

        // Inspired by mx.controls.Label#measureTextFieldBounds():
        // In order to display the text completely,
        // a TextField must be 4-5 pixels larger.
        var labelWidth:Number  = lineMetrics.width  + UITextField.TEXT_WIDTH_PADDING;
        var labelHeight:Number = lineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;

        // Measure icon
        var iconWidth:Number  = icon ? icon.width  : 0;
        var iconHeight:Number = icon ? icon.height : 0;

        var horizontalGap:Number = getStyle("horizontalGap");
        if (iconWidth == 0)
            horizontalGap = 0;

        // Sum measurements of children
        var w:Number = labelWidth + horizontalGap + iconWidth;
        var h:Number = Math.max(labelHeight, iconHeight);

        // Add padding
        w += getStyle("paddingLeft") + getStyle("paddingRight");
        h += getStyle("paddingTop")  + getStyle("paddingBottom");

        // Set required width and height
        measuredMinWidth  = measuredWidth  = w;
        measuredMinHeight = measuredHeight = h;
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        // It seems strange to get a zero-width display,
        // is there a need to handle this case?
        if (unscaledWidth == 0)
            return;

        // Cache padding values
        var paddingLeft:int   = getStyle("paddingLeft");
        var paddingRight:int  = getStyle("paddingRight");
        var paddingTop:int    = getStyle("paddingTop");
        var paddingBottom:int = getStyle("paddingBottom");

        // Size of icon
        // Assumption that iconWidth < unscaledWidth
        // and iconHeight < unscaledHeight
        var iconWidth:Number  = icon ? icon.width  : 0;
        var iconHeight:Number = icon ? icon.height : 0;

        var horizontalGap:Number = getStyle("horizontalGap");
        if (iconWidth == 0)
            horizontalGap = 0;

        // Size of label
        var labelWidth:Number = unscaledWidth - iconWidth - horizontalGap
                                - paddingLeft - paddingRight;
        var labelHeight:Number = unscaledHeight - paddingTop - paddingBottom;
        label.setActualSize(labelWidth, labelHeight);

        // Calculate position of label
        var labelX:Number = paddingLeft;
        var labelY:Number = (unscaledHeight - label.height - paddingTop - paddingBottom ) / 2
                            + paddingTop;
        labelY = Math.max(labelY, 0);

        // Set positions
        label.x = Math.round(labelX);
        label.y = Math.round(labelY);

        // Calculate position of icon
        if (icon)
        {
            var iconX:Number = unscaledWidth - iconWidth - paddingRight;
            var iconY:Number = (unscaledHeight - iconHeight
                                - paddingTop - paddingBottom) / 2
                                + paddingTop;
            icon.x = Math.round(iconX);
            icon.y = Math.round(iconY);

            // Default is false i.e. ascending order
            if (!descending)
            {
                icon.scaleY = -1.0;
                icon.y += iconHeight;
            }
            else
            {
                icon.scaleY = 1.0;
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Gets font styles from the AdvancedDataGrid control 
     *  and uses them to initialize the corresponding font styles for this render. 
     *  The font styles accessed in the AdvancedDataGrid control include 
     *  <code>sortFontFamily</code>, <code>sortFontSize</code>, <code>sortFontStyle</code>, 
     *  and <code>sortFontWeight</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function getFontStyles():void
    {
        // 1. If only there was binding between styles ...
        // 2. Is there a way to avoid this in the sort item renderer itself so
        // that custom sort item renderers get it for free as opposed to
        // manually including it, similar to what we did for styleFunctions.
        // - We considered subcomponent style hookups i.e. using a styleProxy
        //   mechanism, but it works only for non-inheriting styles.

        var gridStyle:* = undefined;

        if (grid)
        {
            gridStyle = grid.getStyle("sortFontFamily");
            if (gridStyle !== undefined)
                setStyle("fontFamily", gridStyle);
            gridStyle = grid.getStyle("sortFontSize");
             if (gridStyle !== undefined)
                setStyle("fontSize", gridStyle);
            gridStyle = grid.getStyle("sortFontStyle");
            if (gridStyle !== undefined)
                setStyle("fontStyle", gridStyle);
            gridStyle = grid.getStyle("sortFontWeight");
            if (gridStyle !== undefined)
                setStyle("fontWeight", gridStyle);
        }
    }

    /**
     *  Returns the sort information for this column from the AdvancedDataGrid control
     *  so that the control can display the column's number in the sort sequence,
     *  and whether the sort is ascending or descending. 
     *  The sorting information is represented by an instance of the SortInfo class,
     *  where each column in the AdvancedDataGrid control has an associated 
     *  SortInfo instance.
     *
     *  @return A SortInfo instance.
     *
     *  @see mx.controls.advancedDataGridClasses.SortInfo
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function getFieldSortInfo():SortInfo
    {
        // Parent is the header renderer.
        if (grid && parent is IDropInListItemRenderer)
        {
            var listData:AdvancedDataGridListData = (parent as IDropInListItemRenderer).listData
                                                    as AdvancedDataGridListData;
            if (listData && listData.columnIndex != -1)
                return grid.getFieldSortInfo(grid.columns[listData.columnIndex]);
        }

        return null;
    }

    /**
     *  Returns a reference to the associated AdvancedDataGrid control.
     *
     *  @return The AdvancedDataGrid control instance.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function get grid():AdvancedDataGrid
    {
        if (parent && IUIComponent(parent).owner
                            && IUIComponent(parent).owner is AdvancedDataGrid)
            return IUIComponent(parent).owner as AdvancedDataGrid;
        else
            return null;
    }

} // end class AdvancedDataGridSortItemRenderer

}
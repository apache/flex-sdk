////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

/**  @private
 *  monkey-patched  from LabelItemRenderer, pruned from label/labelDisplay  and change some variable accessibility
 *  Provides default behavior for  ListMultiPartItemRenderer
 *
 *   @langversion 3.0
 *  @playerversion AIR 3.8
 *  @productversion Flex 4.11
 *
 *  */
//TODO refactoring : should  become superclass of LabelItemRenderer

package spark.components.supportClasses
{
import flash.display.GradientType;
import flash.events.Event;
import flash.geom.Matrix;

import mx.core.DPIClassification;
import mx.core.FlexGlobals;
import mx.core.IDataRenderer;
import mx.core.IFlexDisplayObject;
import mx.core.ILayoutElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.DataGroup;
import spark.components.IItemRenderer;

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
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]

//--------------------------------------
//  Styles
//--------------------------------------

[Style(name="paddingLeft", type="Number", format="Length", inherit="no")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:alternatingItemColors
 *
 */
[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:chromeColor
 *
 *  @default 0xCCCCCC
 *
 */
[Style(name="chromeColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:downColor
 *
 */
[Style(name="downColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:focusColor
 *
 */
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  Number of pixels between the bottom border and the text component
 *  of the item renderer.
 *
 *  @default 5
 *
 */
[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]

/**
 *  Number of pixels between the top border and the text component
 *  of the item renderer.
 *
 *  @default 5
 *
 */
[Style(name="paddingTop", type="Number", format="Length", inherit="no")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:rollOverColor
 *
 */
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]

/**
 *  @copy spark.components.List#style:selectionColor
 *
 */
[Style(name="selectionColor", type="uint", format="Color", inherit="yes")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:symbolColor
 *
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark,mobile")]

/**
 *  The vertical alignment of the content when it does not have
 *  a one-to-one aspect ratio.
 *  Possible values are <code>"top"</code>, <code>"center"</code>,
 *  and <code>"bottom"</code>.
 *
 *  @default "center"
 *
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="verticalAlign", type="String", enumeration="bottom,middle,top", inherit="no")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="focusBlendMode", kind="style")]
[Exclude(name="focusThickness", kind="style")]

public class ItemRendererBase extends UIComponent implements IDataRenderer, IItemRenderer
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function ItemRendererBase()
    {
        super();

        switch (applicationDPI)
        {
            case DPIClassification.DPI_480:
            {
                minHeight = 132;
                break;
            }
            case DPIClassification.DPI_320:
            {
                minHeight = 88;
                break;
            }
            case DPIClassification.DPI_240:
            {
                minHeight = 66;
                break;
            }
            default:
            {
                // default PPI160
                minHeight = 44;
                break;
            }
        }

        interactionStateDetector = new InteractionStateDetector(this);
        interactionStateDetector.addEventListener(Event.CHANGE, interactionStateDetector_changeHandler);

        cacheAsBitmap = true;
    }

    //--------------------------------------------------------------------------
    //
    //  Private Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Helper class to help determine when we are in the hovered or down states
     */
    protected var interactionStateDetector:InteractionStateDetector;

    /**
     *  @private
     *  Whether or not we're the last element in the list
     */
    mx_internal var isLastItem:Boolean = false;

    //--------------------------------------------------------------------------
    //
    //  Public Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  data
    //----------------------------------

    /**
     *  @private
     */
    private var _data:Object;

    [Bindable("dataChange")]

    /**
     *  The implementation of the <code>data</code> property
     *  as defined by the IDataRenderer interface.
     *  When set, it stores the value and invalidates the component
     *  to trigger a relayout of the component.
     *
     *  @see mx.core.IDataRenderer
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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

        if (hasEventListener(FlexEvent.DATA_CHANGE))
            dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));

        if (_data) onDataChanged();
    }

    protected function onDataChanged():void
    {
        // set data related properties
    }

    //----------------------------------
    //  down
    //----------------------------------
    /**
     *  @private
     *  storage for the down property
     */
    private var _down:Boolean = false;

    /**
     *  Set to <code>true</code> when the user is pressing down on an item renderer.
     *
     *  @default false
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function get down():Boolean
    {
        return _down;
    }

    /**
     *  @private
     */
    protected function set down(value:Boolean):void
    {
        if (value == _down)
            return;

        _down = value;
        invalidateDisplayList();
    }

    //----------------------------------
    //  hovered
    //----------------------------------
    /**
     *  @private
     *  storage for the hovered property
     */
    private var _hovered:Boolean = false;

    /**
     *  Set to <code>true</code> when the user is hovered over the item renderer.
     *
     *  @default false
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function get hovered():Boolean
    {
        return _hovered;
    }

    /**
     *  @private
     */
    protected function set hovered(value:Boolean):void
    {
        if (value == _hovered)
            return;

        _hovered = value;
        invalidateDisplayList();
    }

    //----------------------------------
    //  itemIndex
    //----------------------------------

    /**
     *  @private
     *  storage for the itemIndex property
     */
    private var _itemIndex:int;

    /**
     *  @inheritDoc
     *
     *  @default 0
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get itemIndex():int
    {
        return _itemIndex;
    }

    /**
     *  @private
     */
    public function set itemIndex(value:int):void
    {
        var wasLastItem:Boolean = isLastItem;
        var dataGroup:DataGroup = parent as DataGroup;
        isLastItem = (dataGroup && (value == dataGroup.numElements - 1));

        // if whether or not we are the last item in the last has changed then
        // invalidate our display. note:  even if our new index has not changed,
        // whether or not we're the last item may have so we perform this check
        // before the value == _itemIndex check below
        if (wasLastItem != isLastItem)
            invalidateDisplayList();

        if (value == _itemIndex)
            return;

        _itemIndex = value;

        // only invalidateDisplayList() if this causes use to redraw which
        // is only if alternatingItemColors are defined (and technically also
        // only if we are not selected or down, etc..., but we'll ignore those
        // as this will shortcut 95% of the time anyways)
        if (getStyle("alternatingItemColors") !== undefined)
            invalidateDisplayList();
    }

    public function get label():String
    {
        return "";
    }

    public function set label(value:String):void
    {
    }

    private var _showsCaret:Boolean = false;

    /**
     *  @inheritDoc
     *
     *  @default false
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get showsCaret():Boolean
    {
        return _showsCaret;
    }

    /**
     *  @private
     */
    public function set showsCaret(value:Boolean):void
    {
        if (value == _showsCaret)
            return;

        _showsCaret = value;
        invalidateDisplayList();
    }

    //----------------------------------
    //  selected
    //----------------------------------

    /**
     *  @private
     *  storage for the selected property
     */
    private var _selected:Boolean = false;

    /**
     *  @inheritDoc
     *
     *  @default false
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get selected():Boolean
    {
        return _selected;
    }

    /**
     *  @private
     */
    public function set selected(value:Boolean):void
    {
        if (value == _selected)
            return;

        _selected = value;
        invalidateDisplayList();
    }

    //----------------------------------
    //  dragging
    //----------------------------------

    /**
     *  @private
     *  Storage for the dragging property.
     */
    private var _dragging:Boolean = false;

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get dragging():Boolean
    {
        return _dragging;
    }

    /**
     *  @private
     */
    public function set dragging(value:Boolean):void
    {
        _dragging = value;
    }


    //----------------------------------
    //  authorDensity
    //----------------------------------
    /**
     *  Returns the DPI of the application.
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get applicationDPI():Number
    {
        return FlexGlobals.topLevelApplication.applicationDPI;
    }


    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // clear the graphics before calling super.updateDisplayList()
        graphics.clear();

        super.updateDisplayList(unscaledWidth, unscaledHeight);

        drawBackground(unscaledWidth, unscaledHeight);

        layoutContents(unscaledWidth, unscaledHeight);
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Renders a background for the item renderer.
     *
     *  <p>This method, along with <code>layoutContents()</code>, is called
     *  by the <code>updateDisplayList()</code> method.</p>
     *
     *  <p>This method draws the background and the outline for this item renderer.
     *  It knows how to appropriately handle the selected, down, or caretted states.
     *  However, when <code>alternatingItemColors</code> is set to <code>undefined</code>,
     *  the default background is transparent.
     *  Override this method to change the appearance of the background of
     *  the item renderer.</p>
     *
     *  @param unscaledWidth Specifies the width of the component, in pixels,
     *  in the component's coordinates, regardless of the value of the
     *  <code>scaleX</code> property of the component.
     *
     *  @param unscaledHeight Specifies the height of the component, in pixels,
     *  in the component's coordinates, regardless of the value of the
     *  <code>scaleY</code> property of the component.
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // figure out backgroundColor
        var backgroundColor:*;
        var downColor:* = getStyle("downColor");
        var drawBackground:Boolean = true;
        var opaqueBackgroundColor:* = undefined;

        if (down && downColor !== undefined)
        {
            backgroundColor = downColor;
        }
        else if (selected)
        {
            backgroundColor = getStyle("selectionColor");
        }
        else if (hovered)
        {
            backgroundColor = getStyle("rollOverColor");
        }
        else if (showsCaret)
        {
            backgroundColor = getStyle("selectionColor");
        }
        else
        {
            var alternatingColors:Array;
            var alternatingColorsStyle:Object = getStyle("alternatingItemColors");

            if (alternatingColorsStyle)
                alternatingColors = (alternatingColorsStyle is Array) ? (alternatingColorsStyle as Array) : [alternatingColorsStyle];

            if (alternatingColors && alternatingColors.length > 0)
            {
                // translate these colors into uints
                styleManager.getColorNames(alternatingColors);

                backgroundColor = alternatingColors[itemIndex % alternatingColors.length];
            }
            else
            {
                // don't draw background if it is the contentBackgroundColor. The
                // list skin handles the background drawing for us.
                drawBackground = false;
            }

        }

        // draw backgroundColor
        // the reason why we draw it in the case of drawBackground == 0 is for
        // mouse hit testing purposes
        graphics.beginFill(backgroundColor, drawBackground ? 1 : 0);
        graphics.lineStyle();
        graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
        graphics.endFill();

        // Selected and down states have a gradient overlay as well
        // as different separators colors/alphas
        if (selected || down)
        {
            var colors:Array = [0x000000, 0x000000 ];
            var alphas:Array = [.2, .1];
            var ratios:Array = [0, 255];
            var matrix:Matrix = new Matrix();

            // gradient overlay
            matrix.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0);
            graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
            graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
            graphics.endFill();
        }
        else if (drawBackground)
        {
            // If our background is a solid color, use it as the opaqueBackground property
            // for this renderer. This makes scrolling considerably faster.
            opaqueBackgroundColor = backgroundColor;
        }

        // Draw the separator for the item renderer
        drawBorder(unscaledWidth, unscaledHeight, alternatingColorsStyle != null);

        opaqueBackground = opaqueBackgroundColor;
    }

    /**
     *  Renders the border for the item renderer.
     *
     *  <p>This method is called by <code>drawBackground</code> after the
     *  background has been rendered.</p>
     *
     *  <p>Override this method to change the appearance of the separator or
     *  border of the item renderer.</p>
     *
     *  @param unscaledWidth Specifies the width of the component, in pixels,
     *  in the component's coordinates, regardless of the value of the
     *  <code>scaleX</code> property of the component.
     *
     *  @param unscaledHeight Specifies the height of the component, in pixels,
     *  in the component's coordinates, regardless of the value of the
     *  <code>scaleY</code> property of the component.
     *
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
     */
    protected function drawBorder(unscaledWidth:Number, unscaledHeight:Number, hasAlternatingColors:Boolean):void
    {
        var topSeparatorColor:uint;
        var topSeparatorAlpha:Number;
        var bottomSeparatorColor:uint;
        var bottomSeparatorAlpha:Number;

        var borderWidth:Number = 1;
        var drawBottomBorder:Boolean = !hasAlternatingColors; // if alternating colors, don't draw shadow

        // separators are a highlight on the top and shadow on the bottom
        topSeparatorColor = 0xFFFFFF;
        topSeparatorAlpha = .3;
        bottomSeparatorColor = 0x000000;
        bottomSeparatorAlpha = .3;


        // draw separators
        // don't draw top separator for down and selected states
        if (!(selected || down))
        {
            graphics.beginFill(topSeparatorColor, topSeparatorAlpha);
            graphics.drawRect(0, 0, unscaledWidth, borderWidth);
            graphics.endFill();
        }

        if (drawBottomBorder)
            graphics.beginFill(bottomSeparatorColor, bottomSeparatorAlpha);
        graphics.drawRect(0, unscaledHeight - (isLastItem ? 0 : borderWidth), unscaledWidth, borderWidth);
        graphics.endFill();


        // add extra separators to the first and last items so that
        // the list looks correct during the scrolling bounce/pull effect
        // top
        if (itemIndex == 0 && drawBottomBorder)
        {
            graphics.beginFill(bottomSeparatorColor, bottomSeparatorAlpha);
            graphics.drawRect(0, -borderWidth, unscaledWidth, borderWidth);
            graphics.endFill();
        }

        // bottom
        if (isLastItem)
        {
            // we want to offset the bottom by 1 so that we don't get
            // a double line at the bottom of the list if there's a
            // border
            graphics.beginFill(topSeparatorColor, topSeparatorAlpha);
            graphics.drawRect(0, unscaledHeight + borderWidth, unscaledWidth, borderWidth);
            graphics.endFill();
        }
    }

    /**
     *  Positions the children for this item renderer.
     *
     *  <p>This method, along with <code>drawBackground()</code>, is called
     *  by the <code>updateDisplayList()</code> method.</p>
     *
     *  <p>This method positions the <code>labelDisplay</code> component.
     *  Subclasses should override this to position their children.</p>
     *
     *  @param unscaledWidth Specifies the width of the component, in pixels,
     *  in the component's coordinates, regardless of the value of the
     *  <code>scaleX</code> property of the component.
     *
     *  @param unscaledHeight Specifies the height of the component, in pixels,
     *  in the component's coordinates, regardless of the value of the
     *  <code>scaleY</code> property of the component.
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {

    }

    protected function setElementPosition(element:Object, x:Number, y:Number):void
    {
        if (element is ILayoutElement)
        {
            ILayoutElement(element).setLayoutBoundsPosition(x, y, false);
        }
        else if (element is IFlexDisplayObject)
        {
            IFlexDisplayObject(element).move(x, y);
        }
        else
        {
            element.x = x;
            element.y = y;
        }
    }

    /**
     *  @copy spark.skins.mobile.supportClasses.MobileSkin#setElementSize()
     *
     *  @see #setElementPosition
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function setElementSize(element:Object, width:Number, height:Number):void
    {
        if (element is ILayoutElement)
        {
            ILayoutElement(element).setLayoutBoundsSize(width, height, false);
        }
        else if (element is IFlexDisplayObject)
        {
            IFlexDisplayObject(element).setActualSize(width, height);
        }
        else
        {
            element.width = width;
            element.height = height;
        }
    }

    /**
     *  @copy spark.skins.mobile.supportClasses.MobileSkin#getElementPreferredWidth()
     *
     *  @see #setElementPosition
     *  @see #setElementSize
     *  @see #getElementPreferredHeight
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function getElementPreferredWidth(element:Object):Number
    {
        var result:Number;

        if (element is ILayoutElement)
        {
            result = ILayoutElement(element).getPreferredBoundsWidth();
        }
        else if (element is IFlexDisplayObject)
        {
            result = IFlexDisplayObject(element).measuredWidth;
        }
        else
        {
            result = element.width;
        }

        return Math.round(result);
    }

    /**
     *  @copy spark.skins.mobile.supportClasses.MobileSkin#getElementPreferredHeight()
     *
     *  @see #setElementPosition
     *  @see #setElementSize
     *  @see #getElementPreferredWidth
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function getElementPreferredHeight(element:Object):Number
    {
        var result:Number;

        if (element is ILayoutElement)
        {
            result = ILayoutElement(element).getPreferredBoundsHeight();
        }
        else if (element is IFlexDisplayObject)
        {
            result = IFlexDisplayObject(element).measuredHeight;
        }
        else
        {
            result = element.height;
        }

        return Math.ceil(result);
    }

    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function interactionStateDetector_changeHandler(event:Event):void
    {
        down = (interactionStateDetector.state == InteractionState.DOWN);
        hovered = (interactionStateDetector.state == InteractionState.OVER);
    }
}
}

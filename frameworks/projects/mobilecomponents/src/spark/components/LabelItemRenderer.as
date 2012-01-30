////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2004-2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{
import flash.display.GradientType;
import flash.events.Event;
import flash.geom.Matrix;
import flash.text.TextLineMetrics;

import mx.controls.listClasses.*;
import mx.core.DPIClassification;
import mx.core.FlexGlobals;
import mx.core.IDataRenderer;
import mx.core.IFlexDisplayObject;
import mx.core.ILayoutElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.supportClasses.InteractionState;
import spark.components.supportClasses.InteractionStateDetector;
import spark.components.supportClasses.StyleableTextField;

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
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/PaddingStyles.as"
include "../styles/metadata/StyleableTextFieldTextStyles.as"

/**
 *  @copy spark.components.supportClasses.GroupBase#style:alternatingItemColors
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:chromeColor
 *   
 *  @default 0xCCCCCC
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="chromeColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:downColor
 *   
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
[Style(name="downColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:focusColor
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  Number of pixels between the bottom border and the text component
 *  of the item renderer.
 * 
 *  @default 5
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]

/**
 *  Number of pixels between the top border and the text component
 *  of the item renderer.
 * 
 *  @default 5
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="paddingTop", type="Number", format="Length", inherit="no")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:rollOverColor
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]

/**
 *  @copy spark.components.List#style:selectionColor
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
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

/**
 *  The LabelItemRenderer class defines the default item renderer
 *  for a list-based control in the mobile theme.  
 *  This is a simple item renderer with a single text component.
 *
 *  <p>The item renderer creates a single StyleableTextField control 
 *  to display a String. 
 *  The name of the StyleableTextField control in the item renderer is <code>labelDisplay</code>. 
 *  Use the <code>labelField</code> property of the list-based control to specify 
 *  a field of the data item to display in the StyleableTextField control.</p>
 *
 *  <p>To create a custom item renderer for use on mobile devices, 
 *  Adobe recommends that you create a new ActionScript item renderer 
 *  that extends this class.</p>
 *
 *  @mxml
 *  
 *  <p>The <code>&lt;s:LabelItemRenderer&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;s:LabelItemRenderer
 *   <strong>Properties</strong>
 *    label=""
 * 
 *   <strong>Common Styles</strong>
 *    color="<i>Theme dependent</i>"
 *    downColor="<i>Theme dependent</i>"
 *    fontFamily="<i>Theme dependent</i>"
 *    fontSize="<i>Theme dependent</i>"
 *    fontStyle="normal"
 *    fontWeight="normal"
 *    leading="0"
 *    letterSpacing="0"
 *    paddingBottom="0"
 *    paddingLeft="0"
 *    paddingRight="0"
 *    paddingTop="5"
 *    rollOverColor="0xCEDBEF"
 *    selectionColor="0xB2B2B2"
 *    textAlign="left"
 *    textDecoration="none"
 *    textIndent="0"
 *    verticalAlign="center"
 *  
 *   <strong>Spark Styles</strong>
 *    alternatingItemColors="undefined"
 *    focusColor="0x70B2EE"
 *    symbolColor="0x000000"
 *  
 *   <strong>Mobile Styles</strong>
 *    alternatingItemColors="undefined"
 *    focusColor="0x70B2EE"
 *    symbolColor="0x000000"
 * 
 *    <b>Events</b>
 *    dataChange="<i>No default</i>"
 * 
 *  &gt;
 *  </pre>
 *
 *  @see spark.components.IconItemRenderer
 *  @see spark.components.List
 *  @see mx.core.IDataRenderer
 *  @see spark.components.IItemRenderer
 *  @see spark.components.supportClasses.ItemRenderer
 *  @includeExample examples/LabelItemRendererExample.mxml -noswf
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class LabelItemRenderer extends UIComponent
    implements IDataRenderer, IItemRenderer
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
    public function LabelItemRenderer()
    {
        super();
        
        switch (applicationDPI)
        {
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
    private var interactionStateDetector:InteractionStateDetector;
    
    /**
     *  @private
     *  Whether or not we're the last element in the list
     */
    mx_internal var isLastItem:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  baselinePosition
    //----------------------------------
    
    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
        // The text styles aren't known until there is a parent.
        if (!parent)
            return NaN;
        
        return labelDisplay.baselinePosition;
    }
    
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
    
    //----------------------------------
    //  label
    //----------------------------------
    
    /**
     *  @private 
     *  Storage var for label
     */ 
    private var _label:String = "";
    
    /**
     *  The text component used to 
     *  display the label data of the item renderer.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var labelDisplay:StyleableTextField;
    
    /**
     *  @inheritDoc 
     *
     *  @default ""  
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5  
     */
    public function get label():String
    {
        return _label;
    }
    
    /**
     *  @private
     */ 
    public function set label(value:String):void
    {
        if (value == _label)
            return;
        
        _label = value;
        
        // Push the label down into the labelTextField,
        // if it exists
        if (labelDisplay)
        {
            labelDisplay.text = _label;
            invalidateSize();
        }
    }
    
    //----------------------------------
    //  showsCaret
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the showsCaret property 
     */
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
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        if (!labelDisplay)
        {
            createLabelDisplay();
            labelDisplay.text = _label;
        }
    }
    
    /**
     *  Creates the labelDisplay component
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function createLabelDisplay():void
    {
        labelDisplay = StyleableTextField(createInFontContext(StyleableTextField));
        labelDisplay.styleName = this;
        labelDisplay.editable = false;
        labelDisplay.selectable = false;
        labelDisplay.multiline = false;
        labelDisplay.wordWrap = false;
        
        addChild(labelDisplay);
    }
    
    /**
     *  Destroys the labelDisplay component
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function destroyLabelDisplay():void
    {
        removeChild(labelDisplay);
        labelDisplay = null;
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        if (labelDisplay)
        {
            // reset text if it was truncated before.
            if (labelDisplay.isTruncated)
                labelDisplay.text = label;
            
            var horizontalPadding:Number = getStyle("paddingLeft") + getStyle("paddingRight");
            var verticalPadding:Number = getStyle("paddingTop") + getStyle("paddingBottom");
            
            // Text respects padding right, left, top, and bottom
            labelDisplay.commitStyles();
            measuredWidth = getElementPreferredWidth(labelDisplay) + horizontalPadding;
            // We only care about the "real" ascent
            measuredHeight = getElementPreferredHeight(labelDisplay) + verticalPadding; 
        }
        
        measuredMinWidth = 0;
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
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
    protected function drawBackground(unscaledWidth:Number, 
                                      unscaledHeight:Number):void
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
            matrix.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0 );
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
        drawBorder(unscaledWidth, unscaledHeight);
        
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
    protected function drawBorder(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var topSeparatorColor:uint;
        var topSeparatorAlpha:Number;
        var bottomSeparatorColor:uint;
        var bottomSeparatorAlpha:Number;
        
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
            graphics.drawRect(0, 0, unscaledWidth, 1);
            graphics.endFill();
        }
        
        graphics.beginFill(bottomSeparatorColor, bottomSeparatorAlpha);
        graphics.drawRect(0, unscaledHeight - (isLastItem ? 0 : 1), unscaledWidth, 1);
        graphics.endFill();
        
        
        // add extra separators to the first and last items so that 
        // the list looks correct during the scrolling bounce/pull effect
        // top
        if (itemIndex == 0)
        {
            graphics.beginFill(bottomSeparatorColor, bottomSeparatorAlpha);
            graphics.drawRect(0, -1, unscaledWidth, 1);
            graphics.endFill(); 
        }
        
        // bottom
        if (isLastItem)
        {
            // we want to offset the bottom by 1 so that we don't get
            // a double line at the bottom of the list if there's a 
            // border
            graphics.beginFill(topSeparatorColor, topSeparatorAlpha);
            graphics.drawRect(0, unscaledHeight + 1, unscaledWidth, 1);
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
    protected function layoutContents(unscaledWidth:Number, 
                                      unscaledHeight:Number):void
    {
        if (!labelDisplay)
            return;
        
        var paddingLeft:Number   = getStyle("paddingLeft"); 
        var paddingRight:Number  = getStyle("paddingRight");
        var paddingTop:Number    = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");
        var verticalAlign:String = getStyle("verticalAlign");

        var viewWidth:Number  = unscaledWidth  - paddingLeft - paddingRight;
        var viewHeight:Number = unscaledHeight - paddingTop  - paddingBottom;

        var vAlign:Number;
        if (verticalAlign == "top")
            vAlign = 0;
        else if (verticalAlign == "bottom")
            vAlign = 1;
        else // if (verticalAlign == "middle")
            vAlign = 0.5;
        
        // measure the label component
        // text should take up the rest of the space width-wise, but only let it take up
        // its measured textHeight so we can position it later based on verticalAlign
        var labelWidth:Number = Math.max(viewWidth, 0); 
        var labelHeight:Number = 0;

        if (label != "")
        {
            labelDisplay.commitStyles();
            
            // reset text if it was truncated before.
            if (labelDisplay.isTruncated)
                labelDisplay.text = label;
        
            labelHeight = getElementPreferredHeight(labelDisplay);
        }
    
        setElementSize(labelDisplay, labelWidth, labelHeight);    
                
        // We want to center using the "real" ascent
        var labelY:Number = Math.round(vAlign * (viewHeight - labelHeight))  + paddingTop;
        setElementPosition(labelDisplay, paddingLeft, labelY);

        // attempt to truncate the text now that we have its official width
        labelDisplay.truncateToFit();

    }

    //--------------------------------------------------------------------------
    //
    //  Methods: Layout Helpers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @copy spark.skins.mobile.supportClasses.MobileSkin#setElementPosition()
     *
     *  @see #setElementSize  
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
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
            result =  IFlexDisplayObject(element).measuredHeight;
        }
        else
        {
            result =  element.height;
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
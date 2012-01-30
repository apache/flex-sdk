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
import flash.events.Event;
import flash.text.TextLineMetrics;

import mx.controls.listClasses.*;
import mx.core.IDataRenderer;
import mx.core.IFlexDisplayObject;
import mx.core.ILayoutElement;
import mx.core.IUIComponent;
import mx.core.UIComponent;
import mx.core.UITextField;
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
 *  @playerversion Flash 10.1
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
 *  The colors to use for the background of the items in the list. 
 *  The value is an Array of two or more colors. 
 *  The backgrounds of the list items alternate among the colors in the Array. 
 * 
 *  @default undefined
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes", theme="spark, mobile")]
// FIXME (rfrishbe): what to do about theme?

/**
 *  The color of the background of an item renderer when the item is being pressed down.
 * 
 *  <p>If <code>downColor</code> is set to <code>undefined</code>, 
 *  <code>downColor</code> is not used.</p>
 * 
 *  <p>The default value in the 
 *  spark theme is <code>undefined</code>.  The default value in the 
 *  mobile theme is <code>0xB2B2B2</code>.</p>
 *   
 *  @default 0xB2B2B2
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
[Style(name="downColor", type="uint", format="Color", inherit="yes")]

/**
 *  Color of focus ring when the component is in focus.
 *   
 *  @default 0x70B2EE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
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
 *  @playerversion Flash 10.1
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
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="paddingTop", type="Number", format="Length", inherit="no")]

/**
 *  The color of the background of an item renderer when the user rolls over it.
 *   
 *  @default 0xCEDBEF
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]

/**
 *  The color of the background of an item renderer when the user selects it.
 *   
 *  @default 0xB2B2B2
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
[Style(name="selectionColor", type="uint", format="Color", inherit="yes")]
// FIXME (rfrishbe): figure out why this isn't on defaultitemrenderer or itemrenderer

/**
 *  Color of any symbol of a component. 
 *  Examples include the check mark of a CheckBox or
 *  the arrow of a scroll button.
 *   
 *  @default 0x000000
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark,mobile")]
// FIXME (rfrishbe): should we add chromeColor and other inheriting styles?

/**
 *  The vertical alignment of the content when it does not have
 *  a one-to-one aspect ratio.
 *  Possible values are <code>"top"</code>, <code>"center"</code>,
 *  and <code>"bottom"</code>.
 *  
 *  @default "center"
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
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
 *  The MobileItemRenderer class defines the default item renderer
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
 *  Adobe recommends that you 
 *  create a new ActionScript item renderer that extends 
 *  this class.</p>
 *
 *  @see spark.components.MobileIconItemRenderer
 *  @see spark.components.List
 *  @see mx.core.IDataRenderer
 *  @see spark.components.IItemRenderer
 *  @see spark.components.supportClasses.ItemRenderer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class MobileItemRenderer extends UIComponent
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
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function MobileItemRenderer()
    {
        super();
        
        interactionStateDetector = new InteractionStateDetector(this);
        interactionStateDetector.addEventListener(Event.CHANGE, interactionStateDetector_changeHandler);
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
        // Copied from UITextField.baselinePosition
        var tlm:TextLineMetrics;
        
        // The text styles aren't known until there is a parent.
        if (!parent)
            return NaN;
        
        // getLineMetrics() returns strange numbers for an empty string,
        // so instead we get the metrics for a non-empty string.
        var isEmpty:Boolean = (labelDisplay.text == "");
        if (isEmpty)
            labelDisplay.text = "Wj";
        
        tlm = labelDisplay.getLineMetrics(0);
        
        if (isEmpty)
            labelDisplay.text = "";
        
        // TextFields have 2 pixels of padding all around.
        return 2 + tlm.ascent;
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
     *  @playerversion Flash 10.1
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
     *  @playerversion Flash 10.1
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
        if (value == _itemIndex)
            return;
        
        _itemIndex = value;
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
     *  @playerversion Flash 10.1
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
     *  @playerversion Flash 10.1
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
     *  @playerversion Flash 10.1
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
     *  @playerversion Flash 10.1
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
     *  @playerversion Flash 10.1
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
            labelDisplay = StyleableTextField(createInFontContext(StyleableTextField));
            labelDisplay.styleName = this;
            labelDisplay.editable = false;
            labelDisplay.selectable = false;
            labelDisplay.multiline = false;
            labelDisplay.wordWrap = false;
            
            addChild(labelDisplay);
            labelDisplay.text = _label;
        }
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
            
            // commit styles so our text measurement is accurate
            labelDisplay.commitStyles();

            // Text respects padding right, left, top, and bottom
            measuredWidth = labelDisplay.textWidth + UITextField.TEXT_WIDTH_PADDING;
            measuredWidth += getStyle("paddingLeft") + getStyle("paddingRight");
            
            measuredHeight = labelDisplay.textHeight + UITextField.TEXT_HEIGHT_PADDING;
            measuredHeight += getStyle("paddingTop") + getStyle("paddingBottom");
        }
        
        // minimum height of 80 pixels
        measuredHeight = Math.max(measuredHeight, 80);
        
        measuredMinWidth = 0;
        measuredMinHeight = 80;
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
     *  <p>This method draws the background, the outline, 
     *  and the separators for this item renderer.  
     *  When not selected, hovered, or down, the background is transparent.  
     *  However, when <code>alternatingItemColors</code> is set to <code>true</code>, 
     *  the background is drawn by this method.  
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
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function drawBackground(unscaledWidth:Number, 
                                      unscaledHeight:Number):void
    {
        // figure out backgroundColor
        var backgroundColor:uint;
        var drawBackground:Boolean = true;
        var downColor:* = getStyle("downColor");
        
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
        else
        {
            var alternatingColors:Array = getStyle("alternatingItemColors");
            
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
        
        if (showsCaret)
        {
            graphics.lineStyle(1, getStyle("selectionColor"));
            graphics.drawRect(0.5, 0.5, unscaledWidth-1, unscaledHeight-1);
        }
        else 
        {
            graphics.lineStyle();
            graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
        }
        
        graphics.endFill();
        
        if (!showsCaret)
        {
            // FIXME (rfrishbe): separators should be stylable
            
            // draw seperators: two lines
            // 1 pixel from bottom
            graphics.lineStyle(1, 0x1C1C1C);
            graphics.moveTo(0, unscaledHeight-1);
            graphics.lineTo(unscaledWidth, unscaledHeight-1);
            
            // line on the bottom
            graphics.lineStyle(1, 0x606060);
            graphics.moveTo(0, unscaledHeight);
            graphics.lineTo(unscaledWidth, unscaledHeight);
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
     *  @playerversion Flash 10.1
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

        var vAlign:Number;
        if (verticalAlign == "top")
            vAlign = 0;
        else if (verticalAlign == "bottom")
            vAlign = 1;
        else // if (verticalAlign == "middle")
            vAlign = 0.5;
        // made "middle" last even though it's most likely so it is the default and if someone 
        // types "center", then it will still vertically center itself.

        var viewWidth:Number  = unscaledWidth  - paddingLeft - paddingRight;
        var viewHeight:Number = unscaledHeight - paddingTop  - paddingBottom;

        // measure the label component
        var textHeight:Number = 0;

        if (label != "")
        {
            labelDisplay.commitStyles();
            
            // reset text if it was truncated before.
            if (labelDisplay.isTruncated)
                labelDisplay.text = label;
            textHeight = labelDisplay.textHeight + UITextField.TEXT_HEIGHT_PADDING;
        }

        // text should take up the rest of the space width-wise, but only let it take up
        // its measured textHeight so we can position it later based on verticalAlign
        var labelWidth:Number = Math.max(viewWidth, 0);
        var labelHeight:Number = Math.max(Math.min(viewHeight, textHeight), 0);
        resizeElement(labelDisplay, labelWidth, labelHeight);    
        
        var labelY:Number = Math.round(vAlign * (viewHeight - labelHeight)) + paddingTop;
        positionElement(labelDisplay, paddingLeft, labelY);

        // attempt to truncate the text now that we have its official width
        labelDisplay.truncateToFit();
    }

    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------
    
    
    
    /**
     *  A helper method to position the children of this item renderer.
     * 
     *  <p>You can use this method instead of checking for and using
     *  various interfaces such as ILayoutElement or IFlexDisplayObject.</p>
     *
     *  @param part The child to position.
     *
     *  @param x The x-coordinate of the child.
     *
     *  @param y The y-coordinate of the child.
     *
     *  @see #resizeElement  
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected function positionElement(part:Object, x:Number, y:Number):void
    {
        if (part is ILayoutElement)
        {
            ILayoutElement(part).setLayoutBoundsPosition(x, y, false);
        }
        else if (part is IFlexDisplayObject)
        {
            IFlexDisplayObject(part).move(x, y);   
        }
        else
        {
            part.x = x;
            part.y = y;
        }
    }
    
    /**
     *  A helper method to size the children of this item renderer.
     * 
     *  <p>You can use this method instead of checking for and using
     *  various interfaces such as ILayoutElement or IFlexDisplayObject.</p>
     *
     *  @param part The child to position.
     *
     *  @param x The width of the child.
     *
     *  @param y The height of the child.
     *
     *  @see #positionElement  
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected function resizeElement(part:Object, width:Number, height:Number):void
    {
        if (part is ILayoutElement)
        {
            ILayoutElement(part).setLayoutBoundsSize(width, height, false);
        }
        else if (part is IFlexDisplayObject)
        {
            IFlexDisplayObject(part).setActualSize(width, height);
        }
        else
        {
            part.width = width;
            part.height = height;
        }
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
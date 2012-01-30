package spark.components
{
import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.text.TextLineMetrics;

import mx.controls.listClasses.*;
import mx.core.IDataRenderer;
import mx.core.IFlexDisplayObject;
import mx.core.IFlexModuleFactory;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.utils.StringUtil;

import spark.components.Group;
import spark.components.IItemRenderer;
import spark.components.Image;
import spark.components.Label;
import spark.components.supportClasses.TextBase;
import spark.core.ContentCache;
import spark.primitives.BitmapImage;

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
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/PaddingStyles.as"
// FIXME (rfrishbe): make these the new text component supported styles 
include "../../../../spark/src/spark/styles/metadata/BasicInheritingTextStyles.as"
include "../../../../spark/src/spark/styles/metadata/AdvancedInheritingTextStyles.as"
include "../../../../spark/src/spark/styles/metadata/SelectionFormatTextStyles.as"

/**
 *  The colors to use for the backgrounds of the items in the list. 
 *  The value is an array of two or more colors. 
 *  The backgrounds of the list items alternate among the colors in the array. 
 * 
 *  @default undefined
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes", theme="spark, mobile")]
// FIXME (rfrishbe): what to do about theme?

/**
 *  Color of focus ring when the component is in focus
 *   
 *  @default 0x70B2EE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  Number of pixels between the bottom border and the text component.
 * 
 *  @default 5
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]

/**
 *  Number of pixels between the top border and the text component.
 * 
 *  @default 5
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="paddingTop", type="Number", format="Length", inherit="no")]

/**
 *  Color of the highlights when the mouse is over the component
 *   
 *  @default 0xCEDBEF
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]

/**
 *  Color of the highlights when the item is selected
 *   
 *  @default 0xB2B2B2
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
[Style(name="selectionColor", type="uint", format="Color", inherit="yes")]
// FIXME (rfrishbe): figure out why this isn't on defaultitemrenderer or itemrenderer

/**
 *  Color of any symbol of a component. Examples include the check mark of a CheckBox or
 *  the arrow of a scroll button
 *   
 *  @default 0x000000
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark,mobile")]
// FIXME (rfrishbe): should we add chromeColor and other inheriting styles?

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="focusBlendMode", kind="style")]
[Exclude(name="focusThickness", kind="style")]

/**
 *  The MobileItemRenderer class defines the default item renderer
 *  for a List control in the mobile theme.  This is a simple item 
 *  renderer with a single text component.
 *
 *  <p>If creating a custom item renderer for use on mobile devices, 
 *  it is recommended that you try to use 
 *  <code>spark.components.MobileIconItemRenderer</code> or 
 *  create a new ActionScript item renderer that extends 
 *  this class.</p>
 *
 *  @see spark.components.List
 *  @see mx.core.IDataRenderer
 *  @see spark.components.IItemRenderer
 *  @see spark.components.supportClasses.ItemRenderer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
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
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function MobileItemRenderer()
    {
        super();
        addHandlers();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------
    //
    //  Private Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Flag that is set when the mouse is hovered over the item renderer.
     */
    private var hovered:Boolean = false;
    
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
        var isEmpty:Boolean = (labelTextField.text == "");
        if (isEmpty)
            labelTextField.text = "Wj";
        
        tlm = labelTextField.getLineMetrics(0);
        
        if (isEmpty)
            labelTextField.text = "";
        
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
     *  @playerversion Flash 10
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
        
        dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
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
     *  @private
     *  FIXME (rfrishbe): This should be protected when we acutally 
     *  use and expose a real text primitive and not TextField.
     */
    mx_internal var labelTextField:TextField;
    
    /**
     *  @private
     */
    private var recreateLabelTextFieldStyles:Boolean;
    
    /**
     *  @inheritDoc 
     *
     *  @default ""    
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
        if (labelTextField)
        {
            labelTextField.text = _label;
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
        
        if (!labelTextField)
        {
            labelTextField = new TextField();
            labelTextField.multiline = false;
            labelTextField.wordWrap = false;
            labelTextField.selectable = false;
            
            addChild(DisplayObject(labelTextField));
            labelTextField.text = _label;
            
            recreateLabelTextFieldStyles = true;
            invalidateProperties();
        }
    }
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (recreateLabelTextFieldStyles)
        {
            recreateLabelTextFieldStyles = false;
            
            var textFormat:TextFormat = getTextStyles();
            
            // FIXME (rfrishbe): should deal with embedded fonts better
            
            labelTextField.defaultTextFormat = textFormat;
            
            // need to set text here for the defaultTextFormat to take effect
            labelTextField.text = labelTextField.text;
            
            invalidateSize();
            invalidateDisplayList();
        }
    }
    
    /**
     *  @private
     *  Defined by what we use in getTextStyles();
     */
    private static const TEXT_CSS_STYLES:Object = 
        {textAlign: true,
            fontWeight: true,
            color: true,
            disabledColor: true,
            fontFamily: true,
            textIndent: true,
            fontStyle: true,
            kerning: true,
            leading: true,
            letterSpacing: true,
            fontSize: true,
            textDecoration: true};
    
    /**
     *  @private
     *  Returns the TextFormat object that represents 
     *  character formatting information for this UITextField object.
     *
     *  @return A TextFormat object. 
     *
     *  @see flash.text.TextFormat
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function getTextStyles():TextFormat
    {
        // Adapted from UITextField.getTextStyles()
        var textFormat:TextFormat = new TextFormat();
        
        var textAlign:String = getStyle("textAlign");
        
        if (textAlign == "start")
            textAlign = TextFormatAlign.LEFT;
        else if (textAlign == "end")
            textAlign = TextFormatAlign.RIGHT;
        textFormat.align = textAlign; 
        textFormat.bold = getStyle("fontWeight") == "bold";
        if (enabled)
            textFormat.color = getStyle("color");
        else
            textFormat.color = getStyle("disabledColor");
        textFormat.font = StringUtil.trimArrayElements(getStyle("fontFamily"),",");
        textFormat.indent = getStyle("textIndent");
        textFormat.italic = getStyle("fontStyle") == "italic";
        var kerning:* = getStyle("kerning");
        // In Halo components based on TextField,
        // kerning is supposed to be true or false.
        // The default in TextField and Flex 3 is false
        // because kerning doesn't work for device fonts
        // and is slow for embedded fonts.
        // In Spark components based on TLF and FTE,
        // kerning is "auto", "on", or, "off".
        // The default in TLF and FTE is "auto"
        // (which means kern non-Asian characters)
        // because kerning works even on device fonts
        // and has miminal performance impact.
        // Since a CSS selector or parent container
        // can affect both Halo and Spark components,
        // we need to map "auto" and "on" to true
        // and "off" to false for Halo components
        // here and in UIFTETextField.
        // For Spark components, Label and CSSTextLayoutFormat,
        // do the opposite mapping of true to "on" and false to "off".
        // We also support a value of "default"
        // (which we set in the global selector)
        // to mean false for Halo and "auto" for Spark,
        // to get the recommended behavior in both sets of components.
        if (kerning == "auto" || kerning == "on")
            kerning = true;
        else if (kerning == "default" || kerning == "off")
            kerning = false;
        textFormat.kerning = kerning;
        textFormat.leading = getStyle("leading");
        //textFormat.leftMargin = ignorePadding ? 0 : getStyle("paddingLeft");
        textFormat.letterSpacing = getStyle("letterSpacing");
        //textFormat.rightMargin = ignorePadding ? 0 : getStyle("paddingRight");
        textFormat.size = getStyle("fontSize");
        textFormat.underline = getStyle("textDecoration") == "underline";
        
        return textFormat;
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        // Text has 10 pixels on left and 10 pixels on right by default, 5 pixels on top and 5 pixels on bottom by default
        measuredWidth = labelTextField.textWidth + 5 + getStyle("paddingLeft") + getStyle("paddingRight"); // 5 is the extra padding for text field
        measuredHeight = labelTextField.textHeight + 4 + getStyle("paddingTop") + getStyle("paddingBottom"); // 4 is the extra padding for text field
        
        // don't do anything with regards to minimum for the textField as it can just get truncated down anyways
        
        // minimum height of 80 pixels
        measuredHeight = Math.max(measuredHeight, 80);
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
        
        drawBackground();
        
        layoutContents(unscaledWidth, unscaledHeight);
    }
    
    /**
     *  Renders a background for the item renderer.
     * 
     *  <p>This method, along with <code>layoutContents()</code>, is called 
     *  by <code>updateDisplayList()</code>.</p>
     * 
     *  <p>This method is in charge of drawing the background, the outline, 
     *  and the seperators for this item renderer.  When not selected or hovered, 
     *  the background is transparent.  However, when alternatingItemColors is set, 
     *  the background is drawn in this method.  To change the appearance of 
     *  the background, override this method.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function drawBackground():void
    {
        // figure out backgroundColor
        var backgroundColor:uint;
        var drawBackground:Boolean = true;
        if (selected)
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
     *  by <code>updateDisplayList()</code>.</p>
     * 
     *  <p>For MobileItemRenderer, this method positions the labelElement.  
     *  Subclasses should override this and position their children in here.</p>
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
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function layoutContents(unscaledWidth:Number, 
                                      unscaledHeight:Number):void
    {
        // text should take up the rest of the space
        var labelWidth:Number = unscaledWidth;
        labelWidth -= getStyle("paddingLeft") + getStyle("paddingRight");
        
        // labe is positioned after the padding on the left
        var labelX:Number = getStyle("paddingLeft");
        
        labelTextField.width = labelWidth;
        labelTextField.height = labelTextField.textHeight + 4;
        
        labelTextField.x = labelX;
        labelTextField.y = (unscaledHeight - labelTextField.height)/2;
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleName:String):void
    {
        var allStyles:Boolean = !styleName || styleName == "styleName";
        
        super.styleChanged(styleName);
        
        if (allStyles || styleName == "inputMode")
        {
            addHandlers();
        }
        
        if (allStyles || styleName in TEXT_CSS_STYLES)
        {
            recreateLabelTextFieldStyles = true;
            invalidateProperties();
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Keeps track of whether rollover/rollout events were added
     * 
     *  We need to be careful about calling add/remove event listener because 
     *  of the reference counting going on in 
     *  super.addEventListener/removeEventListener.
     */
    private var rolloverEventsAdded:Boolean = false;
    
    /**
     *  @private
     *  Attach the mouse events.
     */
    private function addHandlers():void
    {
        if (getStyle("inputMode") == "mouse")
        {
            if (!rolloverEventsAdded)
            {
                rolloverEventsAdded = true;
                addEventListener(MouseEvent.ROLL_OVER, itemRenderer_rollOverHandler);
                addEventListener(MouseEvent.ROLL_OUT, itemRenderer_rollOutHandler);
            }
        }
        else
        {
            if (rolloverEventsAdded)
            {
                rolloverEventsAdded = false;
                removeEventListener(MouseEvent.ROLL_OVER, itemRenderer_rollOverHandler);
                removeEventListener(MouseEvent.ROLL_OUT, itemRenderer_rollOutHandler);
            }
        }
    }
    
    /**
     *  @private
     */
    private function anyButtonDown(event:MouseEvent):Boolean
    {
        var type:String = event.type;
        // TODO (rfrishbe): we should not code to literals here (and other places where this code is used)
        return event.buttonDown || (type == "middleMouseDown") || (type == "rightMouseDown"); 
    }
    
    /**
     *  @private
     *  Mouse rollOver event handler.
     */
    protected function itemRenderer_rollOverHandler(event:MouseEvent):void
    {
        if (!anyButtonDown(event))
        {
            hovered = true;
            invalidateDisplayList();
        }
    }
    
    /**
     *  @private
     *  Mouse rollOut event handler.
     */
    protected function itemRenderer_rollOutHandler(event:MouseEvent):void
    {
        hovered = false;
        invalidateDisplayList();
    }
    
}
}
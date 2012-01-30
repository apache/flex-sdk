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
import mx.core.InteractionMode;
import mx.core.UIComponent;
import mx.core.UITextField;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.utils.StringUtil;

import spark.components.Group;
import spark.components.IItemRenderer;
import spark.components.Image;
import spark.components.Label;
import spark.components.supportClasses.MobileTextField;
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
include "../styles/metadata/MobileTextFieldTextStyles.as"

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

/**
 *  The vertical alignment of the content when it does not have
 *  a one-to-one aspect ratio.
 *  Possible values are <code>"top"</code>, <code>"middle"</code>,
 *  and <code>"bottom"</code>.
 *  
 *  @default "center"
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
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
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
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
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var labelDisplay:MobileTextField;
    
    /**
     *  @inheritDoc 
     *
     *  @default ""  
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
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
     *  @playerversion Flash 10
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
     *  @playerversion Flash 10
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
     *  @playerversion Flash 10
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
            labelDisplay = MobileTextField(createInFontContext(MobileTextField));
            labelDisplay.styleProvider = this;
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
            var labelLineMetrics:TextLineMetrics = measureText(labelDisplay.text);
            
            // Text respects padding right, left, top, and bottom
            measuredWidth = labelLineMetrics.width + UITextField.TEXT_WIDTH_PADDING;
            measuredWidth += getStyle("paddingLeft") + getStyle("paddingRight");
            
            measuredHeight = labelLineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
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
    
    /**
     *  @private
     */
    override public function styleChanged(styleName:String):void
    {
        var allStyles:Boolean = !styleName || styleName == "styleName";
        
        super.styleChanged(styleName);
        
        if (allStyles || styleName == "interactionMode")
        {
            addHandlers();
        }
        
        // pass all style changes to labelTextField.  It will deal with them 
        // appropriatley and in a performant manner
        if (labelDisplay)
            labelDisplay.styleChanged(styleName);
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
     *  by <code>updateDisplayList()</code>.</p>
     * 
     *  <p>This method is in charge of drawing the background, the outline, 
     *  and the seperators for this item renderer.  When not selected or hovered, 
     *  the background is transparent.  However, when alternatingItemColors is set, 
     *  the background is drawn in this method.  To change the appearance of 
     *  the background, override this method.</p>
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
    protected function drawBackground(unscaledWidth:Number, 
                                      unscaledHeight:Number):void
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
     *  <p>For MobileItemRenderer, this method positions the labelDisplay.  
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
        if (labelDisplay)
        {
            // measure the label component
            var textHeight:Number = 0;
            var labelLineMetrics:TextLineMetrics;
            
            if (label != "")
            {
                labelLineMetrics = measureText(label);
                textHeight = labelLineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
            }
            
            // text should take up the rest of the space width-wise, but only let it take up
            // its measured textHeight so we can position it later based on verticalAlign
            var viewWidth:Number = unscaledWidth - getStyle("paddingLeft") + getStyle("paddingRight");
            var labelWidth:Number = Math.max(viewWidth, 0);
            
            var viewHeight:Number =  unscaledHeight - getStyle("paddingTop") - getStyle("paddingBottom");
            var labelHeight:Number = Math.max(Math.min(viewHeight, textHeight), 0);
            
            // label is positioned after the padding on the left.  look at verticalAlign to see
            // what to do vertically.
            var labelX:Number = getStyle("paddingLeft");
            var labelY:Number;
            if (getStyle("verticalAlign") == "top")
                labelY = getStyle("paddingTop");
            else if (getStyle("verticalAlign") == "bottom")
                labelY = getStyle("paddingTop") + viewHeight - labelHeight;
            else //if (getStyle("verticalAlign") == "middle")
                labelY = getStyle("paddingTop") + Math.round((viewHeight - labelHeight)/2);
            // made "middle" last even though it's most likely so it is the default and if someone 
            // types "center", then it will still vertically center itself.
            
            labelDisplay.commitStyles();
                
            labelDisplay.width = labelWidth;
            labelDisplay.height = labelHeight;
            
            labelDisplay.x = Math.round(labelX);
            labelDisplay.y = Math.round(labelY);
            
            // reset text if it was truncated before.  then attempt to truncate it
            if (labelDisplay.isTruncated)
                labelDisplay.text = label;
            labelDisplay.truncateToFit();
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
        if (getStyle("interactionMode") == InteractionMode.MOUSE)
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
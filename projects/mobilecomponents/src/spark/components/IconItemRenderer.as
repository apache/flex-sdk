////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2004-20010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.mobile
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
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]

//--------------------------------------
//  Styles
//--------------------------------------

// FIXME(rfrishbe): get these styles somehow
//include "../../styles/metadata/BasicInheritingTextStyles.as"
//include "../../styles/metadata/AdvancedInheritingTextStyles.as"
//include "../../styles/metadata/SelectionFormatTextStyles.as"

/**
 *  The colors to use for the backgrounds of the items in the list. 
 *  The value is an array of two or more colors. 
 *  The backgrounds of the list items alternate among the colors in the array. 
 * 
 *  @default undefined
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  Color of focus ring when the component is in focus
 *   
 *  @default 0x70B2EE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  Color of the highlights when the mouse is over the component
 *   
 *  @default 0xCEDBEF
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]
// FIXME (rfrishbe): should be theme="" above

/**
 *  Color of the highlights when the item is selected
 *   
 *  @default 0xCEDBEF
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
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
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="focusBlendMode", kind="style")]
[Exclude(name="focusThickness", kind="style")]

/**
 *  The IconItemRenderer class is a performant item 
 *  renderer optimized for mobile devices.  It contains 
 *  an optional icon on the left, text in the middle, and 
 *  an optional decorator icon on the right.
 *
 *  <p>You can override the default item renderer
 *  by creating a custom item renderer.</p>
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
public class IconItemRenderer extends UIComponent
    implements IDataRenderer, IItemRenderer
{
    
    // Image cache for all instances of this item renderer.
    static private var _imageCache: ContentCache;
    
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
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function IconItemRenderer()
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
    
    /**
     *  @private
     */
    private var dataChanged:Boolean;
    
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
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        
        dataChanged = true;
        invalidateProperties();
        
        dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
    }
    
    //----------------------------------
    //  decoratorClass
    //----------------------------------
    
    /**
     *  @private 
     */ 
    private var _decoratorClass:Class;
    
    /**
     *  @private 
     */ 
    private var decoratorClassChanged:Boolean;
    
    /**
     *  @private 
     */ 
    private var decoratorDisplay:DisplayObject;
    
    /**
     *  Decorator that appears on the right side 
     *  of this item renderer 
     *
     *  @default ""    
     */
    public function get decoratorClass():Class
    {
        return _decoratorClass;
    }
    
    /**
     *  @private
     */ 
    public function set decoratorClass(value:Class):void
    {
        if (value == _decoratorClass)
            return;
        
        _decoratorClass = value;
        
        decoratorClassChanged = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  iconField
    //----------------------------------
    
    /**
     *  @private 
     */ 
    private var _iconField:String;
    
    /**
     *  @private 
     */ 
    private var iconFieldChanged:Boolean;
    
    /**
     *  @private 
     */ 
    private var iconDisplay:BitmapImage;
    
    /**
     *  @private 
     * 
     *  Need a holder for the iconDisplay since it's a GraphicElement
     *  TODO (rfrishbe): would be nice to fix above somehow
     */ 
    private var iconDisplayHolder:Group;
    
    /**
     *  The name of the field in the data provider items to display as the icon. 
     *  By default iconField is <code>null</code>, and the item renderer 
     *  doesn't look for an icon.
     *
     *  @default null
     */
    public function get iconField():String
    {
        return _iconField;
    }
    
    /**
     *  @private
     */ 
    public function set iconField(value:String):void
    {
        if (value == _iconField)
            return;
        
        _iconField = value;
        iconFieldChanged = true;
        dataChanged = true;
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  iconHeight
    //----------------------------------
    
    /**
     *  @private 
     */ 
    private var _iconHeight:Number;
    
    /**
     *  The height of the icon.  If nothing is specified, the 
     *  intrinsic height of the image will be used.
     *
     *  @default NaN
     */
    public function get iconHeight():Number
    {
        return _iconHeight;
    }
    
    /**
     *  @private
     */ 
    public function set iconHeight(value:Number):void
    {
        if (value == _iconHeight)
            return;
        
        _iconHeight = value;
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    //----------------------------------
    //  iconWidth
    //----------------------------------
    
    /**
     *  @private 
     */ 
    private var _iconWidth:Number;
    
    /**
     *  The width of the icon.  If nothing is specified, the 
     *  intrinsic width of the image will be used.
     *
     *  @default NaN
     */
    public function get iconWidth():Number
    {
        return _iconWidth;
    }
    
    /**
     *  @private
     */ 
    public function set iconWidth(value:Number):void
    {
        if (value == _iconWidth)
            return;
        
        _iconWidth = value;
        
        invalidateSize();
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
     */
    private var labelTextField:TextField;
    
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
            labelTextField.text = _label;
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
        if (value == _dragging)
            return;
        
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
            if (_label != "")
                labelTextField.text = _label;
            
            recreateLabelTextFieldStyles = true;
            invalidateProperties();
        }
        
        // iconDisplay and decoratorClass are created in 
        // commitProperties()
    }
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (decoratorClassChanged)
        {
            decoratorClassChanged = false;
            
            // if there's an old one, remove it
            if (decoratorDisplay)
            {
                removeChild(decoratorDisplay);
            }
            
            // if we need to create it, do it here
            if (decoratorClass)
            {
                decoratorDisplay = new _decoratorClass();
                addChild(decoratorDisplay);
            }
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        if (iconFieldChanged)
        {
            iconFieldChanged = false;
            
            // let's see if we need to create or remove it
            if (iconField && !iconDisplay)
            {
                // need to create it
                iconDisplayHolder = new Group();
                
                iconDisplay = new BitmapImage();
                iconDisplay.left = 0;
                iconDisplay.right = 0;
                iconDisplay.top = 0;
                iconDisplay.bottom = 0;
                //				iconDisplay.setStyle("backgroundColor", 0xC0C0C0);
                
                if (_imageCache == null) {
                    _imageCache = new ContentCache();
                    _imageCache.maxCacheEntries = 100;
                }
                iconDisplay.contentLoader = _imageCache;
                
                // add iconDisplayHolder to the display list first in case
                // bitmap needs to check its layoutDirection.
                addChild(iconDisplayHolder);
                iconDisplayHolder.addElement(iconDisplay);
            }
            else if (!iconField && iconDisplay)
            {
                // need to remove it
                removeChild(iconDisplayHolder);
                iconDisplayHolder.removeElement(iconDisplay);
                iconDisplayHolder = null;
                iconDisplay = null;
            }
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        if (dataChanged)
        {
            dataChanged = false;
            
            // if an iconField, try setting that
            if (iconField)
            {
                try
                {
                    if (iconField in data && data[iconField] != null)
                    {
                        iconDisplay.source = data[iconField];
                    }
                }
                catch(e:Error)
                {
                }
            }
            
            invalidateSize();
            invalidateDisplayList();
        }
        
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
     *  Returns the TextFormat object that represents 
     *  character formatting information for this UITextField object.
     *
     *  @return A TextFormat object. 
     *
     *  @see flash.text.TextFormat
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getTextStyles():TextFormat
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
        
        // start them at 0, then go through icon, label, and decorator
        // and add to these
        var myMeasuredWidth:Number = 0;
        var myMeasuredHeight:Number = 0;
        var myMeasuredMinWidth:Number = 0;
        var myMeasuredMinHeight:Number = 0;
        
        // Icon is on left
        if (iconDisplay)
        {
            // padding of 5 on the right...left will be accounted for in the label
            // padding of 10 for height (5 & 5)
            myMeasuredWidth += (isNaN(iconWidth) ? iconDisplay.getPreferredBoundsWidth() : iconWidth) + 5;
            myMeasuredHeight = Math.max(myMeasuredHeight, (isNaN(iconHeight) ? iconDisplay.getPreferredBoundsHeight() : iconHeight) + 10);
            myMeasuredMinWidth += (isNaN(iconWidth) ? iconDisplay.getMinBoundsWidth() : iconWidth) + 5;
            myMeasuredMinHeight += Math.max(myMeasuredMinHeight, (isNaN(iconHeight) ? iconDisplay.getMinBoundsHeight() : iconHeight) + 10);
        }
        
        // Text is aligned next to icon
        
        // FIXME (rfrishbe): will need to change this calculation
        // don't allow text to contribute to width for now
        myMeasuredWidth += labelTextField.textWidth + 5 + 20; // 5 is the extra padding for text field, 20 is normal padding (10 & 10)
        myMeasuredHeight = Math.max(myMeasuredHeight, labelTextField.textHeight + 4 + 10); // 4 is the extra padding for text field, 10 is normal padding (5 & 5)
        
        // don't do anything with regards to minimum for the textField
        
        // Decorator is up next
        if (decoratorDisplay)
        { 
            // padding of 5 on the left...the right is already accounted for in the label
            // padding of 10 for height (5 on top, 5 on bottom)
            if (decoratorDisplay is IVisualElement)
            {
                myMeasuredWidth += IVisualElement(decoratorDisplay).getPreferredBoundsWidth() + 5;
                myMeasuredHeight = Math.max(myMeasuredHeight, IVisualElement(decoratorDisplay).getPreferredBoundsHeight() + 10);
                myMeasuredMinWidth += IVisualElement(decoratorDisplay).getMinBoundsWidth() + 5;
                myMeasuredMinHeight = Math.max(myMeasuredMinHeight, IVisualElement(decoratorDisplay).getMinBoundsHeight() + 10);
            }
            else if (decoratorDisplay is IFlexDisplayObject)
            {
                myMeasuredWidth += IFlexDisplayObject(decoratorDisplay).measuredWidth + 5;
                myMeasuredHeight = Math.max(myMeasuredHeight, IFlexDisplayObject(decoratorDisplay).measuredHeight + 10);
                myMeasuredMinWidth += IFlexDisplayObject(decoratorDisplay).measuredWidth + 5;
                myMeasuredMinHeight = Math.max(myMeasuredMinHeight, IFlexDisplayObject(decoratorDisplay).measuredHeight + 10);
            }
        }
        
        // now set the local variables to the member variables.  Make sure it means our
        // minimum height of 42
        measuredWidth = myMeasuredWidth
        measuredHeight = Math.max(42, myMeasuredHeight);
        
        measuredMinWidth = myMeasuredMinWidth;
        measuredMinHeight = Math.max(42, myMeasuredMinHeight);
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        graphics.clear();
        
        // figure out backgroundColor
        var backgroundColor:uint;
        var drawBackground:Boolean = true;
        if (selected)
            backgroundColor = getStyle("selectionColor");
        else if (hovered)
            backgroundColor = getStyle("rollOverColor");
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
        
        // draw cackgroundColor
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
        
        // draw seperators: two lines
        // 1 pixel from bottom
        graphics.lineStyle(1, 0x1C1C1C);
        graphics.moveTo(0, unscaledHeight-1);
        graphics.lineTo(unscaledWidth, unscaledHeight-1);
        
        // line on the bottom
        graphics.lineStyle(1, 0x606060);
        graphics.moveTo(0, unscaledHeight);
        graphics.lineTo(unscaledWidth, unscaledHeight);
        
        // start laying out our children now
        var iconWidth:Number = 0;
        var iconHeight:Number = 0;
        var decoratorWidth:Number = 0;
        var decoratorHeight:Number = 0;
        
        // icon is on the left
        if (iconDisplay)
        {
            // set the icon's position and size
            iconDisplayHolder.setLayoutBoundsSize(this.iconWidth, this.iconHeight);
            
            iconWidth = iconDisplay.getLayoutBoundsWidth();
            iconHeight = iconDisplay.getLayoutBoundsHeight();
            
            // three from the left and center vertically
            iconDisplayHolder.setLayoutBoundsPosition(10, (unscaledHeight - iconHeight)/2);
        }
        
        // decorator is aligned next to icon
        if (decoratorDisplay)
        {
            if (decoratorDisplay is IVisualElement)
            {
                var decoratorVisualElement:IVisualElement = IVisualElement(decoratorDisplay);
                decoratorVisualElement.setLayoutBoundsSize(NaN, NaN);
                
                decoratorWidth = decoratorVisualElement.getLayoutBoundsWidth();
                decoratorHeight = decoratorVisualElement.getLayoutBoundsHeight();
                
                // three from right and center vertically
                decoratorVisualElement.setLayoutBoundsPosition(unscaledWidth - 10 - decoratorWidth, (unscaledHeight - decoratorHeight)/2);
            }
            else if (decoratorDisplay is IFlexDisplayObject)
            {
                decoratorWidth = IFlexDisplayObject(decoratorDisplay).measuredWidth;
                decoratorHeight = IFlexDisplayObject(decoratorDisplay).measuredHeight;
                
                IFlexDisplayObject(decoratorDisplay).setActualSize(decoratorWidth, decoratorHeight);
                
                // three from right and center vertically
                IFlexDisplayObject(decoratorDisplay).move(unscaledWidth - 10 - decoratorWidth, (unscaledHeight - decoratorHeight)/2);
            }
        }
        
        // text should take up the rest of the space
        var labelWidth:Number = unscaledWidth - iconWidth - decoratorWidth;
        labelWidth -= 20; // padding of 10 always on left and right
        
        // don't forget the extra padding of 5 if these elements exist
        if (iconDisplay)
            labelWidth -= 5;
        if (decoratorDisplay)
            labelWidth -= 5;
        
        // padding of 5 from the left
        var labelX:Number = 10;
        if (iconDisplay)
            labelX += iconWidth + 5;
        
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
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
//  Styles
//--------------------------------------

include "../styles/metadata/GapStyles.as"

/**
 *  Name of the CSS Style declaration to use for the styles for the
 *  header component.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="headerStyleName", type="String", inherit="no")]

/**
 *  Name of the CSS Style declaration to use for the styles for the
 *  subText component.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="subTextStyleName", type="String", inherit="no")]

/**
 *  The MobileIconItemRenderer class is a performant item 
 *  renderer optimized for mobile devices.  It contains 
 *  four optional parts: 1) an icon on the left, 2) headerText 
 *  on top next to the icon, 3) subText below headerText and 
 *  next to the icon, and 4) a decorator on the right.
 *
 *  @see spark.components.List
 *  @see mx.core.IDataRenderer
 *  @see spark.components.IItemRenderer
 *  @see spark.components.supportClasses.ItemRenderer
 *  @see spark.components.MobileItemRenderer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class MobileIconItemRenderer extends MobileItemRenderer
{
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Icon image cache
     */
    static private var _imageCache:ContentCache;
    
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
    public function MobileIconItemRenderer()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Public Properties 
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private var dataChanged:Boolean;
    
    /**
     *  @private
     */
    override public function set data(value:Object):void
    {
        super.data = value;
        
        dataChanged = true;
        invalidateProperties();
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
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5   
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
    //  headerField
    //----------------------------------
    
    /**
     *  @private
     */
    private var _headerField:String;
    
    /**
     *  @private
     */
    private var headerFieldOrFunctionChanged:Boolean; 
    
    /**
     *  The name of the field in the data provider items to display 
     *  as the header. 
     *  The <code>headerFunction</code> property overrides this property.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get headerField():String
    {
        return _headerField;
    }
    
    /**
     *  @private
     */
    public function set headerField(value:String):void
    {
        if (value == _headerField)
            return;
            
        _headerField = value;
        headerFieldOrFunctionChanged = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  headerFunction
    //----------------------------------
    
    /**
     *  @private
     */
    private var _headerFunction:Function; 
    
    /**
     *  A user-supplied function to run on each item to determine its header.  
     *  The <code>headerFunction</code> property overrides 
     *  the <code>headerField</code> property.
     *
     *  <p>You can supply a <code>headerFunction</code> that finds the 
     *  appropriate fields and returns a displayable string. The 
     *  <code>headerFunction</code> is also good for handling formatting and 
     *  localization.</p>
     *
     *  <p>The header function takes a single argument which is the item in 
     *  the data provider and returns a String.</p>
     *  <pre>
     *  myHeaderFunction(item:Object):String</pre>
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get headerFunction():Function
    {
        return _headerFunction;
    }
    
    /**
     *  @private
     */
    public function set headerFunction(value:Function):void
    {
        if (value == _headerFunction)
            return;
            
        _headerFunction = value;
        headerFieldOrFunctionChanged = true;
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
    private var iconFieldOrFunctionChanged:Boolean;
    
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
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
        iconFieldOrFunctionChanged = true;
        dataChanged = true;
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  iconFunction
    //----------------------------------
    
    /**
     *  @private 
     */ 
    private var _iconFunction:Function;
    
    /**
     *  A user-supplied function to run on each item to determine its icon.  
     *  The <code>iconFunction</code> property overrides 
     *  the <code>iconField</code> property.
     *
     *  <p>You can supply an <code>iconFunction</code> that finds the 
     *  appropriate fields and returns a valid URL or object to be used as 
     *  the icon.</p>
     *
     *  <p>The icon function takes a single argument which is the item in 
     *  the data provider and returns an Object that gets passed to a 
     *  <code>spark.primitives.BitmapImage</code> object as the <code>source</code>
     *  property.  Icon function can return a valid URL pointing to an image 
     *  or a Class file that represents an image.  To see what other types 
     *  of objects can be returned from the icon 
     *  function, check out <code>BitmapImage</code>'s documentation</p>
     *  <pre>
     *  myIconFunction(item:Object):Object</pre>
     *
     *  @default null
     * 
     *  @see spark.primitives.BitmapImage#source
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get iconFunction():Function
    {
        return _iconFunction;
    }
    
    /**
     *  @private
     */ 
    public function set iconFunction(value:Function):void
    {
        if (value == _iconFunction)
            return;
        
        _iconFunction = value;
        iconFieldOrFunctionChanged = true;
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
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
    //  subTextField
    //----------------------------------
    
    /**
     *  @private
     */
    private var _subTextField:String;
    
    /**
     *  @private
     */
    private var subTextFieldOrFunctionChanged:Boolean; 
    
    /**
     *  The name of the field in the data provider items to display 
     *  as the subText. 
     *  The <code>subTextFunction</code> property overrides this property.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get subTextField():String
    {
        // FIXME (rfrishbe): PARB this property name b/c confusing with "TextField" the component
        return _subTextField;
    }
    
    /**
     *  @private
     */
    public function set subTextField(value:String):void
    {
        if (value == _subTextField)
            return;
        
        _subTextField = value;
        subTextFieldOrFunctionChanged = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  subTextFunction
    //----------------------------------
    
    /**
     *  @private
     */
    private var _subTextFunction:Function;
    
    /**
     *  A user-supplied function to run on each item to determine its subText.  
     *  The <code>subTextFunction</code> property overrides 
     *  the <code>subTextField</code> property.
     *
     *  <p>You can supply a <code>subTextFunction</code> that finds the 
     *  appropriate fields and returns a displayable string. The 
     *  <code>subTextFunction</code> is also good for handling formatting and 
     *  localization.</p>
     *
     *  <p>The subText function takes a single argument which is the item in 
     *  the data provider and returns a String.</p>
     *  <pre>
     *  mySubTextFunction(item:Object):String</pre>
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get subTextFunction():Function
    {
        return _subTextFunction;
    }
    
    /**
     *  @private
     */
    public function set subTextFunction(value:Function):void
    {
        if (value == _subTextFunction)
            return;
        
        _subTextFunction = value;
        subTextFieldOrFunctionChanged = true;
        invalidateProperties(); 
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
        
        // create any children you need in here
        
        // iconDisplay, subTextDisplay, and decoratorDisplay are created in 
        // commitProperties() since they are dependent on 
        // other properties and we don't always create them
        // headerText just uses labelElement to display its data
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
        
        // FIXME (rfrishbe): handle iconFunction in here as well
        if (iconFieldOrFunctionChanged)
        {
            iconFieldOrFunctionChanged = false;
            
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
        
        // FIXME (rfrishbe): use padding and gaps
        // Icon is on left
        if (iconDisplay)
        {
            // padding of 5 on the right...left will be accounted for in the label
            // padding of 10 for height (5 & 5)
            myMeasuredWidth += (isNaN(iconWidth) ? iconDisplay.getPreferredBoundsWidth() : iconWidth) + 5;
            myMeasuredHeight = Math.max(myMeasuredHeight, (isNaN(iconHeight) ? iconDisplay.getPreferredBoundsHeight() : iconHeight) + 10);
            myMeasuredMinWidth += (isNaN(iconWidth) ? iconDisplay.getMinBoundsWidth() : iconWidth) + 5;
            myMeasuredMinHeight = Math.max(myMeasuredMinHeight, (isNaN(iconHeight) ? iconDisplay.getMinBoundsHeight() : iconHeight) + 10);
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
        // minimum height of 80
        measuredWidth = myMeasuredWidth
        measuredHeight = Math.max(80, myMeasuredHeight);
        
        measuredMinWidth = myMeasuredMinWidth;
        measuredMinHeight = Math.max(80, myMeasuredMinHeight);
    }
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number,
                                               unscaledHeight:Number):void
    {
        // no need to call super.layoutContents() since we're changing how it happens here
        
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

        // FIXME (rfrishbe): update for subText and header and use padding and gaps
        
        // text should take up the rest of the space
        var labelWidth:Number = unscaledWidth - iconWidth - decoratorWidth;
        labelWidth -= (getStyle("paddingLeft") + getStyle("paddingRight"));
        
        // don't forget the extra padding of 5 if these elements exist
        if (iconDisplay)
            labelWidth -= getStyle("horizontalGap");
        if (decoratorDisplay)
            labelWidth -= getStyle("horizontalGap");
        
        // padding of 5 from the left
        var labelX:Number = getStyle("paddingLeft");
        if (iconDisplay)
            labelX += iconWidth + getStyle("horizontalGap");
        
        labelTextField.width = labelWidth;
        labelTextField.height = labelTextField.textHeight + 4; // 4 is text field padding
        
        labelTextField.x = labelX;
        labelTextField.y = (unscaledHeight - labelTextField.height)/2;
    }
    
}
    
}
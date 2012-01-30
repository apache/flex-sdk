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
import mx.core.UITextField;
import mx.core.UITextFormat;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.styles.CSSStyleDeclaration;
import mx.styles.IStyleClient;
import mx.utils.StringUtil;

import spark.components.Group;
import spark.components.IItemRenderer;
import spark.components.Image;
import spark.components.Label;
import spark.components.supportClasses.MobileTextField;
import spark.components.supportClasses.TextBase;
import spark.core.ContentCache;
import spark.core.IContentLoader;
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
 *  message component.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="messageStyleName", type="String", inherit="no")]

/**
 *  The MobileIconItemRenderer class is a performant item 
 *  renderer optimized for mobile devices.  It contains 
 *  four optional parts: 1) an icon on the left, 2) header 
 *  on top next to the icon, 3) message below header and 
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
     *  Static icon image cache.  This is the default for iconContentLoader.
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
        
        if (_imageCache == null) {
            _imageCache = new ContentCache();
            _imageCache.maxCacheEntries = 100;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Holds the styles specific to the header object based on headerStyleName
     */
    private var headerStyles:CSSStyleDeclaration;
    
    /**
     *  @private
     *  Cached UITextFormat object used for measurement purposes for header
     */
    private var cachedHeaderFormat:UITextFormat;
    
    /**
     *  @private
     *  Stores the text of the header component.  This is calculated in 
     *  commitProperties() based on headerField and headerFunction.
     * 
     *  <p>We can't just use labelDisplay.text because it may contain 
     *  a truncated value.</p>
     */
    private var headerText:String = "";
    
    /**
     *  @private
     *  Holds the styles specific to the message object based on messageStyleName
     */
    private var messageStyles:CSSStyleDeclaration;
    
    /**
     *  @private
     *  Cached UITextFormat object used for measurement purposes for message
     */
    private var cachedSubTextFormat:UITextFormat;
    
    /**
     *  @private
     *  Stores the text of the message component.  This is calculated in 
     *  commitProperties() based on messageField and messageFunction.
     * 
     *  <p>We can't just use messageDisplay.text because it may contain 
     *  a truncated value (Technically we don't truncate message's text 
     *  at the moment because it's multi-line text, but in the future 
     *  we may not do that, and this feels more consistent with 
     *  how we deal with headers, so we still keep this "extra"
     *  variable around even though technically it's not needed.</p>
     */
    private var messageText:String = "";
    
    //--------------------------------------------------------------------------
    //
    //  Public Properties: Overridden
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
    
    /**
     *  @private
     */
    override public function set label(value:String):void
    {
        super.label = value;
        
        dataChanged = true;
        invalidateProperties();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Public Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  iconContentLoader
    //----------------------------------
    
    /**
     *  @private 
     */ 
    private var _iconContentLoader:IContentLoader = _imageCache;
    
    
    /**
     *  Optional custom image loader (e.g. image cache or queue) to
     *  associate with content loader client.
     * 
     *  <p>The default is a static content cache defined on MobileIconItemRenderer
     *  that allows up to 100 entries.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5   
     */
    public function get iconContentLoader():IContentLoader
    {
        return _iconContentLoader;
    }
    
    /**
     *  @private
     */ 
    public function set iconContentLoader(value:IContentLoader):void
    {
        if (value == _iconContentLoader)
            return;
        
        _iconContentLoader = value;
        
        if (iconDisplay)
            iconDisplay.contentLoader = _iconContentLoader;
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
     *  of this item renderer.
     * 
     *  <p>The decorator ignores the verticalAlign style
     *  and is always centered vertically.</p>
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
        dataChanged = true;
        
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
        dataChanged = true;
        
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
    //  messageField
    //----------------------------------
    
    /**
     *  @private
     */
    private var _messageField:String;
    
    /**
     *  @private
     */
    private var messageDisplay:MobileTextField;
    
    /**
     *  @private
     */
    private var messageFieldOrFunctionChanged:Boolean; 
    
    /**
     *  The name of the field in the data provider items to display 
     *  as the message. 
     *  The <code>messageFunction</code> property overrides this property.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get messageField():String
    {
        return _messageField;
    }
    
    /**
     *  @private
     */
    public function set messageField(value:String):void
    {
        if (value == _messageField)
            return;
        
        _messageField = value;
        messageFieldOrFunctionChanged = true;
        dataChanged = true;
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  messageFunction
    //----------------------------------
    
    /**
     *  @private
     */
    private var _messageFunction:Function;
    
    /**
     *  A user-supplied function to run on each item to determine its message.  
     *  The <code>messageFunction</code> property overrides 
     *  the <code>messageField</code> property.
     *
     *  <p>You can supply a <code>messageFunction</code> that finds the 
     *  appropriate fields and returns a displayable string. The 
     *  <code>messageFunction</code> is also good for handling formatting and 
     *  localization.</p>
     *
     *  <p>The message function takes a single argument which is the item in 
     *  the data provider and returns a String.</p>
     *  <pre>
     *  myMessageFunction(item:Object):String</pre>
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get messageFunction():Function
    {
        return _messageFunction;
    }
    
    /**
     *  @private
     */
    public function set messageFunction(value:Function):void
    {
        if (value == _messageFunction)
            return;
        
        _messageFunction = value;
        messageFieldOrFunctionChanged = true;
        dataChanged = true;
        
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
        
        // since labelDisplay gets created in super.createChildren(), lets make 
        // sure it's using the right styles
        labelDisplay.getStyleFunction = headerGetStyleFunction;
        headerFieldOrFunctionChanged = true;
        invalidateProperties();
        
        // iconDisplay, messageDisplay, and decoratorDisplay are created in 
        // commitProperties() since they are dependent on 
        // other properties and we don't always create them
        // headerText just uses labelElement to display its data
    }
    
    /**
     *  @private
     */
    override public function notifyStyleChangeInChildren(styleProp:String, recursive:Boolean):void
    {
        super.notifyStyleChangeInChildren(styleProp, recursive);
        
        cachedHeaderFormat = null;
        cachedSubTextFormat = null;
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleName:String):void
    {
        var allStyles:Boolean = !styleName || styleName == "styleName";
        
        super.styleChanged(styleName);
        
        // if header styles may have changed, let's null out the old 
        // value and notify labelDisplay
        if (allStyles || styleName == "headerStyleName")
        {
            headerStyles = null;
            if (labelDisplay)
                labelDisplay.styleChanged("styleName");
        }
        
        // if message styles may have changed, let's null out the old 
        // value and notify messageDisplay
        if (allStyles || styleName == "messageStyleName")
        {
            messageStyles = null;
            if (messageDisplay)
                messageDisplay.styleChanged("styleName");
        }
        
        // pass all style changes to labelTextField and messageField
        // It will deal with them appropriatley and in a performant manner
        if (labelDisplay)
            labelDisplay.styleChanged(styleName);
        if (messageDisplay)
            messageDisplay.styleChanged(styleName);
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
        
        if (iconFieldOrFunctionChanged)
        {
            iconFieldOrFunctionChanged = false;
            
            // let's see if we need to create or remove it
            if ((iconField || (iconFunction != null)) && !iconDisplay)
            {
                // need to create it
                iconDisplayHolder = new Group();
                
                iconDisplay = new BitmapImage();
                iconDisplay.left = 0;
                iconDisplay.right = 0;
                iconDisplay.top = 0;
                iconDisplay.bottom = 0;
                
                iconDisplay.contentLoader = iconContentLoader;
                
                // add iconDisplayHolder to the display list first in case
                // bitmap needs to check its layoutDirection.
                addChild(iconDisplayHolder);
                iconDisplayHolder.addElement(iconDisplay);
            }
            else if (!(iconField || (iconFunction != null)) && iconDisplay)
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
        
        if (messageFieldOrFunctionChanged)
        {
            messageFieldOrFunctionChanged = false;
            
            // let's see if we need to create or remove it
            if ((messageField || (messageFunction != null)) && !messageDisplay)
            {
                // get styles for this text component
                
                // need to create it
                messageDisplay = MobileTextField(createInFontContext(MobileTextField));
                messageDisplay.getStyleFunction = messageGetStyleFunction;
                messageDisplay.editable = false;
                messageDisplay.selectable = false;
                messageDisplay.multiline = true;
                messageDisplay.wordWrap = true;
                
                addChild(messageDisplay);
            }
            else if (!(messageField || (messageFunction != null)) && messageDisplay)
            {
                // need to remove it
                removeChild(messageDisplay);
                messageDisplay = null;
            }
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        if (headerFieldOrFunctionChanged)
        {
            headerFieldOrFunctionChanged = false;
            
            // let's see if we need to create or remove it
            if ((headerField || (headerFunction != null)) && !labelDisplay)
            {
                // get styles for this text component
                
                // need to create it
                labelDisplay = MobileTextField(createInFontContext(MobileTextField));
                labelDisplay.getStyleFunction = headerGetStyleFunction;
                labelDisplay.editable = false;
                labelDisplay.selectable = false;
                labelDisplay.multiline = false;
                labelDisplay.wordWrap = true;
                
                addChild(labelDisplay);
            }
            else if (!(headerField || (headerFunction != null)) && labelDisplay)
            {
                // need to remove it
                removeChild(labelDisplay);
                labelDisplay = null;
            }
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        if (dataChanged)
        {
            dataChanged = false;
            
            // if icon, try setting that
            if (iconFunction != null)
            {
                iconDisplay.source = iconFunction(data);
            }
            else if (iconField)
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
            
            // if message, try setting that
            if (messageFunction != null)
            {
                messageText = messageFunction(data);
                messageDisplay.text = messageText;
            }
            else if (messageField)
            {
                try
                {
                    if (messageField in data && data[messageField] != null)
                    {
                        messageText = data[messageField];
                        messageDisplay.text = messageText;
                    }
                }
                catch(e:Error)
                {
                }
            }
            
            // if header, try setting that
            if (headerFunction != null)
            {
                headerText = headerFunction(data)
                labelDisplay.text = headerText;
            }
            else if (headerField)
            {
                try
                {
                    if (headerField in data && data[headerField] != null)
                    {
                        headerText = data[headerField];
                        labelDisplay.text = headerText;
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
        
        // Icon is on left
        if (iconDisplay)
        {
            var myIconWidth:Number = (isNaN(iconWidth) ? iconDisplay.getPreferredBoundsWidth() : iconWidth);
            var myIconHeight:Number = (isNaN(iconHeight) ? iconDisplay.getPreferredBoundsHeight() : iconHeight);
            
            myMeasuredWidth += iconWidth;
            myMeasuredHeight = Math.max(myMeasuredHeight, myIconHeight);
            myMeasuredMinWidth += iconWidth;
            myMeasuredMinHeight = Math.max(myMeasuredMinHeight, myIconHeight);
        }
        
        // Text is aligned next to icon
        var labelLineMetrics:TextLineMetrics;
        var labelWidth:Number;
        var labelHeight:Number;
        var messageLineMetrics:TextLineMetrics;
        var messageWidth:Number;
        var messageHeight:Number;
        if (labelDisplay && messageDisplay)
        {
            labelLineMetrics = measureHeaderText(headerText);
            
            labelWidth = labelLineMetrics.width + UITextField.TEXT_WIDTH_PADDING;
            labelHeight = labelLineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
            
            messageLineMetrics = measureSubTextText(messageText);
            
            messageWidth = messageLineMetrics.width + UITextField.TEXT_WIDTH_PADDING;
            messageHeight = messageLineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
            
            myMeasuredWidth += Math.max(labelWidth, messageWidth);
            myMeasuredHeight = Math.max(myMeasuredHeight, labelHeight + messageHeight);
        }
        else if (labelDisplay && !messageDisplay)
        {
            labelLineMetrics = measureHeaderText(headerText);
            
            labelWidth = labelLineMetrics.width + UITextField.TEXT_WIDTH_PADDING;
            labelHeight = labelLineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
            
            myMeasuredWidth += labelWidth;
            myMeasuredHeight = Math.max(myMeasuredHeight, labelHeight);
        }
        else if (!labelDisplay && messageDisplay)
        {
            messageLineMetrics = measureSubTextText(messageText);
            
            messageWidth = messageLineMetrics.width + UITextField.TEXT_WIDTH_PADDING;
            messageHeight = messageLineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
            
            myMeasuredWidth += messageWidth;
            myMeasuredHeight = Math.max(myMeasuredHeight, messageHeight);
        }
        
        // Decorator is up next
        if (decoratorDisplay)
        { 
            if (decoratorDisplay is IVisualElement)
            {
                myMeasuredWidth += IVisualElement(decoratorDisplay).getPreferredBoundsWidth();
                myMeasuredHeight = Math.max(myMeasuredHeight, IVisualElement(decoratorDisplay).getPreferredBoundsHeight());
                myMeasuredMinWidth += IVisualElement(decoratorDisplay).getMinBoundsWidth();
                myMeasuredMinHeight = Math.max(myMeasuredMinHeight, IVisualElement(decoratorDisplay).getMinBoundsHeight());
            }
            else if (decoratorDisplay is IFlexDisplayObject)
            {
                myMeasuredWidth += IFlexDisplayObject(decoratorDisplay).measuredWidth;
                myMeasuredHeight = Math.max(myMeasuredHeight, IFlexDisplayObject(decoratorDisplay).measuredHeight);
                myMeasuredMinWidth += IFlexDisplayObject(decoratorDisplay).measuredWidth;
                myMeasuredMinHeight = Math.max(myMeasuredMinHeight, IFlexDisplayObject(decoratorDisplay).measuredHeight);
            }
        }
        
        // now to add on padding and horizontal gap
        var numHorizontalSections:int = 0;
        var numVerticalSections:int = 0;
        if (iconDisplay)
            numHorizontalSections++;
        
        if (decoratorDisplay)
            numHorizontalSections++;
        
        if (labelDisplay && messageDisplay)
        {
            numHorizontalSections++;
            numVerticalSections = 2;
        }
        else if (labelDisplay || messageDisplay)
        {
            numHorizontalSections++;
            numVerticalSections = 1;
        }
        else if (!labelDisplay && !messageDisplay)
        {
            numVerticalSections = 1;
        }
        
        var extraWidth:Number = getStyle("paddingLeft") + getStyle("paddingRight");
        if (numHorizontalSections > 0)
            extraWidth += (getStyle("horizontalGap") * (numHorizontalSections - 1));
        var extraHeight:Number = getStyle("paddingTop") + getStyle("paddingBottom");
        if (numVerticalSections == 2)
            extraHeight += getStyle("verticalGap");
        
        myMeasuredWidth += extraWidth;
        myMeasuredMinWidth += extraWidth;
        myMeasuredHeight += extraHeight;
        myMeasuredMinHeight += extraHeight;
        
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
        
        var paddingLeft:Number = getStyle("paddingLeft");
        var paddingRight:Number = getStyle("paddingRight");
        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");
        
        var viewWidth:Number = unscaledWidth - paddingLeft - paddingRight;
        var viewHeight:Number = unscaledHeight - paddingTop - paddingBottom;
        
        // icon is on the left
        if (iconDisplay)
        {
            // set the icon's position and size
            iconDisplayHolder.setLayoutBoundsSize(this.iconWidth, this.iconHeight);
            
            iconWidth = iconDisplay.getLayoutBoundsWidth();
            iconHeight = iconDisplay.getLayoutBoundsHeight();
            
            // paddingLeft for x, paddingTop for y
            iconDisplayHolder.setLayoutBoundsPosition(paddingLeft, paddingTop);
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
                
                // paddingRight from right and center vertically
                decoratorVisualElement.setLayoutBoundsPosition(unscaledWidth - paddingRight - decoratorWidth, (viewHeight - decoratorHeight)/2 + paddingTop);
            }
            else if (decoratorDisplay is IFlexDisplayObject)
            {
                decoratorWidth = IFlexDisplayObject(decoratorDisplay).measuredWidth;
                decoratorHeight = IFlexDisplayObject(decoratorDisplay).measuredHeight;
                
                IFlexDisplayObject(decoratorDisplay).setActualSize(decoratorWidth, decoratorHeight);
                
                // paddingRight from right and center vertically
                IFlexDisplayObject(decoratorDisplay).move(unscaledWidth - paddingRight - decoratorWidth, (viewHeight - decoratorHeight)/2 + paddingTop);
            }
        }

        // Figure out how much space we have for header and message as well as the 
        // starting left position
        var labelComponentsViewWidth:Number = viewWidth - iconWidth - decoratorWidth;
        
        // don't forget the extra gap padding if these elements exist
        if (iconDisplay)
            labelComponentsViewWidth -= getStyle("horizontalGap");
        if (decoratorDisplay)
            labelComponentsViewWidth -= getStyle("horizontalGap");
        
        var labelComponentsX:Number = getStyle("paddingLeft");
        if (iconDisplay)
            labelComponentsX += iconWidth + getStyle("horizontalGap");
        
        // calculte the natural sizes for header and message (if present)
        var headerTextWidth:Number = 0;
        var headerTextHeight:Number = 0;
        var headerLineMetrics:TextLineMetrics;
        
        if (labelDisplay && labelDisplay.text != "")
        {
            labelDisplay.commitStyles();
            headerLineMetrics = measureHeaderText(headerText);
            headerTextWidth = headerLineMetrics.width + UITextField.TEXT_WIDTH_PADDING;
            headerTextHeight = headerLineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
        }
        
        if (messageDisplay && messageDisplay.text != "")
        {
            messageDisplay.commitStyles();
            // no need to measure the text width and height since the measure function only 
            // take in to account the first line.
        }
        
        // now size and position the elements, 3 different configurations we care about:
        // 1) header and message
        // 2) header only
        // 3) message only
        
        // label display goes on top
        // subtext display goes below
        
        var headerWidth:Number = 0;
        var headerHeight:Number = 0;
        var messageWidth:Number = 0;
        var messageHeight:Number = 0;
        var verticalGap:Number = 0;
        
        if (labelDisplay)
        {
            verticalGap = 0;
            
            // handle labelDisplay.  it can only be 1 line
            
            headerWidth = Math.max(Math.min(labelComponentsViewWidth, headerTextWidth), 0);
            headerHeight = Math.max(Math.min(viewHeight, headerTextHeight), 0);
            
            labelDisplay.width = headerWidth;
            labelDisplay.height = headerHeight;
            
            labelDisplay.x = Math.round(labelComponentsX);
            labelDisplay.y = Math.round(paddingTop);
            
            // reset text if it was truncated before.  then attempt to truncate it
            if (labelDisplay.isTruncated)
                labelDisplay.text = headerText;
            labelDisplay.truncateToFit();
        }
        
        if (messageDisplay)
        {
            // handle message
            // don't use the measured text width or height because that only takes the first line in to account
            messageWidth = Math.max(labelComponentsViewWidth, 0);
            messageHeight = Math.max(viewHeight - headerHeight - verticalGap, 0);
            
            messageDisplay.width = messageWidth;
            messageDisplay.height = messageHeight;
            
            // FIXME (rfrishbe): figure out if this is right with regards to multi-line text.
            // For instance, if the text component spans to 2 lines but only shows one line, then textHeight here 
            // is the size of the two line text.  We take the minimum with messageHeight to make sure 
            // we don't position it outside of the item renderer's bounds later on, but this 
            // calculation still isn't correct.  We basically want the textHeight for the number of 
            // displayed lines.
            messageHeight = Math.min(messageHeight, messageDisplay.textHeight + UITextField.TEXT_HEIGHT_PADDING);
            
            messageDisplay.x = Math.round(labelComponentsX);
            messageDisplay.y = Math.round(paddingTop + headerHeight + verticalGap);
            
            // since it's multi-line, no need to truncate
            //if (messageDisplay.isTruncated)
            //    messageDisplay.text = messageText;
            //messageDisplay.truncateToFit();
        }
        
        // revisit y positions now that we know all heights so we can respect verticalAlign style
        if (getStyle("verticalAlign") == "top")
        {
            // don't do anything...already aligned to top in code above
        }
        else if (getStyle("verticalAlign") == "bottom")
        {
            if (iconDisplay)
                iconDisplayHolder.setLayoutBoundsPosition(paddingLeft, unscaledHeight - iconHeight - paddingBottom);
            if (messageDisplay)
                messageDisplay.y = unscaledHeight - paddingBottom - messageHeight;
            if (labelDisplay)
                labelDisplay.y = unscaledHeight - paddingBottom - messageHeight - verticalGap - headerHeight;
        }
        else //if (getStyle("verticalAlign") == "middle")
        {
            if (iconDisplay)
                iconDisplayHolder.setLayoutBoundsPosition(paddingLeft, Math.round((unscaledHeight - iconHeight)/2));
            var textTotalHeight:Number = headerHeight + messageHeight + verticalGap;
            if (labelDisplay)
                labelDisplay.y = Math.round((unscaledHeight - textTotalHeight)/2);
            if (messageDisplay)
                messageDisplay.y = Math.round((unscaledHeight - textTotalHeight)/2 + verticalGap + headerHeight);
        }
        // made "middle" last even though it's most likely so it is the default and if someone 
        // types "center", then it will still vertically center itself.
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods: Helper functions for determining styles for header and message
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     *  Function we pass in to header for it to grab the styles and push 
     *  them in to the TextFormat object used by that MobileTextField.
     */
    private function headerGetStyleFunction(styleProp:String):*
    {
        // grab the header specific styles
        if (!headerStyles)
            headerStyles = styleManager.getStyleDeclaration("." + getStyle("headerStyleName"));
        
        // see if they are in the header styles
        var styleValue:*;
        if (headerStyles)
            styleValue = headerStyles.getStyle(styleProp);
        
        // if they are not there, try grabbing it from this component directly
        if (styleValue === undefined)
            styleValue = getStyle(styleProp);
        
        return styleValue;
    }
    
    /**
     *  @private 
     *  Function we pass in to message for it to grab the styles and push 
     *  them in to the TextFormat object used by that MobileTextField.
     */
    private function messageGetStyleFunction(styleProp:String):*
    {
        // grab the message specific styles
        if (!messageStyles)
            messageStyles = styleManager.getStyleDeclaration("." + getStyle("messageStyleName"));
        
        // see if they are in the message styles
        var styleValue:*;
        if (messageStyles)
            styleValue = messageStyles.getStyle(styleProp);
        
        // if they are not there, try grabbing it from this component directly
        if (styleValue === undefined)
            styleValue = getStyle(styleProp);
        
        return styleValue;
    }
    
    /**
     *  @private 
     *  Function to help figure out the sizes of the header and message.  We cannot use 
     *  UIComponent.measureText() because we are adding a few additional styles 
     *  to it based on headerStyleName and messageStyleName.
     */
    private function measureHeaderText(text:String):TextLineMetrics
    {
        // Copied from UIComponent.measureText()
        cachedHeaderFormat = determineTextFormatWithGetStyleFunction(headerGetStyleFunction, cachedHeaderFormat);
        return cachedHeaderFormat.measureText(text);
    }
    
    /**
     *  @private 
     *  Function to help figure out the sizes of the header and message.  We cannot use 
     *  UIComponent.measureText() because we are adding a few additional styles 
     *  to it based on headerStyleName and messageStyleName.
     */
    private function measureSubTextText(text:String):TextLineMetrics
    {
        // Copied from UIComponent.measureText()
        cachedSubTextFormat = determineTextFormatWithGetStyleFunction(messageGetStyleFunction, cachedSubTextFormat);
        return cachedSubTextFormat.measureText(text);
    }
    
    /**
     *  @private 
     *  Function to help figure out the sizes of the header and message.  We cannot use 
     *  UIComponent.measureText() because we are adding a few additional styles 
     *  to it based on headerStyleName and messageStyleName.
     */
    private function determineTextFormatWithGetStyleFunction(getStyleFunction:Function, cachedTextFormat:UITextFormat):UITextFormat
    {
        // copied and adapted from UIComponent.determineTextFormatFromStyles
        var textFormat:UITextFormat = cachedTextFormat;
        
        if (!textFormat)
        {
            var font:String =
                StringUtil.trimArrayElements(getStyleFunction("fontFamily"), ",");
            textFormat = new UITextFormat(getNonNullSystemManager(), font);
            textFormat.moduleFactory = moduleFactory;
            
            // Not all flex4 textAlign values are valid so convert to a valid one.
            var align:String = getStyleFunction("textAlign");
            if (align == "start") 
                align = TextFormatAlign.LEFT;
            else if (align == "end")
                align = TextFormatAlign.RIGHT;
            textFormat.align = align; 
            textFormat.bold = getStyleFunction("fontWeight") == "bold";
            textFormat.color = enabled ?
                getStyleFunction("color") :
                getStyleFunction("disabledColor");
            textFormat.font = font;
            textFormat.indent = getStyleFunction("textIndex");
            textFormat.italic = getStyleFunction("fontStyle") == "italic";
            textFormat.kerning = getStyleFunction("kerning");
            textFormat.leading = getStyleFunction("leading");
            textFormat.leftMargin = getStyleFunction("paddingLeft"); // FIXME (rfrishbe): should these be in here...?
            textFormat.letterSpacing = getStyleFunction("letterSpacing")
            textFormat.rightMargin = getStyleFunction("paddingRight");
            textFormat.size = getStyleFunction("fontSize");
            textFormat.underline =
                getStyleFunction("textDecoration") == "underline";
            
            textFormat.antiAliasType = getStyleFunction("fontAntiAliasType");
            textFormat.gridFitType = getStyleFunction("fontGridFitType");
            textFormat.sharpness = getStyleFunction("fontSharpness");
            textFormat.thickness = getStyleFunction("fontThickness");
            
            //textFormat.useFTE =
            //    getTextFieldClassName() == "mx.core::UIFTETextField" ||
            //    getTextInputClassName() == "mx.controls::MXFTETextInput";
            
            //if (textFormat.useFTE)
            //{
            //    textFormat.direction = getStyleFunction("direction");
            //    textFormat.locale = getStyleFunction("locale");
            //}
            
            cachedTextFormat = textFormat;
        }
        
        return textFormat;
    }
    
}
    
}
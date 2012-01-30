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
import mx.graphics.BitmapFillMode;
import mx.graphics.BitmapScaleMode;
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
 *  four optional parts: 1) an icon on the left, 2) single-line label 
 *  on top next to the icon, 3) multi-line message below label and 
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
    static mx_internal var _imageCache:ContentCache;
    
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
     *  Holds the styles specific to the message object based on messageStyleName
     */
    private var messageStyles:CSSStyleDeclaration;
    
    /**
     *  @private
     *  Cached UITextFormat object used for measurement purposes for message
     */
    private var cachedMessageTextFormat:UITextFormat;
    
    /**
     *  @private
     *  Stores the text of the label component.  This is calculated in 
     *  commitProperties() based on labelFunction, labelField, and label.
     * 
     *  <p>We can't just use labelDisplay.text because it may contain 
     *  a truncated value.</p>
     */
    private var labelText:String = "";
    
    /**
     *  @private
     *  Stores the text of the message component.  This is calculated in 
     *  commitProperties() based on messageField and messageFunction.
     * 
     *  <p>We can't just use messageDisplay.text because it may contain 
     *  a truncated value (Technically we don't truncate message's text 
     *  at the moment because it's multi-line text, but in the future 
     *  we may not do that, and this feels more consistent with 
     *  how we deal with labels, so we still keep this "extra"
     *  variable around even though technically it's not needed).</p>
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
    override public function set data(value:Object):void
    {
        super.data = value;
        
        iconChanged = true;
        labelChanged = true;
        messageChanged = true;
        
        invalidateProperties();
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p>If no labelFunction and labelField (labelField === <code>null</code>)
     *  are defined on this item renderer,
     *  then we will use the <code>label</code> property that gets 
     *  pushed in from the list via the <code>IItemRenderer</code> contract.  
     *  However if <code>labelField</code> is explicitly set to 
     *  <code>""</code> (the empty string),
     *  then no label will show up at all.</p>
     * 
     *  @see spark.components.MobileIconItemRenderer#labelField
     *  @see spark.components.MobileIconitemRenderer#labelFunction
     *  @see spark.components.IItemRenderer#label
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5   
     */
    override public function set label(value:String):void
    {
        super.label = value;
        
        labelChanged = true;
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
     *  The display object component used to 
     *  display the decorator for this item renderer.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected var decoratorDisplay:DisplayObject;
    
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
    //  labelField
    //----------------------------------
    
    /**
     *  @private
     */
    private var _labelField:String = null;
    
    /**
     *  @private
     */
    private var labelFieldOrFunctionChanged:Boolean;
    
    /**
     *  @private
     */
    private var labelChanged:Boolean; 
    
    /**
     *  The name of the field in the data provider items to display 
     *  as the label. 
     *  The <code>labelFunction</code> property overrides this property.
     * 
     *  <p>If no labelFunction and labelField (labelField === <code>null</code>)
     *  are defined on this item renderer,
     *  then we will use the <code>label</code> property that gets 
     *  pushed in from the list via the <code>IItemRenderer</code> contract.  
     *  However if <code>labelField</code> is explicitly set to 
     *  <code>""</code> (the empty string),
     *  then no label will show up at all.</p>
     * 
     *  @see spark.components.MobileIconItemRenderer#labelFunction
     *  @see spark.components.IItemRenderer#label
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get labelField():String
    {
        return _labelField;
    }
    
    /**
     *  @private
     */
    public function set labelField(value:String):void
    {
        if (value == _labelField)
            return;
            
        _labelField = value;
        labelFieldOrFunctionChanged = true;
        labelChanged = true;
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  labelFunction
    //----------------------------------
    
    /**
     *  @private
     */
    private var _labelFunction:Function; 
    
    /**
     *  A user-supplied function to run on each item to determine its label.  
     *  The <code>labelFunction</code> property overrides 
     *  the <code>labelField</code> property.
     *
     *  <p>You can supply a <code>labelFunction</code> that finds the 
     *  appropriate fields and returns a displayable string. The 
     *  <code>labelFunction</code> is also good for handling formatting and 
     *  localization.</p>
     *
     *  <p>The label function takes a single argument which is the item in 
     *  the data provider and returns a String.</p>
     *  <pre>
     *  myLabelFunction(item:Object):String</pre>
     * 
     *  <p>If no labelFunction and labelField (labelField === <code>null</code>)
     *  are defined on this item renderer,
     *  then we will use the <code>label</code> property that gets 
     *  pushed in from the list via the <code>IItemRenderer</code> contract.  
     *  However if <code>labelField</code> is explicitly set to 
     *  <code>""</code> (the empty string),
     *  then no label will show up at all.</p>
     * 
     *  @see spark.components.MobileIconItemRenderer#labelFunction
     *  @see spark.components.IItemRenderer#label
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get labelFunction():Function
    {
        return _labelFunction;
    }
    
    /**
     *  @private
     */
    public function set labelFunction(value:Function):void
    {
        if (value == _labelFunction)
            return;
            
        _labelFunction = value;
        labelFieldOrFunctionChanged = true;
        labelChanged = true;
        
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
    private var iconChanged:Boolean;
    
    /**
     *  @private
     *  The class to use when instantiating the icon for MobileIconItemRenderer.
     *  This class must extend spark.primitives.BitmapImage.
     *  This property was added for Design View so they can set this to a special
     *  subclass of BitmapImage that knows how to load and resolve resources in Design View.
     */
    mx_internal var iconDisplayClass:Class = BitmapImage;
    
    /**
     *  The bitmap image component used to 
     *  display the icon data of the item renderer.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var iconDisplay:BitmapImage;
    
    /**
     *  The Group that holds the iconDisplay BitmapImage.  
     *  
     *  <p>The Group is necessary since GraphicElements must live inside 
     *  of one.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var iconDisplayHolder:Group;
    // Need a holder for the iconDisplay since it's a GraphicElement
    // TODO (rfrishbe): would be nice to fix above somehow
    
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
        iconChanged = true;
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  iconFillMode
    //----------------------------------
    
    /**
     *  @private 
     */ 
    private var _iconFillMode:String = BitmapFillMode.SCALE;
    
    [Inspectable(category="General", enumeration="clip,repeat,scale", defaultValue="scale")]
    
    /**
     *  @copy spark.components.BitmapImage#fillMode
     *
     *  @default <code>BitmapFillMode.SCALE</code>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get iconFillMode():String
    {
        return _iconFillMode;
    }
    
    /**
     *  @private
     */ 
    public function set iconFillMode(value:String):void
    {
        if (value == _iconFillMode)
            return;
        
        _iconFillMode = value;
        
        if (iconDisplay)
            iconDisplay.fillMode = _iconFillMode;
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
        iconChanged = true;
        
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
    //  iconScaleMode
    //----------------------------------
    
    /**
     *  @private 
     */ 
    private var _iconScaleMode:String = BitmapScaleMode.STRETCH;
    
    [Inspectable(category="General", enumeration="stretch,letterbox", defaultValue="stretch")]
    
    /**
     *  @copy spark.components.BitmapImage#scaleMode
     *
     *  @default <code>BitmapScaleMode.STRETCH</code>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get iconScaleMode():String
    {
        return _iconScaleMode;
    }
    
    /**
     *  @private
     */ 
    public function set iconScaleMode(value:String):void
    {
        if (value == _iconScaleMode)
            return;
        
        _iconScaleMode = value;
        
        if (iconDisplay)
            iconDisplay.scaleMode = _iconScaleMode;
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
     *  The text component used to 
     *  display the message data of the item renderer.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var messageDisplay:MobileTextField;
    
    /**
     *  @private
     */
    private var messageFieldOrFunctionChanged:Boolean;
    
    /**
     *  @private
     */
    private var messageChanged:Boolean;
    
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
        messageChanged = true;
        
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
        messageChanged = true;
        
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
        
        // iconDisplay, messageDisplay, and decoratorDisplay are created in 
        // commitProperties() since they are dependent on 
        // other properties and we don't always create them
        // labelText just uses labelElement to display its data
    }
    
    /**
     *  @private
     */
    override public function notifyStyleChangeInChildren(styleProp:String, recursive:Boolean):void
    {
        super.notifyStyleChangeInChildren(styleProp, recursive);
        
        cachedMessageTextFormat = null;
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleName:String):void
    {
        var allStyles:Boolean = !styleName || styleName == "styleName";
        
        super.styleChanged(styleName);
        
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
                decoratorDisplay = null;
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
                
                iconDisplay = new iconDisplayClass();
                iconDisplay.left = 0;
                iconDisplay.right = 0;
                iconDisplay.top = 0;
                iconDisplay.bottom = 0;
                
                iconDisplay.contentLoader = iconContentLoader;
                iconDisplay.fillMode = iconFillMode;
                iconDisplay.scaleMode = iconScaleMode;
                
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
        
        // label is created in super.createChildren()
        
        if (iconChanged)
        {
            iconChanged = false;
            
            // if icon, try setting that
            if (iconFunction != null)
            {
                iconDisplay.source = iconFunction(data);
            }
            else if (iconField)
            {
                try
                {
                    if (iconField in data)
                    {
                        iconDisplay.source = data[iconField];
                    }
                }
                catch(e:Error)
                {
                    iconDisplay.source = null;
                }
            }
        }
        
        if (messageChanged)
        {
            messageChanged = false;
            
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
                    else
                    {
                        messageText = "";
                        messageDisplay.text = messageText;
                    }
                }
                catch(e:Error)
                {
                    messageText = "";
                    messageDisplay.text = messageText;
                }
            }
        }
        
        if (labelChanged)
        {
            labelChanged = false;
            
            // if label, try setting that
            if (labelFunction != null)
            {
                labelText = labelFunction(data);
                if (!labelDisplay)
                    createLabelDisplay();
                labelDisplay.text = labelText;
            }
            else if (labelField) // if labelField is not null or "", then this is a user-set value
            {
                try
                {
                    if (labelField in data && data[labelField] != null)
                    {
                        labelText = data[labelField];
                        if (!labelDisplay)
                            createLabelDisplay();
                        labelDisplay.text = labelText;
                    }
                    else
                    {
                        labelText = "";
                        if (!labelDisplay)
                            createLabelDisplay();
                        labelDisplay.text = labelText;
                    }
                }
                catch(e:Error)
                {
                    labelText = "";
                    if (!labelDisplay)
                        createLabelDisplay();
                    labelDisplay.text = labelText;
                }
            }
            else if (label && labelField === null) // if there's a label and labelField === null, then show label
            {
                labelText = label;
                if (!labelDisplay)
                    createLabelDisplay();
                labelDisplay.text = labelText;
            }
            else // if labelField === ""
            {
                // get rid of labelDisplay if present
                if (labelDisplay)
                    removeLabelDisplay();
            }
            
            invalidateSize();
            invalidateDisplayList();
        }
    }
    
    /**
     *  @private
     */
    private function createLabelDisplay():void
    {
        // need to create it
        labelDisplay = MobileTextField(createInFontContext(MobileTextField));
        labelDisplay.styleProvider = this;
        labelDisplay.editable = false;
        labelDisplay.selectable = false;
        labelDisplay.multiline = false;
        labelDisplay.wordWrap = false;
        
        addChild(labelDisplay);
    }
    
    /**
     *  @private
     */
    private function removeLabelDisplay():void
    {
        removeChild(labelDisplay);
        labelDisplay = null;
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        // don't call super.measure() because there's no need to do the work that's
        // in there--we do it all in here.
        //super.measure();
        
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
            
            myMeasuredWidth += myIconWidth;
            myMeasuredHeight = Math.max(myMeasuredHeight, myIconHeight);
            myMeasuredMinWidth += myIconWidth;
            myMeasuredMinHeight = Math.max(myMeasuredMinHeight, myIconHeight);
        }
        
        // Text is aligned next to icon
        var labelWidth:Number = 0;
        var labelHeight:Number = 0;
        var messageWidth:Number = 0;
        var messageHeight:Number = 0;
        
        if (labelDisplay)
        {
            // reset text if it was truncated before.
            if (labelDisplay.isTruncated)
                labelDisplay.text = labelText;
            
            // commit styles to get an accurate measurement
            labelDisplay.commitStyles();
            
            labelWidth = labelDisplay.textWidth + UITextField.TEXT_WIDTH_PADDING;
            labelHeight = labelDisplay.textHeight + UITextField.TEXT_HEIGHT_PADDING;
        }
            
        if (messageDisplay)
        {
            // commit styles to get an accurate measurement
            // FIXME (rfrishbe): should take in to account constrainedWidth here
            messageDisplay.commitStyles();
            
            messageWidth = messageDisplay.textWidth + UITextField.TEXT_WIDTH_PADDING;
            messageHeight = messageDisplay.textHeight + UITextField.TEXT_HEIGHT_PADDING;
        }

        var verticalGap:Number = (labelDisplay && messageDisplay) ? getStyle("verticalGap") : 0;
        
        myMeasuredWidth += Math.max(labelWidth, messageWidth);
        myMeasuredHeight = Math.max(myMeasuredHeight, labelHeight + messageHeight + verticalGap);
        
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
        // verticalGap is already handled above when there's a label
        // and a message since that's the only place verticalGap matters
        var numHorizontalSections:int = 0;
        if (iconDisplay)
            numHorizontalSections++;
        
        if (decoratorDisplay)
            numHorizontalSections++;
        
        if (labelDisplay || messageDisplay)
            numHorizontalSections++;
        
        var extraWidth:Number = getStyle("paddingLeft") + getStyle("paddingRight");
        if (numHorizontalSections > 0)
            extraWidth += (getStyle("horizontalGap") * (numHorizontalSections - 1));
        var extraHeight:Number = getStyle("paddingTop") + getStyle("paddingBottom");
        
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

        var paddingLeft:Number   = getStyle("paddingLeft");
        var paddingRight:Number  = getStyle("paddingRight");
        var paddingTop:Number    = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");
        var horizontalGap:Number = getStyle("horizontalGap");
        var verticalAlign:String = getStyle("verticalAlign");
        var verticalGap:Number   = (labelDisplay && messageDisplay) ? getStyle("verticalGap") : 0;

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
        
        // icon is on the left
        if (iconDisplay)
        {
            // set the icon's position and size
            iconDisplayHolder.setLayoutBoundsSize(this.iconWidth, this.iconHeight);
            iconDisplayHolder.setLayoutBoundsPosition(paddingLeft, paddingTop);
            
            iconWidth = iconDisplayHolder.getLayoutBoundsWidth();
            iconHeight = iconDisplayHolder.getLayoutBoundsHeight();
        }
        
        // decorator is aligned next to icon
        if (decoratorDisplay)
        {
            // FIXME (egeorgie): another helper method for getting the preferred size?
            if (decoratorDisplay is IVisualElement)
            {
                var decoratorVisualElement:IVisualElement = IVisualElement(decoratorDisplay);
                decoratorWidth = decoratorVisualElement.getPreferredBoundsWidth();
                decoratorHeight = decoratorVisualElement.getPreferredBoundsHeight();
            }
            else if (decoratorDisplay is IFlexDisplayObject)
            {
                decoratorWidth = IFlexDisplayObject(decoratorDisplay).measuredWidth;
                decoratorHeight = IFlexDisplayObject(decoratorDisplay).measuredHeight;
            }

            resizeElement(decoratorDisplay, decoratorWidth, decoratorHeight);

            // decorator is always right aligned, vertically centered
            var decoratorY:Number = Math.round(0.5 * (viewHeight - decoratorHeight)) + paddingTop;
            positionElement(decoratorDisplay, unscaledWidth - paddingRight - decoratorWidth, decoratorY);
        }

        // Figure out how much space we have for label and message as well as the 
        // starting left position
        var labelComponentsViewWidth:Number = viewWidth - iconWidth - decoratorWidth;
        
        // don't forget the extra gap padding if these elements exist
        if (iconDisplay)
            labelComponentsViewWidth -= horizontalGap;
        if (decoratorDisplay)
            labelComponentsViewWidth -= horizontalGap;
        
        var labelComponentsX:Number = paddingLeft;
        if (iconDisplay)
            labelComponentsX += iconWidth + horizontalGap;
        
        // calculte the natural height for the label
        var labelTextHeight:Number = 0;
        
        if (labelDisplay && labelText != "")
        {
            // reset text if it was truncated before.
            if (labelDisplay.isTruncated)
                labelDisplay.text = labelText;
            
            // commit styles to get an accurate measurement
            labelDisplay.commitStyles();
            labelTextHeight = labelDisplay.textHeight + UITextField.TEXT_HEIGHT_PADDING;
        }
        
        if (messageDisplay && messageText != "")
        {
            // commit styles to get an accurate measurement
            messageDisplay.commitStyles();
        }

        // now size and position the elements, 3 different configurations we care about:
        // 1) label and message
        // 2) label only
        // 3) message only

        // label display goes on top
        // message display goes below

        var labelWidth:Number = 0;
        var labelHeight:Number = 0;
        var messageWidth:Number = 0;
        var messageHeight:Number = 0;

        if (labelDisplay)
        {
            // handle labelDisplay.  it can only be 1 line
            
            // width of label takes up rest of space
            // height only takes up what it needs so we can properly place the message
            // and make sure verticalAlign is operating on a correct value.
            labelWidth = Math.max(labelComponentsViewWidth, 0);
            labelHeight = Math.max(Math.min(viewHeight, labelTextHeight), 0);
            resizeElement(labelDisplay, labelWidth, labelHeight);
            
            // attempt to truncate text
            labelDisplay.truncateToFit();
        }

        if (messageDisplay)
        {
            // handle message
            // don't use the measured text width or height because that only takes the first line in to account
            messageWidth = Math.max(labelComponentsViewWidth, 0);
            messageHeight = Math.max(viewHeight - labelHeight - verticalGap, 0);
            // FIXME (rfrishbe): we should check to see if this causes textHeight to change because then we 
            // might need to remeasure
            resizeElement(messageDisplay, messageWidth, messageHeight);
            
            // FIXME (rfrishbe): figure out if this is right with regards to multi-line text.
            // For instance, if the text component spans to 2 lines but only shows one line, then textHeight here 
            // is the size of the two line text.  We take the minimum with messageHeight to make sure 
            // we don't position it outside of the item renderer's bounds later on, but this 
            // calculation still isn't correct.  We basically want the textHeight for the number of 
            // displayed lines.
            messageHeight = Math.min(messageHeight, messageDisplay.textHeight + UITextField.TEXT_HEIGHT_PADDING);
            
            // since it's multi-line, no need to truncate
            //if (messageDisplay.isTruncated)
            //    messageDisplay.text = messageText;
            //messageDisplay.truncateToFit();
        }

        // Position the text components now that we know all heights so we can respect verticalAlign style
        if (labelDisplay || messageDisplay)
        {
            var totalHeight:Number = labelHeight + messageHeight + verticalGap;
            var labelComponentsY:Number = Math.round(vAlign * (viewHeight - totalHeight)) + paddingTop;

            if (labelDisplay)
                positionElement(labelDisplay, labelComponentsX, labelComponentsY);

            if (messageDisplay)
                positionElement(messageDisplay, labelComponentsX, labelComponentsY + labelHeight + verticalGap);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods: Helper functions for determining styles for message
    //
    //--------------------------------------------------------------------------
    
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
    
}
    
}
////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.graphics.baseClasses
{

import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.text.engine.TextLine;

import flashx.textLayout.formats.LineBreak;

import mx.core.mx_internal;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;
import mx.styles.CSSStyleDeclaration;
import mx.styles.IAdvancedStyleClient;
import mx.styles.StyleManager;
import mx.styles.StyleProtoChain;
import mx.utils.NameUtil;

/**
 *  The base class for GraphicElements such as TextBox and TextGraphic
 *  which display text using CSS styles for the default format.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class TextGraphicElement extends GraphicElement
    implements IAdvancedStyleClient
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Most resources are fetched on the fly from the ResourceManager,
     *  so they automatically get the right resource when the locale changes.
     *  But since truncation can happen frequently,
     *  this class caches this resource value in this variable
     *  and updates it when the locale changes.
     */ 
    mx_internal static var truncationIndicatorResource:String;

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
    public function TextGraphicElement()
    {
        super();

		var resourceManager:IResourceManager = ResourceManager.getInstance();
                                    
		if (!mx_internal::truncationIndicatorResource)
        {
            mx_internal::truncationIndicatorResource = resourceManager.getString(
                "core", "truncationIndicator");
        }
                
        // Register as a weak listener for "change" events from ResourceManager.
        // If UITextFields registered as a strong listener,
        // they wouldn't get garbage collected.
        resourceManager.addEventListener(
            Event.CHANGE, resourceManager_changeHandler, false, 0, true);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
	/**
     *  @private
     *  The composition bounds used when creating the TextLines.
     */
    mx_internal var bounds:Rectangle = new Rectangle(0, 0, NaN, NaN);

    /**
     *  @private
	 *  The TextLines created to render the text.
     */
    mx_internal var textLines:Array = [];
            
    /**
     *  @private
     *  This flag is set to true if the text must be clipped.
     */
    mx_internal var isOverset:Boolean = false;

    /**
     *  @private
     *  This flag is used to avoid getting or setting the scrollRect
     *  of our displayObject unnecessarily when we need to clip TextLines
     *  that extend beyond our bounds.
     *  It shouldn't even be set to null if you can avoid it,
     *  because Player 10.0 allocates a surface even in this case.
     */
    mx_internal var hasScrollRect:Boolean = false;
    
    /**
     *  @private
     */
    mx_internal var stylesChanged:Boolean = false;    

    /**
     *  @private
     *  Cache this since it accessed for every display list update.
     */
    mx_internal var lineBreakToFit:Boolean = true;

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: GraphicElement
    //
    //--------------------------------------------------------------------------
        
    //----------------------------------
    //  baselinePosition
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
        mx_internal::validateBaselinePosition();
        
        // Return the baseline of the first line of composed text.
        return mx_internal::textLines.length > 0 ?
			   mx_internal::textLines[0].y : 0;
    }

    //----------------------------------
    //  needsDisplayObject
    //----------------------------------

    // TODO!!! Always return a DisplayObject for now.
    // We need to optimize this later. 
    
    /**
     *  @private
     */
    override public function canDrawToShared(sharedDisplayObject:DisplayObject):Boolean
    {
        return false;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties: ISimpleStyleClient
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  styleName
    //----------------------------------

    /**
     *  @private
     *  Storage for the styleName property.
     */
    private var _styleName:Object /* String, CSSStyleDeclaration, or UIComponent */;

    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get styleName():Object /* String, CSSStyleDeclaration, or UIComponent */
    {
        return _styleName;
    }

    /**
     *  @private
     */
    public function set styleName(
        value:Object /* String, CSSStyleDeclaration, or UIComponent */):void
    {
        if (value == _styleName)
            return;

        _styleName = value;

        // If inheritingStyles is undefined, then this object is being
        // initialized and we haven't yet generated the proto chain.
        // To avoid redundant work, don't bother to create
        // the proto chain here.
        if (inheritingStyles == StyleProtoChain.STYLE_UNINITIALIZED)
            return;

        regenerateStyleCache(true);

        styleChanged("styleName");
    }

    //--------------------------------------------------------------------------
    //
    //  Properties: IStyleClient
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  className
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get className():String
    {
        return NameUtil.getUnqualifiedClassName(this);
    }
    
    //----------------------------------
    //  inheritingStyles
    //----------------------------------

    /**
     *  @private
     *  Storage for the inheritingStyles property.
     */
    private var _inheritingStyles:Object =
        StyleProtoChain.STYLE_UNINITIALIZED;
    
    [Inspectable(environment="none")]

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get inheritingStyles():Object
    {
        return _inheritingStyles;
    }
    
    /**
     *  @private
     */
    public function set inheritingStyles(value:Object):void
    {
        _inheritingStyles = value;
    }

    //----------------------------------
    //  nonInheritingStyles
    //----------------------------------

    /**
     *  @private
     *  Storage for the nonInheritingStyles property.
     */
    private var _nonInheritingStyles:Object =
        StyleProtoChain.STYLE_UNINITIALIZED;

    [Inspectable(environment="none")]

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get nonInheritingStyles():Object
    {
        return _nonInheritingStyles;
    }

    /**
     *  @private
     */
    public function set nonInheritingStyles(value:Object):void
    {
        _nonInheritingStyles = value;
    }

    //----------------------------------
    //  styleDeclaration
    //----------------------------------

    /**
     *  @private
     *  Storage for the styleDeclaration property.
     */
    private var _styleDeclaration:CSSStyleDeclaration;

    [Inspectable(environment="none")]

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get styleDeclaration():CSSStyleDeclaration
    {
        return _styleDeclaration;
    }

    /**
     *  @private
     */
    public function set styleDeclaration(value:CSSStyleDeclaration):void
    {
        _styleDeclaration = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties: IAdvancedStyleClient
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  styleParent
    //----------------------------------

    /**
     *  The parent of this component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get styleParent():IAdvancedStyleClient
    {
        return parent as IAdvancedStyleClient;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  styleChainInitialized
    //----------------------------------

    /**
     *  @private
     */
    mx_internal function get styleChainInitialized():Boolean
    {
        return _inheritingStyles != StyleProtoChain.STYLE_UNINITIALIZED &&
               _nonInheritingStyles != StyleProtoChain.STYLE_UNINITIALIZED;
    }

    //----------------------------------
    //  text
    //----------------------------------

    /**
     *  @private
     */
    mx_internal var _text:String = "";
        
    /**
     *  The text in this element.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get text():String 
    {
        return mx_internal::_text;
    }
    
    /**
     *  @private
     */
    public function set text(value:String):void
    {
        if (value != mx_internal::_text)
        {
            mx_internal::_text = value;

            invalidateTextLines("text");
            invalidateSize();
            invalidateDisplayList();
        }
    }
        
    //----------------------------------
    //  truncation
    //----------------------------------
    
    /**
     *  @private
     */
    private var _truncation:int = 0;
    
    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get truncation():int
    {
    	return _truncation;
    }
    
    /**
     *  @private
     */
    public function set truncation(value:int):void
    {
    	if (value != _truncation)
    	{
    		_truncation = value;
    		
    		invalidateSize();
    		invalidateDisplayList();
    	}
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: GraphicElement
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        // The measure() method of a GraphicElement can get called
        // when its style chain hasn't been initialized.
        // In that case, composeTextLines() must not be called.
        if (!mx_internal::styleChainInitialized)
            return;

        composeTextLines(explicitWidth, explicitHeight);

        // If width/height not explicitly set, put on next pixel boundary for 
        // crisp edges.  This should not impact isOverset which was calculated
        // with the pre-adjusted bounds values.  If explcitly set, use it so
        // that a recomposition can possibily be avoided in updateDisplayList().
        if (mx_internal::bounds.width != explicitWidth)
            mx_internal::bounds.width = Math.ceil(mx_internal::bounds.width);

        measuredWidth = mx_internal::bounds.width;         
        
        if (mx_internal::bounds.height != explicitHeight)
            mx_internal::bounds.height = Math.ceil(mx_internal::bounds.height);

        measuredHeight = mx_internal::bounds.height;  
        
        //trace("measure", measuredWidth, measuredHeight);
    }
            
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, 
                                                  unscaledHeight:Number):void
    {
        //trace(updateDisplayList", unscaledWidth, unscaledHeight);
        
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        // The updateDisplayList() method of a GraphicElement can get called
        // when its style chain hasn't been initialized.
        // In that case, composeTextLines() must not be called.
        if (!mx_internal::styleChainInitialized)
            return;

        // Figure out if a compose is needed or maybe just clip what is already
        // composed.

        var compose:Boolean = false;
        var forceClip:Boolean = false;
        
        if (mx_internal::stylesChanged || 
           isNaN(mx_internal::bounds.height) ||
           (unscaledHeight > mx_internal::bounds.height && 
           mx_internal::isOverset)) 
        {
            // Style changed, composition hasn't been done or it has been done
            // but more height is needed and it's possible there is more text 
            // to compose since it didn't all fit before.
            compose = true;
        }
        else if (mx_internal::lineBreakToFit)
        {
            // toFit line breaks so compose if width isn't the same.
            if (unscaledWidth != mx_internal::bounds.width)
                compose = true;            
        }
        else
        {
            // explicit line breaks so compose only if more width is needed and
            // there is more text to compose.
            if (unscaledWidth > mx_internal::bounds.width && 
                mx_internal::isOverset)
            {
                compose = true;
            }    
        }
                
        if (compose)
        {
            // Compose and clip based on value of isOverset.
            composeTextLines(unscaledWidth, unscaledHeight);
        }        
        else if (unscaledHeight != mx_internal::bounds.height ||
                 unscaledWidth != mx_internal::bounds.width)
        {
            // Don't need to recompose but need to clip since the text is
            // a different shape than what was composed.
            forceClip = true;
        }   

        //trace("udl", "compose", compose, "clip", mx_internal::isOverset || forceClip);        
                       
        mx_internal::clip(unscaledWidth, unscaledHeight, forceClip);
    }
            
    //--------------------------------------------------------------------------
    //
    //  Methods: ISimpleStyleClient
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function styleChanged(styleProp:String):void
    {
        StyleProtoChain.styleChanged(this, styleProp);
        
        if (styleProp == "lineBreak")
        {
            mx_internal::lineBreakToFit = 
                (getStyle("lineBreak") == LineBreak.TO_FIT);
        }
           
        mx_internal::stylesChanged = true;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: IStyleClient
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getStyle(styleProp:String):*
    {
        return StyleManager.isInheritingStyle(styleProp) ?
               _inheritingStyles[styleProp] :
               _nonInheritingStyles[styleProp];
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setStyle(styleProp:String, newValue:*):void
    {
        StyleProtoChain.setStyle(this, styleProp, newValue);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function clearStyle(styleProp:String):void
    {
        setStyle(styleProp, undefined);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getClassStyleDeclarations():Array
    {
        return StyleProtoChain.getClassStyleDeclarations(this);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function notifyStyleChangeInChildren(
                        styleProp:String, recursive:Boolean):void
    {
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function regenerateStyleCache(recursive:Boolean):void
    {
        mx_internal::initProtoChain();
    }

    /**
     *  This method is required by the IStyleClient interface,
     *  but doesn't do anything for TextGraphicElements.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function registerEffects(effects:Array /* of String */):void
    {
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: IAdvancedStyleClient
    //
    //--------------------------------------------------------------------------

    /**
     *  This method is required by the IAdvancedStyleClient interface,
     *  but always returns false for TextGraphicElements as they do not have
     *  state specific behavior.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function isPseudoSelectorMatch(pseudoState:String):Boolean
    {
        return false;
    }

    /**
     *  Determines whether this instance is the same as - or is a subclass of -
     *  the given type.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function isTypeSelectorMatch(type:String):Boolean
    {
        return StyleProtoChain.isTypeSelectorMatch(this, type);
    }

    /**
     *  This method is required by the IAdvancedStyleClient interface,
     *  but doesn't do anything for TextGraphicElements as they do not have
     *  state specific behavior.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function applyStateStyles(oldState:String, newState:String, recursive:Boolean):void
    {
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Flex calls the <code>stylesInitialized()</code> method when
     *  the styles for a component are first initialized.
     *
     *  <p>This is an advanced method that you might override
     *  when creating a subclass of TextGraphicElement.
     *  Note that. unlike with UIComponents, Flex does not guarantee that
     *  your TextGraphicElement's styles will be fully initialized before
     *  the first time its component's <code>measure</code> and
     *  <code>updateDisplayList</code> methods are called.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function stylesInitialized():void
    {
        mx_internal::lineBreakToFit = 
            (getStyle("lineBreak") == LineBreak.TO_FIT);
        mx_internal::stylesChanged = true;
    }

    /**
     *  @private
     */
    mx_internal function initProtoChain():void
    {
        StyleProtoChain.initProtoChain(this);
    }

    /**
     *  @private
     *  TODO This should be mx_internal, but that causes a compiler error.
     */
    protected function invalidateTextLines(cause:String):void
    {
    }
    
    /**
     *  @private
     *  TODO This should be mx_internal, but that causes a compiler error.
     */
    protected function composeTextLines(width:Number = NaN,
										height:Number = NaN):void
	{
	}

	/**
	 *  @private
	 *  Adds the TextLines created by composeTextLines()
     *  to a specified DisplayObjectContainer.
	 *  Sets the isOverset flag to indicate whether they require clipping.
	 */
	mx_internal function addTextLines(container:DisplayObjectContainer,
								  index:int = 0):void
	{
		var n:int = mx_internal::textLines.length;
		for (var i:int = n - 1; i >= 0; i--)
		{
			var textLine:TextLine = TextLine(mx_internal::textLines[i]);
			container.addChildAt(textLine, index);
		}
		
		var r:Rectangle = container.getBounds(container);
		mx_internal::isOverset = !mx_internal::bounds.containsRect(r);
				      
	    //trace("bounds", mx_internal::bounds, "r", r, mx_internal::isOverset);
	}

	/**
	 *  @private
	 *  Removes the TextLines created by composeTextLines()
     *  from whatever container they were added to, and frees them.
	 *  Empties the textLines Array.
	 */
	mx_internal function removeTextLines():void
	{
		var n:int = mx_internal::textLines.length;		
		if (n == 0)
			return;

		// The old TextLines might have been added to a different
		// container than the one we'd use now to add new TextLines.
		var container:DisplayObjectContainer =
			mx_internal::textLines[0].parent;

		for (var i:int = 0; i < n; i++)
		{
			var textLine:TextLine = TextLine(mx_internal::textLines[i]);
			container.removeChild(textLine);
		}

		mx_internal::textLines.length = 0;
	}

    /**
	 *  Use scrollRect to clip overset lines.
	 *  But don't read or write scrollRect if you can avoid it,
	 *  because this causes Player 10.0 to allocate memory.
	 *  And if scrollRect is already set to a Rectangle instance,
	 *  reuse it rather than creating a new one.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal function clip(w:Number, h:Number, forceClip:Boolean=false):void
	{
        if (mx_internal::isOverset || forceClip)
        {
            var r:Rectangle = displayObject.scrollRect;
            if (r)
            {
            	r.x = 0;
            	r.y = 0;
            	r.width = w;
            	r.height = h;
            }
            else
            {
            	r = new Rectangle(0, 0, w, h);
            }
            displayObject.scrollRect = r;
            mx_internal::hasScrollRect = true;
        }
        else if (mx_internal::hasScrollRect)
        {
            displayObject.scrollRect = null;
            mx_internal::hasScrollRect = false;
        }
    }

    /**
     * @private
     * Used to ensure baselinePosition will reflect something
     * reasonable.
     */ 
    mx_internal function validateBaselinePosition():void
    {
        // Ensure we're validated and that we have something to 
        // compute our baseline from.
        var isEmpty:Boolean = (text == "");
        text = isEmpty ? "Wj" : text;
        
        if (mx_internal::invalidatePropertiesFlag || mx_internal::invalidateSizeFlag || 
            mx_internal::invalidateDisplayListFlag || isEmpty)
        {
            validateNow();  
            text = isEmpty ? "" : text;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function resourceManager_changeHandler(event:Event):void
    {
		var resourceManager:IResourceManager = ResourceManager.getInstance();

        mx_internal::truncationIndicatorResource = resourceManager.getString(
            "core", "truncationIndicator");

        invalidateSize();
        invalidateDisplayList();
    }
}

}

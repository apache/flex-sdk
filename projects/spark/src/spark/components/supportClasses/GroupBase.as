////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.PropertyChangeEvent;

import spark.components.ResizeMode;
import spark.core.IViewport;
import spark.core.MaskType;
import spark.layouts.BasicLayout;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../../styles/metadata/BasicInheritingTextStyles.as"
include "../../styles/metadata/AdvancedInheritingTextStyles.as"
include "../../styles/metadata/SelectionFormatTextStyles.as"

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
[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  The main color for a component. 
 *   
 *  @default 0xCCCCCC
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="baseColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  The alpha of the content background for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="contentBackgroundAlpha", type="Number", inherit="yes", theme="spark")]

/**
 *  Color of the fill of an item renderer
 *   
 *  @default 0xFFFFFF
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  The alpha value when the container is disabled.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="disabledAlpha", type="Number", inherit="no", theme="spark")]

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
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark")]

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
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes", theme="spark")]

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
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="focusThickness", kind="style")]

/**
 *  The GroupBase class defines the base class for components that display visual elements.
 *  A group component does not control the layout of the visual items that it contains. 
 *  Instead, the layout is handled by a separate layout component.
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:GroupBase&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:GroupBase
 *    <strong>Properties</strong>
 *    autoLayout="true"
 *    clipAndEnableScrolling="false"
 *    horizontalScrollPosition="null"
 *    layout="BasicLayout"
 *    mask=""
 *    maskType="clip"
 *    resizeMode="noScale"
 *    verticalScrollPosition="no default"
 *  
 *    <strong>Events</strong>
 *    elementAdd="<i>No default</i>"
 *    elementRemove="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.layouts.supportClasses.LayoutBase
 *  @see spark.components.ResizeMode
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class GroupBase extends UIComponent implements IViewport
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
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function GroupBase()
    {
        super();
        showInAutomationHierarchy = false;
    }
        
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  alpha
    //----------------------------------
    
    private var _explicitAlpha:Number = 1.0;
    
    /**
     *  @private
     */
    override public function set alpha(value:Number):void
    {
        if (enabled)
            super.alpha = value;
        _explicitAlpha = value;
    }
    
    //----------------------------------
    //  mouseChildren
    //----------------------------------

    private var _explicitMouseChildren:Boolean = true;

    /**
     *  @private
     */
    override public function set mouseChildren(value:Boolean):void
    {
        if (enabled)
            super.mouseChildren = value;
        _explicitMouseChildren = value;
    }

    //----------------------------------
    //  mouseEnabled
    //----------------------------------

    private var _explicitMouseEnabled:Boolean = true;

    /**
     *  @private
     */
    override public function set mouseEnabled(value:Boolean):void
    {
        if (enabled)
            super.mouseEnabled = value;
        _explicitMouseEnabled = value;
    }

    //----------------------------------
    //  enabled
    //----------------------------------

    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
        super.enabled = value;

        // If enabled, reset the mouseChildren, mouseEnabled to the previously
        // set explicit value, otherwise disable mouse interaction.
        super.mouseChildren = value ? _explicitMouseChildren : false;
        super.mouseEnabled  = value ? _explicitMouseEnabled  : false;
        
        if (value)
            super.alpha = _explicitAlpha;
        else
        {
            var disabledAlpha:Number = getStyle("disabledAlpha");
            
            if (!isNaN(disabledAlpha))
                super.alpha = disabledAlpha;
            // else if it is NaN, it'll get handled in styleChanged()
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
        
    //----------------------------------
    //  layout
    //----------------------------------    
    
    // layout is initialized in createChildren() if layout 
    // hasn't been set yet by someone else
    private var _layout:LayoutBase;
    private var _layoutProperties:Object = null;
    private var layoutInvalidateSizeFlag:Boolean = false;
    private var layoutInvalidateDisplayListFlag:Boolean = false;
    
    /**
     *  The layout object for this container.  
     *  This object is responsible for the measurement and layout of 
     *  the visual elements in the container.
     * 
     *  @default spark.layouts.BasicLayout
     *
     *  @see LayoutBase
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get layout():LayoutBase
    {
        return _layout;
    }
        
    /**
     *  @private
     * 
     *  Three properties are delegated to the layout: clipAndEnableScrolling,
     *  verticalScrollPosition, horizontalScrollPosition.
     *  If the layout is reset, we copy the properties from the old
     *  layout to the new one (we don't copy verticalScrollPosition
     *  and horizontalScrollPosition from an old layout object to a new layout 
     *  object because this information might not translate correctly).   
     *  If the new layout is null, then we
     *  temporarily store the delegated properties in _layoutProperties. 
     */
    public function set layout(value:LayoutBase):void
    {
        if (_layout == value)
            return;

        if (value)
        {
            if (_layoutProperties)
            {
                if (_layoutProperties.clipAndEnableScrolling !== undefined)
                    value.clipAndEnableScrolling = _layoutProperties.clipAndEnableScrolling;
                
                if (_layoutProperties.verticalScrollPosition !== undefined)
                    value.verticalScrollPosition = _layoutProperties.verticalScrollPosition;
                
                if (_layoutProperties.horizontalScrollPosition !== undefined)
                    value.horizontalScrollPosition = _layoutProperties.horizontalScrollPosition;
                
                _layoutProperties = null;
            }
            
            if (_layout)
                value.clipAndEnableScrolling = _layout.clipAndEnableScrolling;
        }
        else
        {
            if (_layout)
            {
                // when the layout changes, we don't want to transfer over 
                // horizontalScrollPosition and verticalScrollPosition
                _layoutProperties = {clipAndEnableScrolling: _layout.clipAndEnableScrolling};
            }
        }

        if (_layout)
        {
            _layout.target = null;
            _layout.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, redispatchLayoutEvent);
        }
        _layout = value; 
        if (_layout)
        {
            _layout.target = this;
            _layout.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, redispatchLayoutEvent);
        }

        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  @private
     *  Redispatch the bindable LayoutBase properties that we expose (that we "facade"). 
     */
    private function redispatchLayoutEvent(event:Event):void
    {
        var pce:PropertyChangeEvent = event as PropertyChangeEvent;
        if (pce)
            switch (pce.property)
            {
                case "verticalScrollPosition":
                case "horizontalScrollPosition":
                    dispatchEvent(event);
                    break;
            }
    }    
    
    //----------------------------------
    //  horizontalScrollPosition
    //----------------------------------
        
    [Bindable]

    /**
     *  @copy spark.core.IViewport#horizontalScrollPosition
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get horizontalScrollPosition():Number 
    {
        if (_layout)
        {
            return _layout.horizontalScrollPosition;
        }
        else if (_layoutProperties && 
                _layoutProperties.horizontalScrollPosition !== undefined)
        {
            return _layoutProperties.horizontalScrollPosition;
        }
        else
        {
            return 0;
        }
    }

    /**
     *  @private
     */
    public function set horizontalScrollPosition(value:Number):void 
    {
        if (_layout)
        {
            _layout.horizontalScrollPosition = value;
        }
        else if (_layoutProperties)
        {
            _layoutProperties.horizontalScrollPosition = value;
        }
        else
        {
            _layoutProperties = {horizontalScrollPosition: value};
        }
    }
    
    //----------------------------------
    //  verticalScrollPosition
    //----------------------------------
    
    [Bindable]
    
    /**
     *  @copy spark.core.IViewport#verticalScrollPosition
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get verticalScrollPosition():Number 
    {
        if (_layout)
        {
            return _layout.verticalScrollPosition;
        }
        else if (_layoutProperties && 
                _layoutProperties.verticalScrollPosition !== undefined)
        {
            return _layoutProperties.verticalScrollPosition;
        }
        else
        {
            return 0;
        }
    }

    /**
     *  @private
     */
    public function set verticalScrollPosition(value:Number):void 
    {
        if (_layout)
        {
            _layout.verticalScrollPosition = value;
        }
        else if (_layoutProperties)
        {
            _layoutProperties.verticalScrollPosition = value;
        }
        else
        {
            _layoutProperties = {verticalScrollPosition: value};
        }
    }
    
    //----------------------------------
    //  clipAndEnableScrolling
    //----------------------------------
    
    /**
     *  @copy spark.core.IViewport#clipAndEnableScrolling
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get clipAndEnableScrolling():Boolean 
    {
        if (_layout)
        {
            return _layout.clipAndEnableScrolling;
        }
        else if (_layoutProperties && 
                _layoutProperties.clipAndEnableScrolling !== undefined)
        {
            return _layoutProperties.clipAndEnableScrolling;
        }
        else
        {
            return false;
        }
    }

    /**
     *  @private
     */
    public function set clipAndEnableScrolling(value:Boolean):void 
    {
        if (_layout)
        {
            _layout.clipAndEnableScrolling = value;
        }
        else if (_layoutProperties)
        {
            _layoutProperties.clipAndEnableScrolling = value;
        }
        else
        {
            _layoutProperties = {clipAndEnableScrolling: value};
        }

        // clipAndEnableScrolling affects measured minimum size
        invalidateSize();
    }    
    
    //----------------------------------
    //  scrollRect
    //----------------------------------
    
    private var _scrollRectSet:Boolean = false;
    
    /**
     * @private
     * GroupBase workaround for a FP bug.  Ignore attempts to reset the
     * DisplayObject scrollRect property to null (its default value) if we've
     * never set it.  Similarly, don't read the DisplayObject scrollRect
     * property if its value has not been set.
     */
     override public function get scrollRect():Rectangle
     {
         return (!_scrollRectSet) ? null : super.scrollRect;
     }

     /**
      * @private 
      */
    override public function set scrollRect(value:Rectangle):void
    {
        if (!_scrollRectSet && !value)
            return;
        _scrollRectSet = true;
        super.scrollRect = value;
    }
    
    //----------------------------------
    //  autoLayout
    //----------------------------------

    /**
     *  @private
     *  Storage for the autoLayout property.
     */
    private var _autoLayout:Boolean = true;

    [Inspectable(defaultValue="true")]

    /**
     *  If <code>true</code>, measurement and layout are done
     *  when the position or size of a child is changed.
     *  If <code>false</code>, measurement and layout are done only once,
     *  when children are added to or removed from the container.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get autoLayout():Boolean
    {
        return _autoLayout;
    }

    /**
     *  @private
     */
    public function set autoLayout(value:Boolean):void
    {
        if (_autoLayout == value)
            return;

        _autoLayout = value;

        // If layout is being turned back on, trigger a layout to occur now.
        if (value)
        {
            invalidateSize();
            invalidateDisplayList();
            invalidateParentSizeAndDisplayList();
        }
    }

    //----------------------------------
    //  resizeMode
    //----------------------------------
    
    private var _resizeMode:String = ResizeMode.NOSCALE; 

    /**
     *  The ResizeMode for this container. If the resize mode
     *  is set to <code>ResizeMode.NOSCALE</code>, resizing is done by laying 
     *  out the children with the new width and height. If the 
     *  resize mode is set to <code>ResizeMode.SCALE</code>, all of the children 
     *  keep their unscaled width and height and the children 
     *  are scaled to change size.
     * 
     * <p>The default value is <code>ResizeMode.NOSCALE</code>, corresponding to "noScale".</p>
     * 
     * @see spark.components.ResizeMode
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get resizeMode():String
    {
        return _resizeMode; 
    }
    
    public function set resizeMode(value:String):void
    {
        if (_resizeMode == value)
            return;

        // If old value was scale, reset it            
        if (_resizeMode == ResizeMode.SCALE)
            setStretchXY(1, 1);

        _resizeMode = value;
        
        // We need the measured values and _resizeMode affects
        // our measure (skipMeasure implementation checks resizeMode) so
        // we need to invalidate the size.
        invalidateSize();
        
        // Invalidate the display list so that our validateMatrix() gets called.
        invalidateDisplayList();
    }

    //----------------------------------
    //  mouseOpaque
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the mouseOpaque property
     */
    private var _mouseEnabledWhereTransparent:Boolean = true;
    private var mouseEventReferenceCount:int;

    [Inspectable(category="General", enumeration="true,false")]
    
    /**
     *  When set to true the mouseOpaque flag ensures that the entire bounds
     *  of the Group are opaque to all mouse events such as clicks, rollOvers,
     *  etc.
     * 
     *  @default true
     *  
     *  @langversion 4.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get mouseEnabledWhereTransparent():Boolean
    {
        return _mouseEnabledWhereTransparent;
    }
    
    /**
     *  @private
     */
    public function set mouseEnabledWhereTransparent(value:Boolean):void
    {
        if (value == _mouseEnabledWhereTransparent)
            return;
            
        _mouseEnabledWhereTransparent = value;

        if (_hasMouseListeners)
            invalidateDisplayList();
    }
     
    /**
     *  @private
     *  Render a transparent background fill as necessary to support the mouseOpaque flag.
     *  We assume for now that we are the first layer to be rendered into the graphics
     *  context.
     */
    protected function renderFillForMouseOpaque():void
    {
        if (!_mouseEnabledWhereTransparent || !_hasMouseListeners)
            return;
        
        var w:Number = (_resizeMode == ResizeMode.SCALE) ? measuredWidth : unscaledWidth;
        var h:Number = (_resizeMode == ResizeMode.SCALE) ? measuredHeight : unscaledHeight;

        if (isNaN(w) || isNaN(h))
            return;

        graphics.clear();
        graphics.beginFill(0xFFFFFF, 0);

        if (layout && layout.useVirtualLayout)
            graphics.drawRect(horizontalScrollPosition, verticalScrollPosition, w, h);
        else
        {
            const tileSize:int = 4096;
            const maxX:int = Math.round(Math.max(w, contentWidth));
            const maxY:int = Math.round(Math.max(h, contentHeight));
            for (var x:int = 0; x < maxX; x += tileSize)
                for (var y:int = 0; y < maxY; y += tileSize)
                {
                    var tileWidth:int = Math.min(maxX - x, tileSize);
                    var tileHeight:int = Math.min(maxY - y, tileSize);
                    graphics.drawRect(x, y, tileWidth, tileHeight); 
                }
        }

        graphics.endFill();
    }

    //----------------------------------
    //  hasMouseListeners
    //----------------------------------
    
    private var _hasMouseListeners:Boolean = false;
    
    /**
     * @private
     * 
     * This is a protected helper property used when selectively rendering
     * the fill layer for mouseOpaque (we only render when we have active
     * mouse event listeners).
     * 
     */  
    mx_internal function set hasMouseListeners(value:Boolean):void
    {
        if (_mouseEnabledWhereTransparent)
            $invalidateDisplayList();
    _hasMouseListeners = value;
    }
    
    /**
     * @private
     */  
    mx_internal function get hasMouseListeners():Boolean
    {
        return _hasMouseListeners;
    }
        
    /**
     *  @private
     */
    override protected function canSkipMeasurement():Boolean
    {
        // We never want to skip measure, if we resize by scaling
        return _resizeMode == ResizeMode.SCALE ? false : super.canSkipMeasurement();
    }

    /**
     *  @private
     */
    override public function invalidateSize():void
    {
        super.invalidateSize();
        layoutInvalidateSizeFlag = true;
    }

    /**
     *  @private
     */
    override public function invalidateDisplayList():void
    {
        super.invalidateDisplayList();
        layoutInvalidateDisplayListFlag = true;
    }
    
    /**
     *  @private
     *  Called when the child transform changes (currently x and y on UIComponent),
     *  so that the Group has a chance to invalidate the layout. 
     */
    override mx_internal function childXYChanged():void
    {
        if (autoLayout)
        {
            invalidateSize();
            invalidateDisplayList();
        }
    }
    
    /**
     *  @private
     *  Invalidates the size, but doesn't run layout measure pass. This is useful
     *  for subclasses like Group that perform additional work there - like running
     *  the graphic element measure pass.
     */
    mx_internal function $invalidateSize():void
    {
        super.invalidateSize();
    }
    
    /**
     *  @private
     *  Invalidates the display list, but doesn't run layout updateDisplayList pass.
     *  This is useful for subclasses like Group that perform additional work on
     *  updateDisplayList - like redrawing the graphic elements.
     */
    mx_internal function $invalidateDisplayList():void
    {
        super.invalidateDisplayList();
    }
    
    /**
     *  @inheritDoc
     *  
     *  <p>If the layout object has not been set yet, 
     *  createChildren() assigns this container a 
     *  default layout object, BasicLayout.</p>
     */ 
    override protected function createChildren():void
    {
        super.createChildren();
        
        if (!layout)
            layout = new BasicLayout();
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        if (_layout && layoutInvalidateSizeFlag)
        {
            var oldMeasuredWidth:Number = measuredWidth;
            var oldMeasuredHeight:Number = measuredHeight;
            
            super.measure();
        
            layoutInvalidateSizeFlag = false;
            _layout.measure();
            
            // Special case: If the group clips content, or resizeMode is "scale"
            // then measured minimum size is zero
            if (clipAndEnableScrolling || resizeMode == ResizeMode.SCALE)
            {
                measuredMinWidth = 0;
                measuredMinHeight = 0;
            }

            // Make sure that we invalidate the display list if the measured
            // size changes, as we always size our content at the measured size when in scale mode.
            if (_resizeMode == ResizeMode.SCALE && (measuredWidth != oldMeasuredWidth || measuredHeight != oldMeasuredHeight))
                invalidateDisplayList();
        }
    }

    /**
     *  @private
     */
    override protected function validateMatrix():void
    {
        // Update the stretchXY before the matrix gets validates
        if (_resizeMode == ResizeMode.SCALE)
        {
            var stretchX:Number = 1;
            var stretchY:Number = 1;            

            if (measuredWidth != 0)
                stretchX = width / measuredWidth;
            if (measuredHeight != 0)
                stretchY = height / measuredHeight;

            setStretchXY(stretchX, stretchY);
        }
        super.validateMatrix();
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        if (_resizeMode == ResizeMode.SCALE)
        {
            unscaledWidth = measuredWidth;
            unscaledHeight = measuredHeight;
        }

        super.updateDisplayList(unscaledWidth, unscaledHeight);

        if (maskChanged)
        {
            maskChanged = false;
            if (_mask)
            {
                maskTypeChanged = true;
            
                if (!_mask.parent)
                {
                    // TODO (jszeto): Does this need to be attached to a sibling?
                    super.addChild(_mask);
                    var maskComp:UIComponent = _mask as UIComponent;
                    if (maskComp)
                    {
                        maskComp.validateProperties();
                        maskComp.validateSize();
                        maskComp.setActualSize(maskComp.getExplicitOrMeasuredWidth(), 
                                               maskComp.getExplicitOrMeasuredHeight());
                    }
                }
            }
        }
        
        if (maskTypeChanged)    
        {
            maskTypeChanged = false;
            
            if (_mask)
            {
                if (_maskType == MaskType.CLIP)
                {
                    // Turn off caching on mask
                    _mask.cacheAsBitmap = false; 
                    // Save the original filters and clear the filters property
                    originalMaskFilters = _mask.filters;
                    _mask.filters = []; 
                }
                else if (_maskType == MaskType.ALPHA)
                {
                    _mask.cacheAsBitmap = true;
                    cacheAsBitmap = true;
                }
            }
        }       

        if (layoutInvalidateDisplayListFlag)
        {
            layoutInvalidateDisplayListFlag = false;
            if (autoLayout && _layout)
                _layout.updateDisplayList(unscaledWidth, unscaledHeight);
                
            if (_layout)
                _layout.updateScrollRect(unscaledWidth, unscaledHeight);
        }
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);
        var allStyles:Boolean = (styleProp == null || styleProp == "styleName");
        
        if (!enabled && (allStyles || styleProp == "disabledAlpha"))
        {
            var disabledAlpha:Number = getStyle("disabledAlpha");
            
            if (!isNaN(disabledAlpha))
                super.alpha = disabledAlpha;
        }
    }
    
    //----------------------------------
    //  horizontal,verticalScrollPositionDelta
    //----------------------------------

    /**
     *  @copy spark.core.IViewport#horizontalScrollPositionDelta()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getHorizontalScrollPositionDelta(navigationUnit:uint):Number
    {
        return (layout) ? layout.getHorizontalScrollPositionDelta(navigationUnit) : 0;     
    }
    
    /**
     *  @copy spark.core.IViewport#verticalScrollPositionDelta()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getVerticalScrollPositionDelta(navigationUnit:uint):Number
    {
        return (layout) ? layout.getVerticalScrollPositionDelta(navigationUnit) : 0;     
    }
    
    //--------------------------------------------------------------------------
    //
    //  IViewport properties
    //
    //--------------------------------------------------------------------------        

    //----------------------------------
    //  contentWidth
    //---------------------------------- 
    
    private var _contentWidth:Number = 0;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]    

    /**
     *  @copy spark.core.IViewport#contentWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get contentWidth():Number 
    {
        return _contentWidth;
    }
    
    /**
     *  @private
     */
    private function setContentWidth(value:Number):void 
    {
        if (value == _contentWidth)
            return;
        var oldValue:Number = _contentWidth;
        _contentWidth = value;
        dispatchPropertyChangeEvent("contentWidth", oldValue, value);        
    }

    //----------------------------------
    //  contentHeight
    //---------------------------------- 
    
    private var _contentHeight:Number = 0;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]    

    /**
     *  @copy spark.core.IViewport#contentHeight
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get contentHeight():Number 
    {
        return _contentHeight;
    }
    
    /**
     *  @private
     */
    private function setContentHeight(value:Number):void 
    {            
        if (value == _contentHeight)
            return;
        var oldValue:Number = _contentHeight;
        _contentHeight = value;
        dispatchPropertyChangeEvent("contentHeight", oldValue, value);        
    }    

    /**
     *  Sets the <code>contentWidth</code> and <code>contentHeight</code>
     *  properties.
     * 
     *  This method is intended for layout class developers who should
     *  call it from <code>updateDisplayList()</code> methods.
     *
     *  @param width The new value of <code>contentWidth</code>.
     * 
     *  @param height The new value of <code>contentHeight</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setContentSize(width:Number, height:Number):void
    {
        if ((width == _contentWidth) && (height == _contentHeight))
           return;
        setContentWidth(width);
        setContentHeight(height);
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: EventDispatcher
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  We render a transparent background fill by default when we have mouse
     *  listeners.
     */
    override public function addEventListener(type:String, listener:Function,
        useCapture:Boolean = false, priority:int = 0,
        useWeakReference:Boolean = false):void
    {
        super.addEventListener(type, listener, useCapture, priority, 
            useWeakReference);

        if (type == MouseEvent.CLICK ||
            type == MouseEvent.DOUBLE_CLICK ||
            type == MouseEvent.MOUSE_DOWN ||
            type == MouseEvent.MOUSE_MOVE ||
            type == MouseEvent.MOUSE_OVER ||
            type == MouseEvent.MOUSE_OUT ||
            type == MouseEvent.ROLL_OUT ||
            type == MouseEvent.ROLL_OVER ||
            type == MouseEvent.MOUSE_UP ||
            type == MouseEvent.MOUSE_WHEEL)
        {
            if (mouseEventReferenceCount++ == 0)
                hasMouseListeners = true;
        }
    }

    /**
     *  @private
     *  We no longer render our default transparent background fill when we have 
     *  no mouse listeners.
     */
    override public function removeEventListener( type:String, listener:Function,
        useCapture:Boolean = false):void
    {
        super.removeEventListener(type, listener, useCapture);

        if (type == MouseEvent.CLICK ||
            type == MouseEvent.DOUBLE_CLICK ||
            type == MouseEvent.MOUSE_DOWN ||
            type == MouseEvent.MOUSE_MOVE ||
            type == MouseEvent.MOUSE_OVER ||
            type == MouseEvent.MOUSE_OUT ||
            type == MouseEvent.ROLL_OUT ||
            type == MouseEvent.ROLL_OVER ||
            type == MouseEvent.MOUSE_UP ||
            type == MouseEvent.MOUSE_WHEEL)
        {
            if (--mouseEventReferenceCount == 0)
                hasMouseListeners = false;
        }
    }
    
    /**
     *  @private
     *  Automation requires a version of addEventListener that does not
     *  affect behavior of the underlying component.
     */  
    mx_internal function $addEventListener(
                            type:String, listener:Function,
                            useCapture:Boolean = false,
                            priority:int = 0,
                            useWeakReference:Boolean = false):void
    {
        super.addEventListener(type, listener, useCapture,
                               priority, useWeakReference);
    }

    /**
     *  @private
     *  Automation requires a version of removeEventListener that does not
     *  affect behavior of the underlying component.
     */  
    mx_internal function $removeEventListener(
                              type:String, listener:Function,
                              useCapture:Boolean = false):void
    {
        super.removeEventListener(type, listener, useCapture);
    }
           
    //--------------------------------------------------------------------------
    //
    //  Properties: Overriden Focus management
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  focusPane
    //----------------------------------

    /**
     *  @private
     *  Storage for the focusPane property.
     */
    private var _focusPane:Sprite;

    [Inspectable(environment="none")]
    
    // FIXME (rfrishbe): only reason we need to override focusPane getter/setter
    // is because addChild/removeChild for Groups throw an RTE.
    // This is the same as UIComponent's focusPane getter/setter but it uses
    // super.add/removeChild.

    /**
     *  @private
     */
    override public function get focusPane():Sprite
    {
        return _focusPane;
    }

    /**
     *  @private
     */
    override public function set focusPane(value:Sprite):void
    {
        if (value)
        {
            super.addChild(value);

            value.x = 0;
            value.y = 0;
            value.scrollRect = null;

            _focusPane = value;
        }
        else
        {
             super.removeChild(_focusPane);
             
             // TODO (jszeto): remove mask?  SDK-15310
            _focusPane = null;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Layout item iteration
    //
    //  Iterators used by Layout objects. For visual items, the layout item
    //  is the item itself. For data items, the layout item is the item renderer
    //  instance that is associated with the item.
    //
    //  These methods and getters are really abstract methods that are 
    //  implemented in Group and DataGroup.  We need them here in BaseGroup 
    //  so that layouts can use these methods.
    //--------------------------------------------------------------------------
    
    /**
     *  @copy mx.core.IVisualElementContainer#numElements
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get numElements():int
    {
        return -1;
    }
    
    /**
     *  @copy mx.core.IVisualElementContainer#getElementAt()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getElementAt(index:int):IVisualElement
    {
        return null;
    }
    
    /**
     *  Layouts that honor the <code>useVirtualLayout</code> flag will use this 
     *  method at updateDisplayList() time to get layout elements that are "in view", 
     *  i.e. that overlap the Group's scrollRect.
     * 
     *  <p>If the element to be returned wasn't already a visible child, i.e. if 
     *  it was created or recycled, and either eltWidth or eltHeight is specified,
     *  then the element's initial size is set with setLayoutBoundsSize() before 
     *  it's validated.  This is important for components, like text, that reflow 
     *  when the layout is justified to the Group's width or height.</p>
     *  
     *  <p>The returned layout element will have been validated.</p>
     * 
     *  <p>This method will lazily create or "recycle" and validate layout
     *  elements as needed.</p>
     * 
     *  <p>This method is not intended to be called directly, layouts that
     *  support virutalization will call it.</p>
     * 
     *  @param index The index of the element to retrieve.
     *  @param eltWidth If specified, the newly created or recycled element's initial width.
     *  @param eltHeight If specified, the newly created or recycled element's initial height.
     *  @return The validated element at the specified index.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getVirtualElementAt(index:int, eltWidth:Number=NaN, eltHeight:Number=NaN):IVisualElement
    {
        return getElementAt(index);            
    }
    
    /**
     *  @copy mx.core.IVisualElementContainer#getElementIndex()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getElementIndex(element:IVisualElement):int
    {
        return -1;
    }
    
    //----------------------------------
    //  mask
    //----------------------------------
    private var _mask:DisplayObject;
    mx_internal var maskChanged:Boolean;
    
    [Inspectable(category="General")]
    /**
     *  Sets the mask. The mask will be added to the display list. The mask must
     *  not already on a display list nor in the elements array.  
     *
     *  @see flash.display.DisplayObject#mask
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    override public function get mask():DisplayObject
    {
        return _mask;
    }
    
    /**
     *  @private
     */ 
    override public function set mask(value:DisplayObject):void
    {
        if (_mask !== value)
        {
            if (_mask && _mask.parent === this)
            {       
                super.removeChild(_mask);
            }     
            
            _mask = value;
            maskChanged = true;
            invalidateDisplayList();            
        }
        super.mask = value;         
    } 
    
    //----------------------------------
    //  maskType
    //----------------------------------
    
    [Bindable("propertyChange")]
    [Inspectable(category="General", enumeration="clip,alpha,luminosity", defaultValue="clip")]
    private var _maskType:String = MaskType.CLIP;
    private var maskTypeChanged:Boolean;
    private var originalMaskFilters:Array;
    
    /**
     *  The mask type.
     *  Possible values are <code>MaskType.CLIP</code> and <code>MaskType.ALPHA</code>. 
     *
     *  <p>The default value is <code>MaskType.CLIP</code>, corresponding to "clip".</p>
     *
     *  @see  spark.core.MaskType
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get maskType():String
    {
        return _maskType;
    }
    
    /**
     *  @private
     */
    public function set maskType(value:String):void
    {
    	// FIXME (dsubrama): Temporarily exit when maskType is
    	// set to luminosity; support for this will come shortly. 
    	if (value == "luminosity")
    		return; 
    		
        if (_maskType != value)
        {
            _maskType = value;
            maskTypeChanged = true;
            invalidateDisplayList(); 
        }
    }
    
    //----------------------------------
    //  luminosityInvert
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the luminosityInvert property.
     */
    private var _luminosityInvert:Boolean = false; 
    
    /**
     *  @private
     */
    private var luminosityInvertChanged:Boolean;

    [Inspectable(category="General", enumeration="true,false", defaultValue="false")]
    
    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get luminosityInvert():Boolean
    {
        return _luminosityInvert;
    }

    /**
     *  @private
     */
    public function set luminosityInvert(value:Boolean):void
    {
    	if (_luminosityInvert == value)
            return;

        _luminosityInvert = value;
    }

	//----------------------------------
    //  luminosityClip
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the luminosityClip property.
     */
    private var _luminosityClip:Boolean = false; 
    
    /**
     *  @private
     */
    private var luminosityClipChanged:Boolean;

    [Inspectable(category="General", enumeration="true,false", defaultValue="false")]
    
    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get luminosityClip():Boolean
    {
        return _luminosityClip;
    }

    /**
     *  @private
     */
    public function set luminosityClip(value:Boolean):void
    {
    	if (_luminosityClip == value)
            return;

        _luminosityClip = value;
    }
    
   /**
     *  @private
     * 
     *  A simple insertion sort.  This works well for small lists (under 12 or so), uses
     *  no aditional memory, and most importantly, is stable, meaning items with comparable
     *  values will stay in the same order relative to each other. For layering, we guarantee
     *  first the layer property, and then the item order, so a stable sort is important (and the 
     *  built in flash sort is not stable).
     */
    mx_internal static function sortOnLayer(a:Vector.<IVisualElement>):void
    {
        var len:Number = a.length;
        var tmp:IVisualElement;
        if (len<= 1)
            return;
        for (var i:int = 1;i<len;i++)
        {
            for (var j:int = i;j > 0;j--)
            {
                if ( a[j].depth < a[j-1].depth )
                {
                    tmp = a[j];
                    a[j] = a[j-1];
                    a[j-1] = tmp;
                }
                else
                    break;
            }
        }
    }
}

}

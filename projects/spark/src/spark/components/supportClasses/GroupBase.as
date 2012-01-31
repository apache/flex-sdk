package mx.components.baseClasses
{
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import mx.events.FlexEvent;
import mx.events.ItemExistenceChangedEvent;
import mx.graphics.Graphic;

import mx.graphics.MaskType;
import mx.utils.MatrixUtil;
import mx.graphics.graphicsClasses.GraphicElement;
import mx.graphics.IGraphicElement;
import mx.layout.ILayoutItem;
import mx.core.IViewport;
import mx.core.ScrollUnit;
import mx.layout.LayoutBase;
import mx.layout.BasicLayout;
import mx.layout.LayoutItemFactory;

import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.collections.ListCollectionView;
import mx.components.ResizeMode;
import mx.controls.Label;
import mx.core.IFactory;
import mx.core.mx_internal;
import mx.core.UIComponent;
import mx.events.CollectionEvent;
import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../../styles/metadata/BasicContainerFormatTextStyles.as"
include "../../styles/metadata/AdvancedContainerFormatTextStyles.as"
include "../../styles/metadata/BasicParagraphFormatTextStyles.as"
include "../../styles/metadata/AdvancedParagraphFormatTextStyles.as"
include "../../styles/metadata/BasicCharacterFormatTextStyles.as"
include "../../styles/metadata/AdvancedCharacterFormatTextStyles.as"

[Exclude(name="enabled", kind="property")] 

/**
 *  The GroupBase class defines the base class for components that display visual elements.
 *  A group component does not control the layout of the visual items that it contains. 
 *  Instead, the layout is handled by a separate layout component.
 *
 *  @see mx.layout.LayoutBase
 *  @see mx.components.ResizeMode
 */
public class GroupBase extends UIComponent implements IViewport
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     * Constructor.
     */
     public function GroupBase()
    {
        super();
        tabChildren = true;
        
        _layout = new BasicLayout();
        _layout.target = this;  
    }
        
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
        
    //----------------------------------
    //  layout
    //----------------------------------    
        
    private var _layout:LayoutBase;  // initialized in the ctor
    private var _layoutProperties:Object = null;
    
    /**
     *  The layout object for this container.  
     *  This object determines how the visual elements are laid out in the container.
     */
    public function get layout():LayoutBase
    {
        return _layout;
    }
        
    /**
     *  Three properties are delegated to the layout: clipContent,
     *  verticalScrollPosition, horizontalScrollPosition.
     *  If the layout is reset, we copy the properties from the old
     *  layout to the new one.   If the new layout is null, then we
     *  temporarily store the delegated properties in _layoutProperties.
     *  
     *  @private
     */
    public function set layout(value:LayoutBase):void
    {
        if (_layout == value)
            return;

        if (value)
        {
            value.clipContent = clipContent;
            value.verticalScrollPosition = verticalScrollPosition;
            value.horizontalScrollPosition = horizontalScrollPosition;
            _layoutProperties = null;
        }
        else 
        {
            _layoutProperties = {
                verticalScrollPosition: _layout.verticalScrollPosition,
                horizontalScrollPosition: _layout.horizontalScrollPosition,
                clipContent: _layout.clipContent 
            };
        }

        if (_layout)
            _layout.target = null;
        _layout = value; 
        if (_layout)
            _layout.target = this;

        invalidateSize();
        invalidateDisplayList();
    }
    
    //----------------------------------
    //  horizontalScrollPosition
    //----------------------------------
        
    [Bindable]

    /**
     *  @copy mx.core.IViewport#horizontalScrollPosition
     */
    public function get horizontalScrollPosition():Number 
    {
        return (_layout) 
            ? _layout.horizontalScrollPosition 
            : _layoutProperties.horizontalScrollPosition;
    }

    /**
     *  @private
     */
    public function set horizontalScrollPosition(value:Number):void 
    {
        if (_layout)
            _layout.horizontalScrollPosition = value;
        else
            _layoutProperties.horizontalScrollPosition = value;
    }
    
    //----------------------------------
    //  verticalScrollPosition
    //----------------------------------
    
    [Bindable]
    
    /**
     *  @copy mx.core.IViewport#verticalScrollPosition
     */
    public function get verticalScrollPosition():Number 
    {
        return (_layout) 
            ? _layout.verticalScrollPosition 
            : _layoutProperties.verticalScrollPosition;
    }

    /**
     *  @private
     */
    public function set verticalScrollPosition(value:Number):void 
    {
        if (_layout)
            _layout.verticalScrollPosition = value;
        else
            _layoutProperties.verticalScrollPosition = value;
    }
    
    //----------------------------------
    //  clipContent
    //----------------------------------
    
    /**
     *  @copy mx.core.IViewport#clipContent
     */
    public function get clipContent():Boolean 
    {
        return (_layout) ? _layout.clipContent : _layoutProperties.clipContent;
    }

    /**
     *  @private
     */
    public function set clipContent(value:Boolean):void 
    {
        if (_layout)
            _layout.clipContent = value;
        else
            _layoutProperties.clipContent = value;
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
    private static const _NORMAL_UINT:uint = 0;
    private static const _SCALE_UINT:uint = 1;
    private var _resizeMode:uint = _NORMAL_UINT;

    /**
     *  Converts from the <code>String</code> to the <code>uint</code>
     *  representation of the enumeration value.
     *
     *  @param value The String representation of the enumeration.
     *
     *  @return The uint value corresponding to the String.
     */
    private static function resizeModeToUINT(value:String):uint
    {
        if (value == ResizeMode.SCALE)
            return _SCALE_UINT;
        return _NORMAL_UINT;
    }

    /**
     *  Converts from the <code>uint</code> to the <code>String</code>
     *  representation of the enumeration values.
     *
     *  @param value The uint value of the enumeration. 
     *
     *  @return The String corresponding to the uint value.
     */
    private static function resizeModeToString(value:uint):String
    {
        if (value == _SCALE_UINT)
            return ResizeMode.SCALE;
        return ResizeMode.NORMAL;
    }
    
/**
 *  The ResizeMode for this container.  If the resize mode
 *  is set to <code>ResizeMode.NORMAL</code>, resizing is done by laying 
 *  out the children with our new width and height.  If the 
 *  resize mode is set to <code>ResizeMode.SCALE</code>, all of the children 
 *  keep their unscaled width and height and the children 
 *  are scaled to change size.
 * 
 * @default ResizeMode.NORMAL
 * 
 * @see mx.components.ResizeMode
 */
    public function get resizeMode():String
    {
        return resizeModeToString(_resizeMode);
    }
    
    public function set resizeMode(stringValue:String):void
    {
        var value:uint = resizeModeToUINT(stringValue); 
        if (_resizeMode == value)
            return;
            
        _resizeMode = value;
        
        if (_resizeMode == _SCALE_UINT)
        {
            super.scaleX = 1; 
            super.scaleY = 1;
        }

        // We need the measured values and _resizeMode affects
        // our measure (skipMeasure implementation checks resizeMode) so
        // we need to invalidate the size.
        invalidateSize();

        // TODO EGeorgie: can we directly call setActualSize instead?
        invalidateParentSizeAndDisplayList();
    }
    
    /**
     *  @private
     */
    override public function setActualSize(w:Number, h:Number):void
    {
        if (_resizeMode == _SCALE_UINT)
        {
            // TODO EGeorgie: make sure we don't invalidate again while
            // setting the scale!
            if (measuredWidth != 0)
            {
                $scaleX = w / measuredWidth;
                w = measuredWidth;
            }
            if (measuredHeight != 0)
            {
                $scaleY = h / measuredHeight;
                h = measuredHeight;
            }
        }

        super.setActualSize(w, h);
    }
    
    /**
     *  The scaling factor of the container in the X direction. 
     * 
     *  <p>If <code>resizeMode</code> is set to <code>ResizeMode.SCALE</code>, 
     *  reading this property always returns 1.0, and setting it does nothing.</p>
     *
     *  <p>If <code>resizeMode</code> is set to anything other than <code>ResizeMode.SCALE</code>, 
     *  reading this property returns the current scaling factor.</p>
     *
     *  @copy mx.core.UIComponent#scaleX
     */    
    override public function get scaleX():Number
    {
        if (_resizeMode == _SCALE_UINT)
            return 1;

        return super.scaleX;
    }

    /**
     *  @private
     */    
    override public function set scaleX(value:Number):void
    {
        if (_resizeMode == _SCALE_UINT)
            return;

        super.scaleX = value;
    }
    
    /**
     *  The scaling factor of the container in the Y direction. 
     * 
     *  <p>If <code>resizeMode</code> is set to <code>ResizeMode.SCALE</code>, 
     *  reading this property always returns 1.0, and setting it does nothing.</p>
     *
     *  <p>If <code>resizeMode</code> is set to anything other than <code>ResizeMode.SCALE</code>, 
     *  reading this property returns the current scaling factor.</p>
     *
     *  @copy mx.core.UIComponent#scaleY
     */    
    override public function get scaleY():Number
    {
        if (_resizeMode == _SCALE_UINT)
            return 1;

        return super.scaleY;
    }

    /**
     *  @private 
     */    
    override public function set scaleY(value:Number):void
    {
        if (_resizeMode == _SCALE_UINT)
            return;

        super.scaleY = value;
    }

    [Bindable("widthChanged")]
    [Inspectable(category="General")]
    [PercentProxy("percentWidth")]
    /**
     *  The width of the container, in pixels. 
     */    
    override public function get width():Number
    {
        if (_resizeMode == _SCALE_UINT)
            return super.width * $scaleX;

        return super.width;
    }
    
    [Bindable("heightChanged")]
    [Inspectable(category="General")]
    [PercentProxy("percentHeight")]
    /**
     *  The height of the container, in pixels. 
     */    
    override public function get height():Number
    {
        if (_resizeMode == _SCALE_UINT)
            return super.height * $scaleY;

        return super.height;
    }
    
    /**
     *  @private
     */
    override protected function skipMeasure():Boolean
    {
        // We never want to skip measure, if we resize by scaling
        return _resizeMode == _SCALE_UINT ? false : super.skipMeasure();
    }

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
                
        if (maskChanged)
        {
            maskChanged = false;
            if (_mask && !_mask.parent)
            {
                super.addChild(_mask);
                var maskComp:UIComponent = _mask as UIComponent;
                if (maskComp)
                {
                    maskComp.validateSize();
                    maskComp.setActualSize(maskComp.getExplicitOrMeasuredWidth(), 
                                           maskComp.getExplicitOrMeasuredHeight());
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
    }

    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        if (_layout)
            _layout.measure();
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        if (_resizeMode == _SCALE_UINT)
        {
            unscaledWidth = measuredWidth;
            unscaledHeight = measuredHeight;
        }  
        
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        if (autoLayout && _layout)
            _layout.updateDisplayList(unscaledWidth, unscaledHeight);
            
        if (_layout)
            _layout.updateScrollRect(unscaledWidth, unscaledHeight);
            
    }
    
    //----------------------------------
    //  horizontal,verticalScrollPositionDelta
    //----------------------------------

    /**
     *  @copy mx.core.IViewport#horizontalScrollPositionDelta
     */
    public function getHorizontalScrollPositionDelta(unit:ScrollUnit):Number
    {
        return (layout) ? layout.getHorizontalScrollPositionDelta(unit) : 0;     
    }
    
    /**
     *  @copy mx.core.IViewport#verticalScrollPositionDelta
     */
    public function getVerticalScrollPositionDelta(unit:ScrollUnit):Number
    {
        return (layout) ? layout.getVerticalScrollPositionDelta(unit) : 0;     
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
     *  @copy mx.core.IViewport#contentWidth
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
     *  @copy mx.core.IViewport#contentWidth
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
     *  This method is is intended for layout class developers who should
     *  call it from the <code>measure()</code> and <code>updateDisplayList()</code> methods.
     *
     *  @param w The new value of <code>contentWidth</code>.
     * 
     *  @param h The new value of <code>contentHeight</code>.
     */
    public function setContentSize(w:Number, h:Number):void
    {
        if ((w == _contentWidth) && (h == _contentHeight))
           return;
        setContentWidth(w);
        setContentHeight(h);
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
    
    // TODO (rfrishbe): only reason we need to override focusPane getter/setter
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
             
             // TODO: remove mask?  SDK-15310
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
     *  The number of layout items in this container. Typically this is the same
     *  as the number of items in the container.
     */
    public function get numLayoutItems():int
    {
        return -1;
    }
    
    /**
     *  Gets the <i>n</i>th layout item in the container. For visual items, the 
     *  layout item is the item itself. For data items, the layout item is the 
     *  item renderer instance that is associated with the item.
     *
     *  @param index The index of the layout item to retrieve.
     *
     *  @return The layout item at the specified index.
     */
    public function getLayoutItemAt(index:int):ILayoutItem
    {
        return null;
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
            _mask = value;
            maskChanged = true;
            invalidateProperties();            
        }
        super.mask = value;         
    } 
    
    //----------------------------------
    //  maskType
    //----------------------------------
    
    [Bindable("propertyChange")]
    [Inspectable(category="General",enumeration="clip,alpha", defaultValue="clip")]
    private var _maskType:String = MaskType.CLIP;
    private var _oldMaskType:String = MaskType.CLIP;
    private var maskTypeChanged:Boolean;
    private var originalMaskFilters:Array;
    
    /**
     *  The mask type.
     *  Possible values are <code>MaskType.CLIP</code> and <code>MaskType.ALPHA</code>. 
     *
     *  @see  mx.graphics.MaskType
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
        if (_maskType != value)
        {
            _oldMaskType = _maskType;
            _maskType = value;
            maskTypeChanged = true;
            invalidateProperties();
        }
    }

    /**
     *  Notify the host that an element has changed and needs to be redrawn.
     *
     *  @param e The element that has changed.
     */
    public function elementChanged(e:IGraphicElement):void
    {
        // TODO!!! Optimize
        invalidateSize();
        invalidateDisplayList();    
    }
    
    /**
     *  Notify the host that an element size has changed.
     * 
     *  @param e The element that has changed size.
     */
    public function elementSizeChanged(e:IGraphicElement):void
    {
        // TODO!!! Optimize
        invalidateSize();
        invalidateDisplayList();    
    }
    
    /**
     *  Notify the host that an element layer has changed.
     * 
     *  @param e The element that has layers size.
     */
    public function elementLayerChanged(e:IGraphicElement):void
    {
        // TODO!!! Optimize
        // TODO!!! Need to recalculate the elements
        invalidateSize();
        invalidateDisplayList();
    }
}

}

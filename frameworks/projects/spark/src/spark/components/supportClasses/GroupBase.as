package flex.core
{
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import flex.events.FlexEvent;
import flex.events.ItemExistenceChangedEvent;
import flex.graphics.Graphic;
import flex.graphics.IGraphicElement;
import flex.graphics.IGraphicElementHost;
import flex.graphics.MaskType;
import flex.graphics.TransformUtil;
import flex.graphics.graphicsClasses.GraphicElement;
import flex.intf.ILayoutItem;
import flex.intf.IViewport;
import flex.layout.LayoutBase;
import flex.layout.BasicLayout;
import flex.layout.LayoutItemFactory;

import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.collections.ListCollectionView;
import mx.controls.Label;
import mx.core.IDataRenderer;
import mx.core.IDeferredInstance;
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

include "../styles/metadata/BasicContainerFormatTextStyles.as"
include "../styles/metadata/AdvancedContainerFormatTextStyles.as"
include "../styles/metadata/BasicParagraphFormatTextStyles.as"
include "../styles/metadata/AdvancedParagraphFormatTextStyles.as"
include "../styles/metadata/BasicCharacterFormatTextStyles.as"
include "../styles/metadata/AdvancedCharacterFormatTextStyles.as"

public class GroupBase extends UIComponent implements IGraphicElementHost, IViewport
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function GroupBase()
    {
        super();
        tabChildren = true;
        
        _layout = new BasicLayout();
        _layout.target = this;  
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    
    //----------------------------------
    //  layout
    //----------------------------------    
        
    private var _layout:LayoutBase;  // initialized in the ctor
        
    public function get layout():LayoutBase
    {
        return _layout;
    }
        
    /**
     * @private
     */
    public function set layout(value:LayoutBase):void
    {
        if (_layout == value)
            return;
        
        _layout = value;  
        if (_layout)
            _layout.target = this;
        invalidateSize();
        invalidateDisplayList();
    }
    
    private var _resizeMode:uint = ResizeMode._NORMAL_UINT;
    
    public function get resizeMode():String
    {
        return ResizeMode.toString(_resizeMode);
    }
    
    public function set resizeMode(stringValue:String):void
    {
        var value:uint = ResizeMode.toUINT(stringValue); 
        if (_resizeMode == value)
            return;
            
        _resizeMode = value;
        
        if (_resizeMode == ResizeMode._SCALE_UINT)
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
     *  @inheritDoc
     */
    override public function setActualSize(w:Number, h:Number):void
    {
        if (_resizeMode == ResizeMode._SCALE_UINT)
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
     *  Make sure we return 1 whenever resizeMode is set to scale. 
     */    
    override public function get scaleX():Number
    {
        if (_resizeMode == ResizeMode._SCALE_UINT)
            return 1;

        return super.scaleX;
    }

    /**
     *  Make sure setting scale is no-op when resizeMode is set to scale. 
     */    
    override public function set scaleX(value:Number):void
    {
        if (_resizeMode == ResizeMode._SCALE_UINT)
            return;

        super.scaleX = value;
    }
    
    /**
     *  Make sure we return 1 whenever resizeMode is set to scale. 
     */    
    override public function get scaleY():Number
    {
        if (_resizeMode == ResizeMode._SCALE_UINT)
            return 1;

        return super.scaleY;
    }

    /**
     *  Make sure setting scale is no-op when resizeMode is set to scale. 
     */    
    override public function set scaleY(value:Number):void
    {
        if (_resizeMode == ResizeMode._SCALE_UINT)
            return;

        super.scaleY = value;
    }

    /**
     *  Override so that we can return correct width when in scale mode. 
     */    
   [PercentProxy("percentWidth")]
    override public function get width():Number
    {
        if (_resizeMode == ResizeMode._SCALE_UINT)
            return super.width * $scaleX;

        return super.width;
    }
    
    /**
     *  Override so that we can return correct height when in scale mode. 
     */    
   [PercentProxy("percentHeight")]
    override public function get height():Number
    {
        if (_resizeMode == ResizeMode._SCALE_UINT)
            return super.height * $scaleY;

        return super.height;
    }
    
    /**
     *  @inheritDoc
     */    
    override protected function skipMeasure():Boolean
    {
        // We never want to skip measure, if we resize by scaling
        return _resizeMode == ResizeMode._SCALE_UINT ? false : super.skipMeasure();
    }
    
    override protected function commitProperties():void
    {
        super.commitProperties();
                
        if (maskChanged)
        {
            maskChanged = false;
            if (_mask && (!_mask.parent || _mask.parent !== this))
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

    override protected function measure():void
    {
        super.measure();
        
        if (_layout)
            _layout.measure();
    }
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        if (_resizeMode == ResizeMode._SCALE_UINT)
        {
            unscaledWidth = measuredWidth;
            unscaledHeight = measuredHeight;
        }  
        
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        if (_layout)
            _layout.updateDisplayList(unscaledWidth, unscaledHeight);
    }
    
    //--------------------------------------------------------------------------
    //
    //  IViewport properties and methods that delegate to layout
    //
    //--------------------------------------------------------------------------    
    
    //----------------------------------
    //  horizontalScrollPosition
    //----------------------------------
        
    [Bindable]

    public function get horizontalScrollPosition():Number 
    {
        return (layout) ? layout.horizontalScrollPosition : 0;
    }

    public function set horizontalScrollPosition(value:Number):void 
    {
        if (layout)
            layout.horizontalScrollPosition = value;
    }
    
    //----------------------------------
    //  verticalScrollPosition
    //----------------------------------
    
    [Bindable]

    public function get verticalScrollPosition():Number 
    {
        return (layout) ? layout.verticalScrollPosition : 0;
    }

    public function set verticalScrollPosition(value:Number):void 
    {
        if (layout)
            layout.verticalScrollPosition = value;
    }
    
    //----------------------------------
    //  horizontal,verticalScrollPositionDelta
    //----------------------------------

    public function horizontalScrollPositionDelta(unit:uint):Number
    {
        return (layout) ? layout.horizontalScrollPositionDelta(unit) : 0;     
    }
    
    public function verticalScrollPositionDelta(unit:uint):Number
    {
        return (layout) ? layout.verticalScrollPositionDelta(unit) : 0;     
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
     * The positive extent of this Group's content, relative to the 0,0
     * origin, along the X axis.
     */
    public function get contentWidth():Number 
    {
        return _contentWidth;
    }
    
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
     * The positive extent of this Group's content, relative to the 0,0 
     * origin, along the Y axis.
     */
    public function get contentHeight():Number 
    {
        return _contentHeight;
    }
    
    private function setContentHeight(value:Number):void 
    {            
        if (value == _contentHeight)
            return;
        var oldValue:Number = _contentHeight;
        _contentHeight = value;
        dispatchPropertyChangeEvent("contentHeight", oldValue, value);        
    }    

    /**
     *  Sets this Group's <code>contentWidth</code> and <code>contentHeight</code>
     *  properties.
     * 
     *  This method is is intended for layout class developers who should
     *  call it from <code>measure()</code> and <code>updateDisplayList()</code>.
     *
     *  @param w The new value of contentWidth.
     *  @param h The new value of contentHeight.
     */
    public function setContentSize(w:Number, h:Number):void
    {
        if ((w == _contentWidth) && (h == _contentHeight))
           return;
        setContentWidth(w);
        setContentHeight(h);
    }
    
    //----------------------------------
    //  clipContent
    //----------------------------------
    
    public function get clipContent():Boolean 
    {
        return (layout) ? layout.clipContent : false;
    }

    public function set clipContent(value:Boolean):void 
    {
        if (layout)
            layout.clipContent = value;
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

    override public function get focusPane():Sprite
    {
        return _focusPane;
    }

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
     *  The number of layout items in this Group. Typically this is the same
     *  as the number of items in the Group.
     */
    public function get numLayoutItems():int
    {
        return -1;
    }
    
    /**
     *  Gets the <i>n</i>th layout item in the Group. For visual items, the 
     *  layout item is the item itself. For data items, the layout item is the 
     *  item renderer instance that is associated with the item.
     *
     *  @param index The index of the item to retrieve.
     *
     *  @return The layout item at the specified index.
     */
    public function getLayoutItemAt(index:int):ILayoutItem
    {
        return null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  IGraphicElement Implementation
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  mask
    //----------------------------------
    private var _mask:DisplayObject;
    private var maskChanged:Boolean;
    
    [Inspectable(category="General")]
    override public function get mask():DisplayObject
    {
        return _mask;
    }
    
    /*
     *  sets the mask. The mask will be added to the display list. The mask must
     *  not already on a display list nor in the elements array.  
     */ 
    override public function set mask(value:DisplayObject):void
    {
        if (_mask !== value)
        {
            _mask = value;
            maskChanged = true;
            invalidateProperties();
            //addDrawnElements();
            
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
    
    public function get maskType():String
    {
        return _maskType;
    }
    
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

    //--------------------------------------------------------------------------
    //
    //  IGraphicElementHost Implementation
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @inheritDoc
     */
    public function elementChanged(e:IGraphicElement):void
    {
        // TODO!!! Optimize
        invalidateSize();
        invalidateDisplayList();    
    }
    
    /**
     *  @inheritDoc
     */
    public function elementSizeChanged(e:IGraphicElement):void
    {
        // TODO!!! Optimize
        invalidateSize();
        invalidateDisplayList();    
    }
    
    /**
     * @inheritDoc
     */
    public function elementLayerChanged(e:IGraphicElement):void
    {
        // TODO!!! Optimize
        // TODO!!! Need to recalculate the elements
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  @inheritDoc
     */
    public function get parentGraphic():Graphic
    {
        return null;
    }
    
    /**
     *  @inheritDoc
     */
    public function addMaskElement(mask:DisplayObject, target:IGraphicElement):void
    {
        
    }
    
    /**
     *  @inheritDoc
     */
    public function removeMaskElement(mask:DisplayObject, target:IGraphicElement):void
    {
        
    }
    
    /** 
     *  Helper method to wrap up the changes in a propertyChangeEvent and dispatch it.
     * 
     *  @param prop Property that's changed
     *  @param oldValue Old value of the property
     *  @param value New value of the property
     */
    protected function dispatchPropertyChangeEvent(prop:String, oldValue:*, value:*):void
    {
        dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, prop, oldValue, value));
    }
}
}
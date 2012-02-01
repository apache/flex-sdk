////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.graphics.graphicsClasses
{
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Transform;

import mx.components.baseClasses.GroupBase;
import mx.core.AdvancedLayoutFeatures;
import mx.core.IInvalidating;
import mx.core.IVisualItem;
import mx.core.UIComponent;
import mx.core.UIComponentGlobals;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;
import mx.filters.BaseFilter;
import mx.filters.IBitmapFilter;
import mx.geom.Transform;
import mx.geom.TransformOffsets;
import mx.graphics.IGraphicElement;
import mx.graphics.IStroke;
import mx.graphics.MaskType;
import mx.layout.ILayoutItem;
import mx.managers.ILayoutManagerClient;
import mx.utils.MatrixUtil;
import mx.utils.OnDemandEventDispatcher;
import flash.display.DisplayObjectContainer;

use namespace mx_internal;

/**
 *  A base class for defining individual graphic elements. Types of graphic elements include:
 *  <ul>
 *   <li>Shapes</li>
 *   <li>Text</li>
 *   <li>Raster images</li>
 *  </ul>
 *  
 *  <p>When defining a graphic element, you specify an explicit size for the element; 
 *  that is, you cannot use percentage sizing as you can when specifying the size of a control.</p>
 *  
 *  <p>The TBounds are the boundaries of an
 *  object in the object's parent coordinate space. The UBounds are the boundaries
 *  of an object in its own coordinate space.</p>
 */
public class GraphicElement extends OnDemandEventDispatcher
    implements IGraphicElement, IInvalidating, ILayoutItem, IVisualItem
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  The default value for the <code>maxWidth</code> property.
     *
     *  @default 10000
     */
    public static const DEFAULT_MAX_WIDTH:Number = 10000;

    /**
     *  The default value for the <code>maxHeight</code> property.
     *
     *  @default 10000
     */
    public static const DEFAULT_MAX_HEIGHT:Number = 10000;

     /**
     *  The default value for the <code>minWidth</code> property.
     *
     *  @default 0
     */
    public static const DEFAULT_MIN_WIDTH:Number = 0;

    /**
     *  The default value for the <code>minHeight</code> property.
     *
     *  @default 0
     */
    public static const DEFAULT_MIN_HEIGHT:Number = 0;

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    public function GraphicElement()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private var displayObjectChanged:Boolean;
    
    /**
     *  @private
     */
    private var _colorTransform:ColorTransform;

	/**
     *  @private The Sprite to draw into. 
     *  If null, then we just use displayObject or sharedDisplayObject
     */
	private var _drawnDisplayObject:Sprite;

    /**
     *  @private
     *  Whether this element needs to have its
     *  commitProperties() method called.
     */
    mx_internal var invalidatePropertiesFlag:Boolean = false;

    /**
     *  @private
     *  Whether this element needs to have its
     *  measure() method called.
     */
    mx_internal var invalidateSizeFlag:Boolean = false;

    /**
     *  @private
     *  Whether this element needs to be have its
     *  updateDisplayList() method called.
     */
    mx_internal var invalidateDisplayListFlag:Boolean = false;


    /**
     *  Contain all of the implementation details of how the GraphicElement implements
     *  transform and layering support. In most cases, you should not have to modify this 
     *  property.
     */
    protected var layoutFeatures:AdvancedLayoutFeatures;


    /**
     *  @private
     *  storage for the x property. This property is used when a GraphicElement has a simple transform.
     */
     private var _x:Number = 0;

    /**
     *  @private
     *  storage for the y property. This property is used when a GraphicElement has a simple transform.
     */
     private var _y:Number = 0;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    [Bindable("propertyChange")]
    /**
     *  Defines a set of adjustments that can be applied to the component's transform in a way that is 
     *  invisible to the component's parent's layout. For example, if you want a layout to adjust 
     *  for a component that will be rotated 90 degrees, you set the component's <code>rotation</code> property. 
     *  If you want the layout to <i>not</i> adjust for the component being rotated, you set its <code>offsets.rotationZ</code> 
     *  property.
     */
    public function set offsets(value:TransformOffsets):void
    {
        if(value != null)
            allocateLayoutFeatures();

        var oldValue:TransformOffsets = layoutFeatures.offsets;
        
        if(layoutFeatures.offsets != null)
            layoutFeatures.offsets.removeEventListener(Event.CHANGE,transformOffsetsChangedHandler);
        layoutFeatures.offsets = value;
        if(layoutFeatures.offsets != null)
            layoutFeatures.offsets.addEventListener(Event.CHANGE,transformOffsetsChangedHandler);
        dispatchPropertyChangeEvent("offsets", oldValue, value);
    }
    
    /**
     * @private
     */
    public function get offsets():TransformOffsets
    {
        return (layoutFeatures == null)? null:layoutFeatures.offsets;
    }

    protected function allocateLayoutFeatures():void
    {
        if(layoutFeatures != null)
            return;
        layoutFeatures = new AdvancedLayoutFeatures();
        layoutFeatures.layoutX = _x;
        layoutFeatures.layoutY = _y;
    }
    
    protected function invalidateTransform(changeInvalidatesLayering:Boolean = true,triggerLayout:Boolean = true):void
    {
        if(changeInvalidatesLayering)
            notifyElementLayerChanged();
        if(triggerLayout)
        {
            invalidateParentSizeAndDisplayList();
            invalidateProperties();
        }
        if(layoutFeatures != null)
	        layoutFeatures.updatePending = true;
    }

    /**
     * @private
     */
    private function transformOffsetsChangedHandler(e:Event):void
    {
        invalidateTransform();
    }
    
    //----------------------------------
    //  alpha
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the alpha property.
     */
    private var _alpha:Number = 1.0;
    
    /**
     *  @private
     */
    private var alphaChanged:Boolean = false;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     */
    public function get alpha():Number
    {
        return _alpha;
    }

    /**
     *  @private
     */
    public function set alpha(value:Number):void
    {
        if (_alpha == value)
            return;

        var oldValue:Number = _alpha;
        _alpha = value;
        dispatchPropertyChangeEvent("alpha", oldValue, value);

        alphaChanged = true;
        notifyElementLayerChanged();
        invalidateProperties();
    }

    //----------------------------------
    //  baseline
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the baseline property.
     */
    private var _baseline:Object;

    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     */
    public function get baseline():Object
    {
        return _baseline;
    }

    /**
     *  @private
     */
    public function set baseline(value:Object):void
    {
        if (_baseline == value)
            return;

        _baseline = value;
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  blendMode
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the blendMode property.
     */
    private var _blendMode:String = BlendMode.NORMAL;
    
    /**
     *  @private
     */
    private var blendModeChanged:Boolean;
    private var blendModeExplicitlySet:Boolean = false;

    [Bindable("propertyChange")]
    [Inspectable(category="General", enumeration="add,alpha,darken,difference,erase,hardlight,invert,layer,lighten,multiply,normal,subtract,screen,overlay", defaultValue="normal")]

    /**
     *  @inheritDoc
     */
    public function get blendMode():String
    {
        if (blendModeExplicitlySet)
            return _blendMode;
        else return BlendMode.LAYER;
    }

    /**
     *  @private
     */
    public function set blendMode(value:String):void
    {
        if (blendModeExplicitlySet && _blendMode == value)
            return;

        var oldValue:String = _blendMode;
        _blendMode = value;
        dispatchPropertyChangeEvent("blendMode", oldValue, value);

        blendModeExplicitlySet = true;

        blendModeChanged = true;
        notifyElementLayerChanged();
        invalidateProperties();
    }

    //----------------------------------
    //  bottom
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the blendMode property.
     */
    private var _bottom:Object;

    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     */
    public function get bottom():Object
    {
        return _bottom;
    }

    /**
     *  @private
     */
    public function set bottom(value:Object):void
    {
        if (_bottom == value)
            return;

        _bottom = value;
        invalidateParentSizeAndDisplayList();
    }
    
    //----------------------------------
    //  owner
    //----------------------------------

    /**
     *  @private
     */
    private var _owner:DisplayObjectContainer;

    /**
     *  @inheritDoc
     */
    public function get owner():DisplayObjectContainer
    {
        return _owner ? _owner : parent;
    }

    public function set owner(value:DisplayObjectContainer):void
    {
        _owner = value;
    }
    
    //----------------------------------
    //  parent
    //----------------------------------

    /**
     *  @inheritDoc
     */
    public function get parent():DisplayObjectContainer
    {
        return elementHost;
    }
    
    /**
     *  @private
     */
    public function set parent(value:DisplayObjectContainer):void
    {
        elementHost = GroupBase(value);
    }

    //----------------------------------
    //  elementHost
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the elementHost property.
     */
    protected var _host:GroupBase;

    /**
     *  The is a temporary property, which will be removed when all references to 
     *  elementHost have been removed.
     */
    public function get elementHost():GroupBase
    {
        return _host;
    }

    /**
     *  @private
     */
    public function set elementHost(value:GroupBase):void
    {
        if (_host !== value)
        {
            _host = value;
            if (_host && _host is IInvalidating)
            {
                IInvalidating(_host).invalidateProperties();
                IInvalidating(_host).invalidateSize();
                IInvalidating(_host).invalidateDisplayList();
            }
        }
    }

    //----------------------------------
    //  explicitHeight
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the explicitHeight property.
     */
    private var _explicitHeight:Number;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     */
    public function get explicitHeight():Number
    {
        return _explicitHeight;
    }

    /**
     *  @private
     */
    public function set explicitHeight(value:Number):void
    {
        if (_explicitHeight == value)
            return;

        // height can be pixel or percent, not both
        if (!isNaN(value))
            percentHeight = NaN;

        var oldValue:Number = _explicitHeight;
        _explicitHeight = value;
        dispatchPropertyChangeEvent("explicitHeight", oldValue, value);

        invalidateSize();
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  explicitMaxHeight
    //----------------------------------

    /**
     *  @inheritDoc
     */
    public function get explicitMaxHeight():Number { return maxHeight; }
    public function set explicitMaxHeight(value:Number):void { maxHeight = value; }

    //----------------------------------
    //  explicitMaxWidth
    //----------------------------------

    /**
     *  @inheritDoc
     */
    public function get explicitMaxWidth():Number { return maxWidth; }
    public function set explicitMaxWidth(value:Number):void { maxWidth = value; }

    //----------------------------------
    //  explicitMinHeight
    //----------------------------------

    /**
     *  @inheritDoc
     */
    public function get explicitMinHeight():Number { return minHeight; }
    public function set explicitMinHeight(value:Number):void { minHeight = value; }

    //----------------------------------
    //  explicitMinWidth
    //----------------------------------

    /**
     *  @inheritDoc
     */
    public function get explicitMinWidth():Number { return minWidth; }
    public function set explicitMinWidth(value:Number):void { minWidth = value; }

    //----------------------------------
    //  explicitWidth
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the explicitHeight property.
     */
    private var _explicitWidth:Number;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     */
    public function get explicitWidth():Number
    {
        return _explicitWidth;
    }

    /**
     *  @private
     */
    public function set explicitWidth(value:Number):void
    {
        if (_explicitWidth == value)
            return;

        // height can be pixel or percent, not both
        if (!isNaN(value))
            percentWidth = NaN;

        var oldValue:Number = _explicitWidth;
        _explicitWidth = value;
        dispatchPropertyChangeEvent("explicitWidth", oldValue, value);

        invalidateSize();
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  filters
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the filters property.
     */
    private var _filters:Array = [];
    
    /**
     *  @private
     */
    private var filtersChanged:Boolean;

    /**
     *  @private
     */
    private var _clonedFilters:Array;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  An indexed array that contains each filter object currently associated with the graphic element. 
     *  The mx.filters.* package contains several classes that define specific filters you can use.
     */
    public function get filters():Array
    {
        return _filters;
    }

    /**
     *  @private
     */
    public function set filters(value:Array):void
    {
        var i:int = 0;
        var oldFilters:Array = _filters ? _filters.slice() : null;
        var len:int = oldFilters ? oldFilters.length : 0;
        var edFilter:IEventDispatcher;

        for (i = 0; i < len; i++)
        {
            edFilter = value[i] as IEventDispatcher;
            if (edFilter)
                edFilter.removeEventListener(BaseFilter.CHANGE, filterChangedHandler);
        }

        _clonedFilters = [];
        _filters = value;
        len = value.length;

        for (i = 0; i < len; i++)
        {
            if (value[i] is IBitmapFilter)
            {
                edFilter = value[i] as IEventDispatcher;
                if (edFilter)
                    edFilter.addEventListener(BaseFilter.CHANGE, filterChangedHandler);
                _clonedFilters.push(IBitmapFilter(value[i]).clone());
            }
            else
            {
                _clonedFilters.push(value[i]);
            }
        }

        dispatchPropertyChangeEvent("filters", oldFilters, _filters);

        filtersChanged = true;
        notifyElementLayerChanged();
        invalidateProperties();
    }

    //----------------------------------
    //  height
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the height property.
     */
    mx_internal var _height:Number = 0;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    [PercentProxy("percentHeight")]

    /**
     *  The height of the graphic element.
     *
     *  @default 0
     */
    public function get height():Number
    {
        return _height;
    }

    /**
     *  @private
     */
    
    public function set height(value:Number):void
    {
        explicitHeight = value;

        if (_height == value)
            return;

        var oldValue:Number = _height;
        _height = value;
        dispatchPropertyChangeEvent("height", oldValue, value);

        // Invalidate the display list, since we're changing the actual width
        // and we're not going to correctly detect whether the layout sets
        // new actual width different from our previous value.
        // TODO EGeorgie: is this worth optimizing?
        invalidateDisplayList();
    }

    //----------------------------------
    //  horizontalCenter
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the horizontalCenter property.
     */
    private var _horizontalCenter:Object;

    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     */
    public function get horizontalCenter():Object
    {
        return _horizontalCenter;
    }

    /**
     *  @private
     */
    public function set horizontalCenter(value:Object):void
    {
        if (_horizontalCenter == value)
            return;

        _horizontalCenter = value;
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  left
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the left property.
     */
    private var _left:Object;

    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     */
    public function get left():Object
    {
        return _left;
    }

    /**
     *  @private
     */
    public function set left(value:Object):void
    {
        if (_left == value)
            return;

        _left = value;
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  mask
    //----------------------------------

    /**
     *  @private
     *  Storage for the mask property.
     */
    private var _mask:DisplayObject;
    
    /**
     *  @private
     */
    private var maskChanged:Boolean;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     */
    public function get mask():DisplayObject
    {
        return _mask;
    }

    /**
     *  @private
     */
    public function set mask(value:DisplayObject):void
    {
        if (_mask == value)
            return;

        var oldMask:UIComponent = _mask as UIComponent;
        _mask = value;
        
        // If the old mask was attached by us, then we need to 
        // undo the attachment logic        
 		if (oldMask && oldMask.$parent === displayObject)
        {		
        	if (oldMask.parent is UIComponent)
            	UIComponent(oldMask.parent).childRemoved(oldMask);
            oldMask.$parent.removeChild(oldMask);
        }     
        
        // Cleanup the drawnDisplayObject mask and _drawnDisplayObject here
        // because displayObject (the parent of _drawnDisplayObject)
        // might be null in commitProperties
        if (!_mask || _mask.parent)
        {
        	if (drawnDisplayObject)
        		drawnDisplayObject.mask = null;	
        	
        	if (_drawnDisplayObject)
    		{
    			if (_drawnDisplayObject.parent)
    				_drawnDisplayObject.parent.removeChild(_drawnDisplayObject);
    			_drawnDisplayObject = null;
    		}
        }
        
        dispatchPropertyChangeEvent("mask", oldMask, value);
        maskChanged = true;
        maskTypeChanged = true;
        notifyElementLayerChanged();
        invalidateProperties();
    }

    //----------------------------------
    //  maskType
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the maskType property.
     */
    private var _maskType:String = MaskType.CLIP;
    
    /**
     *  @private
     */
    private var maskTypeChanged:Boolean;

    [Bindable("propertyChange")]
    [Inspectable(category="General", enumeration="clip,alpha", defaultValue="clip")]
    
    /**
     *  @inheritDoc
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
        if (_maskType == value)
            return;

        var oldValue:String = _maskType;
        _maskType = value;
        dispatchPropertyChangeEvent("maskType", oldValue, value);

        maskTypeChanged = true;
        invalidateProperties();
    }

    //----------------------------------
    //  maxHeight
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the maxHeight property.
     */
    private var _maxHeight:Number;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  @copy mx.core.UIComponent#maxHeight
     */
    public function get maxHeight():Number
    {
        // TODO!!! Examine this logic, Make this arbitrarily large (use UIComponent max)
        return !isNaN(_maxHeight) ? _maxHeight : DEFAULT_MAX_HEIGHT;
    }

    /**
     *  @private
     */
    public function set maxHeight(value:Number):void
    {
        if (_maxHeight == value)
            return;

        var oldValue:Number = _maxHeight;
        _maxHeight = value;
        dispatchPropertyChangeEvent("maxHeight", oldValue, value);

        invalidateSize();
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  maxWidth
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the maxHeight property.
     */
    private var _maxWidth:Number;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  @copy mx.core.UIComponent#maxWidth
     */
    public function get maxWidth():Number
    {
        // TODO!!! Examine this logic, Make this arbitrarily large (use UIComponent max)
        return !isNaN(_maxWidth) ? _maxWidth : DEFAULT_MAX_WIDTH;
    }

    /**
     *  @private
     */
    public function set maxWidth(value:Number):void
    {
        if (_maxWidth == value)
            return;

        var oldValue:Number = _maxWidth;
        _maxWidth = value;
        dispatchPropertyChangeEvent("maxWidth", oldValue, value);

        invalidateSize();
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  measuredHeight
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the measuredHeight property.
     */
    private var _measuredHeight:Number = 0;
    
    /**
     *  @copy mx.core.UIComponent#measuredHeight
     */
    public function get measuredHeight():Number
    {
        return _measuredHeight;
    }
    
    /**
     *  @private
     */
    public function set measuredHeight(value:Number):void
    {
        _measuredHeight = value;
    }

    //----------------------------------
    //  measuredWidth
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the measuredWidth property.
     */
    private var _measuredWidth:Number = 0;
    
    /**
     *  @copy mx.core.UIComponent#measuredWidth
     */
    public function get measuredWidth():Number
    {
        return _measuredWidth;
    }
    
    /**
     *  @private
     */
    public function set measuredWidth(value:Number):void
    {
        _measuredWidth = value;
    }

    //----------------------------------
    //  measuredX
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the measuredX property.
     */
    private var _measuredX:Number = 0;
    
    /**
     *  The default measured bounds top-left corner relative to the origin of the element.     
     */
    public function get measuredX():Number
    {
        return _measuredX;
    }
    
    /**
     *  @private
     */
    public function set measuredX(value:Number):void
    {
        _measuredX = value;
    }

    //----------------------------------
    //  measuredY
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the measuredY property.
     */
    private var _measuredY:Number = 0;
    
    /**
     *  The default measured bounds top-left corner relative to the origin of the element.     
     */
    public function get measuredY():Number
    {
        return _measuredY;
    }
    
    /**
     *  @private
     */
    public function set measuredY(value:Number):void
    {
        _measuredY = value;
    }

    //----------------------------------
    //  minHeight
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the minHeight property.
     */
    private var _minHeight:Number;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  @copy mx.core.UIComponent#minHeight
     */
    public function get minHeight():Number
    {
        // TODO!!! Examine this logic
        return !isNaN(_minHeight) ? _minHeight : DEFAULT_MIN_HEIGHT;
    }

    /**
     *  @private
     */
    public function set minHeight(value:Number):void
    {
        if (_minHeight == value)
            return;

        var oldValue:Number = _minHeight;
        _minHeight = value;
        dispatchPropertyChangeEvent("minHeight", oldValue, value);

        invalidateSize();
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  minWidth
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the minWidth property.
     */
    private var _minWidth:Number;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  @copy mx.core.UIComponent#minWidth
     */
    public function get minWidth():Number
    {
        // TODO!!! Examine this logic
        return !isNaN(_minWidth) ? _minWidth : DEFAULT_MIN_WIDTH;
    }

    /**
     *  @private
     */
    public function set minWidth(value:Number):void
    {
        if (_minWidth == value)
            return;

        var oldValue:Number = _minWidth;
        _minWidth = value;
        dispatchPropertyChangeEvent("minWidth", oldValue, value);

        invalidateSize();
        invalidateParentSizeAndDisplayList();
    }
    
    //----------------------------------
    //  percentHeight
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the percentHeight property.
     */
    private var _percentHeight:Number;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  @inheritDoc
     */
    public function get percentHeight():Number
    {
        return _percentHeight;
    }

    /**
     *  @private
     */
    public function set percentHeight(value:Number):void
    {
        if (_percentHeight == value)
            return;

        if (!isNaN(value))
            explicitHeight = NaN;

        var oldValue:Number = _percentHeight;
        _percentHeight = value;
        dispatchPropertyChangeEvent("percentHeight", oldValue, value);

        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  percentWidth
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the percentWidth property.
     */
    private var _percentWidth:Number;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  @copy mx.core.UIComponent#percentWidth
     */
    public function get percentWidth():Number
    {
        return _percentWidth;
    }

    /**
     *  @private
     */
    public function set percentWidth(value:Number):void
    {
        if (_percentWidth == value)
            return;

        if (!isNaN(value))
            explicitWidth = NaN;

        var oldValue:Number = _percentWidth;
        _percentWidth = value;
        dispatchPropertyChangeEvent("percentWidth", oldValue, value);

        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  right
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the right property.
     */
    private var _right:Object;

    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     */
    public function get right():Object
    {
        return _right;
    }

    /**
     *  @private
     */
    public function set right(value:Object):void
    {
        if (_right == value)
            return;

        _right = value;
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  rotation
    //----------------------------------


    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
	/**
	 * Indicates the x-axis rotation of the element instance, in degrees, from its original orientation 
	 * relative to the 3D parent container. Values from 0 to 180 represent clockwise rotation; values 
	 * from 0 to -180 represent counterclockwise rotation. Values outside this range are added to or subtracted from 
	 * 360 to obtain a value within the range.
	 * 
	 * This property is ignored during calculation by any of Flex's 2D layouts. 
	 */
    public function get rotationX():Number
    {
        return (layoutFeatures == null)? 0:layoutFeatures.layoutRotationX;
    }

    /**
     *  @private
     */
    public function set rotationX(value:Number):void
    {
        
        var oldValue:Number = rotationX;
        if (oldValue == value)
            return;

        allocateLayoutFeatures();
        
        layoutFeatures.layoutRotationX = value;
        dispatchPropertyChangeEvent("rotationX", oldValue, value);
        invalidateTransform();
    }

    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
	/**
	 * Indicates the y-axis rotation of the DisplayObject instance, in degrees, from its original orientation 
	 * relative to the 3D parent container. Values from 0 to 180 represent clockwise rotation; values 
	 * from 0 to -180 represent counterclockwise rotation. Values outside this range are added to or subtracted from 
	 * 360 to obtain a value within the range.
	 * 
	 * This property is ignored during calculation by any of Flex's 2D layouts. 
	 */
    public function get rotationY():Number
    {
        return (layoutFeatures == null)? 0:layoutFeatures.layoutRotationY;
    }
    /**
     *  @private
     */
    public function set rotationY(value:Number):void
    {
        var oldValue:Number = rotationY;
        if (oldValue == value)
            return;
        
        allocateLayoutFeatures();
        layoutFeatures.layoutRotationY = value;
        dispatchPropertyChangeEvent("rotationY", oldValue, value);
        invalidateTransform();
    }
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  Indicates the rotation of the element, in degrees,
     *  from the transform point.
     */
    public function get rotationZ():Number
    {
        return (layoutFeatures == null)? 0:layoutFeatures.layoutRotationZ;
    }

    /**
     *  @private
     */
    public function set rotationZ(value:Number):void
    {
        var oldValue:Number = rotationZ;
        if (oldValue == value)
            return;

        allocateLayoutFeatures();
        
        layoutFeatures.layoutRotationZ = value;
        dispatchPropertyChangeEvent("rotationZ", oldValue, value);
        dispatchPropertyChangeEvent("rotation", oldValue, value);
        invalidateTransform();
    }

    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  Indicates the rotation of the element, in degrees,
     *  from the transform point.
     */
    public function get rotation():Number
    {
        return (layoutFeatures == null)? 0:layoutFeatures.layoutRotationZ;
    }

    /**
     *  @private
     */
    public function set rotation(value:Number):void
    {
        rotationZ = value;
    }

    //----------------------------------
    //  scaleX
    //----------------------------------

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  The horizontal scale (percentage) of the element
     *  as applied from the transform point.
     */
    public function get scaleX():Number
    {
        return (layoutFeatures == null)? 1:layoutFeatures.layoutScaleX;
    }

    /**
     *  @private
     */
    public function set scaleX(value:Number):void
    {
        var oldValue:Number = scaleX;
        if (oldValue == value)
            return;

        allocateLayoutFeatures();

        layoutFeatures.layoutScaleX = value;
        dispatchPropertyChangeEvent("scaleX", oldValue, value);
        invalidateTransform();
    }

    //----------------------------------
    //  scaleY
    //----------------------------------

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  The vertical scale (percentage) of the element
     *  as applied from the transform point.
     */
    public function get scaleY():Number
    {
        return (layoutFeatures == null)? 1:layoutFeatures.layoutScaleY;
    }

    /**
     *  @private
     */
    public function set scaleY(value:Number):void
    {
        var oldValue:Number = scaleY;
        if (oldValue == value)
            return;

        allocateLayoutFeatures();

        layoutFeatures.layoutScaleY = value;
        dispatchPropertyChangeEvent("scaleY", oldValue, value);
        invalidateTransform();
    }

    //----------------------------------
    //  scaleZ
    //----------------------------------

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  The z scale (percentage) of the element
     *  as applied from the transform point.
     */
    public function get scaleZ():Number
    {
        return (layoutFeatures == null)? 1:layoutFeatures.layoutScaleZ;
    }

    /**
     *  @private
     */
    public function set scaleZ(value:Number):void
    {
        var oldValue:Number = scaleZ;
        if (oldValue == value)
            return;

        allocateLayoutFeatures();

        layoutFeatures.layoutScaleZ = value;
        dispatchPropertyChangeEvent("scaleZ", oldValue, value);
        invalidateTransform();
    }

    //----------------------------------
    //  top
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the top property.
     */
    private var _top:Object;

    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     */
    public function get top():Object
    {
        return _top;
    }

    /**
     *  @private
     */
    public function set top(value:Object):void
    {
        if (_top == value)
            return;

        _top = value;
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  transform
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the transform property.
     */
    private var _transform:flash.geom.Transform;

    /**
     *  @copy mx.core.UIComponent#transform
     */
    public function get transform():flash.geom.Transform
    {
        if (!_transform) 
            setTransform(new mx.geom.Transform());
            
        return _transform;
    }

    /**
     *  @private
     */
    public function set transform(value:flash.geom.Transform):void
    {
        setTransform(value);

        if (_transform)
        {
            allocateLayoutFeatures();

            if(_transform.matrix != null)
            {
                layoutFeatures.layoutMatrix = _transform.matrix.clone();
            }
            else if (_transform.matrix3D != null)
            {    
                layoutFeatures.layoutMatrix3D = _transform.matrix3D.clone();
            }          
        }
        
        _colorTransform = _transform ? _transform.colorTransform : null;
         
        invalidateTransform();
    }

    /**
     * @private
     */ 
    private function setTransform(value:flash.geom.Transform):void
    {
        // Clean up the old event listeners
        var oldTransform:mx.geom.Transform = _transform as mx.geom.Transform;
        if (oldTransform)
        {
            oldTransform.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, transformPropertyChangeHandler);
        }

        var newTransform:mx.geom.Transform = value as mx.geom.Transform;

        if (newTransform)
        {
            newTransform.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, transformPropertyChangeHandler);
        }

        _transform = value;
    }
    
    /**
     *  The transform matrix that is used to calculate the component's layout relative to its siblings. This matrix
     *  is defined by the component's 2D properties such as <code>x</code>, <code>y</code>, <code>rotation</code>, 
     *  <code>scaleX</code>, <code>scaleY</code>, <code>transformX</code>, and <code>transformY</code>.
     *  <p>This matrix is modified by the values of the <code>offset</code> property to determine its final, computed matrix.</p>
     */
    public function get layoutMatrix():Matrix
    {
        if(layoutFeatures != null)
            return layoutFeatures.layoutMatrix;
        var m:Matrix = new Matrix();
        m.translate(_x,_y);
        return m;         
    }

    /**
     * @private
     */
    public function set layoutMatrix(value:Matrix):void
    {
        allocateLayoutFeatures();
        layoutFeatures.layoutMatrix = value;
        invalidateTransform();
    }

    /**
     *  The transform matrix that is used to calculate a component's layout relative to its siblings. This matrix is defined by
     *  the component's 3D properties (which include the 2D properties such as <code>x</code>, <code>y</code>, <code>rotation</code>, 
     *  <code>scaleX</code>, <code>scaleY</code>, <code>transformX</code>, and <code>transformY</code>, as well as <code>rotationX</code>, 
     *  <code>rotationY</code>, <code>scaleZ</code>, <code>z</code>, and <code>transformZ</code>.
     *  
     *  <p>Most components do not have any 3D transform properties set on them.</p>
     *  
     *  <p>This matrix is modified by the values of the <code>offset</code> property to determine its final, computed matrix.</p>
     */
    public function set layoutMatrix3D(value:Matrix3D):void
    {
        allocateLayoutFeatures();
        layoutFeatures.layoutMatrix3D = value;
        invalidateTransform();
    }

    /**
     * @private
     */
    public function get layoutMatrix3D():Matrix3D
    {
        if(layoutFeatures != null)
            return layoutFeatures.layoutMatrix3D;
        var m:Matrix3D = new Matrix3D();
        m.appendTranslation(_x,_y,0);
        return m;           
    }
    
	/**
	 * A utility method to update the rotation and scale of the transform while keeping a particular point, specified in the component's own coordinate space, 
	 * fixed in the parent's coordinate space.  This function will assign the rotation and scale values provided, then update the x/y/z properties
	 * as necessary to keep tx/ty/tz fixed.
	 * @param rx,ry,rz the new values for the rotation of the transform
	 * @param sx,sy,sz the new values for the scale of the transform
	 * @param tx,ty,tz the point, in the component's own coordinates, to keep fixed relative to its parent.
	 */
    public function transformAround(rx:Number,ry:Number,rz:Number,sx:Number,sy:Number,sz:Number,tx:Number,ty:Number,tz:Number):void
    {
        allocateLayoutFeatures();
        layoutFeatures.transformAround(rx,ry,rz,sx,sy,sz,tx,ty,tz,true);
        invalidateTransform();
    }       

    //----------------------------------
    //  transformX
    //----------------------------------
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  The x position transform point of the element.
     */
    public function get transformX():Number
    {
        return (layoutFeatures == null)? 0:layoutFeatures.transformX;
    }

    /**
     *  @private
     */
    public function set transformX(value:Number):void
    {
        var oldValue:Number = transformX;
        if ( oldValue == value)
            return;
            
        allocateLayoutFeatures();
            
        layoutFeatures.transformX = value;
        dispatchPropertyChangeEvent("transformX", oldValue, value);
        invalidateTransform(false);
    }

    //----------------------------------
    //  transformY
    //----------------------------------
    

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  The y position transform point of the element.
     */
    public function get transformY():Number
    {
        return (layoutFeatures == null)? 0:layoutFeatures.transformY;
    }

    /**
     *  @private
     */
    public function set transformY(value:Number):void
    {
        var oldValue:Number = transformY;
        if (oldValue == value)
            return;

        allocateLayoutFeatures();

        layoutFeatures.transformY = value;
        dispatchPropertyChangeEvent("transformY", oldValue, value);
        invalidateTransform(false);
    }

    //----------------------------------
    //  transformZ
    //----------------------------------
    

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  The y position transform point of the element.
     */
    public function get transformZ():Number
    {
        return (layoutFeatures == null)? 0:layoutFeatures.transformZ;
    }

    /**
     *  @private
     */
    public function set transformZ(value:Number):void
    {
        var oldValue:Number = transformZ;
        if (oldValue == value)
            return;

        allocateLayoutFeatures();

        layoutFeatures.transformZ = value;
        dispatchPropertyChangeEvent("transformZ", oldValue, value);
        invalidateTransform();
    }

    //----------------------------------
    //  verticalCenter
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the verticalCenter property.
     */
    private var _verticalCenter:Object;

    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     */
    public function get verticalCenter():Object
    {
        return _verticalCenter;
    }

    /**
     *  @private
     */
    public function set verticalCenter(value:Object):void
    {
        if (_verticalCenter == value)
            return;

        _verticalCenter = value;
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  width
    //----------------------------------

    /**
     *  @private
     *  Storage for the width property.
     */
    mx_internal var _width:Number = 0;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    [PercentProxy("percentWidth")]

    /**
     *  The width of the graphic element.
     *
     *  @default 0
     */
    public function get width():Number
    {
        return _width;
    }

    /**
     *  @private
     */
    public function set width(value:Number):void
    {
        explicitWidth = value;

        if (_width == value)
            return;

        var oldValue:Number = _width;
        _width = value;
        dispatchPropertyChangeEvent("width", oldValue, value);

        // Invalidate the display list, since we're changing the actual height
        // and we're not going to correctly detect whether the layout sets
        // new actual height different from our previous value.
        // TODO EGeorgie: is this worth optimizing?
        invalidateDisplayList();
    }

    //----------------------------------
    //  layer
    //----------------------------------  
	/**
	 * Determines the order in which items inside of groups are rendered. Groups order their items based on their layer property, with the lowest layer
	 * in the back, and the higher in the front.  items with the same layer value will appear in the order they are added to the Groups item list.
	 * 
	 * defaults to 0
	 * 
	 * @default 0
	 */
    public function get layer():Number
    {
        return (layoutFeatures == null)? 0:layoutFeatures.layer;
    }

    /**
     *  @private
     */
    public function set layer(value:Number):void
    {
        if(value == layer)
            return;

        allocateLayoutFeatures();

         layoutFeatures.layer = value;  
        if(_host != null && _host is UIComponent)
            (_host as UIComponent).invalidateLayering();
    }

    //----------------------------------
    //  x
    //----------------------------------  
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  The x position of the graphic element.
     */
    public function get x():Number
    {
        return (layoutFeatures == null)? _x:layoutFeatures.layoutX;
    }

    /**
     *  @private
     */
    public function set x(value:Number):void
    {
        var oldValue:Number = x;
        if (oldValue == value)
            return;

        if(layoutFeatures != null)
            layoutFeatures.layoutX = value;
        else
            _x = value;
            
        dispatchPropertyChangeEvent("x", oldValue, value);
        invalidateTransform(false);
    }

    //----------------------------------
    //  y
    //----------------------------------   

    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  The y position of the graphic element.
     */
    public function get y():Number
    {
        return (layoutFeatures == null)? _y:layoutFeatures.layoutY;
    }

    /**
     *  @private
     */
    public function set y(value:Number):void
    {
        var oldValue:Number = y;
        if (oldValue == value)
            return;

        if(layoutFeatures != null)
            layoutFeatures.layoutY = value;
        else
            _y = value;
        dispatchPropertyChangeEvent("y", oldValue, value);
        invalidateTransform(false);
    }

    //----------------------------------
    //  z
    //----------------------------------   

    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  The z position of the graphic element.
     */
    public function get z():Number
    {
        return (layoutFeatures == null)? 0:layoutFeatures.layoutZ;
    }

    /**
     *  @private
     */
    public function set z(value:Number):void
    {
        var oldValue:Number = z;
        if (oldValue == value)
            return;
        
        allocateLayoutFeatures();

        layoutFeatures.layoutZ = value;
        dispatchPropertyChangeEvent("z", oldValue, value);
        invalidateTransform();
    }

    //----------------------------------
    //  visible
    //----------------------------------

    /**
     *  @private
     *  Storage for the visible property.
     */
    private var _visible:Boolean = true;
    
    /**
     *  @private
     */
    private var visibleChanged:Boolean;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     */
    public function get visible():Boolean
    {
        return _visible;
    }

    /**
     *  @private
     */
    public function set visible(value:Boolean):void
    {
        if (_visible == value)
            return;

        var oldValue:Boolean = _visible;
        _visible = value;
        dispatchPropertyChangeEvent("visible", oldValue, value);

        visibleChanged = true;

        invalidateProperties();
        
        // TODO: This is a quick fix for MXMLG-228. We should
        // investigate a better solution.
        notifyElementLayerChanged();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties: IDisplayObjectElement
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  displayObject
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the displayObject property.
     */
    private var _displayObject:DisplayObject;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  The DisplayObject where the GraphicElement will be drawn.
     *  This property is automatically assigned by the parent Group of this element.
     */
    public function get displayObject():DisplayObject
    {
        return _displayObject;
    }

    /**
     *  @private
     */
    public function set displayObject(value:DisplayObject):void
    {
        if (_displayObject == value)
            return;

        var oldValue:DisplayObject = _displayObject;

        //esg: matrix3D's are owned by a DO, so we need to reclaim any
        // matrix3D we might have assigned.
        if(oldValue != null)
            oldValue.transform.matrix3D = null;
        
        _displayObject = value;
        dispatchPropertyChangeEvent("displayObject", oldValue, value);

        // We need to apply the display object related properties.
        displayObjectChanged = true;
        invalidateProperties();

        // New display object, we need to redraw
        invalidateDisplayList();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  actualPosition
    //----------------------------------

    /**
     *  The item TBounds top left corner coordinates. 
     */
    public function get actualPosition():Point
    {
        var topLeft:Point = new Point(measuredX, measuredY);

        // Account for transform
        var m:Matrix = computeMatrix(true /*actualMatrix*/);
        if (m)
        {
            // Calculate the vector from pre-transform top-left to
            // post-transform top-left:
            computeTopLeft(topLeft, _width, _height, m);
        }
        else
        {
            topLeft.x += x;
            topLeft.y += y;
        }

        // Take stroke into account:
        // TODO EGeorgie: We assume that the stroke extents are even on both sides.
        // and that's not necessarily true.
        var strokeExtents:Point = getStrokeExtents();
        topLeft.x -= strokeExtents.x * 0.5;
        topLeft.y -= strokeExtents.y * 0.5;

        return topLeft;
    }

    //----------------------------------
    //  actualSize
    //----------------------------------

    /**
     *  The item TBounds size. 
     */
    public function get actualSize():Point
    {
        return transformSizeForLayout(_width, _height, true /*actualMatrix*/);
    }

    //----------------------------------
    //  drawX
    //----------------------------------

    /**
     *  The x position where the element should be drawn.
     */
    protected function get drawX():Number
    {
        // Draw position depends upon which coordinate space we are located in.
        // TODO!!! We need to apply all of the transforms of our ancestors
        if(displayObject != null)
            return 0;
        var result:Number = x;
        if(layoutFeatures != null && layoutFeatures.offsets != null)
            result +=  layoutFeatures.offsets.x;    
        return (sharedDisplayObject && (sharedDisplayObject != parent)) ? 
                    result - sharedDisplayObject.x : 
                    result;
    }
    
    //----------------------------------
    //  drawY
    //----------------------------------

    /**
     *  The y position where the element should be drawn.
     */
    protected function get drawY():Number
    {
        // Draw position depends upon which coordinate space we are located in.
        // TODO!!! We need to apply all of the transforms of our ancestors
        if(displayObject != null)
            return 0;
        var result:Number = y;
        if(layoutFeatures != null && layoutFeatures.offsets != null)
            result +=  layoutFeatures.offsets.y;    
        return sharedDisplayObject && sharedDisplayObject != parent ? result - sharedDisplayObject.y : result;
    }
    
    //----------------------------------
    //  includeInLayout
    //----------------------------------

    /**
     *  @private
     *  Storage for the includeInLayout property.
     */
    private var _includeInLayout:Boolean = true;

    [Bindable("propertyChange")]
    [Inspectable(category="General", defaultValue="true")]

    /**
     *  Specifies whether this element is included in the layout of the group.
     *
     *  @default true
     */
    public function get includeInLayout():Boolean
    {
        return _includeInLayout;
    }
    
    /**
     *  @private
     */
    public function set includeInLayout(value:Boolean):void
    {
        if (_includeInLayout == value)
            return;

        var oldValue:Boolean = _includeInLayout;
        _includeInLayout = value;
        dispatchPropertyChangeEvent("includeInLayout", oldValue, value);
            
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  maxSize
    //----------------------------------

    /**
     *  The TBounds of the maximum item size.
     *  <code>preferredSize</code> &lt;= <code>maxSize</code> must be true.
     */
    public function get maxSize():Point
    {
        return transformSizeForLayout(maxWidth, maxHeight,
                                      false /*actualMatrix*/);
    }

    //----------------------------------
    //  minSize
    //----------------------------------

    /**
     *  The TBounds of the minimum item size.
     *  <code>minSize</code> %lt;= <code>preferredSize</code> must be true.
     */
    public function get minSize():Point
    {
        return transformSizeForLayout(minWidth, minHeight, false /*actualMatrix*/);
    }

    //----------------------------------
    //  preferredSize
    //----------------------------------

    /**
     *  The TBounds of the preferred item size.
     *  The preferred size is usually based on the default
     *  item size and any explicit size overrides.
     */
    public function get preferredSize():Point
    {
        return transformSizeForLayout(preferredWidthPreTransform(),
                                      preferredHeightPreTransform(),
                                      false /*actualMatrix*/);
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Creates a new DisplayObject where the GraphicElement is drawn, 
     *  if one does not already exist.
     */
    public function createDisplayObject():DisplayObject
    {
        if (displayObject)
            return displayObject;
        
        return new Sprite();
    }
    
    
    /**
     *  Destroys the DisplayObject where the GraphicElement is drawn, 
     *  if it exists.
     */
    public function destroyDisplayObject():void
    {
        // TODO!! Figure out what cleanup to do
        if (displayObject)
        {
            if (displayObject.parent)
                displayObject.parent.removeChild(displayObject);
            displayObject = null;
        }
    }
    
    private var _alwaysCreateDisplayObject:Boolean;
    
    // TODO!! Remove once we have a better solution for a design tool to getBitmapData for hit testing
    mx_internal function set alwaysCreateDisplayObject(value:Boolean):void
    {
    	if (value != _alwaysCreateDisplayObject)
    	{
    		_alwaysCreateDisplayObject = value;
    		notifyElementLayerChanged();
    	}
    }
    
    mx_internal function get alwaysCreateDisplayObject():Boolean
    {
    	return _alwaysCreateDisplayObject;
    }
       
















    /**
     *  <code>true</code> if the graphic element needs its own unique display object to render into.
     *  In general, you will not set this property, although if you extend the GraphicElement class, you
     *  might override the setter.
     */
    public function get needsDisplayObject():Boolean
    {
        var result:Boolean;
        result = (alwaysCreateDisplayObject ||
		(_filters && _filters.length > 0) || 
            _blendMode != BlendMode.NORMAL || _mask ||
            (layoutFeatures != null && (layoutFeatures.layoutScaleX != 1 || layoutFeatures.layoutScaleY != 1 || layoutFeatures.layoutScaleZ != 1 ||
            layoutFeatures.layoutRotationX != 0 || layoutFeatures.layoutRotationY != 0 || layoutFeatures.layoutRotationZ != 0 ||
            layoutFeatures.layoutZ  != 0)) ||  
            _colorTransform != null ||
            _alpha != 1 ||
            layer != 0);

        if(layoutFeatures != null && layoutFeatures.offsets != null)
        {
            var o:TransformOffsets = layoutFeatures.offsets;
            result = result || (o.scaleX != 1 || o.scaleY != 1 || o.scaleZ != 1 ||
            o.rotationX != 0 || o.rotationY != 0 || o.rotationZ != 0 || o.z  != 0);  
            
        }
        return result;
    }
    
    /**
     *  
     */
    public function get nextSiblingNeedsDisplayObject():Boolean
    {
        // TODO: The displayObject && visible test is a quick fix for MXMLG-228.
        // Should investigate a better solution.
        return needsDisplayObject || (displayObject && visible == false);
    }
    
    private var _sharedDisplayObject:DisplayObject;
    
    /**
     *  
     */
    public function set sharedDisplayObject(value:DisplayObject):void
    {
        _sharedDisplayObject = value;
    }
    
    /**
     *  @private
     */
    public function get sharedDisplayObject():DisplayObject
    {
        return _sharedDisplayObject;
    }
    
    protected function get drawnDisplayObject():DisplayObject
    {
    	// _drawnDisplayObject is non-null if we needed to create a mask
        return _drawnDisplayObject ? _drawnDisplayObject : 
        							 (displayObject ? displayObject : sharedDisplayObject);
    }

    /**
     *  Returns a bitmap snapshot of the GraphicElement.
     *  The bitmap contains all transformations and is reduced
     *  to fit the visual bounds of the object.
     *  
     *  @param transparent Whether or not the bitmap image supports per-pixel transparency. 
     *  The default value is true (transparent). To create a fully transparent bitmap, set the value of the 
     *  transparent parameter to true and the value of the fillColor parameter to 0x00000000 (or to 0). 
     *  Setting the transparent property to false can result in minor improvements in rendering performance. 
     *  
     *  @param fillColor A 32-bit ARGB color value that you use to fill the bitmap image area. 
     *  The default value is 0xFFFFFFFF (solid white).
     *  
     *  @return A bitmap snapshot of the GraphicElement. 
     *  
     */
    public function getBitmapData(transparent:Boolean = true, fillColor:uint = 0xFFFFFFFF):BitmapData
    {
        // NOTE: This code will not work correctly when we share
        // display objects across multiple graphic elements.
        var bitmapData:BitmapData = new BitmapData(actualSize.x, actualSize.y, transparent, fillColor);

        if (displayObject && nextSiblingNeedsDisplayObject)
        {
            var m:Matrix = displayObject.transform.matrix;
        
            if (m)
                m.translate(-actualPosition.x, -actualPosition.y);
            bitmapData.draw(displayObject, m);
        }
        else
        {
            var oldDisplayObject:DisplayObject = displayObject;
            displayObject = new Sprite();
            invalidateDisplayList();
            validateDisplayList();
            
            bitmapData.draw(displayObject);
            
            displayObject = oldDisplayObject;
                
        }
        return bitmapData;
    }

    /**
     *  Enables clipping or alpha, depending on the type of mask being applied.
     */
    protected function applyMaskType():void
    {
        if (_mask)
        {
            if (_maskType == MaskType.CLIP)
            {
                // Turn off caching on mask
                _mask.cacheAsBitmap = false;
                // Save the original filters and clear the filters property
                //originalMaskFilters = _mask.filters;
                _mask.filters = [];
            }
            else if (_maskType == MaskType.ALPHA)
            {
                _mask.cacheAsBitmap = true;
                //notifyElementLayerChanged(); // Trigger recreation of the layers
                drawnDisplayObject.cacheAsBitmap = true;
            }
        }
    }

    /**
     *  Dispatches a propertyChange event.
     *  
     *  @param prop The property that changed.
     *  
     *  @param oldValue The previous value of the property.
     *  
     *  @param value The new value of the property.
     */
    protected function dispatchPropertyChangeEvent(prop:String, oldValue:*,
                                                   value:*):void
    {
        dispatchEvent(PropertyChangeEvent.createUpdateEvent(
                           this, prop, oldValue, value));

    }

    // TODO EGeorgie: can we use the standart IInvalidating methods instead of
    // notifyElementLayerChanged()?
    
    /**
     *  Utility method that notifies the host that this element has changed and needs
     *  its layer to be updated.
     */
    protected function notifyElementLayerChanged():void
    {
        // TODO EGeorgie: figure this out. For now, invalidateDisplayList
        // to preseve original behavior before layout API unification.
        invalidateDisplayList();
        
        if (parent)
            GroupBase(parent).elementLayerChanged(this);
    }

    /**
     *  Calling this method results in a call to the elements's
     *  <code>validateProperties()</code> method
     *  before the display list is rendered.
     *
     *  <p>Subclasses should do their work in 
     *  <code>commitProperties()</code>.</p>
     */
    public function invalidateProperties():void
    {
        if (invalidatePropertiesFlag)
            return;
        invalidatePropertiesFlag = true;

        // TODO EGeorgie: hook up directly with the layout manager?
        if (parent && parent is IInvalidating)
            IInvalidating(parent).invalidateProperties();
    }

    /**
     *  Calling this method results in a call to the elements's
     *  <code>validateSize()</code> method
     *  before the display list is rendered.
     *
     *  <p>Subclasses should override and do their measurement in
     *  <code>measure()</code>.
     *  By default when <code>explicitWidth</code> and <code>explicitHeight</code>
     *  are set, <code>measure()</code> will not be called. To override this
     *  default behavior subclasses should override <code>skipMeasure()</code>.</p>
     */
    public function invalidateSize():void
    {
        if (invalidateSizeFlag)
            return;
        invalidateSizeFlag = true;

        // TODO EGeorgie: hook up directly with the layout manager?
        if (parent)
            GroupBase(parent).elementSizeChanged(this);
    }

    /**
     *  Helper method to invalidate parent size and display list if
     *  this object affects its layout (includeInLayout is true).
     */
    protected function invalidateParentSizeAndDisplayList():void
    {
        if (!includeInLayout)
            return;

        // We want to invalidate both the parent size and parent display list.
        if (parent && parent is IInvalidating)
        {
            IInvalidating(parent).invalidateSize();
            IInvalidating(parent).invalidateDisplayList();
        }
    }

    /**
     *  Calling this method results in a call to the elements's
     *  <code>validateDisplayList()</code> method
     *  before the display list is rendered.
     *
     *  <p>Subclasses should override and do their work in
     *  <code>updateDisplayList()</code>.</p>
     */
    public function invalidateDisplayList():void
    {
        if (invalidateDisplayListFlag)
            return;
        invalidateDisplayListFlag = true;

        // TODO EGeorgie: make sure elements that share the display object
        // will be invalidated as well.

        // TODO EGeorgie: hook up directly with the layout manager?
        if (parent)
            GroupBase(parent).elementChanged(this);
    }

    /**
     *  Validates and updates the properties and layout of this object
     *  by immediately calling <code>validateProperties()</code>,
     *  <code>validateSize()</code>, and <code>validateDisplayList()</code>,
     *  if necessary.
     */
    public function validateNow():void
    {
        if (parent)
        {
            UIComponentGlobals.layoutManager.validateClient(
                ILayoutManagerClient(parent));
        }
    }

    /**
     *  Used by layout logic to validate the properties of a component
     *  by calling the <code>commitProperties()</code> method.
     *  In general, subclasses should
     *  override the <code>commitProperties()</code> method and not this method.
     */
    public function validateProperties():void
    {
        if (!invalidatePropertiesFlag)
            return;
        commitProperties();
        invalidatePropertiesFlag = false;
        
        // If we aren't doing any more invalidation, send out an UpdateComplete event
        if (!invalidatePropertiesFlag && !invalidateSizeFlag && !invalidateDisplayListFlag)
            dispatchUpdateComplete();        
    }

    /**
     *  Processes the properties set on the element.
     *  This is an advanced method that you might override
     *  when creating a subclass.
     *
     *  <p>You do not call this method directly.
     *  Flex calls the <code>commitProperties()</code> method when you
     *  use the <code>addItem()</code> method to add an element to the group,
     *  or when you call the <code>invalidateProperties()</code> method of the element.
     *  Calls to the <code>commitProperties()</code> method occur before calls to the
     *  <code>measure()</code> method. This lets you set property values that might
     *  be used by the <code>measure()</code> method.</p>
     *
     *  <p>Some elements have properties that
     *  interact with each other.
     *  It is often best at startup time to process all of these
     *  properties at one time to avoid duplicating work.</p>
     */
    protected function commitProperties():void
    {
        //trace("GraphicElement.commitProperties displayObject",displayObject,"this",this);
        var updateTransform:Boolean = false;
        if (displayObject)
        {
            if (alphaChanged)
            {
                alphaChanged = false;
                displayObject.alpha = _alpha;
            }

            if (blendModeChanged)
            {
                blendModeChanged = false;
                displayObject.blendMode = _blendMode;
            }

            if (filtersChanged)
            {
                filtersChanged = false;
                displayObject.filters = _clonedFilters;
            }

            if (maskChanged)
            {
                maskChanged = false;
                
                if (_mask)
                {
                	// If the mask is not parented, then we need to parent it.
                	// Since a mask can not be a child of the maskee, 
                	// we make the mask and maskee siblings. We create a new maskee
                	// called _drawnDisplayObject. Then we attach both the mask 
                	// and maskee to displayObject. 
	                if (!_mask.parent)
	                {
	                	Sprite(displayObject).addChild(_mask);   
	                	var maskComp:UIComponent = _mask as UIComponent;          	
		                if (maskComp)
		                {
		                	if (parent)
		                	{
		                		// Add the mask to the UIComponent document tree. 
		                		// This is required to properly render the mask.
		                		UIComponent(parent).addingChild(maskComp);
		                	}
		                	
		                	// Size the mask so that it actually renders
		                	maskComp.validateProperties();
		                    maskComp.validateSize();
		                    maskComp.setActualSize(maskComp.getExplicitOrMeasuredWidth(), 
		                                           maskComp.getExplicitOrMeasuredHeight());
		                }   
		                
		                if (!_drawnDisplayObject)
						{
							// Create a new target for the drawing commands
							_drawnDisplayObject = new Sprite();
							Sprite(displayObject).addChild(_drawnDisplayObject);
						}    	
	                }
	                
	                drawnDisplayObject.mask = _mask;
                }
            }

            if (maskTypeChanged)
            {
                maskTypeChanged = false;
                applyMaskType();
            }

            if (visibleChanged)
            {
                visibleChanged = false;
                displayObject.visible = _visible;
            }
            
            updateTransform = true;
            displayObjectChanged = false;
        }
        else
        {
            if (visibleChanged)
            {
                visibleChanged = false;
                
                // If we're sharing a display list, we need to force a redraw
                // to change visibility.
                invalidateDisplayList();
            }
        }
        if ((layoutFeatures == null || layoutFeatures.updatePending) ||
            updateTransform)
        {
            applyComputedTransform();
        }
    }

    /**
     *  @inheritDoc
     */
    public function validateSize(recursive:Boolean = false):void
    {
        if (!invalidateSizeFlag)
            return;
        invalidateSizeFlag = false;

        var sizeChanging:Boolean = measureSizes();
                
        if (!sizeChanging || !includeInLayout)
        {
            // If we aren't doing any more invalidation, send out an UpdateComplete event
            if (!invalidatePropertiesFlag && !invalidateSizeFlag && !invalidateDisplayListFlag)
                dispatchUpdateComplete();
            return;
        }

        // Our size has changed, parent has to resize and run layout code
        invalidateParentSizeAndDisplayList();
    }
    
    /**
     *  Determines if the call to the <code>measure()</code> method can be skipped.
     *  
     *  @return Returns <code>true</code> when the <code>measureSizes()</code> method can skip the call to
     *  the <code>measure()</code> method. For example this is usually <code>true</code> when both <code>explicitWidth</code> and
     *  <code>explicitHeight</code> are set. For paths, this is <code>true</code> when the bounds of the path
     *  have not changed.
     */    
    protected function skipMeasure():Boolean
    {
        return !isNaN(explicitWidth) && !isNaN(explicitHeight);
    }

    /**
     *  @private
     */
    private function measureSizes():Boolean
    {
        var oldWidth:Number = preferredWidthPreTransform();
        var oldHeight:Number = preferredHeightPreTransform();
        var oldX:Number = measuredX;
        var oldY:Number = measuredY;

        if (!skipMeasure())
            measure();

        // Did measure() have effect on preferred size? 
        if (oldWidth != preferredWidthPreTransform() ||
            oldHeight != preferredHeightPreTransform() ||
            oldX != measuredX ||
            oldY != measuredY)
        {
            // Preferred size has changed, layout will be affected.
            return true;
        }

        return false;
    }

    /**
     *  Calculates the default size of the element. This is an advanced
     *  method that you might override when creating a subclass of GraphicElement.
     *
     *  <p>You do not call this method directly. Flex calls the
     *  <code>measure()</code> method when the element is added to a group
     *  using the <code>addItem()</code> method, and when the element's
     *  <code>invalidateSize()</code> method is called. </p>
     *
     *  <p>By default you set both explicit height and explicit width of an element,
     *  Flex does not call the <code>measure()</code> method,
     *  even if you explicitly call the <code>invalidateSize()</code> method.
     *  To override this behavior, override <code>skipMeasure()</code> method.</p>
     *
     *  <p>In your override of this method, you must set the
     *  <code>measuredWidth</code> and <code>measuredHeight</code> properties
     *  to define the default size.
     *  You can optionally set the <code>measuredX</code> and
     *  <code>measuredY</code> properties to define the default measured bounds
     *  top-left corner relative to the origin of the element.</p>
     *
     *  <p>The conceptual point of <code>measure()</code> is for the element to
     *  provide its own natural or intrinsic bounds as a default. Therefore, the
     *  <code>measuredWidth</code> and <code>measuredHeight</code> properties
     *  should be determined by factors such as:</p>
     *  <ul>
     *     <li>The amount of text the component needs to display.</li>
     *     <li>The size of a JPEG image that the component displays.</li>
     *  </ul>
     *
     *  <p>In some cases, there is no intrinsic way to determine default values.
     *  For example, a simple GreenCircle element might simply set
     *  measuredWidth = 100 and measuredHeight = 100 in its <code>measure()</code> method to
     *  provide a reasonable default size. In other cases, such as a TextArea,
     *  an appropriate computation (such as finding the right width and height
     *  that would just display all the text and have the aspect ratio of a Golden Rectangle)
     *  might be too time-consuming to be worthwhile.</p>
     *
     *  <p>The default implementation of <code>measure()</code>
     *  sets the values of the <code>measuredWidth</code>, <code>measuredHeight</code>,
     *  <code>measuredX</code>, and <code>measuredY</code> properties
     *  to <code>0</code>.</p>
     */
    protected function measure():void
    {
        measuredWidth = 0;
        measuredHeight = 0;
        measuredX = 0;
        measuredY = 0;
    }

    /**
     *  @inheritDoc
     */
    public function validateDisplayList():void
    {
        // TODO!!! Turn this off for now because we need to clear all of the DisplayObject
        // graphics and thus need to redraw each graphic element
        // Put this back in once we implement drawingAPI2 
        /* if (!invalidateDisplayListFlag)
            return; */
        var wasInvalid:Boolean = invalidateDisplayListFlag; 
        invalidateDisplayListFlag = false;

        // we commit our transform in two places. First, during commit properties, because our size depends on it,
        // and our parent will most likely take it into account during layout. Secondly, here, because our parent will likely
        // change our xform as a result of layout, and we need to commit it before we end up on screen.   
        if (layoutFeatures == null || layoutFeatures.updatePending)
        {
            applyComputedTransform();
        }
        
        if (visible)
            updateDisplayList(_width, _height);
        
        // If we aren't doing any more invalidation, send out an UpdateComplete event
        if (!invalidatePropertiesFlag && !invalidateSizeFlag && !invalidateDisplayListFlag && wasInvalid)
            dispatchUpdateComplete();
    }

    /**
     *  Draws the element and/or sizes and positions its content.
     *  This is an advanced method that you might override
     *  when creating a subclass of GraphicElement.
     *
     *  <p>You do not call this method directly. Flex calls the
     *  <code>updateDisplayList()</code> method when the component is added 
     *  to a group using the <code>addItem()</code> method, and when the element's
     *  <code>invalidateDisplayList()</code> method is called. </p>
     *
     *  <p>This method is where you would do programmatic drawing
     *  using methods on the elements's displayObject
     *  such as <code>graphics.drawRect()</code>.</p>
     *
     *  @param unscaledWidth Specifies the width of the component, in pixels,
     *  in the component's coordinates, regardless of the value of the
     *  <code>scaleX</code> property of the component.
     
     *  @param unscaledHeight Specifies the height of the component, in pixels,
     *  in the component's coordinates, regardless of the value of the
     *  <code>scaleY</code> property of the component.
     */
    protected function updateDisplayList(unscaledWidth:Number,
                                         unscaledHeight:Number):void
    {
    }
    
    /**
     *  @private
     *  Helper function to dispatch the UpdateComplete event 
     */
    private function dispatchUpdateComplete():void
    {
        dispatchEvent(new FlexEvent(FlexEvent.UPDATE_COMPLETE));
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: ILayoutItem
    //
    //--------------------------------------------------------------------------

    /**
     *  A reference to the object in the layout tree represented by this interface.
     */
    public function get target():Object
    {
        return this;
    }

    /**
     *  Gets the transformation matrix.
     *  
     *  @param actualMatrix
     *  
     *  @return Returns the transformation matrix for this element, or null
     *  if it is delta identity.
     */
    protected function computeMatrix(actualMatrix:Boolean):Matrix
    {
        if (!displayObject)
            return null;
                
        if(layoutFeatures == null)
            return null;

        var m:Matrix = layoutFeatures.layoutMatrix;
        return MatrixUtil.isDeltaIdentity(m) ? null : m;
    }

    /**
     *  Transform the element's size.
     *  
     *  @param width The target width.
     *  
     *  @param height The target height.
     *  
     *  @param actualMatrix 
     *  
     *  @return Returns the transformed size. Transformation is this element's
     *  transformation matrix.
     */
    protected function transformSizeForLayout(width:Number, height:Number,
                                              actualMatrix:Boolean):Point
    {
        var size:Point = new Point(width, height);
        var m:Matrix = computeMatrix(actualMatrix);
        if (m)
            size = MatrixUtil.transformSize(size, m);

        // Take stroke into account
        var strokeExtents:Point = getStrokeExtents();
        size.x += strokeExtents.x;
        size.y += strokeExtents.y;
        return size;
    }

    /**
     *  Override for graphic elements that need specific calculation of
     *  coordinates of top-left corner of bounding box when resized to
     *  <code>width</code> and <code>height</code>.
     *  
     *  @param topLeft The origin of the bounds rectangle to be transformed. 
     *  
     *  @param width The target width.
     *  
     *  @param height The target height.
     *  
     *  @param m The transformation matrix.
     *  
     *  @return The top left point of the rectangle after transformation.
     *  
     */
    protected function computeTopLeft(topLeft:Point, width:Number, height:Number, m:Matrix):Point
    {
        MatrixUtil.transformBounds(new Point(_width, _height), m, topLeft);
        return topLeft;
    }

    /**
     *  @private
     */
    private function preferredWidthPreTransform():Number
    {
        return isNaN(explicitWidth) ? measuredWidth : explicitWidth;
    }

    /**
     *  @private
     */
    private function preferredHeightPreTransform():Number
    {
        return isNaN(explicitHeight) ? measuredHeight: explicitHeight;
    }

    /**
     *  Moves the item
     *  such that the left-top corner of the item's TBounds
     *  has the specified coordinates.
     *  
     *  @param x The new x position of the GraphicElement.
     *  
     *  @param y The new y position of the GraphicElement.
     */
    public function setActualPosition(x:Number, y:Number):void
    {

        var currentX:Number = this.x;
        var currentY:Number = this.y;

        // Take stroke into account:
        // TODO EGeorgie: We assume that the stroke extents are even on both sides.
        // and that's not necessarily true.
        var strokeExtents:Point = getStrokeExtents();
        x += strokeExtents.x * 0.5;
        y += strokeExtents.y * 0.5;

        // Handle arbitrary 2d transform
        var m:Matrix = computeMatrix(true /*actualMatrix*/);
        if (m)
        {
            // Calculate the origin of the element after transformation before our changes are applied.
            var topLeft:Point = computeTopLeft(new Point(measuredX, measuredY), _width, _height, m);

            // now adjust our tx/ty values based on the difference between our current transformed position and 
            // where we want to end up.
            x = x - topLeft.x + currentX;
            y = y - topLeft.y + currentY;
        }
        else
        {
            x -= measuredX;
            y -= measuredY;
        }


        if(x != currentX || y != currentY)
        {
            if(layoutFeatures != null)
            {
                layoutFeatures.layoutX = x;
                layoutFeatures.layoutY = y;           

                // note that we don't want to call invalidateTransform, because 
                // this is in the middle of an update pass. Instead, we just note that the 
                // transform has an update pending, so we can apply it later.
                layoutFeatures.updatePending = true;
            }
            else
            {
                _x = x;
                _y = y;
            }
            invalidateDisplayList();
        }
    }

    /**
     *  Modifies the item size/transform
     *  so that its TBounds have the specified <code>width</code>
     *  and <code>height</code>.
     *
     *  <p>If one of the desired TBounds dimensions is left unspecified, its size
     *  is set such that item can be optimally sized to fit the other
     *  TBounds dimension. This is useful when the layout does not
     *  overconstrain the item in cases where the item TBounds width and height
     *  are dependent (such as with text or with components that have complex transforms).</p>
     *
     *  <p>If both TBounds dimensions are left unspecified, the item's preferred size is set.</p>
     *
     *  <p>The <code>setActualSize()</code> method does not clip against the <code>minSize</code> and
     *  <code>maxSize</code> properties.</p>
     *
     *  <p>The <code>setActualSize</code> method must preserve the item's TBounds position,
     *  which means that in some cases it will move the item in addition to
     *  changing its size.</p>
     *
     *  @param width The target width.
     *  
     *  @param height The target height.
     *  
     *  @return The TBounds of the new item size.
     */
    public function setActualSize(width:Number = Number.NaN,
                                  height:Number = Number.NaN):Point
    {
        var strokeExtents:Point = getStrokeExtents();

        // Calculate the width and height pre-transform:
        var m:Matrix = computeMatrix(true /*actualMatrix*/);
        if (!m)
        {
            if (isNaN(width))
                width = preferredSize.x;
            if (isNaN(height))
                height = preferredSize.y;

            // Account for stroke
            width -= strokeExtents.x;
            height -= strokeExtents.y;
        }
        else
        {
            if (!isNaN(width))
               width -= strokeExtents.x;

            if (!isNaN(height))
               height -= strokeExtents.y;

            var newSize:Point = MatrixUtil.fitBounds(width, height, m,
                                                     preferredWidthPreTransform(),
                                                     preferredHeightPreTransform(),
                                                     minWidth, minHeight,
                                                     maxWidth, maxHeight);

            if (newSize)
            {
                width = newSize.x;
                height = newSize.y;
            }
            else
            {
                width = minWidth;
                height = minHeight;
            }
        }

        if (_width != width || _height != height)
        {
            var oldWidth:Number = _width;
            var oldHeight:Number = _height;
            
            _width = width;
            _height = height;
            
            dispatchPropertyChangeEvent("width", oldWidth, width);
            dispatchPropertyChangeEvent("height", oldHeight, height);

            invalidateDisplayList();
        }

        return actualSize;
    }

    /**
     *  Applies the transform to the DisplayObject.
     */
    protected function applyComputedTransform():void
    {       
        if(layoutFeatures != null)
	        layoutFeatures.updatePending = false;

        if(displayObject == null)
            return;
			                    
                                
        if(layoutFeatures != null)
        {
	        if(layoutFeatures.is3D)
	        {
	            displayObject.transform.matrix3D = layoutFeatures.computedMatrix3D;             
	        }
	        else
	        {
	            displayObject.transform.matrix = layoutFeatures.computedMatrix;
	        }
        }
        else
        {
            displayObject.x = _x;
            displayObject.y = _y;
        }
        
        if (_colorTransform)
        {
            displayObject.transform.colorTransform = _colorTransform;
        }
    }
    
    /**
     *  @private
     */
    protected function getStroke():IStroke
    {
        return null;
    }

    // TODO EGeorgie: return rectangle instead so that the function can
    // correctly indicate the left, right, top and bottom extents. Right
    // now we assume they are the same on both sides.
    protected function getStrokeExtents():Point
    {
        // TODO EGeorgie: currently we take only scale into account,
        // but depending on joint style, cap style, etc. we need to take
        // the whole matrix into account as well as examine every line segment...
        var stroke:IStroke = getStroke();
        if (!stroke)
           return new Point();

        // Stroke with weight 0 or scaleMode "none" is always drawn
        // at "hairline" thickness, which is exactly one pixel.
        var weight:Number = stroke.weight;
        if (weight == 0)
            return new Point(1, 1);
        var scaleMode:String = stroke.scaleMode;
        if (!scaleMode || scaleMode == LineScaleMode.NONE)
            return new Point(weight, weight);

        var sX:Number = scaleX;
        var sY:Number = scaleY;

        // TODO EGeorgie: stroke thickness depends on all matrix components,
        // not only on scale.
        if (scaleMode == LineScaleMode.NORMAL)
        {
            if (sX  == sY)
                weight *= sX;
            else
                weight *= Math.sqrt(0.5 * (sX * sX + sY * sY));
            
            return new Point(weight, weight);
        }
        else if (scaleMode == LineScaleMode.HORIZONTAL)
        {
            return new Point(weight * sX, weight);
        }
        else if (scaleMode == LineScaleMode.VERTICAL)
        {
            return new Point(weight, weight * sY);
        }

        return null;
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  Called when a bitmap filter associated with the element is modified.
     *  
     *  @param event The event that is dispatched when the filter was changed.
     */
    protected function filterChangedHandler(event:Event):void
    {
        filters = _filters;
    }

    /**
     *  Called when one of the properties of the transform changes.
     *  
     *  @param event The event that is dispatched when the property changed.
     */
    protected function transformPropertyChangeHandler(
                                    event:PropertyChangeEvent):void
    {
        if (event.kind == PropertyChangeEventKind.UPDATE)
        {
            if (event.property == "matrix")
            {
                // Apply matrix
                if (_transform)
                {
                    allocateLayoutFeatures();

                    layoutFeatures.layoutMatrix = _transform.matrix.clone();
                    invalidateTransform();
                }
            }
            else if (event.property == "colorTransform")
            {
                // Apply colorTranform
                if (_transform)
                {
                    _colorTransform = _transform.colorTransform;
                    
                    if (displayObject)
                    {
                        displayObject.transform.colorTransform = _colorTransform;
                    }
                    else
                    {
                        invalidateDisplayList();
                        notifyElementLayerChanged();
                    }
                }
            }
        }
    }
}

}

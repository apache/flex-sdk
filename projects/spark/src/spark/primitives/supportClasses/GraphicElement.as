package flex.graphics.graphicsClasses
{
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Transform;

import flex.filters.BaseFilter;
import flex.filters.IBitmapFilter;
import flex.geom.Transform;
import flex.graphics.IDisplayObjectElement;
import flex.graphics.IGraphicElement;
import flex.graphics.IGraphicElementHost;
import flex.graphics.MaskType;
import flex.graphics.TransformUtil;
import flex.intf.ILayoutItem;

import mx.core.IConstraintClient;
import mx.core.mx_internal;
import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;
import mx.graphics.IStroke;

use namespace mx_internal;

public class GraphicElement extends EventDispatcher 
							implements IGraphicElement, ILayoutItem, IConstraintClient, IDisplayObjectElement
{
	
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
    
	
	public function GraphicElement()
	{
	}
	
	private var sizeChanged:Boolean = false;
		
	protected var drawWidth:Number = 0;
	protected var drawHeight:Number = 0;
	
	
	//--------------------------------------------------------------------------
	//
	//  IGraphicElement properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  alpha
	//----------------------------------
	private var _alpha:Number = 1;
	private var alphaChanged:Boolean = false;

	[Bindable("propertyChange")]
	[Inspectable(category="General")]

	public function get alpha():Number
	{
		return _alpha;
	}
	
	public function set alpha(value:Number):void
	{
		if (value != _alpha)
		{
			var oldValue:Number = _alpha;
			_alpha = value;
			dispatchPropertyChangeEvent("alpha", oldValue, value);
			
			alphaChanged = true;
			notifyElementLayerChanged();
		}
	}
	
	//----------------------------------
	//  blendMode
	//----------------------------------
	private var _blendMode:String = BlendMode.NORMAL;
	private var blendModeChanged:Boolean;

	[Bindable("propertyChange")]
	[Inspectable(category="General")]

	public function get blendMode():String
	{
		return _blendMode;
	}
	
	public function set blendMode(value:String):void
	{
		if (value != _blendMode)
		{
			var oldValue:String = _blendMode;
			_blendMode = value;
			dispatchPropertyChangeEvent("blendMode", oldValue, value);
			
			blendModeChanged = true;
			notifyElementLayerChanged();
		}
	}
	
	//----------------------------------
	//  baseline
	//----------------------------------
	private var _baseline:Number;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	public function get baseline():Number
	{
		return _baseline;
	}
	
	public function set baseline(value:Number):void
	{
		if (_baseline != value)
		{
			var oldValue:Number = _baseline;
			_baseline = value;
			dispatchPropertyChangeEvent("baseline", oldValue, value);
			
			sizeChanged = true;
			notifyElementChanged();
		}
	}
	
	//----------------------------------
	//  bottom
	//----------------------------------
	private var _bottom:Number;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	public function get bottom():Number
	{
		return _bottom;
	}
	
	public function set bottom(value:Number):void
	{
		if (_bottom != value)
		{
			var oldValue:Number = _bottom;
			_bottom = value;
			dispatchPropertyChangeEvent("bottom", oldValue, value);
			
			sizeChanged = true;
			notifyElementChanged();
		}
	}
	
	//----------------------------------
	//  bounds
	//----------------------------------
    /**
     *  @inheritDoc
     */
	public function get bounds():Rectangle
	{
		return new Rectangle();
	}
	
	//----------------------------------
	//  elementHost
	//----------------------------------
	protected var _host:IGraphicElementHost;
	
	/**
	 *  @private
	 *  The host of this element. This is the Group or Graphic tag that contains
	 *  this element.
	 */
	public function set elementHost(value:IGraphicElementHost):void
	{
		if (_host !== value)
		{
			_host = value;
			/* if (_mask)
				_host.addMaskElement(_mask); */
		}
	}
	
	public function get elementHost():IGraphicElementHost 
	{
		return _host;
	}
	
	//----------------------------------
	//  filters
	//----------------------------------
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	
	private var _filters:Array = [];
	private var _clonedFilters:Array;
	private var filtersChanged:Boolean;
	
	/**
	 *  @private
	 */
	public function set filters(value:Array):void
	{
		var i:int = 0;
		var oldFilters:Array = _filters ? _filters.slice() : null;
		var len:int = oldFilters ? oldFilters.length : 0;
		var edFilter:EventDispatcher;
		
		for (i = 0; i < len; i++)
		{
			if (oldFilters[i] is IBitmapFilter)
			{
				edFilter = value[i] as EventDispatcher;
				if (edFilter)
					edFilter.removeEventListener(BaseFilter.FILTER_CHANGED_TYPE, filterChangedHandler);
			}
		}
				
		_clonedFilters = new Array();
		_filters = value;
		len = value.length;
		
		for (i = 0; i < len; i++)
		{
			if (value[i] is IBitmapFilter)
			{
				edFilter = value[i] as EventDispatcher;
				if (edFilter)
					edFilter.addEventListener(BaseFilter.FILTER_CHANGED_TYPE, filterChangedHandler);
				_clonedFilters.push(IBitmapFilter(value[i]).clone());
			}
			else
				_clonedFilters.push(value[i]);
		}
		
		dispatchPropertyChangeEvent("filters", oldFilters, _filters);
		
		filtersChanged = true;
		notifyElementLayerChanged();
	}
	
	public function get filters():Array
	{
		return _filters;
	}
	
	//----------------------------------
	//  height
	//----------------------------------

	private var _height:Number = 0;
	protected var _explicitHeight:Number;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	
	/**
	 *  The height of the rect.
	 * 
	 *  @default 0
	 */
	public function get height():Number 
	{
		return _height;
	}
	
	public function set height(value:Number):void
	{
		_explicitHeight = value;
		var oldValue:Number = _height;
		
		if (value != oldValue)
		{
			_height = value;
			drawHeight = value;
			dispatchPropertyChangeEvent("height", oldValue, value);	
			notifyElementChanged();		
		}
	}
	
	//----------------------------------
	//  horizontalCenter
	//----------------------------------
	private var _horizontalCenter:Number;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	public function get horizontalCenter():Number
	{
		return _horizontalCenter;
	}
	
	public function set horizontalCenter(value:Number):void
	{
		if (_horizontalCenter != value)
		{
			var oldValue:Number = _horizontalCenter;
			_horizontalCenter = value;
			dispatchPropertyChangeEvent("horizontalCenter", oldValue, value);
			
			sizeChanged = true;
			notifyElementChanged();
		}
	}
	
	//----------------------------------
	//  left
	//----------------------------------
	private var _left:Number;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	public function get left():Number
	{
		return _left;
	}
	
	public function set left(value:Number):void
	{
		if (_left != value)
		{
			var oldValue:Number = _left;
			_left = value;
			dispatchPropertyChangeEvent("left", oldValue, value);
			
			sizeChanged = true;
			notifyElementChanged();
		}
	}
	
	//----------------------------------
	//  mask
	//----------------------------------
	
	private var _mask:DisplayObject;
	private var previousMask:DisplayObject;
	private var isMaskInElementSpace:Boolean;
	private var maskChanged:Boolean;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	
	public function set mask(value:DisplayObject):void
	{
		if (_mask !== value)
		{
			var oldValue:DisplayObject = _mask;
			previousMask = _mask;
			_mask = value;
			dispatchPropertyChangeEvent("mask", oldValue, value);
			maskChanged = true;
			maskTypeChanged = true;
			isMaskInElementSpace = false;
			notifyElementLayerChanged();
		}
	}
	
	public function get mask():DisplayObject
	{
		return _mask;
	}
	
	//----------------------------------
	//  maskType
	//----------------------------------
	private var _maskType:String = MaskType.CLIP;
	private var maskTypeChanged:Boolean;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General",enumeration="clip,alpha", defaultValue="clip")]
	public function get maskType():String
	{
		return _maskType;
	}
	
	public function set maskType(value:String):void
	{
		if (_maskType != value)
		{
			var oldValue:String = _maskType;
			_maskType = value;
			dispatchPropertyChangeEvent("maskType", oldValue, value);
			
			maskTypeChanged = true;
			notifyElementChanged();
		}
	}
	
	//----------------------------------
	//  maxHeight
	//----------------------------------
	private var _maxHeight:Number;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	public function get maxHeight():Number
	{
		// TODO!!! Examine this logic, Make this arbitrarily large (use UIComponent max)
		return !isNaN(_maxHeight) ? _maxHeight : DEFAULT_MAX_HEIGHT; 
	}
	
	public function set maxHeight(value:Number):void
	{
		if (_maxHeight != value)
		{
			var oldValue:Number = _maxHeight;
			_maxHeight = value;
			dispatchPropertyChangeEvent("maxHeight", oldValue, value);
			
			sizeChanged = true;
			notifyElementChanged();
		}
	}

	//----------------------------------
	//  maxWidth
	//----------------------------------
	private var _maxWidth:Number;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	public function get maxWidth():Number
	{
		// TODO!!! Examine this logic, Make this arbitrarily large (use UIComponent max)
		return !isNaN(_maxWidth) ? _maxWidth : DEFAULT_MAX_WIDTH; 
	}
	
	public function set maxWidth(value:Number):void
	{
		if (_maxWidth != value)
		{
			var oldValue:Number = _maxWidth;
			_maxWidth = value;
			dispatchPropertyChangeEvent("maxWidth", oldValue, value);
			
			sizeChanged = true;
			notifyElementChanged();
		}
	}
	
	//----------------------------------
	//  minHeight
	//----------------------------------
	private var _minHeight:Number;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	public function get minHeight():Number
	{
		// TODO!!! Examine this logic
		return !isNaN(_minHeight) ? _minHeight : DEFAULT_MIN_HEIGHT; 
	}
	
	public function set minHeight(value:Number):void
	{
		if (_minHeight != value)
		{
			var oldValue:Number = _minHeight;
			_minHeight = value;
			dispatchPropertyChangeEvent("minHeight", oldValue, value);
			
			sizeChanged = true;
			notifyElementChanged();
		}
	}	
	
	//----------------------------------
	//  minWidth
	//----------------------------------
	private var _minWidth:Number;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	public function get minWidth():Number
	{
		// TODO!!! Examine this logic
		return !isNaN(_minWidth) ? _minWidth : DEFAULT_MIN_WIDTH; 
	}
	
	public function set minWidth(value:Number):void
	{
		if (_minWidth != value)
		{
			var oldValue:Number = _minWidth;
			_minWidth = value;
			dispatchPropertyChangeEvent("minWidth", oldValue, value);
			
			sizeChanged = true;
			notifyElementChanged();
		}
	}
	
	//----------------------------------
	//  percentHeight
	//----------------------------------
	private var _percentHeight:Number;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	public function get percentHeight():Number
	{
		// TODO!!! Examine this logic
		return _percentHeight; 
	}
	
	public function set percentHeight(value:Number):void
	{
		if (_percentHeight != value)
		{
			var oldValue:Number = _percentHeight;
			_percentHeight = value;
			dispatchPropertyChangeEvent("percentHeight", oldValue, value);
			
			sizeChanged = true;
			notifyElementChanged();
		}
	}
	
	//----------------------------------
	//  percentWidth
	//----------------------------------
	private var _percentWidth:Number;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	public function get percentWidth():Number
	{
		// TODO!!! Examine this logic
		return _percentWidth; 
	}
	
	public function set percentWidth(value:Number):void
	{
		if (_percentWidth != value)
		{
			var oldValue:Number = _percentWidth;
			_percentWidth = value;
			dispatchPropertyChangeEvent("percentWidth", oldValue, value);
			
			sizeChanged = true;
			notifyElementChanged();	
		}
	}

	//----------------------------------
	//  right
	//----------------------------------
	private var _right:Number;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	public function get right():Number
	{
		return _right;
	}
	
	public function set right(value:Number):void
	{
		if (_right != value)
		{
			var oldValue:Number = _right;
			_right = value;
			dispatchPropertyChangeEvent("right", oldValue, value);
			
			sizeChanged = true;
			notifyElementChanged();
		}
	}
	
	//----------------------------------
	//  rotation
	//----------------------------------
	
	private var _rotation:Number = 0;
	private var rotationChanged:Boolean;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	/**
	 *  Indicates the rotation of the element, in degrees, from the transform point.
	 */
	public function get rotation():Number
	{
		return _rotation;
	}
	
	public function set rotation(value:Number):void
	{
		if (_rotation != value)
		{
			var oldValue:Number = _rotation;			
			_rotation = value;
			dispatchPropertyChangeEvent("rotation", oldValue, value);
			
			rotationChanged = true;
			notifyElementTransformChanged();
		}
	}
	
	//----------------------------------
	//  scaleX
	//----------------------------------
	
	mx_internal var _scaleX:Number = 1;
	private var scaleXChanged:Boolean;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	
	/**
	 *  Indicates the horizontal scale (percentage) of the element as applied from the transform point.
	 */
	public function get scaleX():Number
	{
		return _scaleX;
	}
	
	public function set scaleX(value:Number):void
	{
		if (_scaleX != value)
		{
			var oldValue:Number = _scaleX;
			_scaleX = value;
			dispatchPropertyChangeEvent("scaleX", oldValue, value);
			
			scaleXChanged = true;			
			notifyElementTransformChanged();
		}
	}
	
	//----------------------------------
	//  scaleY
	//----------------------------------
	mx_internal var _scaleY:Number = 1;
	private var scaleYChanged:Boolean;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	
	/**
	 *  Indicates the vertical scale (percentage) of the element as applied from the transform point.
	 */
	public function get scaleY():Number
	{
		return _scaleY;
	}
	
	public function set scaleY(value:Number):void
	{
		if (_scaleY != value)
		{
			var oldValue:Number = _scaleY;
			_scaleY = value;
			dispatchPropertyChangeEvent("scaleY", oldValue, value);
			
			scaleYChanged = true;
			notifyElementTransformChanged();
		}
	}

	//----------------------------------
	//  top
	//----------------------------------
	private var _top:Number;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	public function get top():Number
	{
		return _top;
	}
	
	public function set top(value:Number):void
	{
		if (_top != value)
		{
			var oldValue:Number = _top;
			_top = value;
			dispatchPropertyChangeEvent("top", oldValue, value);
			
			sizeChanged = true;
			notifyElementChanged();
		}
	}
	
	//----------------------------------
	//  transform
	//----------------------------------
	private var _matrix:Matrix;
	private var _colorTransform:ColorTransform;
	private var _transform:flash.geom.Transform;
		
	/**
	 *  The x position transform point of the element. 
	 */
	public function get transform():flash.geom.Transform
	{
		return _transform;
	}
	
	public function set transform(value:flash.geom.Transform):void
	{
		// Clean up the old event listeners
		var oldTransform:flex.geom.Transform = _transform as flex.geom.Transform;		
		if (oldTransform)
		{
			oldTransform.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, transformPropertyChangeHandler);
		}
		
		var newTransform:flex.geom.Transform = value as flex.geom.Transform;
		
		if (newTransform)
		{	
			newTransform.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, transformPropertyChangeHandler);
			_matrix = value.matrix.clone(); // Make sure it is a copy
			clearTransformProperties();
			_colorTransform = value.colorTransform; 
		}
	
		_transform = value;	
		notifyElementTransformChanged();
	} 
	
	//----------------------------------
	//  transformX
	//----------------------------------
	private var _transformX:Number = 0;
	private var transformXChanged:Boolean;
		
	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
		
	/**
	 *  The x position transform point of the element. 
	 */
	public function get transformX():Number
	{
		return _transformX;
	}
	
	public function set transformX(value:Number):void
	{
		if (_transformX != value)
		{
			var oldValue:Number = _transformX;	
			_transformX = value;
			dispatchPropertyChangeEvent("transformX", oldValue, value);
			
			transformXChanged = true;
			notifyElementTransformChanged();
		}
	}
	
	//----------------------------------
	//  transformY
	//----------------------------------
	private var _transformY:Number = 0;
	private var transformYChanged:Boolean;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	
	/**
	 *  The y position transform point of the element. 
	 */
	public function get transformY():Number
	{
		return _transformY;
	}
	
	public function set transformY(value:Number):void
	{
		if (_transformY != value)
		{
			var oldValue:Number = _transformY;
			_transformY = value;
			dispatchPropertyChangeEvent("transformY", oldValue, value);
			
			transformYChanged = true;
			notifyElementTransformChanged();
		}
	}
	
	
	//----------------------------------
	//  verticalCenter
	//----------------------------------
	private var _verticalCenter:Number;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	public function get verticalCenter():Number
	{
		return _verticalCenter;
	}
	
	public function set verticalCenter(value:Number):void
	{
		if (_verticalCenter != value)
		{
			var oldValue:Number = _verticalCenter;
			_verticalCenter = value;
			dispatchPropertyChangeEvent("verticalCenter", oldValue, value);
			
			sizeChanged = true;
			notifyElementChanged();
		}
	}
	
	//----------------------------------
	//  width
	//----------------------------------

	private var _width:Number = 0;
	protected var _explicitWidth:Number;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	
	/**
	 *  The width of the Graphic Element.
	 * 
	 *  @default 0
	 */
	public function get width():Number 
	{
		return _width;
	}
	
	public function set width(value:Number):void
	{
	    _explicitWidth = value;
		var oldValue:Number = _width;
		
		if (value != oldValue)
		{
			_width = value;
			drawWidth = value;
			dispatchPropertyChangeEvent("width", oldValue, value);	
			notifyElementChanged();			
		}
	}
	
	//----------------------------------
	//  x
	//----------------------------------
	// TODO!!! Change to NaN and integrate Rect/Ellipse bounds/draw functions
	private var _x:Number = 0;
	private var xChanged:Boolean;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	/**
	 *  The x position of the element
	 */
	public function get x():Number
	{
		return _x;
	}
	
	public function set x(value:Number):void
	{
		
		if (value != _x)
		{
			var oldValue:Number = _x;
			_x = value;
			dispatchPropertyChangeEvent("x", oldValue, value);	
			
			xChanged = true;	
			notifyElementChanged();	
		}	
	}
	
	//----------------------------------
	//  y
	//----------------------------------
	// TODO!!! Change to NaN and integrate Rect/Ellipse bounds/draw functions
	private var _y:Number = 0;
	private var yChanged:Boolean;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	/**
	 *  The y position of the element
	 */
	public function get y():Number
	{
		return _y;
	}
	
	public function set y(value:Number):void
	{
		
		if (value != _y)
		{
			var oldValue:Number = _y;
			_y = value;
			dispatchPropertyChangeEvent("y", oldValue, value);	
			
			yChanged = true;	
			notifyElementChanged();		
		}	
	}
	
	//----------------------------------
	//  visible
	//----------------------------------

	private var _visible:Boolean = true;
	private var visibleChanged:Boolean;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]

	/**
	 *  The visible flag for this element.
	 */
	public function set visible(value:Boolean):void
	{
		if (value != _visible)
		{
			var oldValue:Boolean = _visible;
			_visible = value;
			dispatchPropertyChangeEvent("visible", oldValue, value);
			
			visibleChanged = true;
			notifyElementChanged();			
		}
	}
	
	public function get visible():Boolean 
	{
		return _visible;
	}
	
	
	//--------------------------------------------------------------------------
	//
	//  IDisplayObjectElement properties
	//
	//--------------------------------------------------------------------------
	
	
	//----------------------------------
	//  displayObject
	//----------------------------------
	private var _displayObject:DisplayObject;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	
	public function get displayObject():DisplayObject
	{
		return _displayObject;
	}
	
	// TODO!!! Figure out what happens when DO is set.
	public function set displayObject(value:DisplayObject):void
	{
		if (value != _displayObject)
		{
			var oldValue:DisplayObject = _displayObject;
			_displayObject = value;
			//applyTransforms();
			/* TransformUtil.applyTransforms(value, _matrix, _x, _y, _scaleX, _scaleY, 
				_rotation, _transformX, _transformY); */
			dispatchPropertyChangeEvent("displayObject", oldValue, value);	
				
		}
	}
	
	public function createDisplayObject():DisplayObject
	{
		if (displayObject)
			return displayObject;
		else
			return new Sprite();
	}
	
	public function needsDisplayObject():Boolean
	{
		return true;
	}
	
	
	public function draw(g:Graphics):void
	{
	}
	
	public function applyMask():void
	{
		if (displayObject && _mask)
		{
			displayObject.mask = _mask;
			if (!isMaskInElementSpace)
        	{
        		var maskMatrix:Matrix = _mask.transform.matrix;
        		maskMatrix.concat(displayObject.transform.matrix);
        		_mask.transform.matrix = maskMatrix;
        		isMaskInElementSpace = true;
        	}
		}
	}
		
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	protected function applyDisplayObjectProperties():void
	{
		if (displayObject)
		{
			if (alphaChanged)
			{
				alphaChanged = false;
				displayObject.alpha = _alpha;
			}
			
			
			if (blendModeChanged)
			{
				blendModeChanged = true;
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
				if (elementHost)
				{
					if (previousMask)
					{
						elementHost.removeMaskElement(previousMask, this);
						if (displayObject)
							displayObject.mask = null;
					}
					if (_mask)
						elementHost.addMaskElement(_mask, this); 
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
		}
	}
	
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
				displayObject.cacheAsBitmap = true;
			}
		}
	}
	
	protected function clearTransformProperties():void
	{
		scaleXChanged = false;
		scaleYChanged = false;
		xChanged = false;
		yChanged = false;
		rotationChanged = false; 
	}
	
	/** 
	 *  Dispatch a propertyChange event.
	 */
	protected function dispatchPropertyChangeEvent(prop:String, oldValue:*, value:*):void
	{
		dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, prop, oldValue, value));

	}
	
	/**
	 *  Utility method that notifies our host that we have changed and need
	 *  to be updated.
	 */
	protected function notifyElementChanged():void
	{
		if (elementHost)
			elementHost.elementChanged(this);
	}
	
	/**
	 *  Utility method that notifies our host that we have changed and need
	 *  our layer to be updated.
	 */
	protected function notifyElementLayerChanged():void
	{
		if (elementHost)
			elementHost.elementLayerChanged(this);
	}
	
	protected function notifyElementTransformChanged():void
	{
		notifyElementLayerChanged();
	}
	
	//--------------------------------------------------------------------------
	//
	//  EventHandlers
	//
	//--------------------------------------------------------------------------
	
	protected function filterChangedHandler(event:Event):void
	{
		filters = _filters;
	}
	
	protected function transformPropertyChangeHandler(event:PropertyChangeEvent):void
	{
		if (event.kind == PropertyChangeEventKind.UPDATE)
		{			
			if (event.property == "matrix")
			{
				// Apply matrix
				if (_transform)
				{
					_matrix = _transform.matrix.clone();
					clearTransformProperties();
					notifyElementTransformChanged();
				} 
			}
			else if (event.property == "colorTransform")
			{
				// Apply colorTranform
				if (_transform)
				{
					_colorTransform = _transform.colorTransform;
					notifyElementTransformChanged();
				}
			}
		}
	}
	
	//--------------------------------------------------------------------------
    //
    //  ILayoutItem
    //
    //--------------------------------------------------------------------------

    /**
     *  @return Returns the transformation matrix for this element, or null
     *  if it is detla identity.
     */    
    protected function computeMatrix(actualMatrix:Boolean):Matrix
    {
    	if (_matrix)
            return TransformUtil.isDeltaIdentity(_matrix) ? null : _matrix;

        if (_scaleX == 1 && _scaleY == 1 && _rotation == 0)
            return null;

        // TODO EGeorgie: share the duplicated code with the TransformUtil.applyTransforms?
        var m:Matrix = new Matrix();        
        m.translate(-_transformX, -_transformY);
        m.scale(_scaleX, _scaleY); 
        m.rotate(TransformUtil.rotationInRadians(_rotation));
        m.translate(_transformX, _transformY);
        return m;
    }
    
    /**
     *  @return Returns the transformed size. Transformation is this element's
     *  transformation matrix.
     */
    private function transformSizeForLayout(width:Number, height:Number, actualMatrix:Boolean):Point
    {
        var size:Point = new Point(width, height);
        var m:Matrix = computeMatrix(actualMatrix);
        if (m)
            size = TransformUtil.transformBounds(size, m);

        // Take stroke into account
        var strokeExtents:Point = getStrokeExtents();
        size.x += strokeExtents.x;
        size.y += strokeExtents.y;
        return size;
    }

    /**
     *  Indicates whether to layout should ignore this item or not.
     */ 
    public function get includeInLayout():Boolean
    {
        return true;
    }

    /**
     *  @return Returns TBounds of the preferred
     *  item size. The preferred size is usually based on the default
     *  item size and any explicit size overrides.
     */
    public function get preferredSize():Point
    {
    	return transformSizeForLayout(bounds.width, bounds.height, false /*actualMatrix*/);
    }

    /**
     *  @return Returns TBounds of the minimum item size.
     *  <code>minSize</code> <= <code>preferredSize</code> must be true.
     */
    public function get minSize():Point
    {
    	return transformSizeForLayout(minWidth, minHeight, false /*actualMatrix*/);
    }

    /**
     *  @return Returns TBounds of the maximum item size.
     *  <code>preferredSize</code> <= <code>maxSize</code> must be true.
     */
    public function get maxSize():Point
    {
        return transformSizeForLayout(maxWidth, maxHeight, false /*actualMatrix*/);
    }
        
    /**
     *  @return Returns the desired item TBounds size
     *  as a percentage of parent UBounds. Could be NaN.
     */
    public function get percentSize():Point
    {
        return new Point(percentWidth, percentHeight);
    } 

    /**
     *  @return Returns the item TBounds size.
     */ 
    public function get actualSize():Point
    {
    	return transformSizeForLayout(drawWidth, drawHeight, true /*actualMatrix*/);
    }

    /**
     *  @return Returns the item TBounds top left corner coordinates.
     */
    public function get actualPosition():Point
    {
    	var xPos:Number = bounds.left + (_matrix ? _matrix.tx : _x);
    	var yPos:Number = bounds.top + (_matrix ? _matrix.ty : _y);
        var vec:Point = new Point(xPos, yPos);

        // Account for transform
    	var m:Matrix = computeMatrix(true /*actualMatrix*/);
    	if (m)
    	{
	        // Calculate the vector from pre-transform top-left to
	        // post-transform top-left:
	    	TransformUtil.transformBounds(new Point(drawWidth, drawHeight), m, vec);
	    	
	    	// Subtract it from (xPos, yPos):
	    	vec.x = xPos - vec.x;
	    	vec.y = yPos - vec.y;
    	}

        // Take stroke into account:
        // TODO EGeorgie: We assume that the stroke extents are even on both sides.
        // and that's not necessarily true.
        var strokeExtents:Point = getStrokeExtents();
        vec.x -= strokeExtents.x * 0.5;
        vec.y -= strokeExtents.y * 0.5;

    	return vec;
    }

    /**
     *  <code>setActualPosition</code> moves the item such that the item TBounds
     *  top left corner has the specified coordinates.
     */  
    public function setActualPosition(x:Number, y:Number):void
    {
        x -= bounds.left;
        y -= bounds.top;

        // Handle arbitrary 2d transform
        var m:Matrix = computeMatrix(true /*actualMatrix*/);
        if (m)
        {
        	// Calculate the vector from pre-transform top-left to
        	// post-transform top-left:
	        var vec:Point = new Point();       
	        TransformUtil.transformBounds(new Point(drawWidth, drawHeight), m, vec);

            // Add it to (x,y):
	        x += vec.x;
	        y += vec.y;
        }
        
        // Take stroke into account:
        // TODO EGeorgie: We assume that the stroke extents are even on both sides.
        // and that's not necessarily true.
        var strokeExtents:Point = getStrokeExtents();
        x += strokeExtents.x * 0.5;
        y += strokeExtents.y * 0.5;

        // Finally commit x & y property changes:
        _x = x;
        _y = y;
        commitXY();
    }

    /**
     *  <code>setActualSize</code> modifies the item size/transform so that
     *  its TBounds have the specified <code>width</code> and <code>height</code>.
     *  
     *  If one of the desired TBounds dimensions is left unspecified, it's size
     *  will be picked such that item can be optimally sized to fit the other
     *  TBounds dimension. This is useful when the layout doesn't want to 
     *  overconstrain the item in cases where the item TBounds width & height
     *  are dependent (text, components with complex transforms, etc.)
     * 
     *  If both TBounds dimensions are left unspecified, the item will have its
     *  preferred size set.
     * 
     *  <code>setActualSize</code> does not clip against <code>minSize</code> and
     *  <code>maxSize</code> properties.
     * 
     *  <code>setActualSize</code> must preserve the item's TBounds position,
     *  which means that in some cases it will move the item in addition to
     *  changing its size.
     * 
     *  @return Returns the TBounds of the new item size.
     */
    public function setActualSize(width:Number = Number.NaN, height:Number = Number.NaN):Point
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
        	
            var newSize:Point = TransformUtil.fitBounds(width, height, m,
                                                        bounds.width, bounds.height,
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

        drawWidth = width;
        drawHeight = height;

        // Finally, apply the transforms to the object
        commitScaleAndRotation();
        return actualSize;
    }
    
    private function beginCommitTransformProps():void
	{
        if (_mask && isMaskInElementSpace)
        {
            var maskMatrix:Matrix = _mask.transform.matrix;
            var dispObjMatrix:Matrix = displayObject.transform.matrix.clone();
            
            dispObjMatrix.invert();
            maskMatrix.concat(dispObjMatrix);
            _mask.transform.matrix = maskMatrix;
            isMaskInElementSpace = false;
        }
	}
	
	private function endCommitTransformProps():void
	{
        if (_mask && !isMaskInElementSpace)
        {
            var maskMatrix:Matrix = _mask.transform.matrix;
            maskMatrix.concat(displayObject.transform.matrix);
            _mask.transform.matrix = maskMatrix;
            isMaskInElementSpace = true;
        }
	}
    
    /**
     *  Applies _x and _y properties to the display object. 
     */
    protected function commitXY():void
    {
        if (!displayObject)
            return;

        beginCommitTransformProps();
            
        TransformUtil.applyTransforms(displayObject, null, _x, _y);
        _x = displayObject.x;
        _y = displayObject.y;
        xChanged = false;
        yChanged = false;
        
        endCommitTransformProps();
    }
    
    /**
     *  Applies _scaleX and _scaleY properties to the display object. 
     */    
    protected function commitScaleAndRotation():void
    {
        if (!displayObject)
            return;
        
        beginCommitTransformProps();

        var rot:Number = rotationChanged ? _rotation : NaN;
        TransformUtil.applyTransforms(displayObject, _matrix, NaN, NaN, 
                                      _scaleX, _scaleY, rot, _transformX, _transformY);

        _matrix = null;         
        _scaleX = displayObject.scaleX;
        _scaleY = displayObject.scaleY;
        _rotation = displayObject.rotation;
        
        if (!xChanged)
            _x = displayObject.x;
        if (!yChanged)
            _y = displayObject.y;
        
        scaleXChanged = false;
        scaleYChanged = false;
        rotationChanged = false;
        
        endCommitTransformProps();
    }

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
            
        // TODO EGeorgie: stroke thickness depends on all matrix components,
        // not only on scale.
        if (scaleMode == LineScaleMode.NORMAL)
        {
	        if (_scaleX == _scaleY)
	            weight *= _scaleX;
	        else
	            weight *= Math.sqrt(0.5 * (_scaleX * _scaleX + _scaleY * _scaleY));
	        return new Point(weight, weight);
        }
        else if (scaleMode == LineScaleMode.HORIZONTAL)
        {
        	return new Point(weight * _scaleX, weight);
        }
        else if (scaleMode == LineScaleMode.VERTICAL)
        {
        	return new Point(weight, weight * _scaleY);
        }
        return null;
    }

    //--------------------------------------------------------------------------
    //
    //  IConstraintClient
    //
    //--------------------------------------------------------------------------
    
    public function getConstraintValue(constraintName:String):*
    {
    	return this[constraintName];
    }
    
    public function setConstraintValue(constraintName:String, value:*):void
    {
    	this[constraintName] = value;
    }
	
}
}

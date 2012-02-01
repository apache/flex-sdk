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

package spark.primitives.supportClasses
{

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Transform;
import flash.geom.Vector3D;

import mx.core.AdvancedLayoutFeatures;
import mx.core.DesignLayer;
import mx.core.IID;
import mx.core.IInvalidating;
import mx.core.ILayoutElement;
import mx.core.IUIComponent;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.UIComponentGlobals;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.filters.BaseFilter;
import mx.filters.IBitmapFilter;
import mx.geom.Transform;
import mx.geom.TransformOffsets;
import mx.managers.ILayoutManagerClient;
import mx.utils.MatrixUtil;

import spark.components.Group;
import spark.components.supportClasses.InvalidatingSprite;
import spark.core.DisplayObjectSharingMode;
import spark.core.IGraphicElement;
import spark.core.MaskType;

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
 *  
 *  <p>If you set the transform.matrix declaratively in MXML, then it will override
 *  the values of any transform properties (rotation, scaleX, scaleY, x, and y).
 *  If you set the transform.matrix or the transform properties in ActionScript, then
 *  the last value set will be used.</p>  
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class GraphicElement extends EventDispatcher
    implements IGraphicElement, IInvalidating, ILayoutElement, IVisualElement, IID
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  The default value for the <code>maxWidth</code> property.
     */
    private static const DEFAULT_MAX_WIDTH:Number = 10000;

    /**
     *  @private
     *  The default value for the <code>maxHeight</code> property.
     */
    private static const DEFAULT_MAX_HEIGHT:Number = 10000;

     /**
     *  @private 
     *  The default value for the <code>minWidth</code> property.
     */
    private static const DEFAULT_MIN_WIDTH:Number = 0;

    /**
     *  @private
     *  The default value for the <code>minHeight</code> property.
     */
    private static const DEFAULT_MIN_HEIGHT:Number = 0;

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

    private var colorTransformChanged:Boolean;
    
    /**
     *  @private The Sprite to draw into. 
     *  If null, then we just use displayObject or sharedDisplayObject
     */
    private var _drawnDisplayObject:InvalidatingSprite;

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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    //  Properties - IID
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  id
    //----------------------------------

    /**
     *  @private
     *  Storage for the id property.
     */
    private var _id:String;

    /**
     *  The identity of the component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get id():String
    {
        return _id;
    }

    /**
     *  @private
     */ 
    public function set id(value:String):void
    {
        _id = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  @copy mx.core.ILayoutElement#postLayoutTransformOffsets
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get postLayoutTransformOffsets():TransformOffsets
    {
        return (layoutFeatures == null)? null:layoutFeatures.postLayoutTransformOffsets;
    }
    
    /**
     * @private
     */
    public function set postLayoutTransformOffsets(value:TransformOffsets):void
    {
        if(value != null)
            allocateLayoutFeatures();
        
        if(layoutFeatures.postLayoutTransformOffsets != null)
            layoutFeatures.postLayoutTransformOffsets.removeEventListener(Event.CHANGE,transformOffsetsChangedHandler);
        layoutFeatures.postLayoutTransformOffsets = value;
        if(layoutFeatures.postLayoutTransformOffsets != null)
            layoutFeatures.postLayoutTransformOffsets.addEventListener(Event.CHANGE,transformOffsetsChangedHandler);
    }

    /**
     *  @private
     */
    mx_internal function allocateLayoutFeatures():void
    {
        if(layoutFeatures != null)
            return;
        layoutFeatures = new AdvancedLayoutFeatures();
        layoutFeatures.layoutX = _x;
        layoutFeatures.layoutY = _y;
    }
    
    /**
     *  @private
     */
    private function invalidateTransform(changeInvalidatesLayering:Boolean = true,
                                           invalidateLayout:Boolean = true):void
    {
        if (changeInvalidatesLayering)
            invalidateDisplayObjectSharing();

        // Make sure we apply the transform    
        if (layoutFeatures != null)
            layoutFeatures.updatePending = true;

        // If we are sharing a display object we need to redraw
        if (displayObjectSharingMode != DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
            invalidateDisplayList();
        else
            invalidateProperties(); // We apply the transform in commitProperties

        // Trigger a layout pass
        if (invalidateLayout)
            invalidateParentSizeAndDisplayList();
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
    private var _effectiveAlpha:Number = 1.0;
    
    /**
     *  @private
     */
    private var alphaChanged:Boolean = false;
    
    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        
        var previous:Boolean = needsDisplayObject;
        _alpha = value;
        
        if (designLayer)
            value = value * designLayer.effectiveAlpha; 
        
        _effectiveAlpha = value;
        
        // Clear the colorTransform flag since alpha was explicitly set
        var mxTransform:mx.geom.Transform = _transform as mx.geom.Transform;
        if (mxTransform)
            mxTransform.applyColorTransformAlpha = false;        
        
        if (previous != needsDisplayObject)
            invalidateDisplayObjectSharing();    

        alphaChanged = true;
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    //  baselinePosition
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  The y-coordinate of the baseline
     *  of the first line of text of the component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get baselinePosition():Number
    {    
        // Subclasses of GraphicElement should return something 
        // here as appropriate (e.g. text centric GraphicElements).
        return 0;
    }
    
    //----------------------------------
    //  blendMode
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the blendMode property.
     */
    private var _blendMode:String = "auto"; 
    
    /**
     *  @private
     */
    private var blendModeChanged:Boolean;
    private var blendModeExplicitlySet:Boolean = false;

    [Inspectable(category="General", enumeration="auto,add,alpha,darken,difference,erase,hardlight,invert,layer,lighten,multiply,normal,subtract,screen,overlay,colordodge,colorburn,exclusion,softlight,hue,saturation,color,luminosity", defaultValue="auto")]

    /**
     *  A value from the BlendMode class that specifies which blend mode to use. 
     * 
     *  @default auto
     * 
     *  @see flash.display.DisplayObject#blendMode
     *  @see flash.display.BlendMode
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get blendMode():String
    {
		return _blendMode;
    }

    /**
     *  @private
     */
    public function set blendMode(value:String):void
    {
        if (blendModeExplicitlySet && value == _blendMode)
            return;
        
        // FIXME (dsubrama): Temporarily exit when blendMode is set
    	// to one of the AIM blendModes; support for this will come
    	// shortly. 
        if (value == "colordodge" || 
        	value =="colorburn" || value =="exclusion" || 
        	value =="softlight" || value =="hue" || 
        	value =="saturation" || value =="color" 
        	|| value =="luminosity")
            return;

        //The default blendMode in FXG is 'auto'. There are only
        //certain cases where this results in a rendering difference,
        //one being when the alpha of the Group is > 0 and < 1. In that
        //case we set the blendMode to layer to avoid the performance
        //overhead that comes with a non-normal blendMode. 
        
        if (alpha > 0 && alpha < 1 && !blendModeExplicitlySet && value == "auto")
        {
            if (value != BlendMode.LAYER)
            {
                _blendMode = BlendMode.LAYER;
                blendModeChanged = true;
                invalidateProperties();
            }
        }
        else if ((alpha == 1 || alpha == 0) && !blendModeExplicitlySet && value == "auto")
        {
            if (value != BlendMode.NORMAL)
            {
                _blendMode = BlendMode.NORMAL;
                blendModeChanged = true;
                invalidateProperties();
            }
        }
        else 
        {
            var previous:Boolean = needsDisplayObject;
            _blendMode = value;
            if (previous != needsDisplayObject)
                invalidateDisplayObjectSharing();
        
            blendModeExplicitlySet = true;
            blendModeChanged = true;
            invalidateProperties();   
        }
    }

    //----------------------------------
    //  bottom
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the bottom property.
     */
    private var _bottom:Object;

    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    //  layer
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the layer property.
     */
    private var _designLayer:DesignLayer;
    
    [Inspectable (environment='none')]
    
    /**
     *  @copy mx.core.IVisualElement#designLayer
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get designLayer():DesignLayer
    {
        return _designLayer;
    }
    
    /**
     *  @private
     */
    public function set designLayer(value:DesignLayer):void
    {
        if (_designLayer)
            _designLayer.removeEventListener("layerPropertyChange", layer_PropertyChange, false);
        
        _designLayer = value;
        
        if (_designLayer)
            _designLayer.addEventListener("layerPropertyChange", layer_PropertyChange, false, 0, true);
        
        _effectiveAlpha = _designLayer ? _alpha * _designLayer.effectiveAlpha : _alpha;
        _effectiveVisibility = _designLayer ? _visible && _designLayer.effectiveVisibility : _visible;
        alphaChanged = true;
        visibleChanged = true;
        invalidateProperties();
    }
        
    //----------------------------------
    //  parent
    //----------------------------------

    /**
     *  @private
     *  Storage for the parent property.
     */
    private var _parent:DisplayObjectContainer;

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get parent():DisplayObjectContainer
    {
        return _parent;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function parentChanged(value:Group):void
    {
        _parent = value;
    }

    //----------------------------------
    //  explicitHeight
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the explicitHeight property.
     */
    private var _explicitHeight:Number;

    [Inspectable(category="General")]

    /**
     *  Number that specifies the explicit height of the component,
     *  in pixels, in the component's coordinates.
     * 
     *  @see mx.core.UIComponent#explicitHeight
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

        _explicitHeight = value;

        invalidateSize();
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  explicitMaxHeight
    //----------------------------------

    /**
     *  The maximum recommended height of the component to be considered
     *  by the parent during layout. This value is in the
     *  component's coordinates, in pixels.
     * 
     *  @see mx.core.UIComponent#explicitMaxHeight
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get explicitMaxHeight():Number { return maxHeight; }
    public function set explicitMaxHeight(value:Number):void { maxHeight = value; }

    //----------------------------------
    //  explicitMaxWidth
    //----------------------------------

    /**
     *  The maximum recommended width of the component to be considered
     *  by the parent during layout. This value is in the
     *  component's coordinates, in pixels.
     * 
     *  @see mx.core.UIComponent#explicitMaxWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get explicitMaxWidth():Number { return maxWidth; }
    public function set explicitMaxWidth(value:Number):void { maxWidth = value; }

    //----------------------------------
    //  explicitMinHeight
    //----------------------------------

    /**
     *  The minimum recommended height of the component to be considered
     *  by the parent during layout. This value is in the
     *  component's coordinates, in pixels. 
     * 
     *  @see mx.core.UIComponent#explicitMinHeight
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get explicitMinHeight():Number { return minHeight; }
    public function set explicitMinHeight(value:Number):void { minHeight = value; }

    //----------------------------------
    //  explicitMinWidth
    //----------------------------------

    /** 
     *  The minimum recommended width of the component to be considered
     *  by the parent during layout. This value is in the
     *  component's coordinates, in pixels. 
     * 
     *  @see mx.core.UIComponent#explicitMinWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

    [Inspectable(category="General")]

    /**
     *  Number that specifies the explicit width of the component,
     *  in pixels, in the component's coordinates.
     * 
     *  @see mx.core.UIComponent#explicitWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

        _explicitWidth = value;

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
    
    [Inspectable(category="General")]

    /**
     *  An indexed array that contains each filter object currently associated with the graphic element. 
     *  The mx.filters.* package contains several classes that define specific filters you can use.
     *  
     *  The getter returns a copy of the filters array. The filters property value can only be changed 
     *  via the setter. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get filters():Array
    {
        // Return a copy of the filters to prevent it from being mutated. 
        // The only way to change the filters is through the setter. 
        return _filters.slice();
    }

    /**
     *  @private
     */
    public function set filters(value:Array):void
    {
        var i:int = 0;
        var len:int = _filters ? _filters.length : 0;
        var newLen:int = value ? value.length : 0; 
        var edFilter:IEventDispatcher;

        if (len == 0 && newLen == 0)
            return;

        // Remove the event listeners on the previous filters
        for (i = 0; i < len; i++)
        {
            edFilter = _filters[i] as IEventDispatcher;
            if (edFilter)
                edFilter.removeEventListener(BaseFilter.CHANGE, filterChangedHandler);
        }

        var previous:Boolean = needsDisplayObject;
        _filters = value;
        if (previous != needsDisplayObject)
            invalidateDisplayObjectSharing();
        
        _clonedFilters = [];
        
        for (i = 0; i < newLen; i++)
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

        filtersChanged = true;
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

        // Invalidate the display list, since we're changing the actual height
        // and we're not going to correctly detect whether the layout sets
        // new actual height different from our previous value.
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    
    [Inspectable(category="General")]

    /**
     *  The calling display object is masked by the specified mask object. 
     *  If, the mask display object is not on the display list, it will be added to the display list
     *  as a child of the displayObject. The mask object itself is not drawn. 
     *  Set mask to null to remove the mask.
     * 
     *  To use another GraphicElement as a mask, wrap the GraphicElement in a Group or other container. 
     *  
     *  @see flash.display.DisplayObject#mask
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

        var previous:Boolean = needsDisplayObject;
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
        
        maskChanged = true;
        maskTypeChanged = true;
        if (previous != needsDisplayObject)
            invalidateDisplayObjectSharing();

        invalidateProperties();
        invalidateDisplayList();
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

    [Inspectable(category="General", enumeration="clip,alpha,luminosity", defaultValue="clip")]
    
    /**
     *  <p>The maskType defines how the mask is applied to the GraphicElement.</p> 
     * 
     *  <p>The possible values are MaskType.CLIP and MaskType.ALPHA.</p>  
     * 
     *  <p>Clip Masking</p>
     * 
     *  <p>When masking in clip mode, a clipping masks is reduced to 1-bit.  This means that a mask will 
     *  not affect the opacity of a pixel in the source content; it either leaves the value unmodified, 
     *  if the corresponding pixel in the mask is has a non-zero alpha value, or makes it fully 
     *  transparent, if the mask pixel value has an alpha value of zero.</p>
     * 
     *  <p>When clip masking is used, only the actual path and shape vectors and fills defined by the
     *  mask are used to determine the effect on the source content.  strokes and bitmap filters 
     *  defined on the mask are ignored.  Any filled region in the mask is considered filled, and renders 
     *  the source content.  The type and parameters of the fill is irrelevant;  a solid color fill, 
     *  gradient fill, or bitmap fill in a mask will all render the underlying source content, regardless 
     *  of the alpha values of the mask fill.</p>
     *  
     *  <p>BitmapGraphics are treated as bitmap filled rectangles when used in a clipping mask.  As a 
     *  result, the alpha channel of the source bitmap is irrelevant when part of a mask -- the bitmap 
     *  affects the mask in the same manner as solid filled rectangle of equivalent dimensions.</p>
     * 
     *  <p>Alpha Masking</p>
     * 
     *  <p>In alpha mode, the opacity of each pixel in the source content is multiplied by the opacity 
     *  of the corresponding region of the mask.  i.e., a pixel in the source content with an opacity of 
     * 1 that is masked by a region of opacity of .5 will have a resulting opacity of .5.  A source pixel 
     * with an opacity of .8 masked by a region with opacity of .5 will have a resulting opacity of .4.</p>
     * 
     *  <p>Conceptually, Alpha masking is equivalent to rendering the transformed mask and source content 
     *  into separate RGBA surfaces, and multiplying the alpha channel of the mask content into the alpha 
     *  channel of the source content.  All of the mask content is rendered into its surface before 
     *  compositing into the source content's surface. As a result, all FXG features, such as strokes, 
     *  bitmap filters, and fill opacity will affect the final composited content.</p>
     * 
     *  <p>When in alpha mode, the alpha channel of any bitmap data is composited normally into the mask 
     *  alpha channel, and will affect the final rendered content. This holds true for both BitmapGraphics 
     *  and bitmap filled shapes and paths.</p>
     * 
     *  @default MaskType.CLIP
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
    	
        if (_maskType == value)
            return;

        _maskType = value;

        maskTypeChanged = true;
        invalidateProperties();
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
    
    //----------------------------------
    //  maxHeight
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the maxHeight property.
     */
    private var _maxHeight:Number;

    [Inspectable(category="General")]
    
    /**
     *  @copy mx.core.UIComponent#maxHeight
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get maxHeight():Number
    {
        // FIXME (egeorgie): Examine this logic, Make this arbitrarily large (use UIComponent max)
        return !isNaN(_maxHeight) ? _maxHeight : DEFAULT_MAX_HEIGHT;
    }

    /**
     *  @private
     */
    public function set maxHeight(value:Number):void
    {
        if (_maxHeight == value)
            return;

        _maxHeight = value;

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
    mx_internal var _maxWidth:Number;

    [Inspectable(category="General")]
    
    /**
     *  @copy mx.core.UIComponent#maxWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get maxWidth():Number
    {
        // FIXME (egeorgie): Examine this logic, Make this arbitrarily large (use UIComponent max)
        return !isNaN(_maxWidth) ? _maxWidth : DEFAULT_MAX_WIDTH;
    }

    /**
     *  @private
     */
    public function set maxWidth(value:Number):void
    {
        if (_maxWidth == value)
            return;

        _maxWidth = value;

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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

    [Inspectable(category="General")]
    
    /**
     *  @copy mx.core.UIComponent#minHeight
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get minHeight():Number
    {
        // FIXME (egeorgie): Examine this logic
        return !isNaN(_minHeight) ? _minHeight : DEFAULT_MIN_HEIGHT;
    }

    /**
     *  @private
     */
    public function set minHeight(value:Number):void
    {
        if (_minHeight == value)
            return;

        _minHeight = value;

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

    [Inspectable(category="General")]
    
    /**
     *  @copy mx.core.UIComponent#minWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get minWidth():Number
    {
        // FIXME (egeorgie): Examine this logic
        return !isNaN(_minWidth) ? _minWidth : DEFAULT_MIN_WIDTH;
    }

    /**
     *  @private
     */
    public function set minWidth(value:Number):void
    {
        if (_minWidth == value)
            return;

        _minWidth = value;

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

    [Inspectable(category="General")]
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

        _percentHeight = value;

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

    [Inspectable(category="General")]
    
    /**
     *  @copy mx.core.UIComponent#percentWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

        _percentWidth = value;

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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

    [Inspectable(category="General")]
    
    /**
     * Indicates the x-axis rotation of the element instance, in degrees, from its original orientation 
     * relative to the 3D parent container. Values from 0 to 180 represent clockwise rotation; values 
     * from 0 to -180 represent counterclockwise rotation. Values outside this range are added to or subtracted from 
     * 360 to obtain a value within the range.
     * 
     * This property is ignored during calculation by any of Flex's 2D layouts. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        if (rotationX == value)
            return;

        allocateLayoutFeatures();
        var previous:Boolean = needsDisplayObject;
        layoutFeatures.layoutRotationX = value;
        invalidateTransform(previous != needsDisplayObject); 
    }

    [Inspectable(category="General")]
    
    /**
     * Indicates the y-axis rotation of the DisplayObject instance, in degrees, from its original orientation 
     * relative to the 3D parent container. Values from 0 to 180 represent clockwise rotation; values 
     * from 0 to -180 represent counterclockwise rotation. Values outside this range are added to or subtracted from 
     * 360 to obtain a value within the range.
     * 
     * This property is ignored during calculation by any of Flex's 2D layouts. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        if (rotationY == value)
            return;
        
        allocateLayoutFeatures();
        var previous:Boolean = needsDisplayObject;
        layoutFeatures.layoutRotationY = value;
        invalidateTransform(previous != needsDisplayObject);
    }
    
    [Inspectable(category="General")]
    
    /**
     *  Indicates the rotation of the element, in degrees,
     *  from the transform point.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        if (rotationZ == value)
            return;
        
        allocateLayoutFeatures();
        var previous:Boolean = needsDisplayObject;
        layoutFeatures.layoutRotationZ = value;
        invalidateTransform(previous != needsDisplayObject);
    }

    [Inspectable(category="General")]
    
    /**
     *  Indicates the rotation of the element, in degrees,
     *  from the transform point.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

    [Inspectable(category="General")]

    /**
     *  The horizontal scale (percentage) of the element
     *  as applied from the transform point.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        if (scaleX == value)
            return;
        
        allocateLayoutFeatures();
        var previous:Boolean = needsDisplayObject;
        layoutFeatures.layoutScaleX = value;
        invalidateTransform(previous != needsDisplayObject);
    }

    //----------------------------------
    //  scaleY
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  The vertical scale (percentage) of the element
     *  as applied from the transform point.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        if (scaleY == value)
            return;
            
        allocateLayoutFeatures();
        var previous:Boolean = needsDisplayObject;
        layoutFeatures.layoutScaleY = value;
        invalidateTransform(previous != needsDisplayObject);
    }

    //----------------------------------
    //  scaleZ
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  The z scale (percentage) of the element
     *  as applied from the transform point.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        if (scaleZ == value)
            return;
        
        allocateLayoutFeatures();
        var previous:Boolean = needsDisplayObject;
        layoutFeatures.layoutScaleZ = value;
        invalidateTransform(previous != needsDisplayObject);    
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        // TODO (jszeto): Add perspectiveProjection support
        var matrix:Matrix = value && value.matrix ? value.matrix.clone() : null;
        var matrix3D:Matrix3D = value && value.matrix3D ? value.matrix3D.clone() : null;
        var colorTransform:ColorTransform = value ? value.colorTransform : null;
        
        var mxTransform:mx.geom.Transform = value as mx.geom.Transform; 
        if (mxTransform)
        {
            if (!mxTransform.applyMatrix)
                matrix = null;
            
            if (!mxTransform.applyMatrix3D)
                matrix3D = null;
        }
        
        setTransform(value);

        var previous:Boolean = needsDisplayObject;

        if (_transform)
        {
            allocateLayoutFeatures();

            if(matrix != null)
            {
                layoutFeatures.layoutMatrix = matrix;
            }
            else if (matrix3D != null)
            {    
                layoutFeatures.layoutMatrix3D = matrix3D;
            }          
        }
        
             
        applyColorTransform(colorTransform, mxTransform && mxTransform.applyColorTransformAlpha);

        invalidateTransform(previous != needsDisplayObject);
    }

    /**
     * @private
     */ 
    private function setTransform(value:flash.geom.Transform):void
    {
        // Clean up the old transform
        var oldTransform:mx.geom.Transform = _transform as mx.geom.Transform;
        if (oldTransform)
            oldTransform.target = null;

        var newTransform:mx.geom.Transform = value as mx.geom.Transform;

        if (newTransform)
            newTransform.target = this;

        _transform = value;
    }
    
    /**
     * @private
     * 
     * Sets the colorTransform property of the transform. Called by mx.geom.Transform
     * when its colorTransform property has been changed.   
     */
    public function setColorTransform(value:ColorTransform):void
    {
        applyColorTransform(value, true);
    }
    
    /**
     * @private
     */
    private function applyColorTransform(value:ColorTransform, updateAlpha:Boolean):void
    {
        if (_colorTransform != value)
        {
            var previous:Boolean = needsDisplayObject;
            // Make a copy of the colorTransform
            _colorTransform = new ColorTransform(value.redMultiplier, value.greenMultiplier, value.blueMultiplier, value.alphaMultiplier,
                value.redOffset, value.greenOffset, value.blueOffset, value.alphaOffset);
            
            if (updateAlpha)
            {
                _alpha = value.alphaMultiplier;
                _effectiveAlpha = _alpha;
            }
            
            if (displayObject && displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
            {
                displayObject.transform.colorTransform = _colorTransform;
            }
            else
            {
                colorTransformChanged = true;
                invalidateProperties();
                if (previous != needsDisplayObject)
                    invalidateDisplayObjectSharing();       
            }
        }
    }
    
    /**
     * @copy mx.core.ILayoutElement#transformAround
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function transformAround(transformCenter:Vector3D,
                                    scale:Vector3D = null,
                                    rotation:Vector3D = null,
                                    translation:Vector3D = null,
                                    postLayoutScale:Vector3D = null,
                                    postLayoutRotation:Vector3D = null,
                                    postLayoutTranslation:Vector3D = null):void
    {
        // FIXME (egreenfi): optimize for simple translations
        allocateLayoutFeatures();
        var previous:Boolean = needsDisplayObject;
        var prevX:Number = layoutFeatures.layoutX;
        var prevY:Number = layoutFeatures.layoutY;
        var prevZ:Number = layoutFeatures.layoutZ;
        layoutFeatures.transformAround(transformCenter,scale,rotation,translation,postLayoutScale,postLayoutRotation,postLayoutTranslation);
        invalidateTransform(previous != needsDisplayObject);
        if (prevX != layoutFeatures.layoutX)
            dispatchPropertyChangeEvent("x", prevX, layoutFeatures.layoutX);
        if (prevY != layoutFeatures.layoutY)
            dispatchPropertyChangeEvent("y", prevY, layoutFeatures.layoutY);
        if (prevZ != layoutFeatures.layoutZ)
            dispatchPropertyChangeEvent("z", prevZ, layoutFeatures.layoutZ);
    }
    
    /**
     *  FIXME (chaase) : FLEXDOCS-1031
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function transformPointToParent(transformCenter:Vector3D,position:Vector3D,postLayoutPosition:Vector3D):void
    {
        if(layoutFeatures != null)
        {
            layoutFeatures.transformPointToParent(true,transformCenter,position,postLayoutPosition);
        }
        else
        {
            var xformPt:Point = new Point();
            if (transformCenter)
            {
                xformPt.x = transformCenter.x;
                xformPt.y = transformCenter.y;
            }
            if(position != null)
            {            
                position.x = xformPt.x + _x;
                position.y = xformPt.y + _y;
                position.z = 0;
            }
            if (postLayoutPosition != null)
            {
                postLayoutPosition.x = xformPt.x + _x;
                postLayoutPosition.y = xformPt.y + _y;
                postLayoutPosition.z = 0;
            }
        }
    }

    //----------------------------------
    //  transformX
    //----------------------------------
    
    [Inspectable(category="General")]

    /**
     *  The x position transform point of the element.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        if (transformX  == value)
            return;
            
        allocateLayoutFeatures();
        layoutFeatures.transformX = value;
        invalidateTransform(false);
    }

    //----------------------------------
    //  transformY
    //----------------------------------
    
    [Inspectable(category="General")]

    /**
     *  The y position transform point of the element.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        if (transformY == value)
            return;

        allocateLayoutFeatures();
        layoutFeatures.transformY = value;
        invalidateTransform(false);
    }

    //----------------------------------
    //  transformZ
    //----------------------------------
    
    [Inspectable(category="General")]

    /**
     *  The z position transform point of the element.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        if (transformZ == value)
            return;

        allocateLayoutFeatures();
        var previous:Boolean = needsDisplayObject;
        layoutFeatures.transformZ = value;
        invalidateTransform(previous != needsDisplayObject);
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

        // Invalidate the display list, since we're changing the actual width
        // and we're not going to correctly detect whether the layout sets
        // new actual width different from our previous value.
        invalidateDisplayList();
    }

    //----------------------------------
    //  depth
    //----------------------------------  
    /**
     * Determines the order in which items inside of groups are rendered. Groups order their items based on their depth property, with the lowest depth
     * in the back, and the higher in the front.  items with the same depth value will appear in the order they are added to the Groups item list.
     * 
     * defaults to 0
     * 
     * @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get depth():Number
    {
        return (layoutFeatures == null)? 0:layoutFeatures.depth;
    }

    /**
     *  @private
     */
    public function set depth(value:Number):void
    {
        if(value == depth)
            return;

        allocateLayoutFeatures();
        layoutFeatures.depth = value;  
        if(_parent != null && _parent is UIComponent)
            (_parent as UIComponent).invalidateLayering();
        invalidateProperties();
    }

    //----------------------------------
    //  x
    //----------------------------------  
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  The x position of the graphic element.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        if (z == value)
            return;
        var oldValue:Number = z;
        
        allocateLayoutFeatures();
        var previous:Boolean = needsDisplayObject;
        layoutFeatures.layoutZ = value;
        invalidateTransform(previous != needsDisplayObject);
        dispatchPropertyChangeEvent("z", oldValue, value);
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
     *  The actual 'effective' visibility of this
     *  element, one that considers the visibility of
     *  the owning design layer parent (if any).
     */
    protected var _effectiveVisibility:Boolean = true;
    
    /**
     *  @private
     */
    private var visibleChanged:Boolean;

    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        _visible = value;
        
        if (designLayer && !designLayer.effectiveVisibility)
            value = false; 
        
        if (_effectiveVisibility == value)
            return;
        
        _effectiveVisibility = value;
        visibleChanged = true;
        invalidateProperties();
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
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get displayObject():DisplayObject
    {
        return _displayObject;
    }

    /**
     *  @private
     */
    protected function setDisplayObject(value:DisplayObject):void
    {
        if (_displayObject == value)
            return;

        var oldValue:DisplayObject = _displayObject;

        // If we owned the old display object and we have assigned a 3D matrix,
        // clear it from the display object so that we can set it in the new
        // display object. A Matrix3D object can't be used simultaneously with
        // more than one display object.
        if (oldValue && displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
            oldValue.transform.matrix3D = null;

        _displayObject = value;
        dispatchPropertyChangeEvent("displayObject", oldValue, value);

        // We need to apply the display object related properties.
        displayObjectChanged = true;
        invalidateProperties();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  drawX
    //----------------------------------

    /**
     *  The x position where the element should be drawn.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function get drawX():Number
    {
        // If we don't share the display object, we will draw at 0,0
        // since the display object will be positioned at x,y
        if (displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
            return 0;
            
        // Otherwise we draw at x,y since the display object will be
        // positioned at 0,0
        if (layoutFeatures != null && layoutFeatures.postLayoutTransformOffsets != null)
            return x + layoutFeatures.postLayoutTransformOffsets.x;
            
        return x;
    } 
        
    //----------------------------------
    //  drawY
    //----------------------------------

    /**
     *  The y position where the element should be drawn.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function get drawY():Number
    {
        // If we don't share the display object, we will draw at 0,0
        // since the display object will be positioned at x,y
        if (displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
            return 0;
            
        // Otherwise we draw at x,y since the display object will be
        // positioned at 0,0
        if (layoutFeatures != null && layoutFeatures.postLayoutTransformOffsets != null)
            return y + layoutFeatures.postLayoutTransformOffsets.y;
            
        return y;
    }
    
    //----------------------------------
    //  hasComplexLayoutMatrix
    //----------------------------------
    
    /**
     *  Returns true if the GraphicElement has any non-translation (x,y) transform properties
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function get hasComplexLayoutMatrix():Boolean
    {
        return (layoutFeatures == null ? false : !MatrixUtil.isDeltaIdentity(layoutFeatures.layoutMatrix));
    }
    
    //----------------------------------
    //  includeInLayout
    //----------------------------------

    /**
     *  @private
     *  Storage for the includeInLayout property.
     */
    private var _includeInLayout:Boolean = true;

    [Inspectable(category="General", defaultValue="true")]

    /**
     *  Specifies whether this element is included in the layout of the group.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

        // Temporarily set includeInLayout to true so that
        // invalidating the parent doesn't return early.
        _includeInLayout = true;
        invalidateParentSizeAndDisplayList();

        _includeInLayout = value;
    }

    //----------------------------------
    //  displayObjectSharingMode
    //----------------------------------

    private var _displayObjectSharingMode:String;
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set displayObjectSharingMode(value:String):void
    {
        if (value == _displayObjectSharingMode)
            return;
        
        if (value != DisplayObjectSharingMode.USES_SHARED_OBJECT ||
            _displayObjectSharingMode != DisplayObjectSharingMode.USES_SHARED_OBJECT) 
        {
            // If the element was previously at the head of the shared sequence or
            // it is assigned to be at the head, make sure to reapply the 
            // displayObject specific properties.
            displayObjectChanged = true;
            invalidateProperties();            
        }
        _displayObjectSharingMode = value;
    }
    
    /**
     *  @private
     */
    public function get displayObjectSharingMode():String
    {
        return _displayObjectSharingMode;    
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Converts the point object from the object's (local) coordinates 
     * to the Stage (global) coordinates.
     * 
     * <p>This method allows you to convert any given x and y coordinates from 
     * values that are relative to the origin (0,0) of a specific object 
     * (local coordinates) to values that are relative to the origin 
     * of the Stage (global coordinates).</p>
     * 
     * <p>To use this method, first create an instance of the Point class. 
     * The x and y values that you assign represent local coordinates 
     * because they relate to the origin of the object.</p>
     * 
     * <p>You then pass the Point instance that you created as the parameter 
     * to the localToGlobal() method. The method returns a new Point object 
     * with x and y values that relate to the origin of the Stage instead of 
     * the origin of the object.</p>
     * 
     * @param point The name or identifier of a point created with the Point 
     * class, specifying the x and y coordinates as properties.
     * 
     * @return A Point object with coordinates relative to the Stage.
     * 
     * @see flash.display.DisplayObject#localToGlobal
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function localToGlobal(point:Point):Point
    {
        // If there is not yet a displayObject or it's not parented, just
        // return its local position
        if (!displayObject || !displayObject.parent)
            return new Point(x, y);
            
        var returnVal:Point = displayObject.localToGlobal(point);

        if (!needsDisplayObject)
        {
            // If we're sharing the displayObject, add in our offset
            returnVal.x += drawX;
            returnVal.y += drawY;
        }
        
        return returnVal;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function createDisplayObject():DisplayObject
    {
        setDisplayObject(new InvalidatingSprite());
        return displayObject;
    }
    
    private var _alwaysCreateDisplayObject:Boolean;
    
    // Used by the design tool to get bitmap captures
    mx_internal function set alwaysCreateDisplayObject(value:Boolean):void
    {
        if (value != _alwaysCreateDisplayObject)
        {
            var previous:Boolean = needsDisplayObject;
            _alwaysCreateDisplayObject = value;
            if (previous != needsDisplayObject)
                invalidateDisplayObjectSharing();
        }
    }
    
    mx_internal function get alwaysCreateDisplayObject():Boolean
    {
        return _alwaysCreateDisplayObject;
    }

    /**
     *  True if the element requires an exclusive DisplayObject.
     *
     *  Developers don't usually call this method directly, but override it in
     *  their subclasses to indicate that an exclusive DisplayObject is needed.
     *
     *  Usually a subclass needs a DisplayObject when it has to set its properties.  
     *
     *  Some examples of such DisplayObject properties are <code>filters</code>,
     *  <code>blendMode</code>, <code>mask</code>,
     *  <code>rotation</code>, <code>alpha</code>.
     * 
     *  @return Returns true when the element requires an exclusive DisplayObject.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function get needsDisplayObject():Boolean
    {
        var result:Boolean = (alwaysCreateDisplayObject ||
        (_filters && _filters.length > 0) || 
            (_blendMode != BlendMode.NORMAL && _blendMode != "auto") || _mask ||
            (layoutFeatures != null && (layoutFeatures.layoutScaleX != 1 || layoutFeatures.layoutScaleY != 1 || layoutFeatures.layoutScaleZ != 1 ||
            layoutFeatures.layoutRotationX != 0 || layoutFeatures.layoutRotationY != 0 || layoutFeatures.layoutRotationZ != 0 ||
            layoutFeatures.layoutZ  != 0)) ||  
            _colorTransform != null ||
            _effectiveAlpha != 1);
    
        if(layoutFeatures != null && layoutFeatures.postLayoutTransformOffsets != null)
        {
            var o:TransformOffsets = layoutFeatures.postLayoutTransformOffsets;
            result = result || (o.scaleX != 1 || o.scaleY != 1 || o.scaleZ != 1 ||
            o.rotationX != 0 || o.rotationY != 0 || o.rotationZ != 0 || o.z  != 0);       
        }
        
        return result;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setSharedDisplayObject(sharedDisplayObject:DisplayObject):Boolean
    {
        if (!(sharedDisplayObject is Sprite) || _alwaysCreateDisplayObject || needsDisplayObject)
            return false;
        setDisplayObject(sharedDisplayObject);
        return true;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function canShareWithPrevious(element:IGraphicElement):Boolean
    {
        // No need to check _alwaysCreateDisplayObject or needsDisplayObject,
        // as those will be checked in setSharedDisplayObject
        return element is GraphicElement;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function canShareWithNext(element:IGraphicElement):Boolean
    {
        return element is GraphicElement && !_alwaysCreateDisplayObject && !needsDisplayObject;
    }

    /**
     *  The actual DisplayObject that is drawn into by the GraphicElement. Typically this is 
     *  equivalent to the <code>displayObject</code> property. Subclasses should perform drawing commands on
     *  this property instead of on <code>displayObject</code>. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    protected function get drawnDisplayObject():DisplayObject
    {
        // _drawnDisplayObject is non-null if we needed to create a mask
        return _drawnDisplayObject ? _drawnDisplayObject : displayObject; 
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
     *  @param useLocalSpace Whether or not the bitmap shows the GraphicElement in the local or global 
     *  coordinate space. If true, then the snapshot is in the local space. The default value is true. 
     * 
     *  @param clipRect A Rectangle object that defines the area of the source object to draw. 
     *  If you do not supply this value, no clipping occurs and the entire source object is drawn.
     *  The clipRect should be defined in the coordinate space specified by useLocalSpace
     * 
     *  @return A bitmap snapshot of the GraphicElement. 
     *  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal function captureBitmapData(transparent:Boolean = true, fillColor:uint = 0xFFFFFFFF, useLocalSpace:Boolean = true, clipRect:Rectangle = null):BitmapData
    {
        if (!layoutFeatures || !layoutFeatures.is3D)
        {               
            var restoreDisplayObject:Boolean = false;
            var oldDisplayObject:DisplayObject;
            
            if (!displayObject || displayObjectSharingMode != DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
            {
                restoreDisplayObject = true;
                oldDisplayObject = displayObject;
                setDisplayObject(new InvalidatingSprite());
                UIComponent(parent).$addChild(displayObject);
                invalidateDisplayList();
                validateDisplayList();
            }
            
            var topLevel:Sprite = Sprite(IUIComponent(parent).systemManager);   
            var rectBounds:Rectangle = useLocalSpace ? 
                        new Rectangle(getLayoutBoundsX(), getLayoutBoundsY(), getLayoutBoundsWidth(), getLayoutBoundsHeight()) :
                        displayObject.getBounds(topLevel); 
            var bitmapData:BitmapData = new BitmapData(Math.ceil(rectBounds.width), Math.ceil(rectBounds.height), transparent, fillColor);
 
                
            // Can't use target's concatenatedMatrix, as it is sometimes wrong
            var m:Matrix = useLocalSpace ? 
                displayObject.transform.matrix : 
                MatrixUtil.getConcatenatedMatrix(displayObject);
            
            if (m)
                m.translate(-rectBounds.x, -rectBounds.y);
            
            bitmapData.draw(displayObject, m, null, null, clipRect);
           
            if (restoreDisplayObject)
            {
                UIComponent(parent).$removeChild(displayObject);
                setDisplayObject(oldDisplayObject);
            }
            return bitmapData;
        
        }
        else
        {
            return get3DSnapshot(transparent, fillColor, useLocalSpace);
        }
    }

   /**
     *  @private 
     *  Returns a bitmap snapshot of a 3D transformed displayObject. Since BitmapData.draw ignores
     *  the transform matrix of its target when it draws, we need to parent the target in a temporary
     *  sprite and call BitmapData.draw on that temp sprite. We can't take a bitmap snapshot of the 
     *  real parent because it might have other children. 
     */
    private function get3DSnapshot(transparent:Boolean = true, fillColor:uint = 0xFFFFFFFF, useLocalSpace:Boolean = true):BitmapData
    {
        var topLevel:Sprite = Sprite(IUIComponent(parent).systemManager); 
        var dispObjParent:DisplayObjectContainer = displayObject.parent;
        var drawSprite:Sprite = new Sprite();
                
        // Get the visual bounds of the target in both local and global coordinates
        var topLevelRect:Rectangle = displayObject.getBounds(topLevel);
        var displayObjectRect:Rectangle = displayObject.getBounds(dispObjParent);  
        
        // Keep a reference to the original 3D matrix. We will restore this later.
        var oldMat3D:Matrix3D = displayObject.transform.matrix3D.clone();
        
        // Get the concatenated 3D matrix which we will use to position the target when we reparent it
        var globalMat3D:Matrix3D = displayObject.transform.getRelativeMatrix3D(topLevel);
        var newMat3D:Matrix3D = oldMat3D.clone();      
        
        
        // Remove the target from its current parent, making sure to store the child index
        var childIndex:int = dispObjParent.getChildIndex(displayObject);
        if (dispObjParent is Group)
            Group(dispObjParent).$removeChild(displayObject);
        else
            dispObjParent.removeChild(displayObject);
        
        // Parent the target to the drawSprite and then attach the drawSprite to the stage
        topLevel.addChild(drawSprite);
        drawSprite.addChild(displayObject);

        // Assign the globally translated matrix to the target
        if (useLocalSpace)
        {
            newMat3D.position = globalMat3D.position;
            displayObject.transform.matrix3D = newMat3D;
        }
        else
        {
            displayObject.transform.matrix3D = globalMat3D;
        }
        // Translate the bitmap so that the left-top bounds ends up at (0,0)
        var m:Matrix = new Matrix();
        m.translate(-topLevelRect.left, - topLevelRect.top);
               
        // Draw to the bitmapData
        var snapshot:BitmapData = new BitmapData( topLevelRect.width, topLevelRect.height, transparent, fillColor);
        snapshot.draw(drawSprite, m, null, null, null, true);

        // Remove target from temporary sprite and remove temp sprite from stage
        drawSprite.removeChild(displayObject);
        topLevel.removeChild(drawSprite);
        
        // Reattach the target to its original parent at its original child position
        if (dispObjParent is Group)
            Group(dispObjParent).$addChildAt(displayObject, childIndex);
        else
            dispObjParent.addChildAt(displayObject, childIndex);
            
        // Restore the original 3D matrix
        displayObject.transform.matrix3D = oldMat3D;

        return snapshot; 
    }

    /**
     *  @private
     *  Enables clipping or alpha, depending on the type of mask being applied.
     */
    mx_internal function applyMaskType():void
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
     *  @private
     */
    protected function layer_PropertyChange(event:PropertyChangeEvent):void
    {
        switch (event.property)
        {
            case "effectiveVisibility":
            {
                var newValue:Boolean = (event.newValue && _visible);
                
                if (newValue != _effectiveVisibility)
                {
                    _effectiveVisibility = newValue;
                    visibleChanged = true;
                    invalidateProperties();
                }
                break;
            }
            case "effectiveAlpha":
            {
                var newAlpha:Number = Number(event.newValue) * _alpha;
                if (newAlpha != _effectiveAlpha)
                {
                    _effectiveAlpha = newAlpha;
                    alphaChanged = true;
                    
                    var mxTransform:mx.geom.Transform = _transform as mx.geom.Transform;
                    if (mxTransform)
                        mxTransform.applyColorTransformAlpha = false;        
                    
                    invalidateDisplayObjectSharing(); 
                    invalidateProperties();
                }
                break;
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal function dispatchPropertyChangeEvent(prop:String, oldValue:*,
                                                   value:*):void
    {
        dispatchEvent(PropertyChangeEvent.createUpdateEvent(
                           this, prop, oldValue, value));

    }

    /**
     *  Utility method that notifies the host that this element has changed and needs
     *  its layer to be updated.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function invalidateDisplayObjectSharing():void
    {
        if (parent)
            Group(parent).invalidateGraphicElementSharing(this);
    }

    /**
     *  Calling this method results in a call to the elements's
     *  <code>validateProperties()</code> method
     *  before the display list is rendered.
     *
     *  <p>Subclasses should do their work in 
     *  <code>commitProperties()</code>.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function invalidateProperties():void
    {
        if (invalidatePropertiesFlag)
            return;
        invalidatePropertiesFlag = true;

        if (parent)
            Group(parent).invalidateGraphicElementProperties(this);
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function invalidateSize():void
    {
        if (invalidateSizeFlag)
            return;
        invalidateSizeFlag = true;

        if (parent)
            Group(parent).invalidateGraphicElementSize(this);
    }

    /**
     *  Helper method to invalidate parent size and display list if
     *  this object affects its layout (includeInLayout is true).
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function invalidateDisplayList():void
    {
        if (invalidateDisplayListFlag)
            return;
        invalidateDisplayListFlag = true;

        // The Group will take care of redrawing all graphic elements that
        // share the display object with this element.
        if (parent)
            Group(parent).invalidateGraphicElementDisplayList(this);
    }

    /**
     *  Validates and updates the properties and layout of this object
     *  by immediately calling <code>validateProperties()</code>,
     *  <code>validateSize()</code>, and <code>validateDisplayList()</code>,
     *  if necessary.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  use the <code>addElement()</code> method to add an element to the group,
     *  or when you call the <code>invalidateProperties()</code> method of the element.
     *  Calls to the <code>commitProperties()</code> method occur before calls to the
     *  <code>measure()</code> method. This lets you set property values that might
     *  be used by the <code>measure()</code> method.</p>
     *
     *  <p>Some elements have properties that
     *  interact with each other.
     *  It is often best at startup time to process all of these
     *  properties at one time to avoid duplicating work.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function commitProperties():void
    {
        //trace("GraphicElement.commitProperties displayObject",displayObject,"this",this);
        var updateTransform:Boolean = false;
        var mxTransform:mx.geom.Transform;
        
        // If we are the first in the sequence, setup the displayObject properties
        if (displayObjectSharingMode != DisplayObjectSharingMode.USES_SHARED_OBJECT && displayObject)
        {
            if (colorTransformChanged || displayObjectChanged)
            {
                colorTransformChanged = false;
                if (_colorTransform)
                    displayObject.transform.colorTransform = _colorTransform;
            }
            
            if (alphaChanged || displayObjectChanged)
            {
                alphaChanged = false;
                
                mxTransform = _transform as mx.geom.Transform;
                if (!mxTransform || !mxTransform.applyColorTransformAlpha)
                    displayObject.alpha = _effectiveAlpha;
            }  

            if (blendModeChanged || displayObjectChanged)
            {
                blendModeChanged = false;
                if (_blendMode == "auto" && alpha < 1 && alpha > 0)
                    displayObject.blendMode = BlendMode.LAYER;
                else if (_blendMode == "auto" && alpha == 1 || alpha == 0)
                    displayObject.blendMode = BlendMode.NORMAL;
                else 
                    displayObject.blendMode = _blendMode; 
            }

            if (filtersChanged || displayObjectChanged)
            {
                filtersChanged = false;
                
                // there's a flash player bug...even setting filters to null here
                // causes memory to skyrocket
                if (filtersChanged || _clonedFilters)
                    displayObject.filters = _clonedFilters;
            }

            if (maskChanged || displayObjectChanged)
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
                                UIComponent(parent).childAdded(maskComp);
                            }
                            
                            // Size the mask so that it actually renders
                            maskComp.validateProperties();
                            maskComp.validateSize();
                            // Call this to force the mask to complete initialization
                            maskComp.invalidateDisplayList();
                            maskComp.setActualSize(maskComp.getExplicitOrMeasuredWidth(), 
                                                   maskComp.getExplicitOrMeasuredHeight());
                                                           
                        }   
                        
                        if (!_drawnDisplayObject)
                        {
                            // Clear the original displayObject because it might have previously 
                            // drawn the shape. 
                            if (displayObject is Sprite)
                                Sprite(displayObject).graphics.clear();
                            else if (displayObject is Shape)
                                Shape(displayObject).graphics.clear();
                            
                            // Create a new target for the drawing commands
                            _drawnDisplayObject = new InvalidatingSprite();
                            Sprite(displayObject).addChild(_drawnDisplayObject);
                        }       
                    }
                    
                    drawnDisplayObject.mask = _mask;
                }
            }

            if (maskTypeChanged || displayObjectChanged)
            {
                maskTypeChanged = false;
                applyMaskType();
            }
            
            // If we don't share the DisplayObject, set the property directly.
            // If displayObject has changed and we're sharing, then ensure
            // the visible property is set to true.
            if (displayObjectChanged)
                displayObject.visible = (displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT) ? _effectiveVisibility : true;

            updateTransform = true;
            displayObjectChanged = false;
        }

        if (visibleChanged)
        {
            visibleChanged = false;
            
            // If we don't share the DisplayObject, set the property directly,
            // otherwise redraw.
            if (displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
            {
                displayObject.visible = _effectiveVisibility;
            }
            else
                invalidateDisplayList();
        }

        if ((layoutFeatures == null || layoutFeatures.updatePending) ||
            updateTransform)
        {
            applyComputedTransform();
        }
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function validateSize():void
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
     *  @copy mx.core.UIComponent#canSkipMeasurement
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */    
    protected function canSkipMeasurement():Boolean
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

        if (!canSkipMeasurement())
            measure();
            
        if (!isNaN(explicitMinWidth) && measuredWidth < explicitMinWidth)
            measuredWidth = explicitMinWidth;

        if (!isNaN(explicitMaxWidth) && measuredWidth > explicitMaxWidth)
            measuredWidth = explicitMaxWidth;

        if (!isNaN(explicitMinHeight) && measuredHeight < explicitMinHeight)
            measuredHeight = explicitMinHeight;

        if (!isNaN(explicitMaxHeight) && measuredHeight > explicitMaxHeight)
            measuredHeight = explicitMaxHeight;

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
     *  using the <code>addElement()</code> method, and when the element's
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function validateDisplayList():void
    {
        // FIXME (egeorgie): Turn this off for now because we need to clear all of the DisplayObject
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

        // FIXME (egeorgie): don't clear the graphics if the GraphicElement is invisible and explicitly owns the DO?
        // If we are the first in the sequence, clear the graphics:
        if (displayObjectSharingMode != DisplayObjectSharingMode.USES_SHARED_OBJECT)
        {
            if (drawnDisplayObject is Sprite)
                Sprite(drawnDisplayObject).graphics.clear();
            // TODO (rfrishbe): We don't really support shapes, but we should 
            //else if (drawnDisplayObject is Shape)
                //Shape(drawnDisplayObject).graphics.clear();
        }

        doUpdateDisplayList();

        // If we aren't doing any more invalidation, send out an UpdateComplete event
        if (!invalidatePropertiesFlag && !invalidateSizeFlag && !invalidateDisplayListFlag && wasInvalid)
            dispatchUpdateComplete();
         
        // LAYOUT_DEBUG  
        //LayoutManager.debugHelper.addElement(ILayoutElement(this));
    }
    
    /**
     *  @private
     */
    mx_internal function doUpdateDisplayList():void
    {
        if (_effectiveVisibility || displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
            updateDisplayList(_width, _height);
    }

    /**
     *  Draws the element and/or sizes and positions its content.
     *  This is an advanced method that you might override
     *  when creating a subclass of GraphicElement.
     *
     *  <p>You do not call this method directly. Flex calls the
     *  <code>updateDisplayList()</code> method when the component is added 
     *  to a group using the <code>addElement()</code> method, and when the element's
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    //  Methods: ILayoutElement
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
    public function getMaxBoundsWidth(postLayoutTransform:Boolean = true):Number
    {
        return transformWidthForLayout(maxWidth, maxHeight, postLayoutTransform);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getMaxBoundsHeight(postLayoutTransform:Boolean = true):Number
    {
        return transformHeightForLayout(maxWidth, maxHeight, postLayoutTransform);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getMinBoundsWidth(postLayoutTransform:Boolean = true):Number
    {
        return transformWidthForLayout(minWidth, minHeight, postLayoutTransform);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getMinBoundsHeight(postLayoutTransform:Boolean = true):Number
    {
        return transformHeightForLayout(minWidth, minHeight, postLayoutTransform);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getPreferredBoundsWidth(postLayoutTransform:Boolean = true):Number
    {
        return transformWidthForLayout(preferredWidthPreTransform(),
                                       preferredHeightPreTransform(),
                                       postLayoutTransform);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getPreferredBoundsHeight(postLayoutTransform:Boolean = true):Number
    {
        return transformHeightForLayout(preferredWidthPreTransform(),
                                       preferredHeightPreTransform(),
                                       postLayoutTransform);
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getBoundsXAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
    {
        var strokeExtents:Rectangle = getStrokeExtents(postLayoutTransform);
        var m:Matrix = getComplexMatrix(postLayoutTransform); 
        if (!m)
            return strokeExtents.left + this.measuredX + this.x;

        if (!isNaN(width))
            width -= strokeExtents.width;

        if (!isNaN(height))
            height -= strokeExtents.height;

        // Calculate the width and height pre-transform:
        var newSize:Point = MatrixUtil.fitBounds(width, height, m,
                                                 preferredWidthPreTransform(),
                                                 preferredHeightPreTransform(),
                                                 minWidth, minHeight,
                                                 maxWidth, maxHeight);
        if (!newSize)
            newSize = new Point(minWidth, minHeight);

        var topLeft:Point = new Point(measuredX, measuredY);
        MatrixUtil.transformBounds(newSize, m, topLeft);
        return strokeExtents.left + topLeft.x;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getBoundsYAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
    {
        var strokeExtents:Rectangle = getStrokeExtents(postLayoutTransform);
        var m:Matrix = getComplexMatrix(postLayoutTransform);
        if (!m)
            return strokeExtents.top + this.measuredY + this.y;

        if (!isNaN(width))
            width -= strokeExtents.width;

        if (!isNaN(height))
            height -= strokeExtents.height;

        // Calculate the width and height pre-transform:
        var newSize:Point = MatrixUtil.fitBounds(width, height, m,
                                                 preferredWidthPreTransform(),
                                                 preferredHeightPreTransform(),
                                                 minWidth, minHeight,
                                                 maxWidth, maxHeight);
        if (!newSize)
            newSize = new Point(minWidth, minHeight);

        var topLeft:Point = new Point(measuredX, measuredY);
        MatrixUtil.transformBounds(newSize, m, topLeft);
        return strokeExtents.top + topLeft.y;
    }

    /**
     *  @inheritDoc 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getLayoutBoundsX(postLayoutTransform:Boolean = true):Number
    {
        // Take stroke into account:
        var stroke:Number = getStrokeExtents(postLayoutTransform).left;

        var m:Matrix = getComplexMatrix(postLayoutTransform);
        if (!m)
            return stroke + this.measuredX + this.x;
            
        var topLeft:Point = new Point(measuredX, measuredY);
        MatrixUtil.transformBounds(new Point(_width, _height), m, topLeft);
        return stroke + topLeft.x;
    }

    /**
     *  @inheritDoc 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getLayoutBoundsY(postLayoutTransform:Boolean = true):Number
    {
        // Take stroke into account:
        var stroke:Number = getStrokeExtents(postLayoutTransform).top;

        var m:Matrix = getComplexMatrix(postLayoutTransform);
        if (!m)
            return stroke + this.measuredY + this.y;

        var topLeft:Point = new Point(measuredX, measuredY);
        MatrixUtil.transformBounds(new Point(_width, _height), m, topLeft);
        return stroke + topLeft.y;
    }

    /**
     *  @inheirtDoc 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getLayoutBoundsWidth(postLayoutTransform:Boolean = true):Number
    {
        return transformWidthForLayout(_width, _height, postLayoutTransform);
    }

    /**
     *  @inheritDoc 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getLayoutBoundsHeight(postLayoutTransform:Boolean = true):Number
    {
        return transformHeightForLayout(_width, _height, postLayoutTransform);
    }

    /**
     *  Transform the element's size.
     *  
     *  @param width The target pre-transform width.
     *  
     *  @param height The target pre-transform height.
     *  
     *  @return Returns the transformed width. Transformation is this element's
     *  layout transformation matrix.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function transformWidthForLayout(width:Number,
                                               height:Number,
                                               postLayoutTransform:Boolean = true):Number
    {
        if (postLayoutTransform && hasComplexLayoutMatrix)
            width = MatrixUtil.transformSize(new Point(width, height), 
                                             layoutFeatures.layoutMatrix).x;

        // Take stroke into account
        width += getStrokeExtents(postLayoutTransform).width;
        return width;
    }

    /**
     *  Transform the element's size.
     *  
     *  @param width The target pre-transform width.
     *  
     *  @param height The target pre-transform height.
     *  
     *  @return Returns the transformed height. Transformation is this element's
     *  layout transformation matrix.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function transformHeightForLayout(width:Number,
                                                height:Number,
                                                postLayoutTransform:Boolean = true):Number
    {
        if (postLayoutTransform && hasComplexLayoutMatrix)
            height = MatrixUtil.transformSize(new Point(width, height), 
                                              layoutFeatures.layoutMatrix).y;

        // Take stroke into account
        height += getStrokeExtents(postLayoutTransform).height;
        return height;
    }

    /**
     *  Used for the implementation of the ILayoutElement interface,
     *  returns the explicit of measured width pre-transform.
     */
    protected function preferredWidthPreTransform():Number
    {
        return isNaN(explicitWidth) ? measuredWidth : explicitWidth;
    }

    /**
     *  Used for the implementation of the ILayoutElement interface,
     *  returns the explicit of measured height pre-transform.
     */
    protected function preferredHeightPreTransform():Number
    {
        return isNaN(explicitHeight) ? measuredHeight: explicitHeight;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setLayoutBoundsPosition(newBoundsX:Number, newBoundsY:Number, postLayoutTransform:Boolean = true):void
    {
        var currentBoundsX:Number = getLayoutBoundsX(postLayoutTransform);
        var currentBoundsY:Number = getLayoutBoundsY(postLayoutTransform);

        var currentX:Number = this.x;
        var currentY:Number = this.y;

        var newX:Number = currentX + newBoundsX - currentBoundsX;
        var newY:Number = currentY + newBoundsY - currentBoundsY;

        if (newX != currentX || newY != currentY)
        {
            if(layoutFeatures != null)
            {
                layoutFeatures.layoutX = newX;
                layoutFeatures.layoutY = newY;           

                // note that we don't want to call invalidateTransform, because 
                // this is in the middle of an update pass. Instead, we just note that the 
                // transform has an update pending, so we can apply it later.
                layoutFeatures.updatePending = true;
            }
            else
            {
                _x = newX;
                _y = newY;
            }
            if (newX != currentX)
                dispatchPropertyChangeEvent("x", currentX, newX);
            if (newY != currentY)
                dispatchPropertyChangeEvent("y", currentY, newY);

            invalidateDisplayList();
        }
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setLayoutBoundsSize(width:Number,
                                        height:Number,
                                        postLayoutTransform:Boolean = true):void
    {
		if (!isNaN(width) || !isNaN(height))
		{
	        var strokeExtents:Rectangle = getStrokeExtents(postLayoutTransform);

			if (!isNaN(width))
	           width -= strokeExtents.width;
	        if (!isNaN(height))
	           height -= strokeExtents.height;
		}

        // Calculate the width and height pre-transform:
        var m:Matrix;
        if (postLayoutTransform && hasComplexLayoutMatrix)
            m = layoutFeatures.layoutMatrix;
        if (!m)
        {
            if (isNaN(width))
                width = preferredWidthPreTransform();
            if (isNaN(height))
                height = preferredHeightPreTransform();
        }
        else
        {
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
            
            if (width != oldWidth)
                dispatchPropertyChangeEvent("width", oldWidth, width);
            if (height != oldHeight)
                dispatchPropertyChangeEvent("height", oldHeight, height);

            invalidateDisplayList();
        }
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getLayoutMatrix():Matrix
    {
        // esg: _layoutFeatures keeps a single internal copy of the layoutMatrix.
        // since this is an internal class, we don't need to worry about developers
        // accidentally messing with this matrix, _unless_ we hand it out. Instead,
        // we hand out a clone.
        if(layoutFeatures != null)
            return layoutFeatures.layoutMatrix.clone();
        var m:Matrix = new Matrix();
        m.translate(_x,_y);
        return m;         
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setLayoutMatrix(value:Matrix, invalidateLayout:Boolean):void
    {
        allocateLayoutFeatures();
        var previous:Boolean = needsDisplayObject;
        layoutFeatures.layoutMatrix = value;
        invalidateTransform(previous != needsDisplayObject, invalidateLayout);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getLayoutMatrix3D():Matrix3D
    {
        // esg: _layoutFeatures keeps a single internal copy of the layoutMatrix.
        // since this is an internal class, we don't need to worry about developers
        // accidentally messing with this matrix, _unless_ we hand it out. Instead,
        // we hand out a clone.
        if(layoutFeatures != null)
            return layoutFeatures.layoutMatrix3D.clone();
        var m:Matrix3D = new Matrix3D();
        m.appendTranslation(_x,_y,0);
        return m;           
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setLayoutMatrix3D(value:Matrix3D, invalidateLayout:Boolean):void
    {
        allocateLayoutFeatures();
        var previous:Boolean = needsDisplayObject;
        layoutFeatures.layoutMatrix3D = value;
        invalidateTransform(previous != needsDisplayObject, invalidateLayout);
    }

    /**
     *  @private
     *  Applies the transform to the DisplayObject.
     */
    mx_internal function applyComputedTransform():void
    {   
        if (layoutFeatures != null)
            layoutFeatures.updatePending = false;

        // Only the first elment in the sequence updates the transform
        if (displayObjectSharingMode == DisplayObjectSharingMode.USES_SHARED_OBJECT || !displayObject)
            return;
                                
        if (layoutFeatures != null)
        {           
            if (layoutFeatures.is3D)
            {
                displayObject.transform.matrix3D = layoutFeatures.computedMatrix3D;             
            }
            else
            {
                var m:Matrix = layoutFeatures.computedMatrix.clone();
                // If the displayObject is shared, then put it at 0,0
                if (displayObjectSharingMode == DisplayObjectSharingMode.OWNS_SHARED_OBJECT)
                {
                    m.tx = 0;
                    m.ty = 0;
                }
                displayObject.transform.matrix = m;
            }
        }
        else 
        {
            // If the displayObject is shared, then put it at 0,0
            if (displayObjectSharingMode == DisplayObjectSharingMode.OWNS_SHARED_OBJECT)
            {
                displayObject.x = 0;
                displayObject.y = 0;
            }
            else
            {
                displayObject.x = _x;
                displayObject.y = _y;
            }
        }
    }
    
    mx_internal function getComplexMatrix(performCheck:Boolean):Matrix
    {
        return performCheck && hasComplexLayoutMatrix ? layoutFeatures.layoutMatrix : null;
    }

    static mx_internal var _strokeExtents:Rectangle = new Rectangle();

    /**
     *  Returns the amount of pixels occupied by the stroke on each side
	 *  of the element's bounds.
	 * 
	 *  @param postLayoutTransform - if true, the stroke extents are calculated
	 *  in parent coordinate space (after applying the element's transformations).
	 * 
	 *  @return Rectangle of the stroke extents. The rectangle's <code>left</code>,
	 *  <code>right</code>, <code>top</code> and <code>bottom</code> properties
	 *  represent the stroke extent for the respective side of the element's
	 *  bounding box.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function getStrokeExtents(postLayoutTransform:Boolean = true):Rectangle
    {
        _strokeExtents.x = 0;
        _strokeExtents.y = 0;
        _strokeExtents.width = 0;
        _strokeExtents.height = 0;
        return _strokeExtents;
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Called when a bitmap filter associated with the element is modified.
     */
    private function filterChangedHandler(event:Event):void
    {
        filters = _filters;
    }

}

}

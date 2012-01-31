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

package spark.core
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.PerspectiveProjection;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;

import mx.core.AdvancedLayoutFeatures;
import mx.core.DesignLayer;
import mx.core.FlexSprite;
import mx.core.IFlexModule;
import mx.core.IFlexModuleFactory;
import mx.core.IID;
import mx.core.IInvalidating;
import mx.core.IUIComponent;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.PropertyChangeEvent;
import mx.filters.BaseFilter;
import mx.filters.IBitmapFilter;
import mx.geom.Transform;
import mx.geom.TransformOffsets;
import mx.managers.ILayoutManagerClient;
import mx.utils.MatrixUtil;

import spark.components.ResizeMode;

use namespace mx_internal;

/**
 *  The SpriteVisualElement class is a light-weight Sprite-based implemention
 *  of IVisualElement.  It can be dropped in to Spark containers and be laid
 *  out and renderered correctly.
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class SpriteVisualElement extends FlexSprite
    implements IVisualElement, IID, IFlexModule
{
    /**
     *  Constructor.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function SpriteVisualElement()
    {
        super();
        measure();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    // When changing these constants, make sure you change
    // the constants with the same name in UIComponent
    private static const DEFAULT_MAX_WIDTH:Number = 10000;
    private static const DEFAULT_MAX_HEIGHT:Number = 10000;

    /**
     *  @private
     *  Storage for the original size of the graphic. Initialized in the c-tor.
     */
    private var naturalWidth:Number;
    private var naturalHeight:Number;

    /**
     *  @private
     *  Storage for advanced layout and transform properties.
     */
    private var _layoutFeatures:AdvancedLayoutFeatures;

    /**
     *  @private
     *  When true, the transform on this component consists only of translation.
     *  Otherwise, it may be arbitrarily complex.
     */
    private var hasDeltaIdentityTransform:Boolean = true;

    /**
     *  @private
     *  Storage for the modified Transform object that can dispatch
     *  change events correctly.
     */
    private var _transform:flash.geom.Transform;

    /**
     *  @private
     *  Static point for use in transformPointToParent
     */
    private static var xformPt:Point;

    /**
     *  @private
     *  Initializes the implementation and storage of some of the less
     *  frequently used advanced layout features of a component.
     *  Call this function before attempting to use any of the
     *  features implemented by the AdvancedLayoutFeatures object.
     */
    private function initAdvancedLayoutFeatures():void
    {
        var features:AdvancedLayoutFeatures = new AdvancedLayoutFeatures();

        hasDeltaIdentityTransform = false;

        features.layoutScaleX = scaleX;
        features.layoutScaleY = scaleY;
        features.layoutScaleZ = scaleZ;
        features.layoutRotationX = rotationX;
        features.layoutRotationY = rotationY;
        features.layoutRotationZ = rotation;
        features.layoutX = x;
        features.layoutY = y;
        features.layoutZ = z;

        // Initialize the internal variable last,
        // since the transform getters depend on it.
        _layoutFeatures = features;

        invalidateTransform();
    }

    /**
     *  @private
     *  Makes sure that the computed matrix will be committed.
     */
    private function invalidateTransform():void
    {
        if (_layoutFeatures && _layoutFeatures.updatePending == false)
        {
            _layoutFeatures.updatePending = true;
            applyComputedMatrix();
        }
    }

    /**
     *  @private
     *  Commits the computed matrix built from the combination of the layout
     *  matrix and the transform offsets to the flash displayObject's transform.
     */
    private function applyComputedMatrix():void
    {
        _layoutFeatures.updatePending = false;

        if (_layoutFeatures.is3D)
            super.transform.matrix3D = _layoutFeatures.computedMatrix3D;
        else
            super.transform.matrix = _layoutFeatures.computedMatrix;
    }

    /**
     *  @private
     *  Returns the layout matrix, or null if it only consists of translations.
     */
    protected function nonDeltaLayoutMatrix():Matrix
    {
        if (hasDeltaIdentityTransform)
            return null;
        if (_layoutFeatures != null)
        {
            return _layoutFeatures.layoutMatrix;
        }
        else
        {
            // Lose scale.
            // if scale is actually set (and it's not just our "secret scale"), then
            // layoutFeatures wont' be null and we won't be down here
            return MatrixUtil.composeMatrix(x, y, 1, 1, rotation, 0, 0);
        }
    }

    /**
     *  @private
     *  Resizes the sprite to the specified pre-transform size
     */
    private function setActualSize(width:Number, height:Number):void
    {
        _width = width;
        _height = height;

        if (resizeMode == ResizeMode.NOSCALE)
        {
            // Set the internal scale to 1
            if (_layoutFeatures)
            {
                _layoutFeatures.stretchX = 1;
                _layoutFeatures.stretchY = 1;
                invalidateTransform();
            }
        }
        else
        {
            // Scale from the measured size to the layout size
            var measuredWidth:Number = isNaN(_viewWidth) ? naturalWidth : _viewWidth;
            var measuredHeight:Number = isNaN(_viewHeight) ? naturalHeight : _viewHeight;

            var sx:Number = measuredWidth != 0 ? _width / measuredWidth : 1;
            var sy:Number = measuredHeight != 0 ? _height / measuredHeight : 1;

            if (sx != 1 || sy != 1 || _layoutFeatures)
            {
                if (_layoutFeatures == null)
                    initAdvancedLayoutFeatures();

                _layoutFeatures.stretchX = sx;
                _layoutFeatures.stretchY = sy;
                invalidateTransform();
            }
        }
    }

    /**
     *  @private
     *  Moves the sprite to the specified position, doesn't invalidate parent.
     */
    private function move(x:Number, y:Number):void
    {
        if (_layoutFeatures == null)
        {
            super.x = x;
            super.y = y;
        }
        else
        {
            _layoutFeatures.layoutX = x;
            _layoutFeatures.layoutY = y;
            invalidateTransform();
        }
    }

    /**
     *  @private
     *  Measures the naturalWidth and naturalHeight of the container
     */
    private function measure():void
    {
        var bounds:Rectangle = getBounds(this);
        naturalWidth = Math.max(0, bounds.right);
        naturalHeight = Math.max(0, bounds.bottom);

        // If no explicit size has been set, then update the actual size here.
        // In cases where the FXG is included in a layout, the layout will
        // update the size afterwards because we will invalidate the parent.
        if (isNaN(_explicitWidth))
            _width = naturalWidth;
        
        if (isNaN(_explicitHeight))
            _height = naturalHeight;
    }

    /**
     *  @private
     *  Causes to re-measure the natural width/height
     *  if size changes, parent size is invalidated as well.
     */
    protected function invalidateSize():void
    {
        var curWidth:Number = naturalWidth;
        var curHeight:Number = naturalHeight;

        measure();

        if (curWidth != naturalWidth || curHeight != naturalHeight)
        {
            var parent:DisplayObjectContainer = this.parent;
            if (parent is SpriteVisualElement)
                SpriteVisualElement(parent).invalidateSize();
            else 
                invalidateParentSizeAndDisplayList();
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  postLayoutTransformOffsets
    //----------------------------------

    /**
     *  @copy mx.core.ILayoutElement#postLayoutTransformOffsets
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get postLayoutTransformOffsets():TransformOffsets
    {
        return (_layoutFeatures == null)?
            null :
            _layoutFeatures.postLayoutTransformOffsets;
    }

    /**
     * @private
     */
    public function set postLayoutTransformOffsets(value:TransformOffsets):void
    {
        if (value != null && _layoutFeatures == null)
            initAdvancedLayoutFeatures();

        if (_layoutFeatures.postLayoutTransformOffsets != null)
            _layoutFeatures.postLayoutTransformOffsets.removeEventListener
                (Event.CHANGE,transformOffsetsChangedHandler);
        _layoutFeatures.postLayoutTransformOffsets = value;
        if (_layoutFeatures.postLayoutTransformOffsets != null)
            _layoutFeatures.postLayoutTransformOffsets.addEventListener
                (Event.CHANGE,transformOffsetsChangedHandler);
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
    override public function get alpha():Number
    {
        // Here we roundtrip alpha in the same manner as the
        // player (purposely introducing a rounding error).
        return int(_alpha * 256.0) / 256.0;
    }

    /**
     *  @private
     */
    override public function set alpha(value:Number):void
    {
        if (_alpha != value)
        {
            _alpha = value;

            if (designLayer)
                value = value * designLayer.effectiveAlpha;

            super.alpha = value;
        }
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
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get baselinePosition():Number
    {
        return 0;
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
    //  filters
    //----------------------------------

    /**
     *  @private
     *  Storage for the filters property.
     */
    private var _filters:Array;

    /**
     *  @private
     */
    override public function get filters():Array
    {
        return _filters ? _filters : super.filters;
    }

    /**
     *  @private
     */
    override public function set filters(value:Array):void
    {
        var n:int;
        var i:int;
        var e:IEventDispatcher;

        if (_filters)
        {
            n = _filters.length;
            for (i = 0; i < n; i++)
            {
                e = _filters[i] as IEventDispatcher;
                if (e)
                    e.removeEventListener(BaseFilter.CHANGE, filterChangeHandler);
            }
        }

        _filters = value;

        var clonedFilters:Array = [];
        if (_filters)
        {
            n = _filters.length;
            for (i = 0; i < n; i++)
            {
                if (_filters[i] is IBitmapFilter)
                {
                    e = _filters[i] as IEventDispatcher;
                    if (e)
                        e.addEventListener(BaseFilter.CHANGE, filterChangeHandler);
                    clonedFilters.push(IBitmapFilter(_filters[i]).clone());
                }
                else
                {
                    clonedFilters.push(_filters[i]);
                }
            }
        }

        super.filters = clonedFilters;
    }

    //----------------------------------
    //  height
    //----------------------------------

    private var _explicitHeight:Number = NaN;    // The height explicitly set by the user
    private var _height:Number = 0;                 // The height that's set by the layout

    /**
     *  @private
     */
    [PercentProxy("percentHeight")]
    override public function get height():Number
    {
        return _height;
    }

    /**
     *  @private
     */
    override public function set height(value:Number):void
    {
        // Apply to the current actual size
        _height = value;
        setActualSize(_width, _height);

        // Modify the explicit height
        if (_explicitHeight == value)
            return;

        _explicitHeight = value;
        invalidateParentSizeAndDisplayList();
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
    //  includeInLayout
    //----------------------------------

    /**
     *  @private
     *  Storage for the includeInLayout property.
     */
    private var _includeInLayout:Boolean = true;

    [Inspectable(category="General", defaultValue="true")]

    /**
     *  @copy mx.core.UIComponent#includeInLayout
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

        _includeInLayout = value;
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  depth
    //----------------------------------

    /**
     *  @private
     *  Storage for the depth property.
     */
    private var _depth:Number = 0;

    /**
     *  @copy spark.primitives.supportClasses.GraphicElement#depth
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get depth():Number
    {
        return _depth;
    }

    /**
     *  @private
     */
    public function set depth(value:Number):void
    {
        if (value == _depth)
            return;

        _depth = value;
        if (parent != null && "invalidateLayering" in parent && parent["invalidateLayering"] is Function)
            parent["invalidateLayering"]();
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
    //  id
    //----------------------------------

    /**
     *  @private
     *  Storage for the id property.
     */
    private var _id:String;

    /**
     *  @inheritDoc
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

    //----------------------------------
    //  moduleFactory
    //----------------------------------

    /**
     *  @private
     *  Storage for the moduleFactory property.
     */
    private var _moduleFactory:IFlexModuleFactory;

    [Inspectable(environment="none")]

    /**
     *  A module factory is used as context for using embeded fonts and for
     *  finding the style manager that controls the styles for this
     *  component.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    public function get moduleFactory():IFlexModuleFactory
    {
        return _moduleFactory;
    }

    /**
     *  @private
     */
    public function set moduleFactory(factory:IFlexModuleFactory):void
    {
        var n:int = numChildren;
        for (var i:int = 0; i < n; i++)
        {
            var child:IFlexModule = getChildAt(i) as IFlexModule;
            if (!child)
                continue;

            if (child.moduleFactory == null || child.moduleFactory == _moduleFactory)
            {
                child.moduleFactory = factory;
            }
        }

        _moduleFactory = factory;
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

        super.alpha = _designLayer ? _alpha * _designLayer.effectiveAlpha : _alpha;
        super.visible = _designLayer ? _visible && _designLayer.effectiveVisibility : _visible;
    }

    //----------------------------------
    //  percentHeight
    //----------------------------------

    /**
     *  @private
     *  Storage for the percentHeight property.
     */
    mx_internal var _percentHeight:Number;

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
    mx_internal var _percentWidth:Number;

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
    //  x
    //----------------------------------

    /**
     *  @private
     */
    override public function get x():Number
    {
        return (_layoutFeatures == null) ? super.x : _layoutFeatures.layoutX;
    }

    /**
     *  @private
     */
    override public function set x(value:Number):void
    {
        if (x == value)
            return;

        move(value, y);
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  y
    //----------------------------------

    /**
     *  @private
     */
    override public function get y():Number
    {
        return (_layoutFeatures == null) ? super.y : _layoutFeatures.layoutY;
    }

    /**
     *  @private
     */
    override public function set y(value:Number):void
    {
        if (y == value)
            return;

        move(x, value);
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  z
    //----------------------------------

    override public function get z():Number
    {
        return (_layoutFeatures == null) ? super.z : _layoutFeatures.layoutZ;
    }

    /**
     *  @private
     */
    override public function set z(value:Number):void
    {
        if (z == value)
            return;

        if (_layoutFeatures == null)
            initAdvancedLayoutFeatures();

        hasDeltaIdentityTransform = false;
        _layoutFeatures.layoutZ = value;

        invalidateTransform();
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  rotation
    //----------------------------------

    /**
     *  @private
     */
    override public function get rotation():Number
    {
        return (_layoutFeatures == null) ? super.rotation : _layoutFeatures.layoutRotationZ;
    }

    /**
     *  @private
     */
    override public function set rotation(value:Number):void
    {
        if (rotation == value)
            return;

        hasDeltaIdentityTransform = false;
        if (_layoutFeatures == null)
            super.rotation = MatrixUtil.clampRotation(value);
        else
            _layoutFeatures.layoutRotationZ = value;

        invalidateTransform();
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  rotationX
    //----------------------------------

    /**
     *  Indicates the x-axis rotation of the DisplayObject instance, in degrees,
     *  from its original orientation relative to the 3D parent container.
     *  Values from 0 to 180 represent clockwise rotation; values from 0 to -180
     *  represent counterclockwise rotation. Values outside this range are added
     *  to or subtracted from 360 to obtain a value within the range.
     *
     *  This property is ignored during calculation by any of Flex's 2D layouts.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function get rotationX():Number
    {
        return (_layoutFeatures == null) ? super.rotationX : _layoutFeatures.layoutRotationX;
    }

    /**
     *  @private
     */
    override public function set rotationX(value:Number):void
    {
        if (rotationX == value)
            return;

        if (_layoutFeatures == null)
            initAdvancedLayoutFeatures();
        _layoutFeatures.layoutRotationX = value;
        invalidateTransform();
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  rotationY
    //----------------------------------

    /**
     *  Indicates the y-axis rotation of the DisplayObject instance, in degrees,
     *  from its original orientation relative to the 3D parent container.
     *  Values from 0 to 180 represent clockwise rotation; values from 0 to -180
     *  represent counterclockwise rotation. Values outside this range are added
     *  to or subtracted from 360 to obtain a value within the range.
     *
     *  This property is ignored during calculation by any of Flex's 2D layouts.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function get rotationY():Number
    {
        return (_layoutFeatures == null) ? super.rotationY : _layoutFeatures.layoutRotationY;
    }

    /**
     *  @private
     */
    override public function set rotationY(value:Number):void
    {
        if (rotationY == value)
            return;

        if (_layoutFeatures == null)
            initAdvancedLayoutFeatures();
        _layoutFeatures.layoutRotationY = value;
        invalidateTransform();
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  rotationZ
    //----------------------------------

    /**
     *  @private
     */
    override public function get rotationZ():Number
    {
        return rotation;
    }

    /**
     *  @private
     */
    override public function set rotationZ(value:Number):void
    {
        rotation = value;
    }

    //----------------------------------
    //  scaleX
    //----------------------------------

    /**
     *  @private
     */
    override public function get scaleX():Number
    {
        // if it's been set, layoutFeatures won't be null.  Otherwise, return 1 as
        // super.scaleX might be some other value since we change the width/height
        // through scaling
        return (_layoutFeatures == null) ? 1 : _layoutFeatures.layoutScaleX;
    }

    /**
     *  @private
     */
    override public function set scaleX(value:Number):void
    {
        if (value == scaleX)
            return;

        if (_layoutFeatures == null)
            initAdvancedLayoutFeatures();

        hasDeltaIdentityTransform = false;
        _layoutFeatures.layoutScaleX = value;
        invalidateTransform();
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  scaleY
    //----------------------------------

    /**
     *  @private
     */
    override public function get scaleY():Number
    {
        // if it's been set, layoutFeatures won't be null.  Otherwise, return 1 as
        // super.scaleX might be some other value since we change the width/height
        // through scaling
        return (_layoutFeatures == null) ? 1 : _layoutFeatures.layoutScaleY;
    }

    override public function set scaleY(value:Number):void
    {
        if (value == scaleY)
            return;

        if (_layoutFeatures == null)
            initAdvancedLayoutFeatures();

        hasDeltaIdentityTransform = false;
        _layoutFeatures.layoutScaleY = value;
        invalidateTransform();
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  scaleZ
    //----------------------------------

    /**
     *  @private
     */
    override public function get scaleZ():Number
    {
        return (_layoutFeatures == null) ? super.scaleZ : _layoutFeatures.layoutScaleZ;
    }

    /**
     * @private
     */
    override public function set scaleZ(value:Number):void
    {
        if (scaleZ == value)
            return;

        if (_layoutFeatures == null)
            initAdvancedLayoutFeatures();

        hasDeltaIdentityTransform = false;
        _layoutFeatures.layoutScaleZ = value;
        invalidateTransform();
        invalidateParentSizeAndDisplayList();
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
    //  visible
    //----------------------------------

    /**
     *  @private
     *  Storage for the visible property.
     */
    private var _visible:Boolean = true;

    /**
     *  @inheritDoc
     */
    override public function get visible():Boolean
    {
        return _visible;
    }

    /**
     *  @private
     */
    override public function set visible(value:Boolean):void
    {
        _visible = value;

        if (designLayer && !designLayer.effectiveVisibility)
            value = false;

        if (super.visible == value)
            return;

        super.visible = value;
    }

    //----------------------------------
    //  width
    //----------------------------------

    private var _explicitWidth:Number = NaN;    // The width explicitly set by the user
    private var _width:Number = 0;                // The width that's set by the layout

    /**
     *  @private
     */
    [PercentProxy("percentWidth")]
    override public function get width():Number
    {
        return _width;
    }

    /**
     *  @private
     */
    override public function set width(value:Number):void
    {
        // Apply to the current actual size
        _width = value;
        setActualSize(_width, _height);

        // Modify the explicit width
        if (_explicitWidth == value)
            return;

        _explicitWidth = value;
        invalidateParentSizeAndDisplayList();
    }

    //----------------------------------
    //  viewWidth
    //----------------------------------

    private var _viewWidth:Number = NaN;

    /**
     *  @copy spark.primitives.Graphic#viewWidth
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function set viewWidth(value:Number):void
    {
        _viewWidth = value;
    }

    //----------------------------------
    //  viewHeight
    //----------------------------------

    private var _viewHeight:Number = NaN;

    /**
     *  @copy spark.primitives.Graphic#viewHeight
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function set viewHeight(value:Number):void
    {
        _viewHeight = value;
    }

    //----------------------------------
    //  resizeMode
    //----------------------------------

    private var _resizeMode:String = ResizeMode.SCALE;

    /**
     *  @private
     */
    public function get resizeMode():String
    {
        return _resizeMode;
    }

    /**
     *  @private
     */
    public function set resizeMode(value:String):void
    {
        if (_resizeMode == value)
            return;

        _resizeMode = value;

        // When resize mode changes, reapply the current size,
        // so that the correct scale can be calcualted and applied correctly.
        setActualSize(_width, _height);
    }

    //----------------------------------
    //  transform
    //----------------------------------

    /**
     *  @private
     */
    override public function get transform():flash.geom.Transform
    {
        if (_transform == null)
        {
            setTransform(new mx.geom.Transform(this));
        }
        return _transform;
    }

    /**
     * @private
     */
    override public function set transform(value:flash.geom.Transform):void
    {
        var m:Matrix = value.matrix;
        var m3:Matrix3D =  value.matrix3D;
        var ct:ColorTransform = value.colorTransform;
        var pp:PerspectiveProjection = value.perspectiveProjection;

        var mxTransform:mx.geom.Transform = value as mx.geom.Transform;
        if (mxTransform)
        {
            if (!mxTransform.applyMatrix)
                m = null;

            if (!mxTransform.applyMatrix3D)
                m3 = null;
        }

        setTransform(value);

        if (m != null)
            setLayoutMatrix(m.clone(), true /*triggerLayoutPass*/);
        else if (m3 != null)
            setLayoutMatrix3D(m3.clone(), true /*triggerLayoutPass*/);

        super.transform.colorTransform = ct;
        super.transform.perspectiveProjection = pp;
    }

    /**
     *  @private
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
     *  @private
     */
    mx_internal function get $transform():flash.geom.Transform
    {
        return super.transform;
    }

    /**
     *  Sets the x coordinate for the transform center of the component.
     *
     *  <p>When this object is the target of a Spark transform effect,
     *  you can override this property by setting
     *  the <code>AnimateTransform.autoCenterTransform</code> property.
     *  If <code>autoCenterTransform</code> is <code>false</code>, the transform
     *  center is determined by the <code>transformX</code>,
     *  <code>transformY</code>, and <code>transformZ</code> properties
     *  of the effect target.
     *  If <code>autoCenterTransform</code> is <code>true</code>,
     *  the effect occurs around the center of the target,
     *  <code>(width/2, height/2)</code>.</p>
     *
     *  <p>Setting this property on the Spark effect class
     *  overrides the setting on the target object.</p>
     *
     *  @see spark.effects.AnimateTransform#autoCenterTransform
     *  @see spark.effects.AnimateTransform#transformX
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get transformX():Number
    {
        return (_layoutFeatures == null)? 0 : _layoutFeatures.transformX;
    }

    /**
     *  @private
     */
    public function set transformX(value:Number):void
    {
        if (transformX == value)
            return;
        if (_layoutFeatures == null)
            initAdvancedLayoutFeatures();
        _layoutFeatures.transformX = value;
        invalidateTransform();
        invalidateParentSizeAndDisplayList();
    }

    /**
     *  Sets the y coordinate for the transform center of the component.
     *
     *  <p>When this object is the target of a Spark transform effect,
     *  you can override this property by setting
     *  the <code>AnimateTransform.autoCenterTransform</code> property.
     *  If <code>autoCenterTransform</code> is <code>false</code>, the transform
     *  center is determined by the <code>transformY</code>,
     *  <code>transformY</code>, and <code>transformZ</code> properties
     *  of the effect target.
     *  If <code>autoCenterTransform</code> is <code>true</code>,
     *  the effect occurs around the center of the target,
     *  <code>(width/2, height/2)</code>.</p>
     *
     *  <p>Setting this property on the Spark effect class
     *  overrides the setting on the target object.</p>
     *
     *  @see spark.effects.AnimateTransform#autoCenterTransform
     *  @see spark.effects.AnimateTransform#transformY
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get transformY():Number
    {
        return (_layoutFeatures == null)? 0 : _layoutFeatures.transformY;
    }

    /**
     *  @private
     */
    public function set transformY(value:Number):void
    {
        if (transformY == value)
            return;
        if (_layoutFeatures == null)
            initAdvancedLayoutFeatures();
        _layoutFeatures.transformY = value;
        invalidateTransform();
        invalidateParentSizeAndDisplayList();
    }

    /**
     *  Sets the z coordinate for the transform center of the component.
     *
     *  <p>When this object is the target of a Spark transform effect,
     *  you can override this property by setting
     *  the <code>AnimateTransform.autoCenterTransform</code> property.
     *  If <code>autoCenterTransform</code> is <code>false</code>, the transform
     *  center is determined by the <code>transformZ</code>,
     *  <code>transformY</code>, and <code>transformZ</code> properties
     *  of the effect target.
     *  If <code>autoCenterTransform</code> is <code>true</code>,
     *  the effect occurs around the center of the target,
     *  <code>(width/2, height/2)</code>.</p>
     *
     *  <p>Setting this property on the Spark effect class
     *  overrides the setting on the target object.</p>
     *
     *  @see spark.effects.AnimateTransform#autoCenterTransform
     *  @see spark.effects.AnimateTransform#transformZ
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get transformZ():Number
    {
        return (_layoutFeatures == null)? 0 : _layoutFeatures.transformZ;
    }

    /**
     *  @private
     */
    public function set transformZ(value:Number):void
    {
        if (transformZ == value)
            return;
        if (_layoutFeatures == null)
            initAdvancedLayoutFeatures();
        _layoutFeatures.transformZ = value;
        invalidateTransform();
        invalidateParentSizeAndDisplayList();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function addChild(child:DisplayObject):DisplayObject
    {
        // Do anything that needs to be done before the child is added.
        // In the case of SVE..we just need to deal with text UIComponents
        // and setting them up because this is a "static" object
        addingChild(child);

        super.addChild(child);

        childAdded(child);

        return child;
    }

    /**
     *  @private
     */
    override public function addChildAt(child:DisplayObject,
                                        index:int):DisplayObject
    {
        addingChild(child);

        super.addChildAt(child, index);

        childAdded(child);

        return child;
    }

    /**
     *  @private
     */
    mx_internal function addingChild(child:DisplayObject):void
    {
        // for SVE, we just need to set up the parent and the nestLevel
        if (child is IUIComponent)
            IUIComponent(child).parentChanged(this);

        // Set the nestLevel to "2" since we don't really have a
        // concept of nestLevel for SVE
        if (child is ILayoutManagerClient)
            ILayoutManagerClient(child).nestLevel = 2;
    }

    /**
     *  @private
     */
    mx_internal function childAdded(child:DisplayObject):void
    {
        // for SVE, we just need call initialize()
        if (child is IUIComponent)
        {
            IUIComponent(child).initialize();
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function transformOffsetsChangedHandler(e:Event):void
    {
        invalidateTransform();
    }

    private function get preferredWidth():Number
    {
        if (!isNaN(_explicitWidth))
            return _explicitWidth;
        if (!isNaN(_viewWidth))
            return _viewWidth;
        return naturalWidth;
    }

    private function get preferredHeight():Number
    {
        if (!isNaN(_explicitHeight))
            return _explicitHeight;
        if (!isNaN(_viewHeight))
            return _viewHeight;
        return naturalHeight;
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
                if (newValue != super.visible)
                    super.visible = newValue;
                break;
            }
            case "effectiveAlpha":
            {
                var newAlpha:Number = Number(event.newValue) * _alpha;
                if (newAlpha != super.alpha)
                    super.alpha = newAlpha;
                break;
            }
        }
    }

    /**
     *  @private
     */
    private function filterChangeHandler(event:Event):void
    {
        filters = _filters;
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
        var m:Matrix = postLayoutTransform ? nonDeltaLayoutMatrix() : null;
        if (!m)
            return x;

        var topLeft:Point = new Point(0, 0);
        MatrixUtil.transformBounds(new Point(width, height), m, topLeft);
        return topLeft.x;
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
        var m:Matrix = postLayoutTransform ? nonDeltaLayoutMatrix() : null;
        if (!m)
            return y;

        var topLeft:Point = new Point(0, 0);
        MatrixUtil.transformBounds(new Point(width, height), m, topLeft);
        return topLeft.y;
    }

    /**
     *  @copy mx.core.ILayoutElement#getLayoutBoundsWidth()
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getLayoutBoundsWidth(postLayoutTransform:Boolean = true):Number
    {
        return transformWidthForLayout(width, height, postLayoutTransform);
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
        return transformHeightForLayout(width, height, postLayoutTransform);
    }

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
        return transformWidthForLayout(DEFAULT_MAX_WIDTH, DEFAULT_MAX_HEIGHT, postLayoutTransform);
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
        return transformHeightForLayout(DEFAULT_MAX_WIDTH, DEFAULT_MAX_HEIGHT, postLayoutTransform);
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
        return resizeMode == ResizeMode.SCALE ? 0 : getPreferredBoundsWidth(postLayoutTransform);
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
        return resizeMode == ResizeMode.SCALE ? 0 : getPreferredBoundsHeight(postLayoutTransform);
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
        return transformWidthForLayout(preferredWidth, preferredHeight, postLayoutTransform);
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
        return transformHeightForLayout(preferredWidth, preferredHeight, postLayoutTransform);
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
        var m:Matrix = postLayoutTransform ? nonDeltaLayoutMatrix() : null;
        if (!m)
            return x;

        var topLeft:Point = new Point(0, 0);
        MatrixUtil.transformBounds(new Point(preferredWidth, preferredHeight), m, topLeft);
        return topLeft.x;
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
        var m:Matrix = postLayoutTransform ? nonDeltaLayoutMatrix() : null;
        if (!m)
            return y;

        var topLeft:Point = new Point(0, 0);
        MatrixUtil.transformBounds(new Point(preferredWidth, preferredHeight), m, topLeft);
        return topLeft.y;
    }

    /**
     *  Invalidates parent size and display list if
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

        var p:IInvalidating = parent as IInvalidating;
        if (!p)
            return;

        p.invalidateSize();
        p.invalidateDisplayList();
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

        var xOffset:Number = newBoundsX - currentBoundsX;
        var yOffset:Number = newBoundsY - currentBoundsY;

        if (xOffset != 0 || yOffset != 0)
            move(x + xOffset, y + yOffset);
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
        var m:Matrix = postLayoutTransform ? nonDeltaLayoutMatrix() : null;

        if (!m)
        {
            if (isNaN(width))
                width = preferredWidth;
            if (isNaN(height))
                height = preferredHeight;

            setActualSize(width, height);
            return;
        }

        var fitSize:Point = MatrixUtil.fitBounds(width, height, m,
            preferredWidth,
            preferredHeight,
            getMinBoundsWidth(false),
            getMinBoundsHeight(false),
            getMaxBoundsWidth(false),
            getMaxBoundsWidth(false));

        // If we couldn't fit at all, default to the minimum size
        if (!fitSize)
            setActualSize(preferredWidth, preferredHeight);
        else
            setActualSize(fitSize.x, fitSize.y);
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
        if (_layoutFeatures != null || super.transform.matrix == null)
        {
            // TODO: this is a workaround for a situation in which the
            // object is in 2D, but used to be in 3D and the player has not
            // yet cleaned up the matrices. So the matrix property is null, but
            // the matrix3D property is non-null. layoutFeatures can deal with
            // that situation, so we allocate it here and let it handle it for
            // us. The downside is that we have now allocated layoutFeatures
            // forever and will continue to use it for future situations that
            // might not have required it. Eventually, we should recognize
            // situations when we can de-allocate layoutFeatures and back off
            // to letting the player handle transforms for us.
            if (_layoutFeatures == null)
                initAdvancedLayoutFeatures();

            // esg: _layoutFeatures keeps a single internal copy of the layoutMatrix.
            // since this is an internal class, we don't need to worry about developers
            // accidentally messing with this matrix, _unless_ we hand it out. Instead,
            // we hand out a clone.
            return _layoutFeatures.layoutMatrix.clone();
        }
        else
        {
            // flash also returns copies.
            return super.transform.matrix;
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
    public function setLayoutMatrix(value:Matrix, invalidateLayout:Boolean):void
    {
        hasDeltaIdentityTransform = false;
        
        var previousMatrix:Matrix = _layoutFeatures ? 
            _layoutFeatures.layoutMatrix : super.transform.matrix;
        
        if (_layoutFeatures == null)
        {
            // flash will make a copy of this on assignment.
            super.transform.matrix = value;
        }
        else
        {
            // layout features will internally make a copy of this matrix rather than
            // holding onto a reference to it.
            _layoutFeatures.layoutMatrix = value;
            invalidateTransform();
        }
        
        // Early exit if possible. We don't want to invalidate unnecessarily.
        // We need to do the check here, after our new value has been applied
        // because our matrix components are rounded upon being applied to a
        // DisplayObject.
        if (MatrixUtil.isEqual(previousMatrix, _layoutFeatures ? 
            _layoutFeatures.layoutMatrix : super.transform.matrix))
        {    
            return;
        }
        
        if (invalidateLayout)
            invalidateParentSizeAndDisplayList();
    }

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get hasLayoutMatrix3D():Boolean
    {
        return _layoutFeatures ? _layoutFeatures.layoutIs3D : false;
    }

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get is3D():Boolean
    {
        return _layoutFeatures ? _layoutFeatures.is3D : false;
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
        if (_layoutFeatures == null)
            initAdvancedLayoutFeatures();
        // esg: _layoutFeatures keeps a single internal copy of the layoutMatrix.
        // since this is an internal class, we don't need to worry about developers
        // accidentally messing with this matrix, _unless_ we hand it out. Instead,
        // we hand out a clone.
        return _layoutFeatures.layoutMatrix3D.clone();
    }

    /**
     *  Similarly to the layoutMatrix3D property, sets the layout Matrix3D, but
     *  doesn't trigger a layout pass.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setLayoutMatrix3D(value:Matrix3D, invalidateLayout:Boolean):void
    {
        // Early exit if possible. We don't want to invalidate unnecessarily.
        if (_layoutFeatures && MatrixUtil.isEqual3D(_layoutFeatures.layoutMatrix3D, value))
            return;
        
        if (_layoutFeatures == null)
            initAdvancedLayoutFeatures();
        // layout features will internally make a copy of this matrix rather than
        // holding onto a reference to it.
        _layoutFeatures.layoutMatrix3D = value;
        invalidateTransform();

        if (invalidateLayout)
            invalidateParentSizeAndDisplayList();
    }

    /**
     * @copy mx.core.ILayoutElement#transformAround
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function transformAround(transformCenter:Vector3D,
                                    scale:Vector3D = null,
                                    rotation:Vector3D = null,
                                    translation:Vector3D = null,
                                    postLayoutScale:Vector3D = null,
                                    postLayoutRotation:Vector3D = null,
                                    postLayoutTranslation:Vector3D = null):void
    {
        if (_layoutFeatures == null)
        {
            // TODO (chaase): should provide a way to return to having no
            // layoutFeatures if we call this later with a more trivial
            // situation
            var needAdvancedLayout:Boolean =
                (scale != null && ((!isNaN(scale.x) && scale.x != 1) ||
                    (!isNaN(scale.y) && scale.y != 1) ||
                    (!isNaN(scale.z) && scale.z != 1))) ||
                (rotation != null && ((!isNaN(rotation.x) && rotation.x != 0) ||
                    (!isNaN(rotation.y) && rotation.y != 0) ||
                    (!isNaN(rotation.z) && rotation.z != 0))) ||
                (translation != null && translation.z != 0 && !isNaN(translation.z)) ||
                postLayoutScale != null ||
                postLayoutRotation != null ||
                (postLayoutTranslation != null &&
                    (postLayoutTranslation.x != translation.x ||
                        postLayoutTranslation.y != translation.y ||
                        postLayoutTranslation.z != translation.z));
            if (needAdvancedLayout)
                initAdvancedLayoutFeatures();
        }
        if (_layoutFeatures)
        {
            _layoutFeatures.transformAround(transformCenter, scale, rotation, translation,
                postLayoutScale, postLayoutRotation, postLayoutTranslation);
            invalidateTransform();
            invalidateParentSizeAndDisplayList();
        }
        else
        {
            if (translation == null && transformCenter != null)
            {
                if (xformPt == null)
                    xformPt = new Point();
                xformPt.x = transformCenter.x;
                xformPt.y = transformCenter.y;
                var xformedPt:Point =
                    transform.matrix.transformPoint(xformPt);
            }
            if (rotation != null && !isNaN(rotation.z))
                this.rotation = rotation.z;
            if (scale != null)
            {
                scaleX = scale.x;
                scaleY = scale.y;
            }
            if (transformCenter == null)
            {
                if (translation != null)
                {
                    x = translation.x;
                    y = translation.y;
                }
            }
            else
            {
                if (xformPt == null)
                    xformPt = new Point();
                xformPt.x = transformCenter.x;
                xformPt.y = transformCenter.y;
                var postXFormPoint:Point =
                    transform.matrix.transformPoint(xformPt);
                if (translation != null)
                {
                    x += translation.x - postXFormPoint.x;
                    y += translation.y - postXFormPoint.y;
                }
                else
                {
                    x += xformedPt.x - postXFormPoint.x;
                    y += xformedPt.y - postXFormPoint.y;
                }
            }
        }
    }

    /**
     * A utility method to transform a point specified in the local
     * coordinates of this object to its location in the object's parent's
     * coordinates. The pre-layout and post-layout result will be set on
     * the <code>position</code> and <code>postLayoutPosition</code>
     * parameters, if they are non-null.
     *
     * @param localPosition The point to be transformed, specified in the
     * local coordinates of the object.
     * @position A Vector3D point that will hold the pre-layout
     * result. If null, the parameter is ignored.
     * @postLayoutPosition A Vector3D point that will hold the post-layout
     * result. If null, the parameter is ignored.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function transformPointToParent(localPosition:Vector3D,
                                           position:Vector3D,
                                           postLayoutPosition:Vector3D):void
    {
        if (_layoutFeatures != null)
        {
            _layoutFeatures.transformPointToParent(true, localPosition,
                position, postLayoutPosition);
        }
        else
        {
            if (xformPt == null)
                xformPt = new Point();
            if (localPosition)
            {
                xformPt.x = localPosition.x;
                xformPt.y = localPosition.y;
            }
            else
            {
                xformPt.x = 0;
                xformPt.y = 0;
            }
            var tmp:Point = (transform.matrix != null) ?
                transform.matrix.transformPoint(xformPt) :
                xformPt;
            if (position != null)
            {
                position.x = tmp.x;
                position.y = tmp.y;
                position.z = 0;
            }
            if (postLayoutPosition != null)
            {
                postLayoutPosition.x = tmp.x;
                postLayoutPosition.y = tmp.y;
                postLayoutPosition.z = 0;
            }
        }
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
        if (postLayoutTransform)
        {
            var m:Matrix = nonDeltaLayoutMatrix();
            if (m)
            {
                var size:Point = new Point(width, height);
                width = MatrixUtil.transformSize(size, m).x;
            }
        }

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
        if (postLayoutTransform)
        {
            var m:Matrix = nonDeltaLayoutMatrix();
            if (m)
            {
                var size:Point = new Point(width, height);
                height = MatrixUtil.transformSize(size, m).y;
            }
        }

        return height;
    }
}
}


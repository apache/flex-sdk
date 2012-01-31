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
    
import flash.display.DisplayObjectContainer;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;

import mx.core.FlexSprite;
import mx.core.IInvalidating;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.utils.MatrixUtil;

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
public class SpriteVisualElement extends FlexSprite implements IVisualElement
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
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

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
     *  Storage for the blendMode property.
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
    //  height
    //----------------------------------
    
    private var _explicitHeight:Number = NaN;    // The height explicitly set by the user
    private var _layoutHeight:Number = 0;        // The height that's set by the layout
        
    /**
     *  @private
     */
    [PercentProxy("percentHeight")]
    override public function get height():Number
    {
        return _layoutHeight;
    }
    
    /**
     *  @private
     */
    override public function set height(value:Number):void
    {
        _layoutHeight = value;
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
        if(value == _depth)
            return;

        _depth = value;
        if(parent != null && "invalidateLayering" in parent && parent["invalidateLayering"] is Function)
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
    //  width
    //----------------------------------
    
    private var _explicitWidth:Number = NaN;    // The width explicitly set by the user
    private var _layoutWidth:Number = 0;      // The width that's set by the layout
    
    /**
     *  @private
     */
    [PercentProxy("percentWidth")]
    override public function get width():Number
    {
        return _layoutWidth;
    }
    
    /**
     *  @private
     */
    override public function set width(value:Number):void
    {
        _layoutWidth = value;
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
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    private function get preferredWidth():Number
    {
        if (!isNaN(_explicitWidth))
            return _explicitWidth;
        if (!isNaN(_viewWidth))
            return _viewWidth;
        return super.width;
    }

    private function get preferredHeight():Number
    {
        if (!isNaN(_explicitHeight))
            return _explicitHeight;
        if (!isNaN(_viewHeight))
            return _viewHeight;
        return super.height;
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
        var m:Matrix = postLayoutTransform ? transform.matrix : null;
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
        var m:Matrix = postLayoutTransform ? transform.matrix : null;
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
        return getPreferredBoundsWidth(postLayoutTransform);
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
        return getPreferredBoundsHeight(postLayoutTransform);
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
        return getPreferredBoundsWidth(postLayoutTransform);
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
        return getPreferredBoundsHeight(postLayoutTransform);
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
        var m:Matrix;
        if (!postLayoutTransform)
            m = transform.matrix;
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
        var m:Matrix;
        if (!postLayoutTransform)
            m = transform.matrix;
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

        var newX:Number = x + newBoundsX - currentBoundsX;
        var newY:Number = y + newBoundsY - currentBoundsY;

        if (newX != x || newY != y)
        {
            super.x = newX;
            super.y = newY;
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
        if (postLayoutTransform)
        {
            // If the size is specified post-transform,
            // then always snap to the preferredSize.
            width = preferredWidth;
            height = preferredHeight;
        }
        else
        {
            if (isNaN(width))
                width = preferredWidth;
            if (isNaN(height))
                height = preferredHeight;
        }

        _layoutWidth = width;
        _layoutHeight = height;
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
        // flash returns copies.
        return transform.matrix;       
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
        // flash will make a copy of this on assignment.
        transform.matrix = value;
        
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
    public function getLayoutMatrix3D():Matrix3D
    {
        // flash returns copies.
        return transform.matrix3D;        
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
        // flash will make a copy of this on assignment.
        transform.matrix3D = value;
        
        if (invalidateLayout)
            invalidateParentSizeAndDisplayList();
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
            var m:Matrix = transform.matrix;
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
            var m:Matrix = transform.matrix;
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


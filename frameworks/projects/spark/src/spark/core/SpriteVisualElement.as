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

package mx.core
{
    
import flash.display.DisplayObjectContainer;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;

import mx.core.FlexSprite;
import mx.core.IInvalidating;
import mx.core.IVisualElement;
import mx.utils.MatrixUtil;

/**
 *  The SpriteVisualElement class is a light-weight Sprite-based implemention 
 *  of IVisualElement.  It can be dropped in to Spark containers and be laid 
 *  out and renderered correctly.
 */
public class SpriteVisualElement extends FlexSprite implements IVisualElement
{
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
    
    /**
     *  @private
     */
    [PercentProxy("percentHeight")]
    override public function get height():Number
    {
        return super.height;
    }
    
    /**
     *  @private
     */
    override public function set height(value:Number):void
    {
        if (super.height == value)
            return;
        
        super.height = value;
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
     *  @inheritDoc
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
    //  layer
    //----------------------------------  
    
    /**
     *  @private
     *  Storage for the layer property.
     */
    private var _layer:Number = 0;
    
    /**
     * @inheritDoc
     */
    public function get layer():Number
    {
        return _layer;
    }

    /**
     *  @private
     */
    public function set layer(value:Number):void
    {
        if(value == _layer)
            return;

        _layer = value;
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
    private var _percentHeight:Number;

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
     */
    [PercentProxy("percentWidth")]
    override public function get width():Number
    {
        return super.width;
    }
    
    /**
     *  @private
     */
    override public function set width(value:Number):void
    {
        if (super.width == value)
            return;
        
        super.width = value;
        invalidateParentSizeAndDisplayList();
    }
    
    //----------------------------------
    //  mirror
    //----------------------------------

    private var _mirror:Boolean;
    
    public function get mirror():Boolean
    {
        return _mirror;
    }
    
    public function set mirror(value:Boolean):void
    {
        if (value == _mirror)
            return;
        _mirror = value;            
    }

    //----------------------------------
    //  dir
    //----------------------------------

    public function get dir():String
    {
        return "ltr"
    }
    
    public function set dir(value:String):void
    {
    }
    
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Gets the transformation matrix.
     *  
     *  @return Returns the transformation matrix for this element, or null
     *  if it is delta identity.
     */
    protected function computeMatrix():Matrix
    {
        return transform.matrix;
    }
    
    /**
     *  @inheritDoc 
     */
    public function getLayoutBoundsX(postTransform:Boolean = true):Number
    {
        var m:Matrix = postTransform ? computeMatrix() : null;
        if (!m)
            return x;
            
        var topLeft:Point = new Point(0, 0);
        MatrixUtil.transformBounds(new Point(width, height), m, topLeft);
        return topLeft.x;
    }

    /**
     *  @inheritDoc 
     */
    public function getLayoutBoundsY(postTransform:Boolean = true):Number
    {
        var m:Matrix = postTransform ? computeMatrix() : null;
        if (!m)
            return y;
            
        var topLeft:Point = new Point(0, 0);
        MatrixUtil.transformBounds(new Point(width, height), m, topLeft);
        return topLeft.y;
    }

    /**
     *  @inheirtDoc 
     */
    public function getLayoutBoundsWidth(postTransform:Boolean = true):Number
    {
        return transformWidthForLayout(width, height, postTransform);
    }

    /**
     *  @inheritDoc 
     */
    public function getLayoutBoundsHeight(postTransform:Boolean = true):Number
    {
        return transformHeightForLayout(width, height, postTransform);
    }

    /**
     *  @inheritDoc
     */
    public function getMaxBoundsWidth(postTransform:Boolean = true):Number
    {
        return transformWidthForLayout(width, height, postTransform);
    }

    /**
     *  @inheritDoc
     */
    public function getMaxBoundsHeight(postTransform:Boolean = true):Number
    {
        return transformHeightForLayout(width, height, postTransform);
    }

    /**
     *  @inheritDoc
     */
    public function getMinBoundsWidth(postTransform:Boolean = true):Number
    {
        return transformWidthForLayout(width, height, postTransform);
    }

    /**
     *  @inheritDoc
     */
    public function getMinBoundsHeight(postTransform:Boolean = true):Number
    {
        return transformHeightForLayout(width, height, postTransform);
    }

    /**
     *  @inheritDoc
     */
    public function getPreferredBoundsWidth(postTransform:Boolean = true):Number
    {
        return transformWidthForLayout(width, height, postTransform);
    }

    /**
     *  @inheritDoc
     */
    public function getPreferredBoundsHeight(postTransform:Boolean = true):Number
    {
        return transformHeightForLayout(width, height, postTransform);
    }
    
    /**
     *  Helper method to invalidate parent size and display list if
     *  this object affects its layout (includeInLayout is true).
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
     */
    public function setLayoutBoundsPosition(newBoundsX:Number, newBoundsY:Number, postTransform:Boolean = true):void
    {
        var currentBoundsX:Number = getLayoutBoundsX(postTransform);
        var currentBoundsY:Number = getLayoutBoundsY(postTransform);

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
     */
    public function setLayoutBoundsSize(width:Number = NaN,
                                  height:Number = NaN,
                                  postTransform:Boolean = true):void
    {
        // Calculate the width and height pre-transform:
        var m:Matrix;
        if (postTransform)
            m = computeMatrix();
        if (!m)
        {
            if (isNaN(width))
                width = this.width;
            if (isNaN(height))
                height = this.height;
        }
        else
        {
            var newSize:Point = MatrixUtil.fitBounds(width, height, m,
                                                     this.width,
                                                     this.height,
                                                     this.width, this.height,
                                                     this.width, this.height);

            if (newSize)
            {
                width = newSize.x;
                height = newSize.y;
            }
            else
            {
                width = this.width;
                height = this.height;
            }
        }

        if (this.width != width || this.height != height)
        {
            super.width = width;
            super.height = height;
        }
    }
    
    /**
     *  @inheritDoc
     */
    public function getLayoutMatrix():Matrix
    {
        // flash returns copies.
        return transform.matrix;       
    }

    /**
     *  @inheritDoc
     */
    public function setLayoutMatrix(value:Matrix, triggerLayout:Boolean):void
    {
        // flash will make a copy of this on assignment.
        transform.matrix = value;
        
        if (triggerLayout)
            invalidateParentSizeAndDisplayList();
    }

    /**
     *  @inheritDoc
     */
    public function getLayoutMatrix3D():Matrix3D
    {
        // flash returns copies.
        return transform.matrix3D;        
    }

    /**
     *  @inheritDoc
     */
    public function setLayoutMatrix3D(value:Matrix3D, triggerLayout:Boolean):void
    {
        // flash will make a copy of this on assignment.
        transform.matrix3D = value;
        
        if (triggerLayout)
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
     */
    protected function transformWidthForLayout(width:Number,
                                               height:Number,
                                               postTransform:Boolean = true):Number
    {
        if (postTransform)
        {
            var m:Matrix = computeMatrix();
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
     */
    protected function transformHeightForLayout(width:Number,
                                                height:Number,
                                                postTransform:Boolean = true):Number
    {
        if (postTransform)
        {
            var m:Matrix = computeMatrix();
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


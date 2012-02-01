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

package spark.primitives
{
import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.mx_internal;
import mx.utils.GraphicsUtil;
import mx.utils.MatrixUtil;

import spark.primitives.supportClasses.FilledElement;

use namespace mx_internal;

/**
 *  The Rect class is a filled graphic element that draws a rectangle.
 *  The corners of the rectangle can be rounded. The <code>drawElement()</code> method
 *  calls the <code>Graphics.drawRect()</code> and <code>Graphics.drawRoundRect()</code> 
 *  methods.
 * 
 *  <p><b>Note: </b>By default, the stroke of the border is rounded. 
 *  If you do not want rounded corners, set the <code>joints</code> property of 
 *  the stroke to <code>JointStyle.MITER</code>. </p>
 *  
 *  @see flash.display.Graphics
 *  
 *  @includeExample examples/RectExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Rect extends FilledElement
{
    include "../core/Version.as";

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
    public function Rect()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  bottomLeftRadiusX
    //----------------------------------
    
    private var _bottomLeftRadiusX:Number;
    
    [Inspectable(category="General", minValue="0.0")]
    
    /**
     *  The x radius of the bottom left corner of the rectangle.
     *  
     *  @default NaN
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get bottomLeftRadiusX():Number 
    {
        return _bottomLeftRadiusX;
    }
    
    public function set bottomLeftRadiusX(value:Number):void
    {        
        if (value != _bottomLeftRadiusX)
        {
            _bottomLeftRadiusX = value;
            
            invalidateSize();
            invalidateDisplayList();
            invalidateParentSizeAndDisplayList();
        }
    }
    
    //----------------------------------
    //  bottomLeftRadiusY
    //----------------------------------
    
    private var _bottomLeftRadiusY:Number;
    
    [Inspectable(category="General", minValue="0.0")]
    
    /**
     *  The y radius of the bottom left corner of the rectangle.
     *  
     *  @default NaN
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get bottomLeftRadiusY():Number 
    {
        return _bottomLeftRadiusY;
    }
    
    public function set bottomLeftRadiusY(value:Number):void
    {        
        if (value != _bottomLeftRadiusY)
        {
            _bottomLeftRadiusY = value;
            
            invalidateSize();
            invalidateDisplayList();
            invalidateParentSizeAndDisplayList();
        }
    }
    
    //----------------------------------
    //  bottomRightRadiusX
    //----------------------------------
    
    private var _bottomRightRadiusX:Number;
    
    [Inspectable(category="General", minValue="0.0")]
    
    /**
     *  The x radius of the bottom right corner of the rectangle.
     *  
     *  @default NaN
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get bottomRightRadiusX():Number 
    {
        return _bottomRightRadiusX;
    }
    
    public function set bottomRightRadiusX(value:Number):void
    {        
        if (value != bottomRightRadiusX)
        {
            _bottomRightRadiusX = value;
            
            invalidateSize();
            invalidateDisplayList();
            invalidateParentSizeAndDisplayList();
        }
    }
    
    //----------------------------------
    //  bottomRightRadiusY
    //----------------------------------
    
    private var _bottomRightRadiusY:Number;
    
    [Inspectable(category="General", minValue="0.0")]
    
    /**
     *  The y radius of the bottom right corner of the rectangle.
     *  
     *  @default NaN
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get bottomRightRadiusY():Number 
    {
        return _bottomRightRadiusY;
    }
    
    public function set bottomRightRadiusY(value:Number):void
    {        
        if (value != _bottomRightRadiusY)
        {
            _bottomRightRadiusY = value;
            
            invalidateSize();
            invalidateDisplayList();
            invalidateParentSizeAndDisplayList();
        }
    }
            
    //----------------------------------
    //  radiusX
    //----------------------------------

    private var _radiusX:Number = 0;
    
    [Inspectable(category="General", minValue="0.0")]
    
    /**
     *  The default corner radius to use for the x axis on all corners. The 
     *  <code>topLeftRadiusX</code>, <code>topRightRadiusX</code>, 
     *  <code>bottomLeftRadiusX</code>, and <code>bottomRightRadiusX</code>
     *  properties take precedence over this property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get radiusX():Number 
    {
        return _radiusX;
    }
    
    public function set radiusX(value:Number):void
    {        
        if (value != _radiusX)
        {
            _radiusX = value;

            invalidateSize();
            invalidateDisplayList();
            invalidateParentSizeAndDisplayList();
        }
    }
    
    //----------------------------------
    //  radiusY
    //----------------------------------

    private var _radiusY:Number = 0;
    
    [Inspectable(category="General", minValue="0.0")]
    
    /**
     *  The default corner radius to use for the y axis on all corners. The 
     *  <code>topLeftRadiusY</code>, <code>topRightRadiusY</code>, 
     *  <code>bottomLeftRadiusY</code>, and <code>bottomRightRadiusY</code>
     *  properties take precedence over this property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get radiusY():Number 
    {
        return _radiusY;
    }

    public function set radiusY(value:Number):void
    {        
        if (value != _radiusY)
        {
            _radiusY = value;

            invalidateSize();
            invalidateDisplayList();
            invalidateParentSizeAndDisplayList();
        }
    }
    
    //----------------------------------
    //  topLeftRadiusX
    //----------------------------------
    
    private var _topLeftRadiusX:Number;
    
    [Inspectable(category="General", minValue="0.0")]
    
    /**
     *  The x radius of the top left corner of the rectangle.
     *  
     *  @default NaN
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get topLeftRadiusX():Number 
    {
        return _topLeftRadiusX;
    }
    
    public function set topLeftRadiusX(value:Number):void
    {        
        if (value != _topLeftRadiusX)
        {
            _topLeftRadiusX = value;
            
            invalidateSize();
            invalidateDisplayList();
            invalidateParentSizeAndDisplayList();
        }
    }
    
    //----------------------------------
    //  topLeftRadiusY
    //----------------------------------
    
    private var _topLeftRadiusY:Number;
    
    [Inspectable(category="General", minValue="0.0")]
    
    /**
     *  The y radius of the top left corner of the rectangle.
     *  
     *  @default NaN
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get topLeftRadiusY():Number 
    {
        return _topLeftRadiusY;
    }
    
    public function set topLeftRadiusY(value:Number):void
    {        
        if (value != _topLeftRadiusY)
        {
            _topLeftRadiusY = value;
            
            invalidateSize();
            invalidateDisplayList();
            invalidateParentSizeAndDisplayList();
        }
    }
    
    //----------------------------------
    //  topRightRadiusX
    //----------------------------------
    
    private var _topRightRadiusX:Number;
    
    [Inspectable(category="General", minValue="0.0")]
    
    /**
     *  The x radius of the top right corner of the rectangle.
     *  
     *  @default NaN
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get topRightRadiusX():Number 
    {
        return _topRightRadiusX;
    }
    
    public function set topRightRadiusX(value:Number):void
    {        
        if (value != topRightRadiusX)
        {
            _topRightRadiusX = value;
            
            invalidateSize();
            invalidateDisplayList();
            invalidateParentSizeAndDisplayList();
        }
    }
    
    //----------------------------------
    //  topRightRadiusY
    //----------------------------------
    
    private var _topRightRadiusY:Number;
    
    [Inspectable(category="General", minValue="0.0")]
    
    /**
     *  The y radius of the top right corner of the rectangle.
     *  
     *  @default NaN
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get topRightRadiusY():Number 
    {
        return _topRightRadiusY;
    }
    
    public function set topRightRadiusY(value:Number):void
    {        
        if (value != _topRightRadiusY)
        {
            _topRightRadiusY = value;
            
            invalidateSize();
            invalidateDisplayList();
            invalidateParentSizeAndDisplayList();
        }
    }
        
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
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
    override protected function draw(g:Graphics):void
    {
        // If any of the explicit radiusX values are specified, we have corner-specific rounding.
        if (!isNaN(topLeftRadiusX) || !isNaN(topRightRadiusX) ||
            !isNaN(bottomLeftRadiusX) || !isNaN(bottomRightRadiusX))
        {      
            // All of the fallback rules are implemented in drawRoundRectComplex2().
            GraphicsUtil.drawRoundRectComplex2(g, drawX, drawY, width, height, 
                                               radiusX, radiusY, 
                                               topLeftRadiusX, topLeftRadiusY,
                                               topRightRadiusX, topRightRadiusY,
                                               bottomLeftRadiusX, bottomLeftRadiusY,
                                               bottomRightRadiusX, bottomRightRadiusY);
        }
        else if (radiusX != 0)
        {
            var rX:Number = radiusX;
            var rY:Number =  radiusY == 0 ? radiusX : radiusY;
            g.drawRoundRect(drawX, drawY, width, height, rX * 2, rY * 2);
        }
        else
        {
            g.drawRect(drawX, drawY, width, height);
        }
    }
    
    /**
     *  @private
     */
    override protected function transformWidthForLayout(width:Number,
                                                        height:Number,
                                                        postLayoutTransform:Boolean = true):Number
    {
        if (postLayoutTransform && hasComplexLayoutMatrix)
            width = getRoundRectBoundingBox(width, height, this, 
                                            layoutFeatures.layoutMatrix).width;

        // Take stroke into account
        return width + getStrokeExtents(postLayoutTransform).width;
    }

    /**
     *  @private
     */
    override protected function transformHeightForLayout(width:Number,
                                                         height:Number,
                                                         postLayoutTransform:Boolean = true):Number
    {
        if (postLayoutTransform && hasComplexLayoutMatrix)
            height = getRoundRectBoundingBox(width, height, this, 
                                             layoutFeatures.layoutMatrix).height;

        // Take stroke into account
        return height + getStrokeExtents(postLayoutTransform).height;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function getBoundsXAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
    {
        var strokeExtents:Rectangle = getStrokeExtents(postLayoutTransform);
        var m:Matrix = getComplexMatrix(postLayoutTransform);
        if (!m)
            return strokeExtents.left + this.x;

        if (!isNaN(width))
            width -= strokeExtents.width;

        if (!isNaN(height))
            height -= strokeExtents.height;

        // Calculate the width and height pre-transform:
        var newSize:Point = MatrixUtil.fitBounds(width, height, m,
                                                 explicitWidth, explicitHeight,
                                                 preferredWidthPreTransform(),
                                                 preferredHeightPreTransform(),
                                                 minWidth, minHeight,
                                                 maxWidth, maxHeight);
        if (!newSize)
            newSize = new Point(minWidth, minHeight);

        return strokeExtents.left +
            getRoundRectBoundingBox(newSize.x, newSize.y, this, m).x;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function getBoundsYAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
    {
        var strokeExtents:Rectangle = getStrokeExtents(postLayoutTransform);
        var m:Matrix = getComplexMatrix(postLayoutTransform);
        if (!m)
            return strokeExtents.top + this.y;

        if (!isNaN(width))
            width -= strokeExtents.width;

        if (!isNaN(height))
            height -= strokeExtents.height;

        // Calculate the width and height pre-transform:
        var newSize:Point = MatrixUtil.fitBounds(width, height, m,
                                                 explicitWidth, explicitHeight,
                                                 preferredWidthPreTransform(),
                                                 preferredHeightPreTransform(),
                                                 minWidth, minHeight,
                                                 maxWidth, maxHeight);
        if (!newSize)
            newSize = new Point(minWidth, minHeight);

        return strokeExtents.top +
            getRoundRectBoundingBox(newSize.x, newSize.y, this, m).y;
    }

    /**
     *  @private
     */
    override public function getLayoutBoundsX(postLayoutTransform:Boolean = true):Number
    {
        var stroke:Number = getStrokeExtents(postLayoutTransform).left;
        if (postLayoutTransform && hasComplexLayoutMatrix)
            return stroke + getRoundRectBoundingBox(width, height, this, 
                                                    layoutFeatures.layoutMatrix).x;  

        return stroke + this.x;
    }

    /**
     *  @private
     */
    override public function getLayoutBoundsY(postLayoutTransform:Boolean = true):Number
    {
        var stroke:Number = getStrokeExtents(postLayoutTransform).top;
        if (postLayoutTransform && hasComplexLayoutMatrix)
            return stroke + getRoundRectBoundingBox(width, height, this, 
                                                    layoutFeatures.layoutMatrix).y;

        return stroke + this.y;
    }
    
    /**
     *  @private
     */
    override public function setLayoutBoundsSize(width:Number,
                                                 height:Number,
                                                 postLayoutTransform:Boolean = true):void
    {
        super.setLayoutBoundsSize(width, height, postLayoutTransform);

        var isRounded:Boolean = !isNaN(topLeftRadiusX) || 
                                !isNaN(topRightRadiusX) ||
                                !isNaN(bottomLeftRadiusX) || 
                                !isNaN(bottomRightRadiusX) ||
                                radiusX != 0 ||
                                radiusY != 0;
        if (!isRounded)
            return;

        var m:Matrix = getComplexMatrix(postLayoutTransform);
        if (!m)
            return;
        
        setLayoutBoundsTransformed(width, height, m);
    }

    /**
     *  @private
     */
    private function setLayoutBoundsTransformed(width:Number, height:Number, m:Matrix):void
    {
        var strokeExtents:Rectangle = getStrokeExtents(true);
        width -= strokeExtents.width;
        height -= strokeExtents.height;

        var size:Point = fitLayoutBoundsIterative(width, height, m);
        
        // We couldn't find a solution, try to relax the constraints
        if (!size && !isNaN(width) && !isNaN(height))
        {
            // Try without width constraint
            var size1:Point = fitLayoutBoundsIterative(NaN, height, m);
            
            // Try without height constraint
            var size2:Point = fitLayoutBoundsIterative(width, NaN, m);
            
            // Ignore solutions that will exceeed the requested size
            if (size1 && getRoundRectBoundingBox(size1.x, size1.y, this, m).width > width)
                size1 = null;
            if (size2 && getRoundRectBoundingBox(size2.x, size2.y, this, m).height > height)
                size2 = null;
            
            // Which size was better?
            if (size1 && size2)
            {
                var pickSize1:Boolean = size1.x * size1.y > size2.x * size2.y;

                if (pickSize1)
                    size = size1;
                else
                    size = size2;
            }
            else if (size1)
            {
                size = size1;
            }
            else
            {
                size = size2;
            }
        }
        
        if (size)
            setActualSize(size.x, size.y);
        else
            setActualSize(minWidth, minHeight);
    }
    
    /**
     *  Iteratively approach a solution. Returns 0 if no exact solution exists.
     *  NaN values for width/height mean "not constrained" in that dimesion. 
     * 
     *  @private
     */
    private function fitLayoutBoundsIterative(width:Number, height:Number, m:Matrix):Point
    {
        var newWidth:Number = this.preferredWidthPreTransform();
        var newHeight:Number = this.preferredHeightPreTransform();
        var fitWidth:Number = MatrixUtil.transformBounds(newWidth, newHeight, m).x;
        var fitHeight:Number = MatrixUtil.transformBounds(newWidth, newHeight, m).y;

        if (isNaN(width))
            fitWidth = NaN;
        if (isNaN(height))
            fitHeight = NaN;
        
        var i:int = 0;
        while (i++ < 150)
        {
            var roundedRectBounds:Rectangle = getRoundRectBoundingBox(newWidth, newHeight, this, m);
            
            var widthDifference:Number = isNaN(width) ? 0 : width - roundedRectBounds.width;
            var heightDifference:Number = isNaN(height) ? 0 : height - roundedRectBounds.height;
            
            if (Math.abs(widthDifference) < 0.1 && Math.abs(heightDifference) < 0.1)
            {
                return new Point(newWidth, newHeight);
            }
            
            fitWidth += widthDifference * 0.5;
            fitHeight += heightDifference * 0.5;
            
            var newSize:Point = MatrixUtil.fitBounds(fitWidth, 
                                                     fitHeight, 
                                                     m,
                                                     explicitWidth, 
                                                     explicitHeight,
                                                     preferredWidthPreTransform(),
                                                     preferredHeightPreTransform(),
                                                     minWidth, minHeight,
                                                     maxWidth, maxHeight);
            if (!newSize)
                break;
            
            newWidth = newSize.x;
            newHeight = newSize.y;
        }

        return null;        
    }


    /**
     *  @private
     */
    static private function getRoundRectBoundingBox(width:Number,
                                                    height:Number,
                                                    r:Rect,
                                                    m:Matrix):Rectangle
    {
        // We can find the round rect bounds by finding the 
        // bounds of the four ellipses at the four corners
        
        // Make sure that radiusX & radiusY don't exceed the width & height:
        var maxRadiusX:Number = width / 2;
        var maxRadiusY:Number = height / 2;
        
        var radiusX:Number = r.radiusX;
        var radiusY:Number = r.radiusY == 0 ? radiusX : r.radiusY;
        
        function radiusValue(def:Number, value:Number, max:Number):Number
        {
            var result:Number = isNaN(value) ? def : value;
            return Math.min(result, max);
        }
        
        var boundingBox:Rectangle;
        var rX:Number;
        var rY:Number;

        // top-left corner ellipse
        rX = radiusValue(radiusX, r.topLeftRadiusX, maxRadiusX);
        rY = radiusValue(radiusY, r.topLeftRadiusY, maxRadiusY);
        boundingBox = MatrixUtil.getEllipseBoundingBox(rX, rY, rX, rY, m, boundingBox);
        
        // top-right corner ellipse
        rX = radiusValue(radiusX, r.topRightRadiusX, maxRadiusX);
        rY = radiusValue(radiusY, r.topRightRadiusY, maxRadiusY);
        boundingBox = MatrixUtil.getEllipseBoundingBox(width - rX, rY, rX, rY, m, boundingBox);
        
        // bottom-right corner ellipse
        rX = radiusValue(radiusX, r.bottomRightRadiusX, maxRadiusX);
        rY = radiusValue(radiusY, r.bottomRightRadiusY, maxRadiusY);
        boundingBox = MatrixUtil.getEllipseBoundingBox(width - rX, height - rY, rX, rY, m, boundingBox);
        
        // bottom-left corner ellipse
        rX = radiusValue(radiusX, r.bottomLeftRadiusX, maxRadiusX);
        rY = radiusValue(radiusY, r.bottomLeftRadiusY, maxRadiusY);
        boundingBox = MatrixUtil.getEllipseBoundingBox(rX, height - rY, rX, rY, m, boundingBox);
        
        return boundingBox;
    }
}

}

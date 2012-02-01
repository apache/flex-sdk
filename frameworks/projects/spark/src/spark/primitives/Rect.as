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

package spark.primitives
{
import flash.events.EventDispatcher;
import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.mx_internal;
import mx.utils.MatrixUtil;
import spark.primitives.supportClasses.FilledElement;

/**
 *  The Rect class is a filled graphic element that draws a rectangle.
 *  The corners of the rectangle can be rounded. The <code>drawElementent()</code> method
 *  calls the <code>Graphics.drawRect()</code> and <code>Graphics.drawRoundRect()</code> 
 *  methods.
 *  
 *  @see flash.display.Graphics
 *  
 *  @includeExamples examples/RectExample.mxml
 *  
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
    //  radiusX
    //----------------------------------

    private var _radiusX:Number = 0;
    
    [Inspectable(category="General")]
    
    /**
     *  The corner radius to use along the x axis.
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
    
    [Inspectable(category="General")]
    
    /**
     *  The corner radius to use along the y axis.
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
    override protected function drawElement(g:Graphics):void
    {
        if (radiusX != 0 && radiusY != 0)
            g.drawRoundRect(drawX, drawY, width, height, radiusX * 2, radiusY * 2);
        else
            g.drawRect(drawX, drawY, width, height);
    }
    
    /**
     *  @private
     */
    override protected function transformWidthForLayout(width:Number,
                                                        height:Number,
                                                        postTransform:Boolean = true):Number
    {
        if (postTransform)
        {
            var m:Matrix = computeMatrix();
            if (m)
                width = getRoundRectBoundingBox(width, height, radiusX, radiusY, m).width;
        }

        // Take stroke into account
        return width + getStrokeExtents(postTransform).x;
    }

    /**
     *  @private
     */
    override protected function transformHeightForLayout(width:Number,
                                                         height:Number,
                                                         postTransform:Boolean = true):Number
    {
        if (postTransform)
        {
            var m:Matrix = computeMatrix();
            if (m)
                height = getRoundRectBoundingBox(width, height, radiusX, radiusY, m).height;
        }

        // Take stroke into account
        return height + getStrokeExtents(postTransform).y;
    }

    /**
     *  @private
     */
    override public function getLayoutBoundsX(postTransform:Boolean = true):Number
    {
        var stroke:Number = -getStrokeExtents(postTransform).x * 0.5;
        if (postTransform)
        {
            var m:Matrix = computeMatrix();
            if (m)
                return stroke + getRoundRectBoundingBox(width, height, radiusX, radiusY, m).x;  
        }

        return stroke + this.x;
    }

    /**
     *  @private
     */
    override public function getLayoutBoundsY(postTransform:Boolean = true):Number
    {
        var stroke:Number = - getStrokeExtents(postTransform).y * 0.5;
        if (postTransform)
        {
            var m:Matrix = computeMatrix();
            if (m)
                return stroke + getRoundRectBoundingBox(width, height, radiusX, radiusY, m).y;
        }

        return stroke + this.y;
    }

    /**
     *  @private
     */
    static private function getRoundRectBoundingBox(width:Number,
                                                    height:Number,
                                                    radiusX:Number,
                                                    radiusY:Number,
                                                    m:Matrix):Rectangle
    {
        // We can find the round rect bounds by finding the 
        // bounds of the four ellipses at the four corners
        
        // Make sure that radiusX & radiusY don't exceed the width & height:
        radiusX = Math.min(radiusX, width / 2);
        radiusY = Math.min(radiusY, height / 2);
        
        // TODO EGeorgie: optimize to not allocate a new Rectangle?
        var boundingBox:Rectangle;

        // top-left corner ellipse
        boundingBox = MatrixUtil.getEllipseBoundingBox(radiusX, radiusY, radiusX, radiusY, m, boundingBox);
        // top-right corner ellipse
        boundingBox = MatrixUtil.getEllipseBoundingBox(width - radiusX, radiusY, radiusX, radiusY, m, boundingBox);
        // bottom-right corner ellipse
        boundingBox = MatrixUtil.getEllipseBoundingBox(width - radiusX, height - radiusY, radiusX, radiusY, m, boundingBox);
        // bottom-left corner ellipse
        boundingBox = MatrixUtil.getEllipseBoundingBox(radiusX, height - radiusY, radiusX, radiusY, m, boundingBox);
        
        return boundingBox;
    }
}

}

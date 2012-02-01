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
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;
import mx.utils.MatrixUtil;
import spark.primitives.supportClasses.FilledElement;

/**
 *  The Ellipse class is a filled graphic element that draws an ellipse.
 *  To draw the ellipse, this class calls the <code>Graphics.drawEllipse()</code> 
 *  method.
 *  
 *  @see flash.display.Graphics
 *  
 *  @includeExample examples/EllipseExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Ellipse extends FilledElement
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
    public function Ellipse()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
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
        g.drawEllipse(drawX, drawY, width, height);
    }
    
    /**
     *  @private
     */
    override protected function transformWidthForLayout(width:Number,
                                                        height:Number,
                                                        postLayoutTransform:Boolean = true):Number
    {
        if (postLayoutTransform)
        {
            var m:Matrix = computeMatrix();
            if (m)
                width = MatrixUtil.getEllipseBoundingBox(width / 2, height / 2, width / 2, height / 2, m).width;
        }

        // Take stroke into account
        return width + getStrokeExtents().x;
    }

    /**
     *  @private
     */
    override protected function transformHeightForLayout(width:Number,
                                                         height:Number,
                                                         postLayoutTransform:Boolean = true):Number
    {
        if (postLayoutTransform)
        {
            var m:Matrix = computeMatrix();
            if (m)
                height = MatrixUtil.getEllipseBoundingBox(width / 2, height / 2, width / 2, height / 2, m).height;
        }

        // Take stroke into account
        return height + getStrokeExtents().y;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function getBoundsXAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
    {
        var strokeExtents:Point = getStrokeExtents(postLayoutTransform);
        var m:Matrix = postLayoutTransform ? computeMatrix() : null;
        if (!m)
            return strokeExtents.x * -0.5 + this.x;

        if (!isNaN(width))
            width -= strokeExtents.x;
        if (!isNaN(height))
            height -= strokeExtents.y;

        // Calculate the width and height pre-transform:
        var newSize:Point = MatrixUtil.fitBounds(width, height, m,
                                                 preferredWidthPreTransform(),
                                                 preferredHeightPreTransform(),
                                                 minWidth, minHeight,
                                                 maxWidth, maxHeight);
        if (!newSize)
            newSize = new Point(minWidth, minHeight);

        return strokeExtents.x * -0.5 + 
            MatrixUtil.getEllipseBoundingBox(newSize.x / 2, newSize.y / 2, newSize.x / 2, newSize.y / 2, m).x;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function getBoundsYAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
    {
        var strokeExtents:Point = getStrokeExtents(postLayoutTransform);
        var m:Matrix = postLayoutTransform ? computeMatrix() : null;
        if (!m)
            return strokeExtents.y * -0.5 + this.y;

        if (!isNaN(width))
            width -= strokeExtents.x;
        if (!isNaN(height))
            height -= strokeExtents.y;

        // Calculate the width and height pre-transform:
        var newSize:Point = MatrixUtil.fitBounds(width, height, m,
                                                 preferredWidthPreTransform(),
                                                 preferredHeightPreTransform(),
                                                 minWidth, minHeight,
                                                 maxWidth, maxHeight);
        if (!newSize)
            newSize = new Point(minWidth, minHeight);

        return strokeExtents.y * -0.5 + 
            MatrixUtil.getEllipseBoundingBox(newSize.x / 2, newSize.y / 2, newSize.x / 2, newSize.y / 2, m).y;
    }

    /**
     *  @private
     */
    override public function getLayoutBoundsX(postLayoutTransform:Boolean = true):Number
    {
        var stroke:Number = -getStrokeExtents(postLayoutTransform).x * 0.5;
        
        if (postLayoutTransform)
        {
            var m:Matrix = computeMatrix();
            if (m)
                return stroke + MatrixUtil.getEllipseBoundingBox(width / 2, height / 2, width / 2, height / 2, m).x;
        }
        
        return stroke + this.x;
    }

    /**
     *  @private
     */
    override public function getLayoutBoundsY(postLayoutTransform:Boolean = true):Number
    {
        var stroke:Number = - getStrokeExtents(postLayoutTransform).y * 0.5;

        if (postLayoutTransform)
        {
            var m:Matrix = computeMatrix();
            if (m)
                return stroke + MatrixUtil.getEllipseBoundingBox(width / 2, height / 2, width / 2, height / 2, m).y;
        }

        return stroke + this.y;
    }
}
}

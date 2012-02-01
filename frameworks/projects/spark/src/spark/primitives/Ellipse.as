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

package mx.graphics
{

import flash.events.EventDispatcher;
import flash.display.Graphics;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;

import mx.utils.MatrixUtil;

/**
 *  The Ellipse class is a filled graphic element that draws an ellipse.
 *  To draw the ellipse, this class calls the <code>Graphics.drawEllipse()</code> 
 *  method.
 *  
 *  @see flash.display.Graphics
 *  
 *  @includeExample examples/EllipseExample.mxml
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
                                                        postTransform:Boolean = true):Number
    {
        if (postTransform)
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
                                                         postTransform:Boolean = true):Number
    {
        if (postTransform)
        {
            var m:Matrix = computeMatrix();
            if (m)
                height = MatrixUtil.getEllipseBoundingBox(width / 2, height / 2, width / 2, height / 2, m).height;
        }

        // Take stroke into account
        return height + getStrokeExtents().y;
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
                return stroke + MatrixUtil.getEllipseBoundingBox(width / 2, height / 2, width / 2, height / 2, m).x;
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
                return stroke + MatrixUtil.getEllipseBoundingBox(width / 2, height / 2, width / 2, height / 2, m).y;
        }

        return stroke + this.y;
    }
}
}

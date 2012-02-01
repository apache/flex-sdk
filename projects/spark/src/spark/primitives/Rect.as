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
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.mx_internal;

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
            invalidateDisplayList();
            // No need to invalidateSize() since we don't use radiusX to compute size 
        }
    }
    
    //----------------------------------
    //  radiusY
    //----------------------------------

    private var _radiusY:Number = 0;
    
    [Inspectable(category="General")]
    
    /**
     *  The corner radius to use along the y axis.
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
            invalidateDisplayList();
            // No need to invalidateSize() since we don't use radiusY to compute size 
        }
    }
        
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
        if (radiusX != 0 || radiusY != 0)
            g.drawRoundRect(drawX, drawY, width, height, radiusX * 2, radiusY * 2);
        else
            g.drawRect(drawX, drawY, width, height);
    }

}

}

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

import flash.display.Graphics;
import flash.events.EventDispatcher;
import flash.geom.Rectangle;

/**
 *  The Line class is a graphic element that draws a line between two points.
 *  
 *  <p>The default stroke for a line is undefined; therefore, if you do not specify
 *  the stroke, the line is invisible.</p>
 *  
 *  @see mx.graphics.Stroke
 */
public class Line extends StrokedElement
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
    public function Line()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  xFrom
    //----------------------------------

    private var _xFrom:Number = 0;
    
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
    *  The starting x position for the line.
    *
    *  @default 0
    */
    
    public function get xFrom():Number 
    {
        return _xFrom;
    }
    
    /**
     *  @private 
     */
    public function set xFrom(value:Number):void
    {
        var oldValue:Number = _xFrom;
        
        if (value != oldValue)
        {
            _xFrom = value;
            dispatchPropertyChangeEvent("xFrom", oldValue, value);
            invalidateSize();
        }
    }
    
    //----------------------------------
    //  xTo
    //----------------------------------

    private var _xTo:Number = 0;
    
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
    *  The ending x position for the line.
    *
    *  @default 0
    */
    
    public function get xTo():Number 
    {
        return _xTo;
    }
    
    /**
     *  @private 
     */
    public function set xTo(value:Number):void
    {
        var oldValue:Number = _xTo;
        
        if (value != oldValue)
        {
            _xTo = value;
            dispatchPropertyChangeEvent("xTo", oldValue, value);
            invalidateSize();
        }
    }
    
    //----------------------------------
    //  yFrom
    //----------------------------------

    private var _yFrom:Number = 0;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
    *  The starting y position for the line.
    *
    *  @default 0
    */
    
    public function get yFrom():Number 
    {
        return _yFrom;
    }
    
    /**
     *  @private 
     */
    public function set yFrom(value:Number):void
    {
        var oldValue:Number = _yFrom;
        
        if (value != oldValue)
        {
            _yFrom = value;
            dispatchPropertyChangeEvent("yFrom", oldValue, value);
            invalidateSize();
        }
    }
    
    //----------------------------------
    //  yTo
    //----------------------------------

    private var _yTo:Number = 0;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
    *  The ending y position for the line.
    *
    *  @default 0
    */
    
    public function get yTo():Number 
    {
        return _yTo;
    }
    
    /**
     *  @private 
     */
    public function set yTo(value:Number):void
    {
        var oldValue:Number = _yTo;
        
        if (value != oldValue)
        {
            _yTo = value;
            dispatchPropertyChangeEvent("yTo", oldValue, value);
            invalidateSize();
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
    override protected function skipMeasure():Boolean
    {
        // Since our measure() is quick, we prefer to call it always instead of
        // trying to detect cases where measuredX and measuredY would change.
        return false;
    }

    /**
     *  @inheritDoc
     */
    override protected function measure():void
    {
        measuredWidth = Math.abs(xFrom - xTo);
        measuredHeight = Math.abs(yFrom - yTo);
        measuredX = Math.min(xFrom, xTo);
        measuredY = Math.min(yFrom, yTo);
    }

    /**
     * @inheritDoc
     */
    override protected function drawElement(g:Graphics):void
    {
        var drawToX:Number = xFrom <= xTo ? width : -width;  
        var drawToY:Number = yFrom <= yTo ? height : -height;

        drawToX += xFrom;
        drawToY += yFrom;

        g.moveTo(xFrom + drawX, yFrom + drawY);
        g.lineTo(drawToX + drawX, drawToY + drawY);
    }
}

}

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
import flash.display.Graphics;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.mx_internal;
import mx.events.PropertyChangeEvent;
import mx.graphics.IStroke;

use namespace mx_internal;

/**
 *  The StrokedElement class is the base class for all graphic elements that
 *  have a stroke, including Line, Ellipse, Path, and Rect.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class StrokedElement extends GraphicElement
{
    include "../../core/Version.as";
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
    public function StrokedElement()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  stroke
    //----------------------------------

    /**
     *  @private
     */
    mx_internal var _stroke:IStroke;
    
    [Bindable("propertyChange")]    
    [Inspectable(category="General")]

    /**
     *  The stroke used by this element.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get stroke():IStroke
    {
        return _stroke;
    }
    
    /**
     *  @private
     */
    public function set stroke(value:IStroke):void
    {
        var strokeEventDispatcher:EventDispatcher;
        var oldValue:IStroke = _stroke;
        
        strokeEventDispatcher = _stroke as EventDispatcher;
        if (strokeEventDispatcher)
            strokeEventDispatcher.removeEventListener(
                PropertyChangeEvent.PROPERTY_CHANGE, 
                stroke_propertyChangeHandler);
            
        _stroke = value;
        
        strokeEventDispatcher = _stroke as EventDispatcher;
        if (strokeEventDispatcher)
            strokeEventDispatcher.addEventListener(
                PropertyChangeEvent.PROPERTY_CHANGE, 
                stroke_propertyChangeHandler);
     
     	dispatchPropertyChangeEvent("stroke", oldValue, _stroke);
     
        invalidateDisplayList();
        // Parent layout takes stroke into account
        invalidateParentSizeAndDisplayList();
    }
    
    //--------------------------------------------------------------------------
    //
	//  overridden methods from GraphicElement
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
    override protected function updateDisplayList(unscaledWidth:Number, 
                                                  unscaledHeight:Number):void
    {
        //trace("StrokedElement.updateDisplayList w",unscaledWidth,"h",unscaledHeight,"drawnDisplayObject",drawnDisplayObject,"this",this);                                                     
        if (!drawnDisplayObject || !(drawnDisplayObject is Sprite))
            return;
            
        // The base GraphicElement class has cleared the graphics for us.    
        var g:Graphics = (drawnDisplayObject as Sprite).graphics;

        beginDraw(g);
        draw(g);
        endDraw(g);
    }
            
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Set up the drawing for this element. This is the first of three steps
     *  taken during the drawing process. In this step, the stroke properties
     *  are applied.
     *  
     *  @param g The graphic element to draw.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function beginDraw(g:Graphics):void
    {
        if (stroke)
        {
            var strokeBounds:Rectangle = getStrokeBounds();
            strokeBounds.offset(drawX, drawY);
            stroke.apply(g, strokeBounds, new Point(drawX, drawY));
        }
        else
            g.lineStyle();
            
        // Even though this is a stroked element, we still need to beginFill/endFill
        // otherwise subsequent fills could get messed up.
        g.beginFill(0, 0);
    }

    /**
     *  Draw the element. This is the second of three steps taken during the drawing
     *  process. Override this method to implement your drawing. The stroke
     *  (and fill, if applicable) have been set in the <code>beginDraw()</code> method. 
     *  Your override should only contain calls to drawing methods such as 
     *  <code>moveTo()</code>, <code>curveTo()</code>, and <code>drawRect()</code>.
     *  
     *  @param g The graphic element to draw.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function draw(g:Graphics):void
    {
        // override to do your drawing
    }
    
    /**
     *  Finalize drawing for this element. This is the final of the three steps taken
     *  during the drawing process. In this step, fills are closed.
     *  
     *  @param g The graphics element to finish drawing.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function endDraw(g:Graphics):void
    {
        g.endFill();
    
    }

    /**
     *  @private
     *  Returns the bounds of the element, including stroke in local coordinates.
     */  
    protected function getStrokeBounds():Rectangle
    {
        var strokeBounds:Rectangle = getStrokeExtents(false /*postLayoutTransform*/);
        strokeBounds.x += measuredX;
        strokeBounds.width += width;
        strokeBounds.y += measuredY;
        strokeBounds.height += height;
        return strokeBounds;
    }

    /**
     *  @private
     */  
    override protected function getStrokeExtents(postLayoutTransform:Boolean = true):Rectangle
    {
        // TODO (egeorgie): currently we take only scale into account,
        // but depending on joint style, cap style, etc. we need to take
        // the whole matrix into account as well as examine every line segment...

        if (!stroke)
        {
            _strokeExtents.x      = 0;
            _strokeExtents.y      = 0;
			_strokeExtents.width  = 0;
			_strokeExtents.height = 0;
            return _strokeExtents;
        }

        // Stroke with weight 0 or scaleMode "none" is always drawn
        // at "hairline" thickness, which is exactly one pixel.
        var weight:Number = stroke.weight;
        if (weight == 0)
        {
            _strokeExtents.width  = 1;
            _strokeExtents.height = 1;
			_strokeExtents.x      = -0.5;
			_strokeExtents.y      = -0.5;
            return _strokeExtents;
        }

        var scaleMode:String = stroke.scaleMode;
        if (!scaleMode || scaleMode == LineScaleMode.NONE || !postLayoutTransform)
        {
            _strokeExtents.width  = weight;
            _strokeExtents.height = weight;
			_strokeExtents.x = -weight * 0.5;
			_strokeExtents.y = -weight * 0.5;
            return _strokeExtents;
        }

        var sX:Number = scaleX;
        var sY:Number = scaleY;

        // TODO (egeorgie): stroke thickness depends on all matrix components,
        // not only on scale.
        if (scaleMode == LineScaleMode.NORMAL)
        {
            if (sX  == sY)
                weight *= sX;
            else
                weight *= Math.sqrt(0.5 * (sX * sX + sY * sY));

            _strokeExtents.width  = weight;
            _strokeExtents.height = weight;
			_strokeExtents.x      = weight * -0.5;
			_strokeExtents.y      = weight * -0.5;
            return _strokeExtents;
        }
        else if (scaleMode == LineScaleMode.HORIZONTAL)
        {
            _strokeExtents.width  = weight * sX;
            _strokeExtents.height = weight;
			_strokeExtents.x      = weight * sX * -0.5;
			_strokeExtents.y      = weight * -0.5;
            return _strokeExtents;
        }
        else if (scaleMode == LineScaleMode.VERTICAL)
        {
            _strokeExtents.width  = weight;
            _strokeExtents.height = weight * sY;
			_strokeExtents.x      = weight * -0.5;
			_strokeExtents.y      = weight * sY * -0.5;
            return _strokeExtents;
        }

        return null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  EventHandlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    protected function stroke_propertyChangeHandler(event:PropertyChangeEvent):void
    {
        invalidateDisplayList();
        switch (event.property)
        {
            case "weight":
            case "scaleMode":
                // Parent layout takes stroke weight into account
                invalidateParentSizeAndDisplayList();
            break;
        }
    }

}

}

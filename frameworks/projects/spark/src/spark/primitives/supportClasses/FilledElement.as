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
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.mx_internal;
import mx.events.PropertyChangeEvent;
import mx.graphics.IFill;

use namespace mx_internal;

/**
 *  The FilledElement class is the base class for graphics elements that contain a stroke
 *  and a fill.
 *  This is a base class, and is not used directly in MXML or ActionScript.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class FilledElement extends StrokedElement
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
    public function FilledElement()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  fill
    //----------------------------------

    /**
     *  @private
     */
    protected var _fill:IFill;
    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  The object that defines the properties of the fill.
     *  If not defined, the object is drawn without a fill.
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get fill():IFill
    {
        return _fill;
    }
    
    /**
     *  @private
     */
    public function set fill(value:IFill):void
    {
    	var oldValue:IFill = _fill;
        var fillEventDispatcher:EventDispatcher;
        
        fillEventDispatcher = _fill as EventDispatcher;
        if (fillEventDispatcher)
            fillEventDispatcher.removeEventListener(
                PropertyChangeEvent.PROPERTY_CHANGE, 
                fill_propertyChangeHandler);
            
        _fill = value;
        
        fillEventDispatcher = _fill as EventDispatcher;
        if (fillEventDispatcher)
            fillEventDispatcher.addEventListener(
                PropertyChangeEvent.PROPERTY_CHANGE, 
                fill_propertyChangeHandler);
                
        dispatchPropertyChangeEvent("fill", oldValue, _fill);    
        invalidateDisplayList();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
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
    override protected function beginDraw(g:Graphics):void
    {
        // Don't call super.beginDraw() since it will also set up an 
        // invisible fill.
        
        var origin:Point = new Point(drawX, drawY);
        if (stroke)
        {
            var strokeBounds:Rectangle = getStrokeBounds();
            strokeBounds.offset(drawX, drawY);
            stroke.apply(g, strokeBounds, origin);
        }
        else
            g.lineStyle();

        if (fill)
        {
            var fillBounds:Rectangle = new Rectangle(drawX, drawY, width, height);
            fill.begin(g, fillBounds, origin);
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
    override protected function endDraw(g:Graphics):void
    {
        // Don't call super.endDraw() since it will clear the invisible
        // fill.
        
        if (fill)
            fill.end(g);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function fill_propertyChangeHandler(event:Event):void
    {
        invalidateDisplayList();
    }
}
}

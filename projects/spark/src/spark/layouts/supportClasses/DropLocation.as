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

package spark.layouts.supportClasses
{
import flash.geom.Point;

import mx.core.IVisualElement;
import mx.events.DragEvent;

/**
 *  The DropLocation class contains information describing the drop location
 *  for the dragged data in a drag-and-drop operation. 
 * 
 *  <p>The <code>DropLocation</code> is created by the <code>LayoutBase</code>
 *  class when the <code>List</code> calls the layout's
 *  <code>calculateDropLocation()</code> method in response to a <code>dragOver</code>.</p>
 * 
 *  <p>The DropLocation class is used by the layout for operations such as
 *  calculating the drop indicator bounds and drag-scroll deltas.</p>
 * 
 *  @see spark.layouts.supportClasses.LayoutBase#calculateDropLocation()
 *  @see spark.layouts.supportClasses.LayoutBase#calculateDropIndicatorBounds()
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class DropLocation
{
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function DropLocation()
    {
    }
    
    /**
     *  The <code>DragEvent</code> associated with this location. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var dragEvent:DragEvent = null;
    
    /**
     *  The drop index corresponding to the event.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var dropIndex:int = -1;
    
    /**
     *  The event point in local coordinates of the layout's target.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var dropPoint:Point = null;
}
}

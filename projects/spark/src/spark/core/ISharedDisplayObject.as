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
package spark.core
{
/**
 *  ISharedDisplayObject defines the minimum requirements for a
 *  <code>DisplayObject</code> to be shared between <code>IGraphicElement</code>
 *  objects.
 *
 *  <code>Group</code> uses <code>ISharedDisplayObject</code> to manage
 *  invalidation and redrawing of sequences of <code>IGraphicElement</code>
 *  objects that share a <code>DisplayObject</code>.
 *
 *  Typically when implementing a custom <code>IGraphicElement</code>
 *  Developers also implement this interface for the <code>DisplayObject</code>
 *  that the custom <code>IGraphicElement</code> creates.
 *
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface ISharedDisplayObject
{
    /**
     *  True when any of the <code>IGraphicElement</code> objects, that share
     *  this <code>DisplayObject</code>, needs to redraw.  This is used internally
     *  by the <code>Group</code> class and developers don't typically use this.
     *  The <code>Group</code> sets and reads back this property in order to
     *  determine which graphic elements to validate.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get redrawRequested():Boolean;
    
    /**
     *  @private
     */    
    function set redrawRequested(value:Boolean):void;
}
}
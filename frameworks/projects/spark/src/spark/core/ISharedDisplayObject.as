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
 *  The ISharedDisplayObject interface defines the minimum requirements 
 *  that a DisplayObject must implement to be shared between 
 *  <code>IGraphicElement</code> objects.
 *
 *  The Group class uses the ISharedDisplayObject interface to manage
 *  invalidation and redrawing of sequences of IGraphicElement
 *  objects that share a DisplayObject.
 *
 *  <p>Typically, when implementing a custom IGraphicElement class,
 *  you also implement this interface for the DisplayObject
 *  that the custom IGraphicElement creates.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface ISharedDisplayObject
{
    /**
     *  Contains <code>true</code> when any of the IGraphicElement objects that share
     *  this DisplayObject need to redraw.  
     *  This property is used internally by the Group class 
     *  and you do not typically use it.
     *  The Group class sets and reads back this property to
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
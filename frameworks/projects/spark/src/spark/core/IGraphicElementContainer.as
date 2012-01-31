////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package spark.core
{

/**
 *  The IGraphicElementHost is the minimal contract for a container class to 
 *  support <code>IGraphicElement</code> children.
 *
 *  <p>Typically instead of directly implementing this interface, a developer
 *  would sub-class Group which already implements the IGraphicElementHost interface.</p>
 *  
 *  @see spark.core.IGraphicElement
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
public interface IGraphicElementHost
{
    /**
     *  Notify the host that an element layer has changed.
     *
     *  The <code>IGraphicElementHost</code> must re-evaluates the sequences of 
     *  graphic elements with shared DisplayObjects and may need to re-assign the 
     *  DisplayObjects and redraw the sequences as a result. 
     * 
     *  Typically the host will perform this in its 
     *  <code>validateProperties()</code> method.
     *
     *  @param element The element that has changed size.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    function invalidateGraphicElementSharing(element:IGraphicElement):void

    /**
     *  Notify the host component that an element changed and needs to validate properties.
     * 
     *  The <code>IGraphicElementHost</code> must call the <code>validateProperties()</code>
     *  method on the IGraphicElement to give it a chance to commit its properties.
     * 
     *  Typically the host will validate the elements' properties in its
     *  <code>validateProperties()</code> method.
     *
     *  @param element The element that has changed.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    function invalidateGraphicElementProperties(element:IGraphicElement):void;
    
    /**
     *  Notify the host component that an element size has changed.
     * 
     *  The <code>IGraphicElementHost</code> must call the <code>validateSize()</code>
     *  method on the IGraphicElement to give it a chance to validate its size.
     * 
     *  Typically the host will validate the elements' size in its
     *  <code>validateSize()</code> method.
     *
     *  @param element The element that has changed size.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    function invalidateGraphicElementSize(element:IGraphicElement):void;
    
    /**
     *  Notify the host component that an element has changed and needs to be redrawn.
     * 
     *  The <code>IGraphicElementHost</code> must call the <code>validateDisplayList()</code>
     *  method on the IGraphicElement to give it a chance to redraw.
     * 
     *  Typically the host will validate the elements' display lists in its
     *  <code>validateDisplayList()</code> method.
     *
     *  @param element The element that has changed.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    function invalidateGraphicElementDisplayList(element:IGraphicElement):void;
    
    /**
     *  Removes the <code>DisplayObject</code> of the element from this host's
     *  display list and returns and its index.
     * 
     *  Typically the developer calls <code>detachDisplayObject()</code> before
     *  performing some temporary operation, like taking a snap-shot with a different parent,
     *  after which the developer calls <code>attachDisplayObject()</code> to restore
     *  the display list of the host.
     *
     *  The return value is used as a parameter to a subsequent call to 
     *  the <code>attachDisplayObject()</code> method.
     * 
     *  Note: for performance reasons, the <code>attachDisplayObject()</code> and
     *  <code>detachDisplayObject()</code> methods don't invalidate anything in the
     *  host and it is assumed that they will always be called in pairs -
     *  <code>detachDisplayObject()</code> followed by <code>attachDisplayObject()</code>.
     * 
     *  @param element The element whose <code>DisplayObject</code> will be detached.
     * 
     *  @see #attachDisplayObject 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    function detachDisplayObject(element:IGraphicElement):int;
    
    /**
     *  Re-adds the <code>DisplayObject</code> of the element to this host's
     *  display list.
     * 
     *  Typically the developer calls <code>detachDisplayObject()</code> before
     *  performing some temporary operation, like taking a snap-shot with a different parent,
     *  after which the developer calls <code>attachDisplayObject()</code> to restore
     *  the display list of the host.
     *
     *  Note: for performance reasons, the <code>attachDisplayObject()</code> and
     *  <code>detachDisplayObject()</code> methods don't invalidate anything in the
     *  host and it is assumed that they will always be called in pairs -
     *  <code>detachDisplayObject()</code> followed by <code>attachDisplayObject()</code>.
     *
     *  @param element The element whose <code>DisplayObject</code> will be attached.
     *  @param index The value returned from a preceding call to <code>detachDisplayObject()</code>.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    function attachDisplayObject(element:IGraphicElement, index:int):void
        
    /**
     *  Removes the element's <code>DisplayObject</code> from this <code>IGraphicElementHost</code>
     *  display list.
     *
     *  The host also must ensure that any elements that share the
     *  <code>DisplayObject</code> are redrawn.
     * 
     *  <p>This method doesn't necessarily trigger new <code>DisplayObject</code>
     *  reassignment for the passed in <code>element</code>.
     *
     *  To request new display object reassignment for the element, call the
     *  <code>invalidateGraphicElementSharing()</code> method.</p> 
     *
     *  @param element The graphic element whose display object is discarded.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    function discardDisplayObject(element:IGraphicElement):void;
}
}
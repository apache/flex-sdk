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
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import mx.components.Group;
import mx.core.IVisualElement;

/**
 *  The <code>IGraphicElement</code> is implemented by IVisualElements that
 *  take advantage of the parent <code>Group's</code> <code>DisplayObject</code>
 *  management.
 *
 *  <p>One typical use case is <code>DisplayObject</code> sharing.  
 *  <code>Group</code> organizes its
 *  <code>IGraphicElement</code> children in sequences that share and draw to
 *  the same <code>DisplayObject</code>.
 *  The <code>DisplayObject</code> is created by the first element in the
 *  sequence.</p>
 *
 *  <p>Another use case is when an element does not derrive from
 *  <code>DisplayObject</code> but instead maintains, creates and/or destroys
 *  its own <code>DisplayObject</code>.  The <code>Group</code> will ensure to
 *  call the element to create the <code>DisplayObject</code>, add the
 *  <code>DisplayObject</code> as its child at the correct index as well as
 *  handle its removal.</p> 
 *
 *  Typically a Developer will extend the <code>GraphicElement</code> class
 *  instead of directly implementing the <code>IGraphciElement</code>
 *  interface as <code>GraphicElement</code> already provides most of the
 *  required functionality.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface IGraphicElement extends IVisualElement
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  displayObject
    //----------------------------------

    /**
     *  The shared <code>DisplayObject</code> where this
     *  <code>IGraphicElement</code> is drawn.
     *
     *  The parent <code>Group</code> sets this property to the
     *  <code>DisplayObject</code> created by the first
     *  <code>IGraphicElement</code> in the sequence.
     * 
     *  Implementers should not create the <code>DisplayObject</code>
     *  here, but in <code>createDisplayObject()</code>.
     * 
     *  @see #createDisplayObject
     *  @see #validateDisplayList
     *  @see #shareIndex
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get displayObject():DisplayObject;

    /**
     *  @private
     */
    function set displayObject(value:DisplayObject):void;
    
    //----------------------------------
    //  shareIndex
    //----------------------------------

    /**
     *  The index of this <code>IGraphicElement</code> in the sequence
     *  of elements that share the same <code>DisplayObject</code>.
     * 
     *  A value of -1 indicates that this element doesn't
     *  share its <code>displayObject</code> with other elements and its sequence
     *  doesn't contain any other elements.
     * 
     *  A value of 0 or greater indicates the position of this element in its
     *  sequence.
     * 
     *  A value of 0 also indicates that this element creates the
     *  <code>DisplayObject</code> for its sequence. 
     *
     *  <code>Group</code> sets this index before updating the
     *  <code>displayObject</code> property. 
     * 
     *  @see #displayObject
     *  @see #createDisplayObject
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get shareIndex():int;

    /**
     *  @private 
     */
    function set shareIndex(value:int):void;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Creates a new <code>DisplayObject</code> where this <code>IGraphicElement</code>
     *  is drawn.
     *
     *  After the <code>DisplayObject</code> is created, the parent <code>Group</code>
     *  will assign it to this element's <code>displayObject</code> property as well
     *  update the display objects of all the other elements in the sequence.
     *
     *  Implementers of this method must always create a new DisplayObject instead
     *  of returning the value of the <code>displayObject</code> property.
     *
     *  <code>Group</code> will ensure that this method is called only when needed.
     *
     *  <p>If the element wants to participate in the <code>DisplayObject</code>
     *  sharing, then the new DisplayObject must implement <code>IShareableDisplayObject</code>.
     *  This interface is being used by the Group to manage invalidation and
     *  redrawing of the graphic element sequence and typically is not directly
     *  used by the Developer.</p>
     *
     *  To reevaluate the shared sequences, call the parent <code>Group</code>
     *  <code>graphicElementLayerChanged()</code> method.
     *
     *  To force the <code>Group</code> to discard the element's current
     *  <code>DisplayObject</code> call the parent <code>Group</code>
     *  <code>discardDisplayObject()</code> method.
     *
     *  @return The display object created
     *  @see #displayObject
     *  @see mx.components.Group#graphicElementLayerChanged
     *  @see mx.components.Group#discardDisplayObject
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function createDisplayObject():DisplayObject;
    
    /**
     *  Determines whether this element can draw itself to the
     *  <code>sharedDisplayObject</code> of the sequence.
     * 
     *  <p>Typically implementers will return <code>true</code> when this
     *  <code>IGraphicElement</code> can cumulatively draw in the shared
     *  <code>DisplayObject</code> <code>graphics</code> property.
     *  In all cases where this <code>IGraphicElement</code> needs to set
     *  properties on the <code>DisplayObject</code> that don't apply to the
     *  rest of the elements in the sequence this method must return <code>false</code>.
     *  Examples for such properties are rotation, scale, transform,
     *  mask, alpha, filters, color transform, 3D, layer, etc.</p>
     * 
     *  <p>Note that in certain cases the <code>sharedDisplayObject</code> may be
     *  the parent <code>Group</code> itself.  In the rest of the cases the
     *  <code>DisplayObject</code> is created by the first element in the sequence.</p> 
     *  
     *  <p>When this <code>IGraphicElement</code> needs to rebuild its sequence,
     *  it notifies the parent <code>Group</code> by calling its
     *  <code>graphicElementLayerChanged()</code> method.</p>
     * 
     *  @return Returns true when this <code>IGraphicElement</code> can draw itself
     *  to the shared <code>DisplayObject</code> of the sequence.
     *
     *  @see #closeSequence
     *  @see mx.components.Group#graphicElementLayerChanged
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function canDrawToShared(sharedDisplayObject:DisplayObject):Boolean;
    
    /**
     *  Returns whether the parent <code>Group</code> can append graphic
     *  elements to this element's shared sequence.
     *
     *  This method is called only for elements that already return
     *  <code>true</code> for <code>canDrawToShared()</code>.
     *
     *  <p>This method is useful for the cases where a graphic element uses
     *  the shared <code>DisplayObject</code> in a way that prevents any other
     *  element from using drawing to it.  For example, if a graphic element
     *  adds child display objects to the shared <code>DisplayObject</code>,
     *  it should return false, otherwise any subsequent draws to the
     *  shared <code>DisplayObject</code> will have the incorrect
     *  rendering order.</p>
     *
     *  @return Returns true when this <code>IGraphicElement</code> can
     *  have more elements appended to its shared sequence.
     * 
     *  @see #canDrawToShared
     *  @see mx.components.Group#graphicElementLayerChanged
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */    
    function closeSequence():Boolean;

    /**
     *  Called by <code>Group</code> when an <code>IGraphicElement</code>
     *  is added to or removed from a <code>Group</code>.
     *  Developers typically never need to call this method.
     *
     *  @param parent The parent group of this <code>IGraphicElement</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function parentChanged(parent:Group):void;

    /**
     *  Called by the parent <code>Group</code> to validate the properties of
     *  this element.
     * 
     *  To ensure this method is called, notify the parent <code>Group</code>
     *  by calling its <code>graphicElementPropertiesChanged()</code> method.  
     * 
     *  Note that this method may be called even if this element have not
     *  notified the parent <code>Group</code>.
     * 
     *  @see #validateSize
     *  @see #validateDisplayList
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function validateProperties():void;
    
    /**
     *  Called by the parent <code>Group</code> to validate the size of
     *  this element.
     * 
     *  When the size of the element changes and is going to affect the
     *  parent <code>Group</code> layout, the implementer is responsible
     *  for invalidating the parent's size and display list.
     * 
     *  To ensure this method is called, notify the parent <code>Group</code>
     *  by calling its <code>graphicElementSizeChanged()</code> method.  
     * 
     *  Note that this method may be called even if this element have not
     *  notified the parent <code>Group</code>.
     * 
     *  @see #validateProperties
     *  @see #validateDisplayList
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function validateSize(recursive:Boolean = false):void;
    
    /**
     *  Called by the parent <code>Group</code> to redraw this element
     *  in its <code>displayObject</code> property.
     *
     *  <p>If the element is the first in the sequence (<code>shareIndex</code>
     *  is less than or equal to zero) it must clear the <code>displayObject</code>
     *  graphics and set it up as necessary for drawing the rest of the elements.</p>
     *
     *  <p>The element must alway redraw even if it itself has not changed
     *  since the last time <code>validateDisplayList()</code> was called
     *  as the parent <code>Group</code> will redraw the whole sequence
     *  if any of its elements need to be redrawn.</p>
     * 
     *  <p>To ensure this method is called, notify the parent <code>Group</code>
     *  by calling its <code>graphicElementSizeChanged()</code> method.</p>  
     * 
     *  <p>Note that this method may be called even if this element have not
     *  notified the parent <code>Group</code>.</p>
     * 
     *  @see #displayObject
     *  @see #validateProperties
     *  @see #validateSize
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function validateDisplayList():void;
}
}

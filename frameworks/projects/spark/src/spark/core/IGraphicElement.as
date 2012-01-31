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
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import spark.components.Group;
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
     *  Implementers should not create the <code>DisplayObject</code>
     *  here, but in <code>createDisplayObject()</code>.
     *
     *  @see #createDisplayObject
     *  @see #validateDisplayList
     *  @see #displayObjectSharingMode
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get displayObject():DisplayObject;

    //----------------------------------
    //  displayObjectSharingMode
    //----------------------------------

    /**
     *  Indicates the association between this IGraphicElement and its
     *  display objects.  The Group manages this property and the values
     *  are one of the <code>DisplayObjectSharingMode</code> enum class.
     *
     *  <ul> 
     *    <li>A value of <code>DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT</code>
     *    indicates that the IGraphicElement owns exclusively the
     *    DisplayObject corresponding to its <code>displayObject</code>
     *    property.</li>
     * 
     *    <li>A value of <code>DisplayObjectSharingMode.OWNS_SHARED_OBJECT</code>
     *    indicates taht the IGraphicElement owns the DisplayObject 
     *    corresponding to its <code>displayObject</code> property but
     *    other IGraphicElements are using/drawing to that display object as well.
     *    Depending on the specific implementation, the IGraphicElement may perform
     *    certain management of the display object.
     *    For example the base class <code>GraphicElement</code> 
     *    clears the transform of the display object, reset its visibility, alpha,
     *    etc. properties to their default values and additionally clear the
     *    graphics on every <code>validateDisplayList()</code> call.</li>
     * 
     *    <li>A value of <code>DisplayObjectSharingMode.USES_SHARED_OBJECT</code>
     *    indicates that the IGraphicElement draws into the
     *    DisplayObject corresponding to its <code>displayObject</code>
     *    property. There are one or more IGraphicElements that draw
     *    into that same displayObject, and the first element that draws
     *    has its mode set to <code>DisplayObjectMode.OWNS_SHARED_OBJECT</code></li>
     *  </ul>
     */
     function get displayObjectSharingMode():String;

    /**
     *  @private 
     */
    function set displayObjectSharingMode(value:String):void;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Creates a new <code>DisplayObject</code> where this <code>IGraphicElement</code>
     *  is drawn.
     *  
     *  Subsequent calls to the getter of the <code>displayObject</code> property must
     *  return the same display object.
     *
     *  After the <code>DisplayObject</code> is created, the parent <code>Group</code>
     *  will pass along the display objects to the rest of the elements in the sequence.
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
     *  <code>invalidateGraphicElementSharing()</code> method.
     *
     *  To force the <code>Group</code> to remove the element's current
     *  <code>DisplayObject</code> from its display list and recalculate the
     *  display object sharing, call the parent <code>Group</code>
     *  <code>discardDisplayObject()</code> method.
     *
     *  @return The display object created
     *  @see #displayObject
     *  @see spark.components.Group#invalidateGraphicElementSharing
     *  @see spark.components.Group#discardDisplayObject
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
     *  When this method returns true, subsequent calls to the getter of the
     *  <code>displayObject</code> property must return the same display object.
     *
     *  <p>Note that in certain cases the <code>sharedDisplayObject</code> may be
     *  the parent <code>Group</code> itself.  In the rest of the cases the
     *  <code>DisplayObject</code> is created by the first element in the sequence.</p> 
     *  
     *  <p>When this <code>IGraphicElement</code> needs to rebuild its sequence,
     *  it notifies the parent <code>Group</code> by calling its
     *  <code>invalidateGraphicElementSharing()</code> method.</p>
     * 
     *  @return Returns true when this <code>IGraphicElement</code> can draw itself
     *  to the shared <code>DisplayObject</code> of the sequence.
     *
     *  @see #canShareWithPrevious
     *  @see #canShareWithNext
     *  @see spark.components.Group#invalidateGraphicElementSharing
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function setSharedDisplayObject(sharedDisplayObject:DisplayObject):Boolean;
    
    /**
     *  Return true if this <code>IGraphicElement</code> is compatible and can
     *  share display objects with the previous <code>IGraphicElement</code>
     *  in the sequence.
     * 
     *  <p>Note that in certain cases the element may be passed offered the parent
     *  <code>Group</code> itself in a call to <code>setSharedDisplayObject</code>.
     *  In those cases, this method won't be called.</p>
     * 
     *  @param element The element that comes before this element in the sequence.
     *  @return Returns true when this element is compatible with the previous
     *  element in the sequence.
     * 
     *  @see #canShareWithNext
     *  @see #setSharedDisplayObject 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function canShareWithPrevious(element:IGraphicElement):Boolean;

    /**
     *  Return true if this <code>IGraphicElement</code> is compatible and can
     *  share display objects with the next <code>IGraphicElement</code>
     *  in the sequence.
     * 
     *  @param element The element that comes after this element in the sequence.
     *  @return Returns true when this element is compatible with the previous
     *  element in the sequence.
     * 
     *  @see #canShareWithPrevious
     *  @see #setSharedDisplayObject 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function canShareWithNext(element:IGraphicElement):Boolean;
    
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
     *  by calling its <code>invalidateGraphicElementProperties()</code> method.  
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
     *  by calling its <code>invalidateGraphicElementSize()</code> method.  
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
    function validateSize():void;
    
    /**
     *  Called by the parent <code>Group</code> to redraw this element
     *  in its <code>displayObject</code> property.
     *
     *  <p>If the element is the first in the sequence (<code>displayObjectSharingMode</code>
     *  is set to <code>DisplayObjectSharingMode.OWNS_SHARED_OBJECT</code>)
     *  then it must clear the <code>displayObject</code>
     *  graphics and set it up as necessary for drawing the rest of the elements.</p>
     *
     *  <p>The element must alway redraw even if it itself has not changed
     *  since the last time <code>validateDisplayList()</code> was called
     *  as the parent <code>Group</code> will redraw the whole sequence
     *  if any of its elements need to be redrawn.</p>
     * 
     *  <p>To ensure this method is called, notify the parent <code>Group</code>
     *  by calling its <code>invalidateGraphicElementSize()</code> method.</p>  
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

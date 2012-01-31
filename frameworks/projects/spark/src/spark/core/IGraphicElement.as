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

import mx.core.IVisualElement;

/**
 *  The IGraphicElement is implemented by IVisualElements that
 *  take advantage of the parent <code>IGraphicElementHost</code>
 *  DisplayObject management.
 *
 *  <p>One typical use case is DisplayObject sharing.  
 *  Group, which implements <code>IGraphicElementHost</code>, organizes its
 *  IGraphicElement children in sequences that share and draw to
 *  the same DisplayObject.
 *  The DisplayObject is created by the first element in the
 *  sequence.</p>
 *
 *  <p>Another use case is when an element does not derrive from
 *  DisplayObject but instead maintains, creates and/or destroys
 *  its own DisplayObject. The <code>IGraphicElementHost</code> will ensure to
 *  call the element to create the DisplayObject, add the
 *  DisplayObject as its child at the correct index as well as
 *  handle its removal.</p> 
 *
 *  <p>Typically a developer extends the GraphicElement class
 *  instead of directly implementing the IGraphciElement
 *  interface. The GraphicElement class already provides most of the
 *  required functionality.</p>
 *
 *  @see spark.core.IGraphicElementHost
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
     *  The shared DisplayObject where this
     *  IGraphicElement is drawn.
     *
     *  <p>Implementers should not create the DisplayObject
     *  here, but in the <code>createDisplayObject()</code> method.</p>
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
     *  display objects.  The <code>IGraphicElementHost</code> manages this 
     *  property and the values are one of the DisplayObjectSharingMode enum class.
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
     *    For example the base class GraphicElement 
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
     *  Creates a new DisplayObject where this IGraphicElement
     *  is drawn.
     *  
     *  Subsequent calls to the getter of the <code>displayObject</code> property must
     *  return the same display object.
     *
     *  After the DisplayObject is created, the parent <code>IGraphicElementHost</code>
     *  will pass along the display objects to the rest of the elements in the sequence.
     *
     *  The <code>IGraphicElementHost</code> ensures that this method is called only when needed.
     *
     *  <p>If the element wants to participate in the DisplayObject
     *  sharing, then the new DisplayObject must implement IShareableDisplayObject.
     *  This interface is being used by the <code>IGraphicElementHost</code> to manage invalidation and
     *  redrawing of the graphic element sequence and typically is not directly
     *  used by the Developer.</p>
     *
     *  <p>To reevaluate the shared sequences, call the 
     *  <code>invalidateGraphicElementSharing()</code> method
     *  on the <code>IGraphicElementHost</code>.</p>
     *
     *  <p>To force the <code>IGraphicElementHost</code> to remove the element's current
     *  DisplayObject from its display list and recalculate the
     *  display object sharing, call the
     *  <code>discardDisplayObject()</code> method on the <code>IGraphicElementHost</code>.</p>
     *
     *  @return The display object created.
     * 
     *  @see #displayObject
     *  @see spark.components.IGraphicElementHost#invalidateGraphicElementSharing
     *  @see spark.components.IGraphicElementHost#discardDisplayObject
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
     *  IGraphicElement can cumulatively draw in the shared
     *  DisplayObject <code>graphics</code> property.
     *  In all cases where this IGraphicElement needs to set
     *  properties on the DisplayObjects that don't apply to the
     *  rest of the elements in the sequence, this method must return <code>false</code>.
     *  Examples for such properties are rotation, scale, transform,
     *  mask, alpha, filters, color transform, 3D, and layer.</p>
     *
     *  <p>When this method returns true, subsequent calls to the getter of the
     *  <code>displayObject</code> property must return the same display object.</p>
     *
     *  <p>In certain cases, the <code>sharedDisplayObject</code> property might be
     *  the <code>IGraphicElementHost</code> itself. In the rest of the cases, the
     *  DisplayObject is created by the first element in the sequence.</p> 
     *  
     *  <p>When this IGraphicElement needs to rebuild its sequence,
     *  it notifies the <code>IGraphicElementHost</code> by calling its
     *  <code>invalidateGraphicElementSharing()</code> method.</p>
     * 
     *  @return Returns <code>true</code> when this IGraphicElement can draw itself
     *  to the shared DisplayObject of the sequence.
     *
     *  @see #canShareWithPrevious
     *  @see #canShareWithNext
     *  @see spark.components.IGraphicElementHost#invalidateGraphicElementSharing
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function setSharedDisplayObject(sharedDisplayObject:DisplayObject):Boolean;
    
    /**
     *  Returns <code>true</code> if this IGraphicElement is compatible and can
     *  share display objects with the previous IGraphicElement
     *  in the sequence.
     * 
     *  <p>In certain cases the element might be passed to the <code>IGraphicElementHost</code>
     *  in a call to the <code>setSharedDisplayObject()</code> method.
     *  In those cases, this method is not called.</p>
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
     *  Returns <code>true</code> if this IGraphicElement is compatible and can
     *  share display objects with the next IGraphicElement
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
     *  Called by <code>IGraphicElementHost</code> when an IGraphicElement
     *  is added to or removed from the host.
     *  <p>Developers typically never need to call this method.</p>
     *
     *  @param parent The <code>IGraphicElementHost</code> of this <code>IGraphicElement</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function parentChanged(parent:IGraphicElementHost):void;

    /**
     *  Called by the <code>IGraphicElementHost</code> to validate the properties of
     *  this element.
     * 
     *  <p>To ensure that this method is called, notify the <code>IGraphicElementHost</code>
     *  by calling its <code>invalidateGraphicElementProperties()</code> method.</p>  
     * 
     *  <p>This method might be called even if this element has not
     *  notified the <code>IGraphicElementHost</code>.</p>
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
     *  Called by the <code>IGraphicElementHost</code> to validate the size of
     *  this element.
     * 
     *  <p>When the size of the element changes and is going to affect the
     *  <code>IGraphicElementHost</code> layout, the implementer is responsible
     *  for invalidating the parent's size and display list.</p>
     * 
     *  <p>To ensure that this method is called, notify the <code>IGraphicElementHost</code>
     *  by calling its <code>invalidateGraphicElementSize()</code> method.</p>
     * 
     *  <p>This method might be called even if this element has not
     *  notified the <code>IGraphicElementHost</code>.</p>
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
     *  Called by the <code>IGraphicElementHost</code> to redraw this element
     *  in its <code>displayObject</code> property.
     *
     *  <p>If the element is the first in the sequence (<code>displayObjectSharingMode</code>
     *  is set to <code>DisplayObjectSharingMode.OWNS_SHARED_OBJECT</code>)
     *  then it must clear the <code>displayObject</code>
     *  graphics and set it up as necessary for drawing the rest of the elements.</p>
     *
     *  <p>The element must alway redraw even if it itself has not changed
     *  since the last time the <code>validateDisplayList()</code> method was called.
     *  The parent <code>IGraphicElementHost</code> will redraw the whole sequence
     *  if any of its elements need to be redrawn.</p>
     * 
     *  <p>To ensure this method is called, notify the <code>IGraphicElementHost</code>
     *  by calling its <code>invalidateGraphicElementSize()</code> method.</p>  
     * 
     *  <p>This method might be called even if this element has not
     *  notified the <code>IGraphicElementHost</code>.</p>
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

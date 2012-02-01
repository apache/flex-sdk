////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.events
{

import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import spark.components.IItemRenderer;

/**
 *  ListEvents dispatched by ListBase components like ButtonBar and List
 *  in response to MouseEvents are constructed with
 *  the incoming mouse event's properties.   The list event's x,y location, i.e. the value of
 *  its localX and localY properties, is defined relative to the entire component, not just the 
 *  part of the component that has been scrolled into view.   Similarly, the event's row and column
 *  indices may correspond to a cell that has not been scrolled into view.
 *
 *  @param type Distinguishes the mouse gesture that caused this event to be dispatched.
 *
 *  @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 *
 *  @param cancelable Specifies whether the behavior associated with the event can be prevented.
 * 
 *  @param localX The event's x coordinate relative to the ListBase component.
 * 
 *  @param localY The event's y coordinate relative to ListBase component.
 * 
 *  @param relatedObject The relatedObject property of the MouseEvent that triggered this ListEvent.
 * 
 *  @param ctrlKey Whether the Control key is down.
 * 
 *  @param altKey Whether the Alt key is down.
 * 
 *  @param shiftKey Whether the Shift key is down.
 * 
 *  @param buttonDown Whether the Control key is down.
 * 
 *  @param delta Not used.
 * 
 *  @param item The data provider item at rowIndex.
 * 
 *  @param itemIndex The index of the item in the data provider.
 * 
 *  @param itemRenderer The visible item renderer where the event occurred or null.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5 
 */
public class ListEvent extends MouseEvent
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  The ListEvent.ITEM_ROLL_OUT constant defines the value of the 
     *  <code>type</code> property of the ListEvent object for an
     *  <code>itemRollOut</code> event, which indicates that the user rolled 
     *  the mouse pointer out of a visual item in the control.
     *
     *  <p>The properties of the event object have the following values:</p>
     * 
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>itemIndex</code></td><td>The data provider index of the item displayed 
     *        by the item renderer where the event occurred.</td></tr>
     *     <tr><td><code>item</code></td><td>The data provider item for the item renderer.</td></tr>
     *     <tr><td><code>itemRenderer</code></td><td>The The item renderer that displayed 
     *       this item.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>Type</code></td><td>ListEvent.ITEM_ROLL_OUT</td></tr>
     *  </table>
     *
     *  @eventType itemRollOut
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const ITEM_ROLL_OUT:String = "itemRollOut";

    /**
     *  The ListEvent.ITEM_ROLL_OVER constant defines the value of the 
     *  <code>type</code> property of the ListEvent object for an
     *  <code>itemRollOver</code> event, which indicates that the user rolled 
     *  the mouse pointer over a visual item in the control.
     *
     *  <p>The properties of the event object have the following values:</p>
     * 
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>itemIndex</code></td><td>The data provider index of the item displayed 
     *        by the item renderer where the event occurred.</td></tr>
     *     <tr><td><code>item</code></td><td>The data provider item for the item renderer.</td></tr>
     *     <tr><td><code>itemRenderer</code></td><td>The The item renderer that displayed 
     *       this item.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>Type</code></td><td>ListEvent.ITEM_ROLL_OVER</td></tr>
     *  </table>
     *
     *  @eventType itemRollOver
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const ITEM_ROLL_OVER:String = "itemRollOver";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  Normally called by the Flex control and not used in application code.
     *
     *  @param type The event type; indicates the action that caused the event.
     *
     *  @param bubbles Specifies whether the event can bubble
     *  up the display list hierarchy.
     *
     *  @param cancelable Specifies whether the behavior
     *  associated with the event can be prevented.
     *
     *  @param type Distinguishes the mouse gesture that caused this event to be dispatched.
     *
     *  @param bubbles Specifies whether the event can bubble up the display list hierarchy.
     *
     *  @param cancelable Specifies whether the behavior associated with the event can be prevented.
     * 
     *  @param localX The event's x coordinate relative to the List.
     * 
     *  @param localY The event's y coordinate relative to the List.
     * 
     *  @param relatedObject The <code>relatedObject</code> property of the 
     *  MouseEvent that triggered this ListEvent.
     * 
     *  @param ctrlKey Whether the Control key is down.
     * 
     *  @param altKey Whether the Alt key is down.
     * 
     *  @param shiftKey Whether the Shift key is down.
     * 
     *  @param buttonDown Whether the Control key is down.
     * 
     *  @param delta Not used.
     * 
     *  @param itemIndex The index of the item where the event occurred.
     * 
     *  @param item The data provider item at <code>itemIndex</code>.
     * 
     *  @param itemRenderer The visible item renderer where the event occurred.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function ListEvent(type:String, bubbles:Boolean = false,
                              cancelable:Boolean = false,
                              localX:Number = NaN,
                              localY:Number = NaN,
                              relatedObject:InteractiveObject = null,
                              ctrlKey:Boolean = false,
                              altKey:Boolean = false,
                              shiftKey:Boolean = false,
                              buttonDown:Boolean = false,
                              delta:int = 0,
                              itemIndex:int = -1,
                              item:Object = null,
                              itemRenderer:IItemRenderer = null)
    {
        super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);

        this.itemIndex = itemIndex;
        this.item = item;
        this.itemRenderer = itemRenderer;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  item
    //----------------------------------
    
    /**
     *  The data provider item the item renderer is displaying.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var item:Object;
    
    //----------------------------------
    //  itemRenderer
    //----------------------------------
    
    /**
     *  The item renderer that is displaying the item.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var itemRenderer:IItemRenderer;
    
    //----------------------------------
    //  itemIndex
    //----------------------------------
    
    /**
     *  The index of the data item the item renderer is displaying.
     *  You can access the data provider item using this property. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var itemIndex:int;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: Event
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function clone():Event
    {
        var cloneEvent:ListEvent = new ListEvent(type, bubbles, cancelable, 
            localX, localY, relatedObject,
            ctrlKey, altKey, shiftKey, buttonDown, delta,
            itemIndex, item, itemRenderer);
        
        cloneEvent.relatedObject = this.relatedObject;
        
        return cloneEvent;
    }
}

}

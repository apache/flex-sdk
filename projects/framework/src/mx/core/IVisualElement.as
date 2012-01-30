////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package mx.core
{
import flash.display.DisplayObjectContainer;
import flash.events.IEventDispatcher;
import mx.core.DesignLayer;
import mx.geom.TransformOffsets;

/**
 *  The IVisualElement interface defines the minimum properties and methods 
 *  required for a visual element to be laid out and displayed in a Spark container.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface IVisualElement extends ILayoutElement
{

    /**
     *  The owner of this IVisualElement object. 
     *  By default, it is the parent of this IVisualElement object.
     *  However, if this IVisualElement object is a child component that is
     *  popped up by its parent, such as the drop-down list of a ComboBox control,
     *  the owner is the component that popped up this IVisualElement object.
     *
     *  <p>This property is not managed by Flex, but by each component.
     *  Therefore, if you use the <code>PopUpManger.createPopUp()</code> or
     *  <code>PopUpManger.addPopUp()</code> method to pop up a child component,
     *  you should set the <code>owner</code> property of the child component
     *  to the component that popped it up.</p>
     *
     *  <p>The default value is the value of the <code>parent</code> property.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get owner():DisplayObjectContainer;
    
    /**
     *  @private
     */
    function set owner(value:DisplayObjectContainer):void;
    
    /**
     *  The parent container or component for this component.
     *  Only visual elements should have a <code>parent</code> property.
     *  Non-visual items should use another property to reference
     *  the object to which they belong.
     *  By convention, non-visual objects use an <code>owner</code>
     *  property to reference the object to which they belong.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get parent():DisplayObjectContainer;
    
    /**
     *  Determines the order in which items inside of containers
     *  are rendered. 
     *  Spark containers order their items based on their 
     *  <code>depth</code> property, with the lowest depth in the back, 
     *  and the higher in the front.  
     *  Items with the same depth value appear in the order
     *  they are added to the container.
     * 
     *  @default 0
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function set depth(value:Number):void;
    
    /**
     *  @private
     */
    function get depth():Number;

    /**
     *  Controls the visibility of this visual element. 
     *  If <code>true</code>, the object is visible.
     * 
     *  <p>If an object is not visible, but the <code>includeInLayout</code> 
     *  property is set to <code>true</code>, then the object 
     *  takes up space in the container, but is invisible.</p>
     * 
     *  <p>If <code>visible</code> is set to <code>true</code>, the object may not
     *  necessarily be visible due to its size and whether container clipping 
     *  is enabled.</p>
     * 
     *  <p>Setting <code>visible</code> to <code>false</code>, 
     *  prevents the component from getting focus.</p>
     * 
     *  @default true
     *  @see ILayoutElement#includeInLayout
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get visible():Boolean;
    
    /**
     *  @private
     */
    function set visible(value:Boolean):void;
    
    /**
     *  @copy flash.display.DisplayObject#alpha
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get alpha():Number;
    
    /**
     *  @private
     */
    function set alpha(value:Number):void;


    /**
     *  @copy flash.display.DisplayObject#width
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get width():Number;
    
    /**
     *  @private
     */
    function set width(value:Number):void;

    /**
     *  @copy flash.display.DisplayObject#height
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get height():Number;
    
    /**
     *  @private
     */
    function set height(value:Number):void;

    /**
     *  @copy flash.display.DisplayObject#x
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get x():Number;
    
    /**
     *  @private
     */
    function set x(value:Number):void;


    /**
     *  @copy flash.display.DisplayObject#y
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get y():Number;
    
    /**
     *  @private
     */
    function set y(value:Number):void;
    
    /**
     *  Specifies the optional runtime DesignLayer associated
     *  with this visual element.  
     *
     *  When a DesignLayer is assigned, a visual element 
     *  must listen for "layerPropertyChange" notifications from 
     *  the associated layer parent.  When the "computedAlpha" or
     *  "computedVisibility" of the layer changes, the element must
     *  then compute its own effective visibility (or alpha)
     *  and apply it accordingly. 
     *
     *  This property should not be set within MXML directly.
     *    
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get layer():DesignLayer;
    
    /**
     *  @private
     */
    function set layer(value:DesignLayer):void;
}
}

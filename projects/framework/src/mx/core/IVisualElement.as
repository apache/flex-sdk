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

import mx.geom.TransformOffsets;

/**
 *  The IVisualElement interface represents the common methods and properties between UIComponents and
 *  GraphicElements and the minimum properties/methods required for a visual element to be 
 *  laid out and displayed in a Spark application.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IVisualElement extends ILayoutElement
{

    /**
     *  The owner of this IVisualElement. By default, it is the parent of this IVisualElement.
     *  However, if this IVisualElement object is a child component that is
     *  popped up by its parent, such as the dropdown list of a ComboBox control,
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get owner():DisplayObjectContainer;
    function set owner(value:DisplayObjectContainer):void;
    
    /**
     *  The parent container or component for this component.
     *  Only visual elements should have a parent property.
     *  Non-visual items should use another property to reference
     *  the object to which they belong.
     *  By convention, non-visual item objects use an <code>owner</code>
     *  property to reference the object to which they belong.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get parent():DisplayObjectContainer;
    
	/**
	 * Documentation is not currently available.
     *  Determines the order in which items inside of groups and datagroups 
     *  are rendered. Groups and DataGroups order their items based on their 
     *  layer property, with the lowest layer in the back, and the higher in 
     *  the front.  items with the same layer value will appear in the order
     *  they are added to the Groups item list.
     * 
     *  @default 0
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function set layer(value:Number):void;
	function get layer():Number;

    /**
     *  The y-coordinate of the baseline
     *  of the first line of text of the component.
     *
     *  <p>This property is used to implement
     *  the <code>baseline</code> constraint style.
     *  It is also used to align the label of a FormItem
     *  with the controls in the FormItem.</p>
     *
     *  <p>Each component should override this property.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get baselinePosition():Number;
    
    /**
     *  Controls the visibility of this visual element. If <code>true</code>,
     *  the object is visible.
     * 
     *  <p>If an object is not visible, but <code>includeInLayout</code> is set 
     *  to <code>true</code>, then the object still takes up space as far 
     *  as layout is concerned.</p>
     * 
     *  <p>If <code>visible</code> is set to <code>true</code>, the object may not
     *  necessarily be visible due to its size and whether clipping is turned on 
     *  or not.</p>
     * 
     *  <p>Setting <code>visible</code> to <code>false</code>, should 
     *  disallow the component from getting focus.</p>
     * 
     *  @default true
     *  @see ILayoutElement#includeInLayout
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get visible():Boolean;
    function set visible(value:Boolean):void;

}
}

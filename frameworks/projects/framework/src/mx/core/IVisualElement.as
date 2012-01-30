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
    
import mx.geom.ITransformable;
import mx.geom.TransformOffsets;

/**
 *  The IVisualItem interface represents the common methods and properties between UIComponents and
 *  GraphicElements.
 */
public interface IVisualItem extends ITransformable
{

    /**
     *  The owner of this IVisualItem. By default, it is the parent of this IVisualItem.
     *  However, if this IVisualItem object is a child component that is
     *  popped up by its parent, such as the dropdown list of a ComboBox control,
     *  the owner is the component that popped up this IVisualItem object.
     *
     *  <p>This property is not managed by Flex, but by each component.
     *  Therefore, if you use the <code>PopUpManger.createPopUp()</code> or
     *  <code>PopUpManger.addPopUp()</code> method to pop up a child component,
     *  you should set the <code>owner</code> property of the child component
     *  to the component that popped it up.</p>
     *
     *  <p>The default value is the value of the <code>parent</code> property.</p>
     */
    function get owner():DisplayObjectContainer;
    function set owner(value:DisplayObjectContainer):void;
    
    /**
     *  The parent container or component for this component.
     *  Only visual items should have a parent property.
     *  Non-visual items should use another property to reference
     *  the object to which they belong.
     *  By convention, non-visual item objects use an <code>owner</code>
     *  property to reference the object to which they belong.
     */
    function get parent():DisplayObjectContainer;
    
	/**
	 * Documentation is not currently available.
	 */
	function set layer(value:Number):void;
	function get layer():Number;

    /**
     * Documentation is not currently available.
     */
    function get rotation():Number;
    function set rotation(value:Number):void;

    /**
     * Documentation is not currently available.
     */
    function get transformX():Number;
    function set transformX(value:Number):void;

    /**
     * Documentation is not currently available.
     */
    function get transformY():Number;
    function set transformY(value:Number):void;

    /**
     * Documentation is not currently available.
     */
    function get visible():Boolean;
    function set visible(value:Boolean):void;

    /**
     * Documentation is not currently available.
     */
     function get offsets():TransformOffsets;
     function set offsets(value:TransformOffsets):void;

    /**
     *  The horizontal distance in pixels from the left edge of the component to the
     *  anchor target's left edge.
     *
     *  By default the anchor target is the the container's content area. In layouts
     *  with advanced constraints, the target can be a constraint column.
     *
     *  Setting the property to a number or to a numerical string like "10"
     *  specifies use of the default anchor target.
     *
     *  To spcify an anchor target, set the property value to a string in the format
     *  "anchorTargetName:value" e.g. "col1:10".
     *
     *  @default null
     */
    function get left():Object;
    function set left(value:Object):void;

    /**
     *  The horizontal distance in pixels from the right edge of the component to the
     *  anchor target's right edge.
     *
     *  By default the anchor target is the the container's content area. In layouts
     *  with advanced constraints, the target can be a constraint column.
     *
     *  Setting the property to a number or to a numerical string like "10"
     *  specifies use of the default anchor target.
     *
     *  To spcify an anchor target, set the property value to a string in the format
     *  "anchorTargetName:value" e.g. "col1:10".
     *
     *  @default null
     */
    function get right():Object;
    function set right(value:Object):void;

    /**
     *  The vertical distance in pixels from the top edge of the component to the
     *  anchor target's top edge.
     *
     *  By default the anchor target is the the container's content area. In layouts
     *  with advanced constraints, the target can be a constraint row.
     *
     *  Setting the property to a number or to a numerical string like "10"
     *  specifies use of the default anchor target.
     *
     *  To spcify an anchor target, set the property value to a string in the format
     *  "anchorTargetName:value" e.g. "row1:10".
     *
     *  @default null
     */
    function get top():Object;
    function set top(value:Object):void;

    /**
     *  The vertical distance in pixels from the bottom edge of the component to the
     *  anchor target's bottom edge.
     *
     *  By default the anchor target is the the container's content area. In layouts
     *  with advanced constraints, the target can be a constraint row.
     *
     *  Setting the property to a number or to a numerical string like "10"
     *  specifies use of the default anchor target.
     *
     *  To spcify an anchor target, set the property value to a string in the format
     *  "anchorTargetName:value" e.g. "row1:10".
     *
     *  @default null
     */
    function get bottom():Object;
    function set bottom(value:Object):void;

    /**
     *  The horizontal distance in pixels from the center of the component to the
     *  center of the anchor target's content area.
     *
     *  The default anchor target is the container itself.
     *
     *  In layouts with advanced constraints, the anchor target can be a constraint column.
     *  Then the content area is the space between the preceeding column
     *  (or container side) and the target column.
     *
     *  Setting the property to a number or to a numerical string like "10"
     *  specifies use of the default anchor target.
     *
     *  To specify an anchor target, set the property value to a string in the format
     *  "constraintColumnId:value" e.g. "col1:10".
     *
     *  @default null
     */
    function get horizontalCenter():Object;
    function set horizontalCenter(value:Object):void;

    /**
     *  The vertical distance in pixels from the center of the component to the
     *  center of the anchor target's content area.
     *
     *  The default anchor target is the container itself.
     *
     *  In layouts with advanced constraints, the anchor target can be a constraint row.
     *  Then the content area is the space between the preceeding row
     *  (or container side) and the target row.
     *
     *  Setting the property to a number or to a numerical string like "10"
     *  specifies use of the default anchor target.
     *
     *  To specify an anchor target, set the property value to a string in the format
     *  "constraintColumnId:value" e.g. "row1:10".
     *
     *  @default null
     */
    function get verticalCenter():Object;
    function set verticalCenter(value:Object):void;

    /**
     *  The vertical distance in pixels from the anchor target to
     *  the control's baseline position.
     *
     *  By default the anchor target is the the top edge of the container's
     *  content area. In layouts with advanced constraints, the target can be
     *  a constraint row.
     *
     *  Setting the property to a number or to a numerical string like "10"
     *  specifies use of the default anchor target.
     *
     *  To spcify an anchor target, set the property value to a string in the format
     *  "anchorTargetName:value" e.g. "row1:10".
     *
     *  @default null
     */
    function get baseline():Object;
    function set baseline(value:Object):void;

    /**
     *  Number that specifies the width of a component as a percentage
     *  of its parent's size. Allowed values are 0-100.
     *  Setting the <code>width</code> or <code>explicitWidth</code> properties
     *  resets this property to NaN.
     *
     *  <p>This property returns a numeric value only if the property was
     *  previously set; it does not reflect the exact size of the component
     *  in percent.</p>
     *
     *  @default NaN
     */
    function get percentWidth():Number;
    function set percentWidth(value:Number):void;

    /**
     *  Number that specifies the height of a component as a percentage
     *  of its parent's size. Allowed values are 0-100.
     *  Setting the <code>height</code> or <code>explicitHeight</code> properties
     *  resets this property to NaN.
     *
     *  <p>This property returns a numeric value only if the property was
     *  previously set; it does not reflect the exact size of the component
     *  in percent.</p>
     *
     *  @default NaN
     */
    function get percentHeight():Number;
    function set percentHeight(value:Number):void;

    /**
     *  Number that specifies the explicit width of the component,
     *  in pixels, in the component's coordinates.
     *
     *  <p>This value is used by the layout in calculating
     *  the size and position of the component.
     *  It is not used by the component itself in determining
     *  its default size.
     *  Thus this property may not have any effect if parented by
     *  Container, or containers that don't factor in
     *  this property.</p>
     *  <p>Setting the <code>width</code> property also sets this property to
     *  the specified width value.</p>
     *
     *  @default NaN
     */
    function get explicitWidth():Number;
    function set explicitWidth(value:Number):void;

    /**
     *  The minimum recommended width of the component to be considered
     *  by the parent during layout. This value is in the
     *  component's coordinates, in pixels.
     *
     *  <p>Application developers typically do not set the explicitMinWidth property. Instead, they
     *  set the value of the minWidth property, which sets the explicitMinWidth property.</p>
     *
     *  <p>At layout time, if minWidth was explicitly set by the application developer, then
     *  the value of explicitMinWidth is used. Otherwise, a default value is used. Typically
     *  containers have a measuredMinWidth that is used as a default.</p>
     *
     *  <p>This value is used by the container in calculating
     *  the size and position of the component.
     *  It is not used by the component itself in determining
     *  its default size.
     *  Thus this property may not have any effect if parented by
     *  Container, or containers that don't factor in
     *  this property.</p>
     *
     *  @default NaN
     */
    function get explicitMinWidth():Number;
    function set explicitMinWidth(value:Number):void;

    /**
     *  The maximum recommended width of the component to be considered
     *  by the parent during layout. This value is in the
     *  component's coordinates, in pixels.
     *
     *  <p>Application developers typically do not set the explicitMaxWidth property. Instead, they
     *  set the value of the maxWidth property, which sets the explicitMaxWidth property.</p>
     *
     *  <p>At layout time, if maxWidth was explicitly set by the application developer, then
     *  the value of explicitMaxWidth is used. Otherwise, a default value is used. Typically
     *  containers have a measuredMaxWidth that is used as a default.</p>
     *
     *  <p>This value is used by the container in calculating
     *  the size and position of the component.
     *  It is not used by the component itself in determining
     *  its default size.
     *  Thus this property may not have any effect if parented by
     *  Container, or containers that don't factor in
     *  this property.</p>
     *
     *  @default NaN
     */
    function get explicitMaxWidth():Number;
    function set explicitMaxWidth(value:Number):void;

    /**
     *  Number that specifies the explicit height of the component,
     *  in pixels, in the component's coordinates.
     *
     *  <p>This value is used by the layout in calculating
     *  the size and position of the component.
     *  It is not used by the component itself in determining
     *  its default size.
     *  Thus this property may not have any effect if parented by
     *  Container, or containers that don't factor in
     *  this property.</p>
     *  <p>Setting the <code>height</code> property also sets this property to
     *  the specified height value.</p>
     *
     *  @default NaN
     */
    function get explicitHeight():Number;
    function set explicitHeight(value:Number):void;

    /**
     *  The minimum recommended height of the component to be considered
     *  by the parent during layout. This value is in the
     *  component's coordinates, in pixels.
     *
     *  <p>Application developers typically do not set the explicitMinHeight property. Instead, they
     *  set the value of the minHeight property, which sets the explicitMinHeight property.</p>
     *
     *  <p>At layout time, if minHeight was explicitly set by the application developer, then
     *  the value of explicitMinHeight is used. Otherwise, a default value is used. Typically
     *  containers have a measuredMinHeight that is used as a default.</p>
     *
     *  <p>This value is used by the container in calculating
     *  the size and position of the component.
     *  It is not used by the component itself in determining
     *  its default size.
     *  Thus this property may not have any effect if parented by
     *  Container, or containers that don't factor in
     *  this property.</p>
     *
     *  @default NaN
     */
    function get explicitMinHeight():Number;
    function set explicitMinHeight(value:Number):void;

    /**
     *  The maximum recommended height of the component to be considered
     *  by the parent during layout. This value is in the
     *  component's coordinates, in pixels.
     *
     *  <p>Application developers typically do not set the explicitMaxHeight property. Instead, they
     *  set the value of the maxHeight property, which sets the explicitMaxHeight property.</p>
     *
     *  <p>At layout time, if maxHeight was explicitly set by the application developer, then
     *  the value of explicitMaxHeight is used. Otherwise, a default value is used. Typically
     *  containers have a measuredMaxHeight that is used as a default.</p>
     *
     *  <p>This value is used by the container in calculating
     *  the size and position of the component.
     *  It is not used by the component itself in determining
     *  its default size.
     *  Thus this property may not have any effect if parented by
     *  Container, or containers that don't factor in
     *  this property.</p>
     *
     *  @default NaN
     */
    function get explicitMaxHeight():Number;
    function set explicitMaxHeight(value:Number):void;
}
}

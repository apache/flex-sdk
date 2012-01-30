////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core
{

import flash.events.IEventDispatcher;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;

/**
 *  The ILayoutElement interface is used primarily by the layout classes to query,
 *  size and position the elements of the GroupBase based containers.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface ILayoutElement extends IEventDispatcher
{
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get left():Object;
    
    /**
     *  @private
     */
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get right():Object;
    
    /**
     *  @private
     */
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get top():Object;
    
    /**
     *  @private
     */
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get bottom():Object;
    
    /**
     *  @private
     */
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get horizontalCenter():Object;
    
    /**
     *  @private
     */
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get verticalCenter():Object;
    
    /**
     *  @private
     */
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get baseline():Object;
    
    /**
     *  @private
     */
    function set baseline(value:Object):void;

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
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get baselinePosition():Number;
    
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get percentWidth():Number;
    
    /**
     *  @private
     */
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get percentHeight():Number;
    
    /**
     *  @private
     */
    function set percentHeight(value:Number):void;
 
    /**
     *  @copy mx.core.UIComponent#includeInLayout
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */   
    function get includeInLayout():Boolean;
    
    /**
     *  @private
     */
    function set includeInLayout(value:Boolean):void;
    
    /**
     *  Returns the element's preferred width.   
     * 
     *  @param postLayoutTransform When postLayoutTransform is true the method returns
     *  the element's bounding box width.  Bounding box is in element's parent
     *  coordinate space and is calculated from  the element's perferred size and
     *  layout transform matrix.
     *
     *  @return Returns the element's preferred width.  Preferred width is
     *  usually based on the default element size and any explicit overrides.
     *  For UIComponent this is the same as getExplicitOrMeasuredWidth().
     * 
     *  @see #getPreferredHeight
     *  @see #getLayoutMatrix
     *  @see #getLayoutMatrix3D
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function getPreferredBoundsWidth(postLayoutTransform:Boolean = true):Number;

    /**
     *  Returns the element's preferred height.  
     *
     *  @param postLayoutTransform When postLayoutTransform is true the method returns
     *  the element's bounding box height.  Bounding box is in element's parent
     *  coordinate space and is calculated from  the element's perferred size and
     *  layout transform matrix.
     *
     *  @return Returns the element's preferred height.  Preferred height is
     *  usually based on the default element size and any explicit overrides.
     *  For UIComponent this is the same as getExplicitOrMeasuredHeight().
     *
     *  @see #getPreferredWidth
     *  @see #getLayoutMatrix
     *  @see #getLayoutMatrix3D
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function getPreferredBoundsHeight(postLayoutTransform:Boolean = true):Number;

    /**
     *  Returns the element's minimum width.
     * 
     *  @param postLayoutTransform When postLayoutTransform is true the method returns
     *  the element's bounding box width. Bounding box is in element's parent
     *  coordinate space and is calculated from the element's minimum size and
     *  layout transform matrix.
     *
     *  @see #getMinHeight
     *  @see #getLayoutMatrix
     *  @see #getLayoutMatrix3D
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function getMinBoundsWidth(postLayoutTransform:Boolean = true):Number;

    /**
     *  Returns the element's minimum height.
     * 
     *  @param postLayoutTransform When postLayoutTransform is true the method returns
     *  the element's bounding box height. Bounding box is in element's parent
     *  coordinate space and is calculated from the element's minimum size and
     *  layout transform matrix.
     *
     *  @see #getMinWidth
     *  @see #getLayoutMatrix
     *  @see #getLayoutMatrix3D
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function getMinBoundsHeight(postLayoutTransform:Boolean = true):Number;

    /**
     *  Returns the element's maximum width.
     * 
     *  @param postLayoutTransform When postLayoutTransform is true the method returns
     *  the element's bounding box width. Bounding box is in element's parent
     *  coordinate space and is calculated from the element's maximum size and
     *  layout transform matrix.
     *
     *  @see #getMaxHeight
     *  @see #getLayoutMatrix
     *  @see #getLayoutMatrix3D
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function getMaxBoundsWidth(postLayoutTransform:Boolean = true):Number;

    /**
     *  Returns the element's maximum height.
     * 
     *  @param postLayoutTransform When postLayoutTransform is true the method returns
     *  the element's bounding box height. Bounding box is in element's parent
     *  coordinate space and is calculated from the element's maximum size and
     *  layout transform matrix.
     *
     *  @see #getMaxWidth
     *  @see #getLayoutMatrix
     *  @see #getLayoutMatrix3D
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function getMaxBoundsHeight(postLayoutTransform:Boolean = true):Number;
    
    /**
     *  Returns the x coordinate of the element's bounds at the specified element size.
     * 
     *  This method is typically used by layouts during measure() to predict what
     *  the element position will be, if the element is resized to particular dimesions.
     * 
     *  @param width The element's bounds width, or NaN to use the preferred width.
     *  @param height The element's bounds height, or NaN to use the preferred height.
     *  @param postLayoutTransform When postLayoutTransform is true the method returns
     *  x coordinate of the element's bounding box top-left corner.
     *  Bounding box is in element's parent coordinate space and is calculated
     *  from the specified bounds size, layout position and layout transform matrix.
     *
     *  @see #setLayoutBoundsSize
     *  @see #getLayoutPositionX
     *  @see #getLayoutMatrix
     *  @see #getLayoutMatrix3D
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function getBoundsXAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number;

    /**
     *  Returns the y coordinate of the element's bounds at the specified element size.
     * 
     *  This method is typically used by layouts during measure() to predict what
     *  the element position will be, if the element is resized to particular dimesions.
     * 
     *  @param width The element's bounds width, or NaN to use the preferred width.
     *  @param height The element's bounds height, or NaN to use the preferred height.
     *  @param postLayoutTransform When postLayoutTransform is true the method returns
     *  y coordinate of the element's bounding box top-left corner.
     *  Bounding box is in element's parent coordinate space and is calculated
     *  from the specified bounds size, layout position and layout transform matrix.
     *
     *  @see #setLayoutBoundsSize
     *  @see #getLayoutPositionY
     *  @see #getLayoutMatrix
     *  @see #getLayoutMatrix3D
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function getBoundsYAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number;
    
    /**
     *  Returns the element's layout width. This is the size that the element uses
     *  to draw on screen.
     *
     *  @param postLayoutTransform When postLayoutTransform is true the method returns
     *  the element's bounding box width. Bounding box is in element's parent
     *  coordinate space and is calculated from the element's layout size and
     *  layout transform matrix.
     *
     *  @see #getLayoutHeight
     *  @see #getLayoutMatrix
     *  @see #getLayoutMatrix3D
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function getLayoutBoundsWidth(postLayoutTransform:Boolean = true):Number;

    /**
     *  Returns the element's layout height. This is the size that the element uses
     *  to draw on screen.
     *
     *  @param postLayoutTransform When postLayoutTransform is true the method returns
     *  the element's bounding box width. Bounding box is in element's parent
     *  coordinate space and is calculated from the element's layout size and
     *  layout transform matrix.
     *
     *  @see #getLayoutWidth
     *  @see #getLayoutMatrix
     *  @see #getLayoutMatrix3D
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function getLayoutBoundsHeight(postLayoutTransform:Boolean = true):Number;
    
    /**
     *  Returns the x coordinate that the element uses to draw on screen.
     *
     *  @param postLayoutTransform When postLayoutTransform is true the method returns
     *  x coordinate of the element's bounding box top-left corner.
     *  Bounding box is in element's parent coordinate space and is calculated
     *  from the element's layout size, layout position and layout transform matrix.
     * 
     *  @see #getLayoutPositionY
     *  @see #getLayoutMatrix
     *  @see #getLayoutMatrix3D
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function getLayoutBoundsX(postLayoutTransform:Boolean = true):Number;

    /**
     *  Returns the y coordinate that the element uses to draw on screen.
     *
     *  @param postLayoutTransform When postLayoutTransform is true the method returns
     *  y coordinate of the element's bounding box top-left corner.
     *  Bounding box is in element's parent coordinate space and is calculated
     *  from the element's layout size, layout position and layout transform matrix.
     * 
     *  @see #getLayoutPositionX
     *  @see #getLayoutMatrix
     *  @see #getLayoutMatrix3D
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function getLayoutBoundsY(postLayoutTransform:Boolean = true):Number;

    /**
     *  Sets the coordinates that the element uses to draw on screen.
     *
     *  @param postLayoutTransform When postLayoutTransform is true, the element is positioned
     *  in such a way that the top-left corner of its bounding box is (x, y).
     *  Bounding box is in element's parent coordinate space and is calculated
     *  from the element's layout size, layout position and layout transform matrix.
     *
     *  Note that calls to setLayoutSize can affect the layout position, so 
     *  setLayoutPosition should be called after setLayoutSize.
     *
     *  @see #setLayoutSize
     *  @see #getLayoutMatrix
     *  @see #getLayoutMatrix3D
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function setLayoutBoundsPosition(x:Number, y:Number, postLayoutTransform:Boolean = true):void;

    /**
     *  Sets the layout size to the specified dimensions.  This is the size that
     *  the element uses to draw on screen.
     *  
     *  If one of the dimensions is left unspecified (NaN), it's size
     *  will be picked such that element can be optimally sized to fit the other
     *  dimension.  This is useful when the caller doesn't want to 
     *  overconstrain the element, for example when the element's width and height
     *  are corelated (text, components with complex transforms, etc.)
     *  If both dimensions are left unspecified, the element will have its layout size
     *  set to its preferred size.
     * 
     *  <code>setLayoutSize</code> does not clip against minium or maximum sizes.
     *
     *  Note that calls to setLayoutSize can affect the layout position, so 
     *  setLayoutSize should be called before setLayoutPosition.
     *
     *  @param width The target width.
     *
     *  @param height The target height.
     *
     *  @param postLayoutTransform When postLayoutTransform is true, the specified dimensions
     *  are those of the element's bounding box.
     *  Bounding box is in element's parent coordinate space and is calculated
     *  from the element's layout size, layout position and layout transform matrix.
     * 
     *  @see #setLayoutPosition
     *  @see #getLayoutMatrix
     *  @see #getLayoutMatrix3D
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function setLayoutBoundsSize(width:Number,
                                 height:Number,
                                 postLayoutTransform:Boolean = true):void;

    /**
     *  Returns the transform matrix that is used to calculate the component's
     *  layout relative to its siblings.
     *
     *  <p>This matrix is typically defined by the
     *  component's 2D properties such as <code>x</code>, <code>y</code>,
     *  <code>rotation</code>, <code>scaleX</code>, <code>scaleY</code>,
     *  <code>transformX</code>, and <code>transformY</code>.
     *  Some components may have additional transform properties that
     *  are applied on top of the layout matrix to determine the final,
     *  computed matrix.  For example <code>UIComponent</code>
     *  defines the <code>offsets</code> property.</p>
     *  
     *  @return <p>Returns the layout transform Matrix for this element.
     *  Don't directly modify the return value but call setLayoutMatrix instead.</p>
     * 
     *  @see #setLayoutMatrix
     *  @see #getLayoutMatrix3D
     *  @see #setLayoutMatrix3D
     *  @see mx.core.UIComponent#offsets
     *  @see mx.graphics.baseClasses.GraphicElement#offsets
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function getLayoutMatrix():Matrix;

    /**
     *  Sets the transform Matrix that is used to calculate the component's layout
     *  size and position relative to its siblings.
     *
     *  <p>This matrix is typically defined by the
     *  component's 2D properties such as <code>x</code>, <code>y</code>,
     *  <code>rotation</code>, <code>scaleX</code>, <code>scaleY</code>,
     *  <code>transformX</code>, and <code>transformY</code>.
     *  Some components may have additional transform properties that
     *  are applied on top of the layout matrix to determine the final,
     *  computed matrix.  For example <code>UIComponent</code>
     *  defines the <code>offsets</code>.</p>
     *  
     *  <p>Note that layout Matrix is factored in the getPreferredSize(),
     *  getMinSize(), getMaxSize(), getLayoutSize() when computed in parent coordinates
     *  as well as in getLayoutPosition() in both parent and child coordinates.
     *  Layouts that calculate the transform matrix explicitly typically call
     *  this method and work with sizes in child coordinates.
     *  Layouts calling this method pass <code>false</code>
     *  to <code>invalidateLayout</code> so that a subsequent layout pass is not
     *  triggered.</p>
     * 
     *  <p>Developers that call this method directly typically pass <code>true</code>
     *  to <code>invalidateLayout</code> so that the parent container is notified that
     *  it needs to re-layout the children.</p>
     * 
     *  @see #getLayoutMatrix
     *  @see #getLayoutMatrix3D
     *  @see #setLayoutMatrix3D
     *  @see mx.core.UIComponent#offsets
     *  @see mx.graphics.baseClasses.GraphicElement#offsets
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function setLayoutMatrix(value:Matrix, invalidateLayout:Boolean):void;
    
    /**
     *  True if the element has 3D Matrix.
     *
     *  Use <code>hasLayoutMatrix3D</code> instead of calling and examining the
     *  value of <code>getLayoutMatrix3D()</code> as that method returns a valid
     *  matrix even when the element is in 2D.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get hasLayoutMatrix3D():Boolean;

    /**
     *  Returns the layout transform Matrix3D for this element.
     * 
     *  <p>This matrix is typically defined by the
     *  component's transform properties such as <code>x</code>, <code>y</code>, 
     *  <code>z</code>, <code>rotationX</code>, <code>rotationY</code>,
     *  <code>rotationZ</code>, <code>scaleX</code>, <code>scaleY</code>,
     *  <code>scaleZ</code>, <code>transformX</code>, and <code>transformY</code>.
     *  Some components may have additional transform properties that
     *  are applied on top of the layout matrix to determine the final,
     *  computed matrix.  For example <code>UIComponent</code>
     *  defines the <code>offsets</code> property.</p>
     * 
     *  @return <p>Returns the layout transform Matrix3D for this element.
     *  Don't directly modify the return value but call setLayoutMatrix instead.</p>
     *  
     *  @see #getLayoutMatrix
     *  @see #setLayoutMatrix
     *  @see #setLayoutMatrix3D
     *  @see mx.core.UIComponent#offsets
     *  @see mx.graphics.baseClasses.GraphicElement#offsets
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function getLayoutMatrix3D():Matrix3D;

    /**
     *  Sets the transform Matrix3D that is used to calculate the component's layout
     *  size and position relative to its siblings.
     *
     *  <p>This matrix is typically defined by the
     *  component's transform properties such as <code>x</code>, <code>y</code>, 
     *  <code>z</code>, <code>rotationX</code>, <code>rotationY</code>,
     *  <code>rotationZ</code>, <code>scaleX</code>, <code>scaleY</code>,
     *  <code>scaleZ</code>, <code>transformX</code>, and <code>transformY</code>.
     *  Some components may have additional transform properties that
     *  are applied on top of the layout matrix to determine the final,
     *  computed matrix.  For example <code>UIComponent</code>
     *  defines the <code>offsets</code> property.</p>
     *  
     *  <p>Note that layout Matrix3D is factored in the getPreferredSize(),
     *  getMinSize(), getMaxSize(), getLayoutSize() when computed in parent coordinates
     *  as well as in getLayoutPosition() in both parent and child coordinates.
     *  Layouts that calculate the transform matrix explicitly typically call
     *  this method and work with sizes in child coordinates.
     *  Layouts calling this method pass <code>false</code>
     *  to <code>invalidateLayout</code> so that a subsequent layout pass is not
     *  triggered.</p>
     * 
     *  <p>Developers that call this method directly typically pass <code>true</code>
     *  to <code>invalidateLayout</code> so that the parent container is notified that
     *  it needs to re-layout the children.</p>
     * 
     *  @see #getLayoutMatrix
     *  @see #setLayoutMatrix
     *  @see #getLayoutMatrix3D
     *  @see mx.core.UIComponent#offsets
     *  @see mx.graphics.baseClasses.GraphicElement#offsets
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function setLayoutMatrix3D(value:Matrix3D, invalidateLayout:Boolean):void;

    /**
     * A utility method to update the rotation, scale, and translation of the 
     * transform while keeping a particular point, specified in the component's 
     * own coordinate space, fixed in the parent's coordinate space.  
     * This function will assign the rotation, scale, and translation values 
     * provided, then update the x/y/z properties as necessary to keep 
     * the transform center fixed.
     * @param transformCenter the point, in the component's own coordinates, 
     * to keep fixed relative to its parent.
     * @param scale the new values for the scale of the transform
     * @param rotation the new values for the rotation of the transform
     * @param translation the new values for the translation of the transform
     * @param postLayoutScale the new values for the post-layout scale 
     * of the transform
     * @param postLayoutRotation the new values for the post-layout rotation 
     * of the transform
     * @param postLayoutTranslation the new values for the post-layout translation 
     * of the transform
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function transformAround(transformCenter:Vector3D,
                                    scale:Vector3D = null,
                                    rotation:Vector3D = null,
                                    translation:Vector3D = null,
                                    postLayoutScale:Vector3D = null,
                                    postLayoutRotation:Vector3D = null,
                                    postLayoutTranslation:Vector3D = null):void;
    
}

}

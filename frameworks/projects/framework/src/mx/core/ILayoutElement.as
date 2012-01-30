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

package mx.layout
{

import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;

/**
 *  The ILayoutElement interface is used primarily by the layout classes to query,
 *  size and position the elements of the GroupBase based containers.
 */
public interface ILayoutElement
{
    /**
     * @copy mx.core.IVisualElement#left
     */
    function get left():Object;

    /**
     * @copy mx.core.IVisualElement#right
     */
    function get right():Object;

    /**
     * @copy mx.core.IVisualElement#top
     */
    function get top():Object;

    /**
     * @copy mx.core.IVisualElement#bottom
     */
    function get bottom():Object;

    /**
     * @copy mx.core.IVisualElement#horizontalCenter
     */
    function get horizontalCenter():Object;

    /**
     * @copy mx.core.IVisualElement#verticalCenter
     */
    function get verticalCenter():Object;

    /**
     * @copy mx.core.IVisualElement#baseline
     */
    function get baseline():Object;

    /**
     * @copy mx.core.IVisualElement#percentWidth
     */
    function get percentWidth():Number;

    /**
     * @copy mx.core.IVisualElement#percentHeight
     */
    function get percentHeight():Number;

    /**
     *  A reference to the object in the layout tree
     *  represented by this interface.
     */
    function get target():Object;

    /**
     *  Indicates whether the layout should ignore this element or not.
     */     
    function get includeInLayout():Boolean;
    
    /**
     *  @return Returns the element's preferred width.  Preferred width is
     *  usually based on the default element size and any explicit overrides.
     *  For UIComponent this is the same as getExplicitOrMeasuredWidth().
     * 
     *  @param postTransform When postTransform is true the method returns
     *  the element's bounding box width.  Bounding box is in element's parent
     *  coordinate space and is calculated from  the element's perferred size and
     *  layout transform matrix.
     *
     *  @see #getPreferredHeight
     *  @see mx.core.UIComponent#layoutMatrix
     *  @see mx.core.UIComponent#layoutMatrix3D
     */
    function getPreferredWidth(postTransform:Boolean=true):Number;

    /**
     *  @return Returns the element's preferred height.  Preferred height is
     *  usually based on the default element size and any explicit overrides.
     *  For UIComponent this is the same as getExplicitOrMeasuredHeight().
     *
     *  @param postTransform When postTransform is true the method returns
     *  the element's bounding box height.  Bounding box is in element's parent
     *  coordinate space and is calculated from  the element's perferred size and
     *  layout transform matrix.
     *
     *  @see #getPreferredWidth
     *  @see mx.core.UIComponent#layoutMatrix
     *  @see mx.core.UIComponent#layoutMatrix3D
     */
    function getPreferredHeight(postTransform:Boolean=true):Number;

    /**
     *  Returns the element's minimum width.
     * 
     *  @param postTransform When postTransform is true the method returns
     *  the element's bounding box width. Bounding box is in element's parent
     *  coordinate space and is calculated from the element's minimum size and
     *  layout transform matrix.
     *
     *  @see #getMinHeight
     *  @see mx.core.UIComponent#layoutMatrix
     *  @see mx.core.UIComponent#layoutMatrix3D
     */
    function getMinWidth(postTransform:Boolean=true):Number;

    /**
     *  Returns the element's minimum height.
     * 
     *  @param postTransform When postTransform is true the method returns
     *  the element's bounding box height. Bounding box is in element's parent
     *  coordinate space and is calculated from the element's minimum size and
     *  layout transform matrix.
     *
     *  @see #getMinWidth
     *  @see mx.core.UIComponent#layoutMatrix
     *  @see mx.core.UIComponent#layoutMatrix3D
     */
    function getMinHeight(postTransform:Boolean=true):Number;

    /**
     *  Returns the element's maximum width.
     * 
     *  @param postTransform When postTransform is true the method returns
     *  the element's bounding box width. Bounding box is in element's parent
     *  coordinate space and is calculated from the element's maximum size and
     *  layout transform matrix.
     *
     *  @see #getMaxHeight
     *  @see mx.core.UIComponent#layoutMatrix
     *  @see mx.core.UIComponent#layoutMatrix3D
     */
    function getMaxWidth(postTransform:Boolean=true):Number;

    /**
     *  Returns the element's maximum height.
     * 
     *  @param postTransform When postTransform is true the method returns
     *  the element's bounding box height. Bounding box is in element's parent
     *  coordinate space and is calculated from the element's maximum size and
     *  layout transform matrix.
     *
     *  @see #getMaxWidth
     *  @see mx.core.UIComponent#layoutMatrix
     *  @see mx.core.UIComponent#layoutMatrix3D
     */
    function getMaxHeight(postTransform:Boolean=true):Number;
    
    /**
     *  Returns the element's layout width. This is the size that the element uses
     *  to draw on screen.
     *
     *  @param postTransform When postTransform is true the method returns
     *  the element's bounding box width. Bounding box is in element's parent
     *  coordinate space and is calculated from the element's layout size and
     *  layout transform matrix.
     *
     *  @see #getLayoutHeight
     *  @see mx.core.UIComponent#layoutMatrix
     *  @see mx.core.UIComponent#layoutMatrix3D
     */
    function getLayoutWidth(postTransform:Boolean=true):Number;

    /**
     *  Returns the element's layout height. This is the size that the element uses
     *  to draw on screen.
     *
     *  @param postTransform When postTransform is true the method returns
     *  the element's bounding box width. Bounding box is in element's parent
     *  coordinate space and is calculated from the element's layout size and
     *  layout transform matrix.
     *
     *  @see #getLayoutWidth
     *  @see mx.core.UIComponent#layoutMatrix
     *  @see mx.core.UIComponent#layoutMatrix3D
     */
    function getLayoutHeight(postTransform:Boolean=true):Number;

    /**
     *  Returns the x coordinate that the element uses to draw on screen.
     *
     *  @param postTransform When postTransform is true the method returns
     *  x coordinate of the element's bounding box top-left corner.
     *  Bounding box is in element's parent coordinate space and is calculated
     *  from the element's layout size, layout position and layout transform matrix.
     * 
     *  @see #getLayoutPositionY
     *  @see mx.core.UIComponent#layoutMatrix
     *  @see mx.core.UIComponent#layoutMatrix3D
     */
    function getLayoutPositionX(postTransform:Boolean=true):Number;

    /**
     *  Returns the y coordinate that the element uses to draw on screen.
     *
     *  @param postTransform When postTransform is true the method returns
     *  y coordinate of the element's bounding box top-left corner.
     *  Bounding box is in element's parent coordinate space and is calculated
     *  from the element's layout size, layout position and layout transform matrix.
     * 
     *  @see #getLayoutPositionX
     *  @see mx.core.UIComponent#layoutMatrix
     *  @see mx.core.UIComponent#layoutMatrix3D
     */
    function getLayoutPositionY(postTransform:Boolean=true):Number;

    /**
     *  Sets the coordinates that the element uses to draw on screen.
     *
     *  @param postTransform When postTransform is true, the element is positioned
     *  in such a way that the top-left corner of its bounding box is (x, y).
     *  Bounding box is in element's parent coordinate space and is calculated
     *  from the element's layout size, layout position and layout transform matrix.
     *
     *  Note that calls to setLayoutSize can affect the layout position, so 
     *  setLayoutPosition should be called after setLayoutSize.
     *
     *  @see #setLayoutSize
     *  @see mx.core.UIComponent#layoutMatrix
     *  @see mx.core.UIComponent#layoutMatrix3D
     */
    function setLayoutPosition(x:Number, y:Number, postTransform:Boolean=true):void;

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
     *  @param postTransform When postTransform is true, the specified dimensions
     *  are those of the element's bounding box.
     *  Bounding box is in element's parent coordinate space and is calculated
     *  from the element's layout size, layout position and layout transform matrix.
     * 
     *  @see #setLayoutPosition
     *  @see mx.core.UIComponent#layoutMatrix
     *  @see mx.core.UIComponent#layoutMatrix3D
     */
    function setLayoutSize(width:Number = Number.NaN,
                           height:Number = Number.NaN,
                           postTransform:Boolean=true):void;

    /**
     *  Returns the layout transform Matrix for this element.
     *  Don't directly modify the return value but call setLayoutMatrix instead. 
     */
    function getLayoutMatrix():Matrix;

    /**
     *  Sets the transform Matrix that is used to calculate the component's layout
     *  size and position relative to its siblings.
     *
     *  Note that layout Matrix is factored in the getPreferredSize(),
     *  getMinSize(), getMaxSize(), getLayoutSize() when computed in parent coordinates
     *  as well as in getLayoutPosition() in both parent and child coordinates.
     *
     *  <p>The method is typically used by layouts that calculate the transform
     *  matrix explicitly and work with sizes in child coordinates, ingnoring
     *  getLayoutPosition.  Calling this method does not cause a subsequent layout
     *  pass (doesn't invalidate element's parent size or display list).</p>
     * 
     *  @see #setLayoutMatrix3D
     *  @see mx.core.UIComponent#layoutMatrix
     *  @see mx.core.UIComponent#layoutMatrix3D
     */
    function setLayoutMatrix(m:Matrix):void;

    /**
     *  Returns the layout transform Matrix3D for this element.
     *  Don't directly modify the return value but call setLayoutMatrix instead. 
     */
    function getLayoutMatrix3D():Matrix3D;

    /**
     *  Sets the transform Matrix3D that is used to calculate the component's layout
     *  size and position relative to its siblings.
     *
     *  Note that layout Matrix3D is factored in the getPreferredSize(),
     *  getMinSize(), getMaxSize(), getLayoutSize() when computed in parent coordinates
     *  as well as in getLayoutPosition() in both parent and child coordinates.
     *
     *  <p>The method is typically used by layouts that calculate the transform
     *  matrix explicitly and work with sizes in child coordinates, ingnoring
     *  getLayoutPosition.  Calling this method does not cause a subsequent layout
     *  pass (doesn't invalidate element's parent size or display list).</p>
     * 
     *  @see #setLayoutMatrix3D
     *  @see mx.core.UIComponent#layoutMatrix
     *  @see mx.core.UIComponent#layoutMatrix3D
     */
    function setLayoutMatrix3D(m:Matrix3D):void;
}

}

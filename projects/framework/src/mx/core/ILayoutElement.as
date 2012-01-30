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

import flash.geom.Point;

/**
 *  TERMINOLOGY
 * 
 *  <p>TBounds - bounds of an object in object's parent coordinate space, i.e.
 *            bounds of the transformed object.</p>
 *
 *  <p>UBounds - bounds of an object in object's own coordinate space, i.e.
 *            bounds of the untransformed object (object's dimensions).</p>
 *
 *  <p>Example: Consider a rectangle width=3, height=1 with rotation=90.</p>
 * 
 *  <p>Ubounds (before transform) are (3,1):
 *  <pre>
 *       +--------+ 
 *       |        |
 *       +--------+
 *  </pre>
 *  </p>
 *  
 *  <p>TBounds (after transform) are (1,3):
 *  <pre>
 *       +----+
 *       |    |
 *       |    |
 *       |    |
 *       +----+
 *  </pre>
 *  </p>
 */
public interface ILayoutItem
{
    /**
     * @copy mx.core.IVisualItem#left
     */
    function get left():Object;

    /**
     * @copy mx.core.IVisualItem#right
     */
    function get right():Object;

    /**
     * @copy mx.core.IVisualItem#top
     */
    function get top():Object;

    /**
     * @copy mx.core.IVisualItem#bottom
     */
    function get bottom():Object;

    /**
     * @copy mx.core.IVisualItem#horizontalCenter
     */
    function get horizontalCenter():Object;

    /**
     * @copy mx.core.IVisualItem#verticalCenter
     */
    function get verticalCenter():Object;

    /**
     * @copy mx.core.IVisualItem#baseline
     */
    function get baseline():Object;

    /**
     * @copy mx.core.IVisualItem#percentWidth
     */
    function get percentWidth():Number;

    /**
     * @copy mx.core.IVisualItem#percentHeight
     */
    function get percentHeight():Number;

    /**
     *  A reference to the object in the layout tree
     *  represented by this interface.
     */
    function get target():Object;

    /**
     *  Indicates whether to layout should ignore this item or not.
     */     
    function get includeInLayout():Boolean;
    
    /**
     *  The TBounds of the preferred
     *  item size. The preferred size is usually based on the default
     *  item size and any explicit size overrides.
     */
    function get preferredSize():Point;

    /**
     *  The TBounds of the minimum item size.
     *  <code>minSize</code> &lt;= <code>preferredSize</code> must be true.
     */
    function get minSize():Point;

    /**
     *  The TBounds of the maximum item size.
     *  <code>preferredSize</code> &lt;= <code>maxSize</code> must be true.
     */
    function get maxSize():Point;
    
    /**
     *  The item TBounds size.
     */ 
    function get actualSize():Point;

    /**
     *  The item TBounds top left corner coordinates.
     */
    function get actualPosition():Point;

    /**
     *  Moves the item such that the item TBounds
     *  top left corner has the specified coordinates.
     */
    function setActualPosition( x:Number, y:Number ):void;

    /**
     *  <code>setActualSize</code> modifies the item size/transform so that
     *  its TBounds have the specified <code>width</code> and <code>height</code>.
     *  
     *  If one of the desired TBounds dimensions is left unspecified, it's size
     *  will be picked such that item can be optimally sized to fit the other
     *  TBounds dimension. This is useful when the layout doesn't want to 
     *  overconstrain the item in cases where the item TBounds width and height
     *  are dependent (text, components with complex transforms, etc.)
     * 
     *  If both TBounds dimensions are left unspecified, the item will have its
     *  preferred size set.
     * 
     *  <code>setActualSize</code> does not clip against <code>minSize</code> and
     *  <code>maxSize</code> properties.
     * 
     *  <code>setActualSize</code> must preserve the item's TBounds position,
     *  which means that in some cases it will move the item in addition to
     *  changing its size.
     *  
     *  @param width The target width. The path is scaled to fit the specified dimensions.
     *  
     *  @param height the target height. The path is scaled to fit the specified dimensions.
     * 
     *  @return Returns the TBounds of the new item size.
     */
    function setActualSize( width:Number = Number.NaN, height:Number = Number.NaN ):Point;
}

}

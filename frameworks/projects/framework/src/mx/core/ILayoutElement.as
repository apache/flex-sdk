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

package flex.intf
{

import flash.geom.Point;

/**
 *  TERMINOLOGY
 * 
 *  TBounds - bounds of an object in object's parent coordinate space, i.e.
 *            bounts of the transformed object.
 *
 *  UBounds - bounds of an object in object's own coordinate space, i.e.
 *            bounds of the untransformed object (object's dimensions).
 *
 *  Example: Consider a rectangle width=3, height=1 with rotation=90
 * 
 *  Ubounds (before transform) are (3,1):
 *       +--------+ 
 *       |        |
 *       +--------+
 * 
 *  TBounds (after transform) are (1,3):
 *       +----+
 *       |    |
 *       |    |
 *       |    |
 *       +----+
 */
public interface ILayoutItem
{
    /**
     *  @return Returns a reference to the object in the layout tree
     *  represented by this interface.
     */
    function get target():Object;

    /**
     *  Indicates whether to layout should ignore this item or not.
     */     
    function get includeInLayout():Boolean;
    
    /**
     *  @return Returns TBounds of the preferred
     *  item size. The preferred size is usually based on the default
     *  item size and any explicit size overrides.
     */
    function get preferredSize():Point;

    /**
     *  @return Returns TBounds of the minimum item size.
     *  <code>minSize</code> <= <code>preferredSize</code> must be true.
     */
    function get minSize():Point;

    /**
     *  @return Returns TBounds of the maximum item size.
     *  <code>preferredSize</code> <= <code>maxSize</code> must be true.
     */
    function get maxSize():Point;
    
    /**
     *  @return Returns the desired item TBounds size
     *  as a percentage of parent UBounds. Could be NaN.
     */
    function get percentSize():Point; 
    
    /**
     *  @return Returns the item TBounds size.
     */ 
    function get actualSize():Point;

    /**
     *  @return Returns the item TBounds top left corner coordinates.
     */
    function get actualPosition():Point;

    /**
     *  <code>setActualPosition</code> moves the item such that the item TBounds
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
     *  @return Returns the TBounds of the new item size.
     */
    function setActualSize( width:Number = Number.NaN, height:Number = Number.NaN ):Point;
}

}

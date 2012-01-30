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

package mx.graphics
{

import flash.display.Graphics;
import flash.display.GraphicsStroke;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 *  Defines the interface that classes that define a line must implement.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IStroke
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  weight
	//----------------------------------

	/**
	 *  The line weight, in pixels.
	 *  For many chart lines, the default value is 1 pixel.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function get weight():Number;
	
	/**
	 *  @private
	 */
	function set weight(value:Number):void;
	
    //----------------------------------
    //  scaleMode
    //----------------------------------

    /**
     *  A value from the LineScaleMode class
     *  that  specifies which scale mode to use.
     *  Value valids are:
     * 
     *  <ul>
     *  <li>
     *  <code>LineScaleMode.NORMAL</code>&#151;
     *  Always scale the line thickness when the object is scaled  (the default).
     *  </li>
     *  <li>
     *  <code>LineScaleMode.NONE</code>&#151;
     *  Never scale the line thickness.
     *  </li>
     *  <li>
     *  <code>LineScaleMode.VERTICAL</code>&#151;
     *  Do not scale the line thickness if the object is scaled vertically 
     *  <em>only</em>. 
     *  </li>
     *  <li>
     *  <code>LineScaleMode.HORIZONTAL</code>&#151;
     *  Do not scale the line thickness if the object is scaled horizontally 
     *  <em>only</em>. 
     *  </li>
     *  </ul>
     * 
     *  @default LineScaleMode.NORMAL
     *  
     *  @see flash.display.LineScaleMode
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get scaleMode():String;
    
    //----------------------------------
    //  miterLimit
    //----------------------------------

    /**
     *  Indicates the limit at which a miter is cut off.
     *  Valid values range from 0 to 255.
     *  
     *  @default 3
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get miterLimit():Number;
    
    //----------------------------------
    //  joints
    //----------------------------------
    
    /**
     *  Specifies the appearance of line intersections used at angles.
     *  Valid values are <code>JointStyle.ROUND</code>, <code>JointStyle.MITER</code>,
     *  and <code>JointStyle.BEVEL</code>.
     *  
     *  @see flash.display.JoingStyle
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get joints():String;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Applies the properties to the specified Graphics object.
	 *   
	 *  @param graphics The Graphics object to apply the properties to.
	 *  
	 *  @param targetBounds The bounds of the shape that the stroke is applied to. 
	 * 
     *  @param targetOrigin The Point that defines the origin (0,0) of the shape in the 
     *  coordinate system of target.  
     * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function apply(graphics:Graphics, targetBounds:Rectangle, targetOrigin:Point):void;

    /**
     *  Generates a GraphicsStroke object representing 
     *  this stroke. 
     * 
     *  @param targetBounds The stroke's bounding box.
     *  
     *  @param targetOrigin The Point that defines the origin (0,0) of the shape in the 
     *  coordinate system of target. 
     * 
     *  @return The Drawing API-2 GraphicsStroke object representing 
     *  this stroke. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
	function createGraphicsStroke(targetBounds:Rectangle, targetOrigin:Point):GraphicsStroke; 
}

}

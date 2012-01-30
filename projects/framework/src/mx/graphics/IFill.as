////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2004-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.graphics
{

import flash.display.Graphics;
import flash.geom.Rectangle;

/**
 *  Defines the interface that classes
 *  that perform a fill must implement.
 *
 *  @see mx.graphics.LinearGradient
 *  @see mx.graphics.RadialGradient
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IFill
{	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Starts the fill.
	 *  
	 *  @param target The target Graphics object that is being filled.
	 *
	 *  @param bounds The Rectangle object that defines the size of the fill
	 *  inside the <code>target</code>.
	 *  If the dimensions of the Rectangle are larger than the dimensions
	 *  of the <code>target</code>, the fill is clipped.
	 *  If the dimensions of the Rectangle are smaller than the dimensions
	 *  of the <code>target</code>, the fill expands to fill the entire
	 *  <code>target</code>.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function begin(target:Graphics, bounds:Rectangle):void;
	
	/**
	 *  Ends the fill.
	 *  
	 *  @param target The Graphics object that is being filled. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function end(target:Graphics):void;
}

}

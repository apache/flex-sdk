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
	import mx.geom.ITransformable;
	
/**
 *  The IVisualItem interface represents the common methods and properties between UIComponents and
 *  GraphicElements.
 */
	public interface IVisualItem extends ITransformable
	{
		/**
		 * Documentation is not currently available.
		 */
		function set layer(value:Number):void;
		function get layer():Number;
	}
}
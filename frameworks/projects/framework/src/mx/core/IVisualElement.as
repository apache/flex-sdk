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
	import flash.geom.Matrix;
    import flash.geom.Matrix3D;
	
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
		
        function get layoutMatrix():Matrix;
        function set layoutMatrix(value:Matrix):void;

        function get layoutMatrix3D():Matrix3D;
        function set layoutMatrix3D(value:Matrix3D):void;
	}
}
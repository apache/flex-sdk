////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package flex.graphics
{
import flash.display.DisplayObject;
import flash.display.Graphics;

import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.geom.Transform;

/**
 *  The IGraphicElement interface is implemented by all child tags of Graphic and Group.
 */
public interface IGraphicElement
{
 
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

	//----------------------------------
	//  elementHost
	//----------------------------------
	
 	/**
	 *  @private
	 */
	function get elementHost():IGraphicElementHost;
	function set elementHost(value:IGraphicElementHost):void;

	//----------------------------------
	//  alpha
	//----------------------------------
	/**
     *  Specifies the alpha
     * 
     *  @see flash.display.DisplayObject#Alpha
     */
	function get alpha():Number;
	function set alpha(value:Number):void;

	//----------------------------------
	//  blendMode
	//----------------------------------
	/**
     *  Specifies the blendMode
     * 
     *  @see flash.display.DisplayObject#BlendMode
     */
	function get blendMode():String;
	function set blendMode(value:String):void;
		
 	//----------------------------------
	//  bounds
	//----------------------------------
	
    /**
     *  Returns the pre-transform measured or explicit bounds,
     *  excluding stroke, as drawn at position (0,0). This is read-only property.   
     */
    function get bounds():Rectangle;
	
	//----------------------------------
	//  filters
	//----------------------------------
	/**
	 *  The array of IBitmapFilter filters applied to the element
	 */
	function get filters():Array;
	function set filters(value:Array):void;
	
	//----------------------------------
	//  maskType
	//----------------------------------
	/**
	 *  Controls how the mask performs masking on the element. 
	 *  Possible values are MaskType.CLIP and MaskType.ALPHA
	 *  A value of MaskType.CLIP means that the mask either displays the pixel
	 *  or doesn't. Strokes and bitmap filters are not used. 
	 *  A value of MaskType.ALPHA means that the mask respects opacity and
	 *  will use the strokes and bitmap filters of the mask.  
	 */
	function get maskType():String;
	function set maskType(value:String):void;
	
	//----------------------------------
	//  mask
	//----------------------------------
	/**
	 * The mask applied to the element
	 */
	
	function set mask(value:DisplayObject):void;
	function get mask():DisplayObject;
		
	//----------------------------------
	//  rotation
	//----------------------------------
	/**
	 *  Indicates the rotation of the element, in degrees, from the transform point.
	 */
	function get rotation():Number;
	function set rotation(value:Number):void;
	
	//----------------------------------
	//  scaleX
	//----------------------------------
	/**
	 *  Indicates the horizontal scale (percentage) of the element as applied from the transform point.
	 */
	function get scaleX():Number;
	function set scaleX(value:Number):void;
	
	//----------------------------------
	//  scaleY
	//----------------------------------
	/**
	 *  Indicates the vertical scale (percentage) of the element as applied from the transform point.
	 */
	function get scaleY():Number;
	function set scaleY(value:Number):void;
	
	//----------------------------------
	//  transform
	//----------------------------------
	/**
	 *  An object with properties pertaining to an element's matrix, 
	 *  color transform, and pixel bounds. 
	 */
	function get transform():Transform;
	function set transform(value:Transform):void; 
	
	//----------------------------------
	//  transformX
	//----------------------------------
	/**
	 *  The x position transform point of the element. 
	 */
	function get transformX():Number;
	function set transformX(value:Number):void;
	
	//----------------------------------
	//  transformY
	//----------------------------------
	/**
	 *  The y position transform point of the element. 
	 */
	function get transformY():Number;
	function set transformY(value:Number):void;
	
	//----------------------------------
	//  visible
	//----------------------------------
	
	/**
	 *  Controls the visibility of the element.
	 */
	function get visible():Boolean;
	function set visible(value:Boolean):void;
	
	//----------------------------------
	//  x
	//----------------------------------
	/**
	 *  The x position of the element
	 */
	function get x():Number;
	function set x(value:Number):void;
	
	//----------------------------------
	//  y
	//----------------------------------
	/**
	 *  The y position of the element
	 */
	function get y():Number;
	function set y(value:Number):void;
	
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

	function applyMask():void;
}
}

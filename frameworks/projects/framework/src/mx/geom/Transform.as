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

package mx.geom
{
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.PerspectiveProjection;
import flash.geom.Rectangle;
import flash.geom.Transform;

import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.mx_internal;

use namespace mx_internal;
	
/**
 *  FIXME (jszeto): comment
 * 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */	
public class Transform extends flash.geom.Transform
{
	/**
	 *  FIXME (jszeto): comment
	 * 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */		
	public function Transform(src:DisplayObject = null)
	{		
		if(src == null)
			src = new Shape();
		super(src);		
	}
	
	//--------------------------------------------------------------------------
    //
    //  Overridden flash.geom.Transform Properties
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 */ 
	override public function set colorTransform(value:ColorTransform):void
	{
		if (target && "$transform" in target) // UIComponent/UIMovieClip
			target["$transform"]["colorTransform"] = value;
		else if (target && "setColorTransform" in target)
			target["setColorTransform"](value);			
		else
			super.colorTransform = value;
	}
	
	/**
	 *  @private
	 */ 	
	override public function get colorTransform():ColorTransform
	{
		if (target && "$transform" in target) // UIComponent/UIMovieClip	
			return target["$transform"]["colorTransform"];
		else if (target && "displayObject" in target && target["displayObject"] != null)
			return target["displayObject"]["transform"]["colorTransform"];
		else
			return super.colorTransform;	
	}
	
	/**
	 *  @private
	 */ 	
	override public function get concatenatedColorTransform():ColorTransform
	{
		if (target && "$transform" in target) // UIComponent/UIMovieClip
			return target["$transform"]["concatenatedColorTransform"];
		else if (target && "displayObject" in target && target["displayObject"] != null)
			return target["displayObject"]["transform"]["concatenatedColorTransform"];
		else
			return super.concatenatedColorTransform;	
	}

	/**
	 *  @private
	 */ 	
	override public function get concatenatedMatrix():Matrix
	{
		if (target && "$transform" in target) // UIComponent/UIMovieClip
			return target["$transform"]["concatenatedMatrix"];
		else if (target && "displayObject" in target && target["displayObject"] != null)
			return target["displayObject"]["transform"]["concatenatedMatrix"];
		else
			return super.concatenatedMatrix;
	}

	/**
	 *  @private
	 */ 
	override public function set matrix(value:Matrix):void
	{
		if (target is ILayoutElement)
			ILayoutElement(target).setLayoutMatrix(value, true);
		else 
			super.matrix = value;
	}

	/**
	 *  @private
	 */ 	
	override public function get matrix():Matrix
	{
		if (target is ILayoutElement)
			return ILayoutElement(target).getLayoutMatrix();
		else
			return super.matrix;
	}
	
	/*override public function set matrix3D(value:Matrix3D):void 
	{
		if (target is ILayoutElement)
			ILayoutElement(target).setLayoutMatrix3D(value, true);
		else 
			super.matrix3D = value;
	}*/

	/**
	 *  @private
	 */ 	
	override public function get matrix3D():Matrix3D
	{
		if (target is ILayoutElement)
			return ILayoutElement(target).getLayoutMatrix3D();
		else
			return super.matrix3D;
	}

	/**
	 *  @private
	 */ 	
	override public function set perspectiveProjection(value:PerspectiveProjection):void
	{
		// FIXME (jszeto): !!!
		var oldValue:PerspectiveProjection = super.perspectiveProjection;
		super.perspectiveProjection = value;	
		
	}

	/**
	 *  @private
	 */ 	
	override public function get perspectiveProjection():PerspectiveProjection
	{
		if (target && "$transform" in target) // UIComponent/UIMovieClip
			return target["$transform"]["perspectiveProjection"];
		else if (target && "displayObject" in target && target["displayObject"] != null)
			return target["displayObject"]["transform"]["perspectiveProjection"];
		else
			return super.perspectiveProjection;	
	}
	
	/**
	 *  @private
	 */ 	
	override public function get pixelBounds():Rectangle
	{
		if (target && "$transform" in target) // UIComponent/UIMovieClip
			return target["$transform"]["pixelBounds"];
		else if (target && "displayObject" in target && target["displayObject"] != null)
			return target["displayObject"]["transform"]["pixelBounds"];
		else
			return super.pixelBounds;
	}
	
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------	
	
	private var _target:IVisualElement;

	/**
	 *  FIXME (jszeto): comment
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 	
	public function set target(value:IVisualElement):void
	{
		if (value !== _target)
			_target = value;
	}
	
	/**
	 *  @private
	 */ 
	public function get target():IVisualElement
	{
		return _target;
	}
	
	//--------------------------------------------------------------------------
    //
    //  Overridden flash.geom.Transform Methods
    //
    //--------------------------------------------------------------------------

	override public function getRelativeMatrix3D(relativeTo:DisplayObject):Matrix3D
	{
		if (target && "$transform" in target) // UIComponent/UIMovieClip
			return target["$transform"]["getRelativeMatrix3D"](relativeTo);
		else if (target && "displayObject" in target && target["displayObject"] != null)
			return target["displayObject"]["transform"]["getRelativeMatrix3D"](relativeTo);
		else
			return super.getRelativeMatrix3D(relativeTo);
	}
}
}
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
package mx.geom
{
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import __AS3__.vec.Vector;
	import flash.geom.Vector3D;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import mx.core.mx_internal;
	import mx.core.AdvancedLayoutFeatures;
	import flash.geom.Point;
	use namespace mx_internal;	
	
	/**
	 *  A CompoundTransform represents a 2D or 3D matrix transform. It can be used in the postLayoutTransformOffsets property on a UIComponent or GraphicElement.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class TransformOffsets extends EventDispatcher 
	{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
		public function TransformOffsets()
		{
		}
		
			
	
    /**
     * @private
     * storage for transform properties. These values are concatenated together with the layout properties to
     * form the actual computed matrix used to render the object.
     */
	private var _rotationX:Number = 0;
	private var _rotationY:Number = 0;
	private var _rotationZ:Number = 0;
	private var _scaleX:Number = 1;
	private var _scaleY:Number = 1;
	private var _scaleZ:Number = 1;		
	private var _x:Number = 0;
	private var _y:Number = 0;
	private var _z:Number = 0;
		
    /**
     * @private
     * flags for tracking whether the  transform is 3D. A transform is 3D if any of the 3D properties -- rotationX/Y, scaleZ, or z -- are set.
     */
	private static const IS_3D:uint 				= 0x200;
	private static const M3D_FLAGS_VALID:uint			= 0x400;
	 			
    /**
     * @private
     * general storage for all of our flags.  
     */
    private var _flags:uint =  0;

    /**
     * @private
     */
	mx_internal var owner:AdvancedLayoutFeatures;
	//----------------------------------------------------------------------------
	
	/**
	 * the  x value added to the transform
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function set x(value:Number):void
	{		
		if (value == _x)
			return;
		_x = value;
		invalidate(false);
	}
    /**
     * @private
     */
	public function get x():Number
	{		
		return _x;
	}
	
	/**
	 * the y value added to the transform
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function set y(value:Number):void
	{		
		if (value == _y)
			return;
		_y = value;
		invalidate(false);
	}
	
    /**
     * @private
     */
	public function get y():Number
	{		
		return _y;
	}
	
	/**
	 * the z value added to the transform
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function set z(value:Number):void
	{		
		if (value == _z)
			return;
		_z = value;
		invalidate(true);
	}
	
    /**
     * @private
     */
	public function get z():Number
	{		
		return _z;
	}
	
	//------------------------------------------------------------------------------

	
	/**
	 * the rotationX, in degrees, added to the transform
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function set rotationX(value:Number):void
	{		
		if (value == _rotationX)
			return;
		_rotationX = value;
		invalidate(true);
	}
	
    /**
     * @private
     */
	public function get rotationX():Number
	{		
		return _rotationX;
	}
	
	/**
	 * the rotationY, in degrees, added to the transform
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function set rotationY(value:Number):void
	{		
		if (value == _rotationY)
			return;
		_rotationY = value;
		invalidate(true);
	}
	
    /**
     * @private
     */
	public function get rotationY():Number
	{		
		return _rotationY;
	}
	
	/**
	 * the rotationZ, in degrees, added to the transform
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function set rotationZ(value:Number):void
	{		
		if (value == _rotationZ)
			return;
		_rotationZ = value;
		invalidate(false);
	}
	
    /**
     * @private
     */
	public function get rotationZ():Number
	{		
		return _rotationZ;
	}
	
	//------------------------------------------------------------------------------
	
	
	/**
	 * the multiplier applied to the scaleX of the transform.  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function set scaleX(value:Number):void
	{		
		if (value == _scaleX)
			return;
		_scaleX = value;
		invalidate(false);
	}
	
    /**
     * @private
     */
	public function get scaleX():Number
	{
		return _scaleX;
	}
	
	/**
	 * the multiplier applied to the scaleY of the transform.  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function set scaleY(value:Number):void
	{		
		if (value == _scaleY)
			return;
		_scaleY = value;
		invalidate(false);
	}
	
    /**
     * @private
     */
	public function get scaleY():Number
	{		
		return _scaleY;
	}
	
	
	/**
	 * the multiplier applied to the scaleZ of the transform.  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function set scaleZ(value:Number):void
	{		
		if (value == _scaleZ)
			return;
		_scaleZ = value;
		invalidate(true);
	}
	
    /**
     * @private
     */
	public function get scaleZ():Number
	{		
		return _scaleZ;
	}
	

	/**
	 * @private
	 * returns true if the transform has 3D values.
	 */
	mx_internal function get is3D():Boolean
	{
		if ((_flags & M3D_FLAGS_VALID) == 0)
			update3DFlags();
		return ((_flags & IS_3D) != 0);
	}
	

	//------------------------------------------------------------------------------
	
	/**
	 * @private
	 * invalidates our various cached values.  Any change to the CompoundTransform object that affects
	 * the various transforms should call this function. 
     * @param reason - the code indicating what changes to cause the invalidation.
     * @param affects3D - a flag indicating whether the change affects the 2D/3D nature of the various transforms.
     * @param dispatchChangeEvent - if true, the CompoundTransform will dispatch a change indicating that its underlying transforms
     * have been modified. 
  	 */
	private function invalidate(affects3D:Boolean,dispatchChangeEvent:Boolean = true):void
	{
		if (affects3D)
			_flags &= ~M3D_FLAGS_VALID;
			
		if (dispatchChangeEvent)
			dispatchEvent(new Event(Event.CHANGE));	
	}
	
	private static const EPSILON:Number = .001;
	/**
	 * @private
	 * updates the flags that indicate whether the layout, offset, and/or computed transforms are 3D in nature.  
	 * Since the user can set either the individual transform properties or the matrices directly, we compute these 
	 * flags based on what the current 'source of truth' is for each of these values.
  	 */
	private function update3DFlags():void
	{			
		if ((_flags & M3D_FLAGS_VALID) == 0)
		{
			var matrixIs3D:Boolean = ( // note that rotationZ is the same as rotation, and not a 3D affecting							
			  	(Math.abs(_scaleZ-1) > EPSILON) ||  // property.
			  	((Math.abs(_rotationX)+EPSILON)%360) > 2*EPSILON ||
			  	((Math.abs(_rotationY)+EPSILON)%360) > 2*EPSILON ||
			  	Math.abs(_z) > EPSILON
			  	);
			if (matrixIs3D)
				_flags |= IS_3D;
			else
				_flags &= ~IS_3D;				
			_flags |= M3D_FLAGS_VALID;
		}
	}
		
}
}

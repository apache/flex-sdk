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
	import mx.geom.ITransformable;
	import mx.core.AdvancedLayoutFeatures;
	use namespace mx_internal;	
	
	/**
	 *  A CompoundTransform represents a 2D or 3D matrix transform. It can be used in the offsets property on a UIComponent or GraphicElement.
	 */
	public class CompoundTransform extends EventDispatcher implements ITransformable
	{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    /**
     *  Constructor.
     */
		public function CompoundTransform()
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
	
	mx_internal var transformX:Number = 0;
	mx_internal var transformY:Number = 0;
	mx_internal var transformZ:Number = 0;

	mx_internal var dispatchChangeEvents:Boolean = true;
	
    /**
     * @private
     * a flag for use by the owning object indicating whether the owning object has a pending update
     * to its matrix.  If this is false, the CompoundTransform will notify the owning object of any changes
     * to its transform properties. Otherwise, it assumes the owner has already taken appropriate action. 
     * it is the owner's responsibility to set this flag.
     */
	mx_internal var updatePending:Boolean = false;
		
	
    /**
     * @private
     * slots for the 2D and 3D matrix transforms.  Note that 
     * these are only allocated and computed on demand -- many component instances will never use a 3D
     * matrix, for example. 
     */
	private var _matrix:Matrix;
	private var _matrix3D:Matrix3D;
	
	
    /**
     * @private
     * bit field flags for indicating which transforms are valid -- the layout properties, the matrices,
     * and the 3D matrices.  Since developers can set any of the three programmatically, the last one set
     * will always be valid, and the others will be invalid until validated on demand.
     */
	private static const MATRIX_VALID:uint		= 0x20;
	private static const MATRIX3D_VALID:uint		= 0x40;
	private static const PROPERTIES_VALID:uint 	= 0x80;
	
	
    /**
     * @private
     * flags for tracking whether the  transform is 3D. A transform is 3D if any of the 3D properties -- rotationX/Y, scaleZ, or z -- are set.
     */
	private static const IS_3D:uint 				= 0x200;
	private static const M3D_FLAGS_VALID:uint			= 0x400;
	 			
    /**
     * @private
     * constants to indicate which form of a transform -- the properties, matrix, or matrix3D -- is
     *  'the source of truth.'   
     */
	mx_internal static const SOURCE_NONE:uint				= 0;
	mx_internal static const SOURCE_PROPERTIES:uint			= 1;
	mx_internal static const SOURCE_MATRIX:uint 			= 2;
	mx_internal static const SOURCE_MATRIX3D:uint 			= 3;
	
    /**
     * @private
     * indicates the 'source of truth' for the transform.  
     */
	mx_internal var sourceOfTruth:uint = SOURCE_NONE;
	
    /**
     * @private
     * general storage for all of ur flags.  
     */
	private var _flags:uint =  PROPERTIES_VALID;
	
    /**
     * @private
     * flags that get passed to the invalidate method indicating why the invalidation is happening.
     */
	private static const INVALIDATE_FROM_PROPERTY:uint = 		4;						
	private static const INVALIDATE_FROM_MATRIX:uint = 			5;						
	private static const INVALIDATE_FROM_MATRIX3D:uint = 		6;						

	/**
	 * @private
	 * static data used by utility methods below
	 */
	private static var decomposition:Vector.<Number> = new Vector.<Number>();
	decomposition.push(0);
	decomposition.push(0);
	decomposition.push(0);
	decomposition.push(0);
	decomposition.push(0);

	private static const RADIANS_PER_DEGREES:Number = Math.PI / 180;

	//----------------------------------------------------------------------------
	
	/**
	 * the  x value of the transform
	 */
	public function set x(value:Number):void
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		if(value == _x)
			return;
		_x = value;
		invalidate(INVALIDATE_FROM_PROPERTY,false);
	}
    /**
     * @private
     */
	public function get x():Number
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		return _x;
	}
	
	/**
	 * the y value of the transform
	 */
	public function set y(value:Number):void
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		if(value == _y)
			return;
		_y = value;
		invalidate(INVALIDATE_FROM_PROPERTY,false);
	}
	
    /**
     * @private
     */
	public function get y():Number
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		return _y;
	}
	
	/**
	 * the z value of the transform
	 */
	public function set z(value:Number):void
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		if(value == _z)
			return;
		_z = value;
		invalidate(INVALIDATE_FROM_PROPERTY,true);
	}
	
    /**
     * @private
     */
	public function get z():Number
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		return _z;
	}
	
	//------------------------------------------------------------------------------
	
	
	/**
	 * the rotationX, in degrees, of the transform
	 */
	public function set rotationX(value:Number):void
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		if(value == _rotationX)
			return;
		_rotationX = value;
		invalidate(INVALIDATE_FROM_PROPERTY,true);
	}
	
    /**
     * @private
     */
	public function get rotationX():Number
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		return _rotationX;
	}
	
	/**
	 * the rotationY, in degrees, of the transform
	 */
	public function set rotationY(value:Number):void
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		if(value == _rotationY)
			return;
		_rotationY = value;
		invalidate(INVALIDATE_FROM_PROPERTY,true);
	}
	
    /**
     * @private
     */
	public function get rotationY():Number
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		return _rotationY;
	}
	
	/**
	 * the rotationZ, in degrees, of the transform
	 */
	public function set rotationZ(value:Number):void
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		if(value == _rotationZ)
			return;
		_rotationZ = value;
		invalidate(INVALIDATE_FROM_PROPERTY,false);
	}
	
    /**
     * @private
     */
	public function get rotationZ():Number
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		return _rotationZ;
	}
	
	//------------------------------------------------------------------------------
	
	
	/**
	 * the scaleX of the transform
	 */
	public function set scaleX(value:Number):void
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		if(value == _scaleX)
			return;
		_scaleX = value;
		invalidate(INVALIDATE_FROM_PROPERTY,false);
	}
	
    /**
     * @private
     */
	public function get scaleX():Number
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		return _scaleX;
	}
	
	/**
	 * the scaleY of the transform
	 */
	public function set scaleY(value:Number):void
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		if(value == _scaleY)
			return;
		_scaleY = value;
		invalidate(INVALIDATE_FROM_PROPERTY,false);
	}
	
    /**
     * @private
     */
	public function get scaleY():Number
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		return _scaleY;
	}
	
	
	/**
	 * the scaleZ of the transform
	 */
	public function set scaleZ(value:Number):void
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		if(value == _scaleZ)
			return;
		_scaleZ = value;
		invalidate(INVALIDATE_FROM_PROPERTY,true);
	}
	
    /**
     * @private
     */
	public function get scaleZ():Number
	{
		if ((_flags & PROPERTIES_VALID) == false) validatePropertiesFromMatrix();
		return _scaleZ;
	}
	

	/**
	 * @private
	 * returns true if the transform has 3D values.
	 */
	mx_internal function get is3D():Boolean
	{
		if((_flags & M3D_FLAGS_VALID) == false)
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
	private function invalidate(reason:uint,affects3D:Boolean,dispatchChangeEvent:Boolean = true):void
	{
		//race("invalidating: " + reason);
		switch(reason)
		{
			case INVALIDATE_FROM_PROPERTY:
				sourceOfTruth = SOURCE_PROPERTIES;
				_flags |= PROPERTIES_VALID;
				_flags &= ~MATRIX_VALID;
				_flags &= ~MATRIX3D_VALID;
				break;
			case INVALIDATE_FROM_MATRIX:
				sourceOfTruth = SOURCE_MATRIX;
				_flags |= MATRIX_VALID;
				_flags &= ~PROPERTIES_VALID;
				_flags &= ~MATRIX3D_VALID;
				break;
			case INVALIDATE_FROM_MATRIX3D:
				sourceOfTruth = SOURCE_MATRIX3D;
				_flags |= MATRIX3D_VALID;
				_flags &= ~PROPERTIES_VALID;
				_flags &= ~MATRIX_VALID;
				break;
		}						
		if(affects3D)
			_flags &= ~M3D_FLAGS_VALID;
			
		if(updatePending)
		{
			//race("\t** Aready invalid, aborting");
			return;
		}
		
		if(dispatchChangeEvents && dispatchChangeEvent)
			dispatchEvent(new Event(Event.CHANGE));	
	}
	
	/**
	 * @private
	 * updates the flags that indicate whether the layout, offset, and/or computed transforms are 3D in nature.  
	 * Since the user can set either the individual transform properties or the matrices directly, we compute these 
	 * flags based on what the current 'source of truth' is for each of these values.
  	 */
	private function update3DFlags():void
	{			
		if((_flags & M3D_FLAGS_VALID) == false)
		{
			var matrixIs3D:Boolean = false;

			switch(sourceOfTruth)
			{
				case SOURCE_PROPERTIES:
					matrixIs3D = ( // note that rotationZ is the same as rotation, and not a 3D affecting							
					  	_scaleZ != 1 ||  // property.
					  	_rotationX != 0 ||
					  	_rotationY != 0 ||
					  	_z != 0
					  	);
					break;
				case SOURCE_MATRIX:
					matrixIs3D = false;
					break;
				case SOURCE_MATRIX3D:
					matrixIs3D = true;
					break;					
			}

			if(matrixIs3D)
				_flags |= IS_3D;
			else
				_flags &= ~IS_3D;
				
			_flags |= M3D_FLAGS_VALID;
		}
	}
	

	/**
	 * the 2D matrix either set directly by the user, or composed by combining the transform center, scale, rotation
	 * and translation, in that order.  
	 */
	public function get matrix():Matrix
	{
		
		if(_flags & MATRIX_VALID)
			return _matrix;
			
		if((_flags & PROPERTIES_VALID) == false)
			validatePropertiesFromMatrix();
			
		var m:Matrix = _matrix;
		if(m == null)
			m = _matrix = new Matrix();
		else
			m.identity();
	
		AdvancedLayoutFeatures.build2DMatrix(m,transformX,transformY,
					  _scaleX,_scaleY,
					  _rotationZ,
					  _x,_y);	
		_flags |= MATRIX_VALID;
		return m;		
	}
		
	/**
	 * @private
	 */	
	public function set matrix(v:Matrix):void
	{
		if(_matrix== null)
		{
			_matrix = v.clone();
		}
		else
		{
			_matrix.identity();	
			_matrix.concat(v);			
		}
		invalidate(INVALIDATE_FROM_MATRIX,false);
	}
	
	
	
	
	
	
	
	/**
	 * @private
	 * a utility function for decomposing a matrix into its component scale, rotation, and translation parts.
	 */	
	private function decomposeMatrix(v:Vector.<Number>,m:Matrix):void
	{
	    // else decompose matrix.  Don't use MatrixDecompose(), it can return erronous values
	    //   when negative scales (and therefore skews) are in use.
	    var Ux:Number;
	    var Uy:Number;
	    var Vx:Number;
	    var Vy:Number;
	
	    Ux = m.a;
	    Uy = m.b;
	    v[3] = Math.sqrt(Ux*Ux + Uy*Uy);
	 
	    Vx = m.c;
	    Vy = m.d;
	    v[4] = Math.sqrt(Vx*Vx + Vy*Vy );
	 
	          // sign of the matrix determinant will tell us if the space is inverted by a 180 degree skew or not.
	    var determinant:Number = Ux*Vy - Uy*Vx;
	    if (determinant < 0) // if so, choose y-axis scale as the skewed one.  Unfortunately, its impossible to tell if it originally was the y or x axis that had the negative scale/skew.
	    {
	          v[4] = -(v[4]);
	          Vx = -Vx;
	          Vy = -Vy;
	    }
	 
	    v[2] = Math.atan2( Uy, Ux ) / RADIANS_PER_DEGREES;     
	    v[0] = m.tx;
	    v[1] = m.ty;
	}
	
	/**
	 * @private
	 * decomposes the offset transform matrices down into the convenience offset properties. Note that this is not
	 * a bi-directional transformation -- it is possible to create a matrix that can't be fully represented in the
	 * convenience properties. This function will pull from the matrix or matrix3D values, depending on which was most
	 * recently set
	 */
	private function validatePropertiesFromMatrix():void
	{
	    
	    if(sourceOfTruth == SOURCE_MATRIX3D)
	    {
	    	var result:Vector.<Vector3D> = _matrix3D.decompose();
	    	_x = result[0].x;
	    	_y = result[0].y;
	    	_z = result[0].z;
	    	_rotationX = result[1].x;
	    	_rotationY = result[1].y;
	    	_rotationZ = result[1].z;
	    	_scaleX = result[2].x;
	    	_scaleY = result[2].y;
	    	_scaleZ = result[2].z;
	    }                        
	    else if(sourceOfTruth == SOURCE_MATRIX)
	    {
	    	decomposeMatrix(decomposition,_matrix);
	    	_x = decomposition[0];
	    	_y = decomposition[1];
	    	_z = 0;
	    	_rotationX = 0;
	    	_rotationY = 0;
	    	_rotationZ = decomposition[2];
	    	_scaleX = decomposition[3];
	    	_scaleY = decomposition[4];
	    	_scaleZ = 1;
	    }
	    _flags |= PROPERTIES_VALID;
		
	}
	
	
	
	/**
	 * the 3D matrix either set directly by the user, or composed by combining the transform center, scale, rotation
	 * and translation, in that order. 
	 */
	public function get matrix3D():Matrix3D
	{
		if(_flags & MATRIX3D_VALID)
			return _matrix3D;
		
		if((_flags & PROPERTIES_VALID) == false)
			validatePropertiesFromMatrix();
							
		var m:Matrix3D = _matrix3D;
		if(m == null)
			m =  _matrix3D = new Matrix3D();
		else
			m.identity();
		
			AdvancedLayoutFeatures.build3DMatrix(m,transformX,transformY,transformZ,
					  _scaleX,_scaleY,_scaleZ,
					  _rotationX,_rotationY,_rotationZ,						  
					  _x,_y,_z);
		_flags |= MATRIX3D_VALID;
		return m;
		
	}
	
	/**
	 * @private
	 */
	public function set matrix3D(v:Matrix3D):void
	{
		if(_matrix3D == null)
		{
			_matrix3D = v.clone();
		}
		else
		{
			_matrix3D.identity();	
			_matrix3D.append(v);			
		}
		invalidate(INVALIDATE_FROM_MATRIX3D,true);
	}
}
}
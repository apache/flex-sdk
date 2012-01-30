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
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import mx.geom.CompoundTransform;
	import mx.geom.TransformOffsets;

	use namespace mx_internal;	
	
	/**
	 *  Transform Offsets can be assigned to any Component or GraphicElement to modify the transform
	 *  of the object beyond where its parent layout places it.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class AdvancedLayoutFeatures
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
		public function AdvancedLayoutFeatures()
		{
			layout = new CompoundTransform();
		}
		
			

    /**
     * @private
     * a flag for use by the owning object indicating whether the owning object has a pending update
     * to the computed matrix.  it is the owner's responsibility to set this flag.
     */
	public var updatePending:Boolean = false;
	
    /**
     * storage for the layer value. Layering is considered 'advanced' layout behavior, and not something
     * that gets used by the majority of the components out there.  So if a component has a non-zero layer,
     * it will allocate a AdvancedLayoutFeatures object and store the value here.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public var layer:Number = 0;


	
    /**
     * @private
     * slots for the various 2D and 3D matrices for layout, offset, and computed transforms.  Note that 
     * these are only allocated and computed on demand -- many component instances will never use a 3D
     * matrix, for example. 
     */
	protected var _computedMatrix:Matrix;
	protected var _computedMatrix3D:Matrix3D;
	
	/**
	 * @private
	 * the layout visible transform as defined by the user and parent layout.
	 */
	protected var layout:CompoundTransform;
	
	/**
	 * @private
	 * offset values applied by the user
	 */
	private var _offsets:TransformOffsets;
	
    /**
     * @private
     * bit field flags for indicating which transforms are valid -- the layout properties, the matrices,
     * and the 3D matrices.  Since developers can set any of the three programmatically, the last one set
     * will always be valid, and the others will be invalid until validated on demand.
     */
	private static const COMPUTED_MATRIX_VALID:uint 	= 0x1;
	private static const COMPUTED_MATRIX3D_VALID:uint 	= 0x2;
	
    /**
     * @private
     * general storage for all of our flags.  
     */
	private var _flags:uint = 0;
	
	/**
	 * @private
	 * static data used by utility methods below
	 */
	private static var reVT:Vector3D = new Vector3D(0,0,0);
	private static var reVR:Vector3D = new Vector3D(0,0,0);
	private static var reVS:Vector3D = new Vector3D(1,1,1);
	
	private static var reV:Vector.<Vector3D> = new Vector.<Vector3D>();
	reV.push(reVT);
	reV.push(reVR);
	reV.push(reVS);


	private static const RADIANS_PER_DEGREES:Number = Math.PI / 180;

	private static const ZERO_REPLACEMENT_IN_3D:Number = .00000000000001;
	
	//------------------------------------------------------------------------------
	
    /**
     * layout transform convenience property.  Represents the x value of the layout matrix used in layout and in 
     * the computed transform.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public function set layoutX(value:Number):void
	{
		layout.x = value;
		invalidate();
	}

    /**
     * @private
     */
	public function get layoutX():Number
	{
		return layout.x;
	}
    /**
     * layout transform convenience property.  Represents the y value of the layout matrix used in layout and in 
     * the computed transform.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public function set layoutY(value:Number):void
	{
		layout.y = value;
		invalidate();
	}
	
    /**
     * @private
     */
	public function get layoutY():Number
	{
		return layout.y;
	}
	
    /**
     * layout transform convenience property.  Represents the z value of the layout matrix used in layout and in 
     * the computed transform.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public function set layoutZ(value:Number):void
	{
		layout.z = value;
		invalidate();
	}
	
    /**
     * @private
     */
	public function get layoutZ():Number
	{
		return layout.z;
	}
	
	//------------------------------------------------------------------------------
	
    /**
     * @private
     * the x value of the point around which any rotation and scale is performed in both the layout and computed matrix.
     */
	public function set transformX(value:Number):void
	{
		layout.transformX = value;
		invalidate();
	}
    /**
     * @private
     */
	public function get transformX():Number
	{
		return layout.transformX;
	}
	
    /**
     * @private
     * the y value of the point around which any rotation and scale is performed in both the layout and computed matrix.
     */
	public function set transformY(value:Number):void
	{
		layout.transformY = value;
		invalidate();
	}
	
    /**
     * @private
     */
	public function get transformY():Number
	{
		return layout.transformY;
	}
	
    /**
     * @private
     * the z value of the point around which any rotation and scale is performed in both the layout and computed matrix.
     */
	public function set transformZ(value:Number):void
	{
		layout.transformZ = value;	
		invalidate();
	}
	
    /**
     * @private
     */
	public function get transformZ():Number
	{
		return layout.transformZ;
	}

//------------------------------------------------------------------------------
	
	
    /**
     * layout transform convenience property.  Represents the rotation around the X axis of the layout matrix used in layout and in 
     * the computed transform.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public function set layoutRotationX(value:Number):void
	{
		layout.rotationX= value;
		invalidate();
	}
	
    /**
     * @private
     */
	public function get layoutRotationX():Number
	{
		return layout.rotationX;
	}
	
    /**
     * layout transform convenience property.  Represents the rotation around the Y axis of the layout matrix used in layout and in 
     * the computed transform.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public function set layoutRotationY(value:Number):void
	{
		layout.rotationY= value;
		invalidate();
	}
	
    /**
     * @private
     */
	public function get layoutRotationY():Number
	{
		return layout.rotationY;
	}
	
    /**
     * layout transform convenience property.  Represents the rotation around the Z axis of the layout matrix used in layout and in 
     * the computed transform.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public function set layoutRotationZ(value:Number):void
	{
		layout.rotationZ= value;
		invalidate();
	}
	
    /**
     * @private
     */
	public function get layoutRotationZ():Number
	{
		return layout.rotationZ;
	}
	
	//------------------------------------------------------------------------------
	
	
    /**
     * layout transform convenience property.  Represents the scale along the X axis of the layout matrix used in layout and in 
     * the computed transform.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public function set layoutScaleX(value:Number):void
	{
		layout.scaleX = value;
		invalidate();
	}
	
    /**
     * @private
     */
	public function get layoutScaleX():Number
	{
		return layout.scaleX;
	}
	
    /**
     * layout transform convenience property.  Represents the scale along the Y axis of the layout matrix used in layout and in 
     * the computed transform.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public function set layoutScaleY(value:Number):void
	{
		layout.scaleY= value;
		invalidate();
	}
	
    /**
     * @private
     */
	public function get layoutScaleY():Number
	{
		return layout.scaleY;
	}
	
	
    /**
     * layout transform convenience property.  Represents the scale along the Z axis of the layout matrix used in layout and in 
     * the computed transform.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public function set layoutScaleZ(value:Number):void
	{
		layout.scaleZ= value;
		invalidate();
	}
	
    /**
     * @private
     */
	public function get layoutScaleZ():Number
	{
		return layout.scaleZ;
	}

    /**
     * @private
     * The 2D matrix used during layout calculations to determine the layout and size of the component and its parent and siblings.
     * If the convenience properties are set, this matrix is built from those properties.  
     * If the matrix is set directly, the convenience properties will be updated to values derived from this matrix.
     * This matrix is used in the calculation of the computed transform if possible. Under certain circumstances, such as when 
     * offsets are provided, the decomposed layout properties will be used instead.
     */
	public function set layoutMatrix(value:Matrix):void
	{
		layout.matrix = value;
		invalidate();
	}
	
	
    /**
     * @private
     */
	public function get layoutMatrix():Matrix
	{
		return layout.matrix;
							
	}
	

    /**
     * @private
     * The 3D matrix used during layout calculations to determine the layout and size of the component and its parent and siblings.
     * This matrix is only used by parents that respect 3D layoyut.
     * If the convenience properties are set, this matrix is built from those properties.  
     * If the matrix is set directly, the convenience properties will be updated to values derived from this matrix.
     * This matrix is used in the calculation of the computed transform if possible. Under certain circumstances, such as when 
     * offsets are provided, the decomposed layout properties will be used instead.
     */
	public function set layoutMatrix3D(value:Matrix3D):void
	{
		layout.matrix3D = value;
		invalidate();
	}
	
    /**
     * @private
     */
	public function get layoutMatrix3D():Matrix3D
	{
		return layout.matrix3D;
	}
	
	/**
	 * true if the computed transform has 3D values.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get is3D():Boolean
	{
		return (layout.is3D || (offsets != null && offsets.is3D));
	}

	/**
	 * true if the layout transform has 3D values.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get layoutIs3D():Boolean
	{
		return layout.is3D;
	}

	//------------------------------------------------------------------------------
	
	/** offsets to the transform convenience properties that are applied when a component is rendered. If this 
	 * property is set, its values will be added to the layout transform properties to determine the true matrix used to render
	 * the component
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function set offsets(value:TransformOffsets):void
	{
		if(_offsets != null)
		{
			_offsets.removeEventListener(Event.CHANGE,offsetsChangedHandler);
			_offsets.owner = null;
		}
		_offsets = value;
		if(_offsets != null)
		{
			_offsets.addEventListener(Event.CHANGE,offsetsChangedHandler);
			_offsets.owner = this;
		}
		invalidate();		
	}
	
	public function get offsets():TransformOffsets
	{
		return _offsets;
	}
	
	private function offsetsChangedHandler(e:Event):void
	{
		invalidate();		
	}
	
	//------------------------------------------------------------------------------
	
	/**
	 * @private
	 * invalidates our various cached values.  Any change to the AdvancedLayoutFeatures object that affects
	 * the various transforms should call this function. 	
     * @param reason - the code indicating what changes to cause the invalidation.
     * @param affects3D - a flag indicating whether the change affects the 2D/3D nature of the various transforms.
     * @param dispatchChangeEvent - if true, the AdvancedLayoutFeatures will dispatch a change indicating that its underlying transforms
     * have been modified. 
  	 */
	private function invalidate():void
	{						
		_flags &= ~COMPUTED_MATRIX_VALID;
		_flags &= ~COMPUTED_MATRIX3D_VALID;
	}
	
	
	/**
	 * the computed matrix, calculated by combining the layout matrix and  and any offsets provided..
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get computedMatrix():Matrix
	{
		if(_flags & COMPUTED_MATRIX_VALID)
			return _computedMatrix;
	
		if(offsets == null)
		{
			return layout.matrix;
		}			
		
		var m:Matrix = _computedMatrix;
		if(m == null)
			m = _computedMatrix = new Matrix();
		else
			m.identity();

			build2DMatrix(m,layout.transformX,layout.transformY,
						  layout.scaleX * offsets.scaleX,layout.scaleY * offsets.scaleY,
						  layout.rotationZ + offsets.rotationZ,
						  layout.x + offsets.x,layout.y + offsets.y);					
	
		_flags |= COMPUTED_MATRIX_VALID;
		return m;
	}
	
	/**
	 * the computed 3D matrix, calculated by combining the 3D layout matrix and  and any offsets provided..
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get computedMatrix3D():Matrix3D
	{
		if(_flags & COMPUTED_MATRIX3D_VALID)
			return _computedMatrix3D;
	
	
		if(offsets == null)
		{
			return layout.matrix3D;
		}

		var m:Matrix3D = _computedMatrix3D;
		if(m == null)
			m = _computedMatrix3D = new Matrix3D();
		else
			m.identity();
	
	
		build3DMatrix(m,layout.transformX,layout.transformY,layout.transformZ,					  
				  layout.scaleX*offsets.scaleX,layout.scaleY*offsets.scaleY,layout.scaleZ*offsets.scaleZ,
				  layout.rotationX+offsets.rotationX,layout.rotationY+offsets.rotationY,layout.rotationZ+offsets.rotationZ,
				  layout.x+offsets.x,layout.y+offsets.y,layout.z+offsets.z);
	
		_flags |= COMPUTED_MATRIX3D_VALID;
		return m;			
	}
	
	
	
	

	
	/**
	 * @private
	 * convenience function for building a 2D matrix from the convenience properties 
	 */
	public static function build2DMatrix(m:Matrix,
									tx:Number,ty:Number,
									sx:Number,sy:Number,
									rz:Number,
									x:Number,y:Number):void
	{
		m.translate(-tx,-ty);
		m.scale(sx,sy);
		m.rotate(rz* RADIANS_PER_DEGREES);
		m.translate(x+tx,y+ty);			
	}


	/**
	 * @private
	 * convenience function for building a 3D matrix from the convenience properties 
	 */
	public static function build3DMatrix(m:Matrix3D,
										tx:Number,ty:Number,tz:Number,
										sx:Number,sy:Number,sz:Number,
										rx:Number,ry:Number,rz:Number,
										x:Number,y:Number,z:Number):void
	{
		reVR.x = rx * RADIANS_PER_DEGREES;
		reVR.y = ry * RADIANS_PER_DEGREES;
		reVR.z = rz * RADIANS_PER_DEGREES;
		m.recompose(reV);
		if(sx == 0)
			sx = ZERO_REPLACEMENT_IN_3D;
		if(sy == 0)
			sy = ZERO_REPLACEMENT_IN_3D;
		if(sz == 0)
			sz = ZERO_REPLACEMENT_IN_3D;
		m.prependScale(sx,sy,sz);
		m.prependTranslation(-tx,-ty,-tz);
		m.appendTranslation(tx+x,ty+y,tz+z);
	}									
						

	/**
	 * @private
	 * call when you're about to change the transform, and when complete you want to keep a particular point fixed in its parent coordinate space.
	 */
	public function prepareForTransformCenterAdjustment(affectLayout:Boolean,propertyIs3D:Boolean,tx:Number = NaN,ty:Number = NaN,tz:Number = NaN):Object
	{
		var computedCenterV:Vector3D;
		var computedCenterP:Point;
		var token:Object = {};
		
		if(isNaN(tx))
			tx = layout.transformX;
		if(isNaN(ty))
			ty = layout.transformY;
		if(isNaN(tz))
			tz = layout.transformZ;
				
		var needAdjustment:Boolean = (tx != 0 || ty != 0 || tz != 0);
		
		if(needAdjustment == false)
		{
			return null;		
		}

		if (is3D || propertyIs3D) 
		{
			var centerV:Vector3D = new Vector3D(tx,ty,tz);
			if(affectLayout)
			{
				var layoutCenterV:Vector3D = layoutMatrix3D.transformVector(centerV);
				layoutCenterV.project();
				token.layout = layoutCenterV;
			} 
			
			if(_offsets != null)
			{			
				computedCenterV = computedMatrix3D.transformVector(centerV);
				computedCenterV.project();
				token.offset = computedCenterV;
			}
			token.center = centerV;
		}
		else
		{
			var centerP:Point = new Point(tx,ty);
			if(affectLayout)
				token.layout = layoutMatrix.transformPoint(centerP);

			if(_offsets != null)
				token.offset = computedMatrix.transformPoint(centerP);
			token.center = centerP;
		}
		return token;
	}

	/**
	 * @private
	 * call when you've changed the inputs to the computed transform to make any adjustments to keep a particular point fixed in parent coordinates.
	 */
	public function completeTransformCenterAdjustment(token:Object,changeIs3D:Boolean):void
	{
		if(token == null)
			return;
			
		var computedCenterV:Vector3D;
		var computedCenterP:Point;
		var layoutCenterV:Vector3D;
		var layoutCenterP:Point;
		
		if(is3D || changeIs3D)
		{
			var centerV:Vector3D = token.center;
			computedCenterV = token.offset;
			layoutCenterV = token.layout;
			if(layoutCenterV != null)
			{
				var adjustedLayoutCenterV:Vector3D = layoutMatrix3D.transformVector(centerV);
				adjustedLayoutCenterV.project();
				if(adjustedLayoutCenterV.equals(layoutCenterV) == false)
				{
					layout.translateBy(layoutCenterV.x - adjustedLayoutCenterV.x,
								layoutCenterV.y - adjustedLayoutCenterV.y,	
								layoutCenterV.z - adjustedLayoutCenterV.z
								);
					invalidate(); 
				}		
			}
			if(computedCenterV != null)
			{
				var adjustedComputedCenterV:Vector3D = computedMatrix3D.transformVector(centerV);
				adjustedComputedCenterV.project();
				if(adjustedComputedCenterV.equals(computedCenterV) == false)
				{
					offsets.x +=computedCenterV.x - adjustedComputedCenterV.x;
					offsets.y += computedCenterV.y - adjustedComputedCenterV.y;
					offsets.z += computedCenterV.z - adjustedComputedCenterV.z;
					invalidate(); 
				}		
			}
		}
		else
		{
			var centerP:Point = token.center;
			computedCenterP = token.offset;
			layoutCenterP = token.layout;
			if(layoutCenterP != null)
			{
				var adjustedLayoutCenterP:Point = layoutMatrix.transformPoint(centerP);
				if(adjustedLayoutCenterP.equals(layoutCenterP) == false)
				{
					layout.translateBy(layoutCenterP.x - adjustedLayoutCenterP.x,
								layoutCenterP.y - adjustedLayoutCenterP.y,
								0
								);
					invalidate(); 
				}		
			}
			
			if(computedCenterP != null)
			{			
				var adjustedComputedCenterP:Point = computedMatrix.transformPoint(centerP);
				if(adjustedComputedCenterP.equals(computedCenterP) == false)
				{
					_offsets.x += computedCenterP.x - adjustedComputedCenterP.x;
				    _offsets.y += computedCenterP.y - adjustedComputedCenterP.y;
					invalidate(); 
				}		
			}
		}
	}	
	
	/**
	 * A utility method to update the rotation and scale of the transform while keeping a particular point, specified in the component's own coordinate space, 
	 * fixed in the parent's coordinate space.  This function will assign the rotation and scale values provided, then update the x/y/z properties
	 * as necessary to keep tx/ty/tz fixed.
	 * @param rx,ry,rz the new values for the rotation of the transform
	 * @param sx,sy,sz the new values for the scale of the transform
	 * @param tx,ty,tz the point, in the component's own coordinates, to keep fixed relative to its parent.
	 * affectLayout: whether the rotation and scale should be applied to the layout transform or the offsets.  Note that the offsets might be updated
	 * even when the new values are being applied to the layout.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function transformAround(rx:Number,ry:Number,rz:Number,sx:Number,sy:Number,sz:Number,tx:Number,ty:Number,tz:Number,affectLayout:Boolean = true):void
	{
		var is3D:Boolean = ((!isNaN(rx) && rx != 0) || (!isNaN(ry) && ry != 0) || (!isNaN(sz) && sz != 1));
		
		var token:Object = prepareForTransformCenterAdjustment(affectLayout,is3D,tx,ty,tz);
		if(affectLayout)
		{
			if(!isNaN(rx))
				layout.rotationX = rx;
			if(!isNaN(ry))
				layout.rotationY = ry;
			if(!isNaN(rz))
				layout.rotationZ = rz;
			if(!isNaN(sx))
				layout.scaleX = sx;
			if(!isNaN(sx))
				layout.scaleY = sy;
			if(!isNaN(sz))
				layout.scaleZ = sz;			
		}
		else
		{
			if(_offsets == null)
				offsets = new TransformOffsets();
				
			if(!isNaN(rx))
				_offsets.rotationX = rx;
			if(!isNaN(ry))
				_offsets.rotationY = ry;
			if(!isNaN(rz))
				_offsets.rotationZ = rz;
			if(!isNaN(sx))
				_offsets.scaleX = sx;
			if(!isNaN(sx))
				_offsets.scaleY = sy;
			if(!isNaN(sz))
				_offsets.scaleZ = sz;			
		}
		invalidate();
		completeTransformCenterAdjustment(token,is3D);
		
	}
		
}
}


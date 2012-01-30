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

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Matrix;

import mx.core.mx_internal;
import mx.events.PropertyChangeEvent;
import mx.geom.CompoundTransform;

use namespace mx_internal;

[DefaultProperty("entries")]

/**
 *  The GradientBase class is the base class for
 *  LinearGradient, LinearGradientStroke, and RadialGradient.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class GradientBase extends EventDispatcher
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
	public function GradientBase() 
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

 	/**
	 *  @private
	 */
	mx_internal var colors:Array /* of uint */ = [];

 	/**
	 *  @private
	 */
	mx_internal var ratios:Array /* of Number */ = [];

 	/**
	 *  @private
	 */
	mx_internal var alphas:Array /* of Number */ = [];
	
	//--------------------------------------------------------------------------
	//
	//  Class Properties
	//
	//--------------------------------------------------------------------------
	
	
	/**
	 *  Value of the width and height of the untransformed gradient
	 * 
	 *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
	 */ 
	public static const GRADIENT_DIMENSION:Number = 1638.4;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
    //  angle
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the angle property.
     */
    mx_internal var _angle:Number;
    
    [Inspectable(category="General")]
	[Deprecated(replacement="rotation")]
    /**
     *  By default, the LinearGradientStroke defines a transition
     *  from left to right across the control. 
     *  Use the <code>angle</code> property to control the transition direction. 
     *  For example, a value of 180.0 causes the transition
     *  to occur from right to left, rather than from left to right.
     *
     *  @default 0.0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get angle():Number
    {
        return _angle / Math.PI * 180;
    }

    /**
     *  @private
     */
    public function set angle(value:Number):void
    {
        var oldValue:Number = _angle;
        _angle = value / 180 * Math.PI;
        
        dispatchGradientChangedEvent("angle", oldValue, _angle);
    }  
    
    //----------------------------------
    //  compoundTransform
    //----------------------------------
    
    /**
     *  Holds the matrix and the convenience transform properties (<code>x</code>, <code>y</code>, and <code>rotation</code>).
     *  The compoundTransform is only created when the <code>matrix</code> property is set. 
     */
    protected var compoundTransform:CompoundTransform;

	//----------------------------------
	//  entries
	//----------------------------------

 	/**
	 *  @private
	 *  Storage for the entries property.
	 */
	private var _entries:Array = [];
	
	[Bindable("propertyChange")]
    [Inspectable(category="General", arrayType="mx.graphics.GradientEntry")]

	/**
	 *  An Array of GradientEntry objects
	 *  defining the fill patterns for the gradient fill.
	 *
	 *  @default []
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get entries():Array
	{
		return _entries;
	}

 	/**
	 *  @private
	 */
	public function set entries(value:Array):void
	{
		var oldValue:Array = _entries;
		_entries = value;
		
		processEntries();
		
		dispatchGradientChangedEvent("entries", oldValue, value);
	}
	
	//----------------------------------
    //  interpolationMethod
    //----------------------------------

    /**
     *  @private
     *  Storage for the interpolationMethod property.
     */
    private var _interpolationMethod:String = "rgb";
    
    [Inspectable(category="General", enumeration="rgb,linearRGB", defaultValue="rgb")]

    /**
     *  A value from the InterpolationMethod class
     *  that specifies which interpolation method to use.
     *
     *  <p>Valid values are <code>InterpolationMethod.LINEAR_RGB</code>
     *  and <code>InterpolationMethod.RGB</code>.</p>
     *  
     *  @default InterpolationMethod.RGB
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get interpolationMethod():String
    {
        return _interpolationMethod;
    }
    
    /**
     *  @private
     */
    public function set interpolationMethod(value:String):void
    {
        var oldValue:String = _interpolationMethod;
        if (value != oldValue)
        {
            _interpolationMethod = value;
            
            dispatchGradientChangedEvent("interpolationMethod", oldValue, value);
        }
    }
    
    //----------------------------------
    //  matrix
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the matrix property.
     */
    private var _matrix:Matrix;
    
    [Inspectable(category="General")]

    /**
     *  An array of values used for matrix transformation.
     * 
     *  <p>The gradient <code>scaleX</code> and <code>scaleY</code> properties represent pixels while the Matrix scale properties represent multipliers. 
     *  Thus they are not compatible. 
     *  Another difference is the most of the transform properties (<code>x</code>, <code>y</code>, <code>scaleX</code>, and <code>scaleY</code>) 
     *  support NaN values while the matrix does not. A NaN value means that the gradient will choose an appropriate value.</p>
     *  
     *  <p>The <code>scaleX</code> and <code>scaleY</code> properties can not be represented by the matrix. 
     *  Once the matrix is set, <code>scaleX</code> and <code>scaleY</code> can no longer be set. 
     *  Also, <code>x</code> and <code>y</code> can not be set to NaN. 
     *  The matrix can be set back to null which also resets all of the convenience transform properties back to their default values.</p>
     *  
     *  <p>If the matrix is set, then the gradient draw logic will scale the gradient to fit the bounds of the graphic element. 
     *  It will then position the gradient in the upper left corner of the graphic element. 
     *  Finally, it will apply the matrix transformations.</p>
    
     *  <p>By default, the LinearGradientStroke defines a transition
     *  from left to right across the control. 
     *  Use the <code>rotation</code> property to control the transition direction. 
     *  For example, a value of 180.0 causes the transition
     *  to occur from right to left, rather than from left to right.</p>
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get matrix():Matrix
    {
        return compoundTransform ? compoundTransform.matrix : null;
    }

    /**
     *  @private
     */
    public function set matrix(value:Matrix):void
    {
    	var oldValue:Matrix = matrix;
    	
    	var oldX:Number = x;
    	var oldY:Number = y;
    	var oldRotation:Number = rotation;
    	
    	if (value == null)
    	{
    		compoundTransform = null;
    		x = NaN;
    		y = NaN;
    		rotation = 0;
    	}	
    	else
    	{
	    	// Create the transform if none exists. 
	    	if (compoundTransform == null)
	            compoundTransform = new CompoundTransform();
	       	compoundTransform.matrix = value; // CompoundTransform will create a clone
	       	
	       	dispatchGradientChangedEvent("x", oldX, compoundTransform.x);
	       	dispatchGradientChangedEvent("y", oldY, compoundTransform.y);
	       	dispatchGradientChangedEvent("rotation", oldRotation, compoundTransform.rotationZ);
	    }
    }
    
    //----------------------------------
    //  rotation
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the rotation property.
     */
    private var _rotation:Number = 0.0;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  By default, the LinearGradientStroke defines a transition
     *  from left to right across the control. 
     *  Use the <code>rotation</code> property to control the transition direction. 
     *  For example, a value of 180.0 causes the transition
     *  to occur from right to left, rather than from left to right.
     *
     *  @default 0.0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get rotation():Number
    {
        return compoundTransform ? compoundTransform.rotationZ : _rotation;
    }

    /**
     *  @private
     */
    public function set rotation(value:Number):void
    {
        if (value != rotation)
        {
        	var oldValue:Number = rotation;
        	
        	if (compoundTransform)
                compoundTransform.rotationZ = value;
        	else
                _rotation = value;   
        	dispatchGradientChangedEvent("rotation", oldValue, value);
        }
    }

    //----------------------------------
	//  spreadMethod
	//----------------------------------
	
	/**
     *  @private
     *  Storage for the spreadMethod property.
     */
    private var _spreadMethod:String = "pad";
    
    [Bindable("propertyChange")]
    [Inspectable(category="General", enumeration="pad,reflect,repeat", defaultValue="pad")]

    /**
     *  A value from the SpreadMethod class
     *  that specifies which spread method to use.
     *
     *  <p>Valid values are <code>SpreadMethod.PAD</code>, 
     *  <code>SpreadMethod.REFLECT</code>,
     *  and <code>SpreadMethod.REPEAT</code>.</p>
     *  
     *  @default SpreadMethod.PAD
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get spreadMethod():String
    {
        return _spreadMethod;
    }
    
    /**
     *  @private
     */
    public function set spreadMethod(value:String):void
    {
        var oldValue:String = _spreadMethod;
        if (value != oldValue)
        {
            _spreadMethod = value;    
            dispatchGradientChangedEvent("spreadMethod", oldValue, value);
        }
    }
    
    //----------------------------------
	//  x
	//----------------------------------
	
    private var _x:Number;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  The distance by which to translate each point along the x axis.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get x():Number
    {
    	return compoundTransform ? compoundTransform.x : _x;	
    }
    
	/**
	 *  @private
	 */
    public function set x(value:Number):void
    {
        var oldValue:Number = x;
    	if (value != oldValue)
    	{
    		if (compoundTransform)
    		{
    			// If we have a compoundTransform, only non-NaN values are allowed
    			if (!isNaN(value))
                    compoundTransform.x = value; 
    		}   
            else
            {
                _x = value;
            }       
    		dispatchGradientChangedEvent("x", oldValue, value);
    	}
    }
    
    //----------------------------------
	//  y
	//----------------------------------
    
    private var _y:Number;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
     /**
     *  The distance by which to translate each point along the y axis.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get y():Number
    {
    	return compoundTransform ? compoundTransform.y : _y;	
    }
    
    /**
     *  @private
     */
    public function set y(value:Number):void
    {
    	var oldValue:Number = y;
    	if (value != oldValue)
    	{
    		if (compoundTransform)
    		{
    			// If we have a compoundTransform, only non-NaN values are allowed
    		    if (!isNaN(value))
                    compoundTransform.y = value;
            }
            else
            {
                _y = value;                
            }
                
    		dispatchGradientChangedEvent("y", oldValue, value);
    	}
    }
    
    mx_internal function get rotationInRadians():Number
    {
    	return rotation / 180 * Math.PI;
    }

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Extract the gradient information in the public <code>entries</code>
	 *  Array into the internal <code>colors</code>, <code>ratios</code>,
	 *  and <code>alphas</code> arrays.
	 */
	private function processEntries():void
	{
		colors = [];
		ratios = [];
		alphas = [];

		if (!_entries || _entries.length == 0)
			return;

		var ratioConvert:Number = 255;

		var i:int;
		
		var n:int = _entries.length;
		for (i = 0; i < n; i++)
		{
			var e:GradientEntry = _entries[i];
			e.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, 
							   entry_propertyChangeHandler, false, 0, true);
			colors.push(e.color);
			alphas.push(e.alpha);
			ratios.push(e.ratio * ratioConvert);
		}
		
		if (isNaN(ratios[0]))
			ratios[0] = 0;
			
		if (isNaN(ratios[n - 1]))
			ratios[n - 1] = 255;
		
		i = 1;

		while (true)
		{
			while (i < n && !isNaN(ratios[i]))
			{
				i++;
			}

			if (i == n)
				break;
				
			var start:int = i - 1;
			
			while (i < n && isNaN(ratios[i]))
			{
				i++;
			}
			
			var br:Number = ratios[start];
			var tr:Number = ratios[i];
			
			for (var j:int = 1; j < i - start; j++)
			{
				ratios[j] = br + j * (tr - br) / (i - start);
			}
		}
	}

	/**
	 *  Dispatch a gradientChanged event.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	mx_internal function dispatchGradientChangedEvent(prop:String,
													  oldValue:*, value:*):void
	{
		dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, prop,
															oldValue, value));
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private function entry_propertyChangeHandler(event:Event):void
	{
		processEntries();

		dispatchGradientChangedEvent("entries", entries, entries);
	}
}

}

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

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.events.EventDispatcher;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.getDefinitionByName;

import mx.events.PropertyChangeEvent;
import mx.geom.CompoundTransform;


/** 
 *  Defines a set of values used to fill an area on screen
 *  with a bitmap or other DisplayObject.
 *  
 *  @see mx.graphics.IFill
 *  @see flash.display.Bitmap
 *  @see flash.display.BitmapData
 *  @see flash.display.DisplayObject
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class BitmapFill extends EventDispatcher implements IFill
{
	include "../core/Version.as";

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
	public function BitmapFill()
 	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	private static const RADIANS_PER_DEGREES:Number = Math.PI / 180;
	private static var transformMatrix:Matrix = new Matrix();
    
    
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  compoundTransform
    //----------------------------------
    
    protected var compoundTransform:CompoundTransform;        
    
    //----------------------------------
    //  matrix
    //----------------------------------
    
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
        var oldScaleX:Number = scaleX;
        var oldScaleY:Number = scaleY;
        
        if (value == null)
        {
            compoundTransform = null;
        }	
        else
        {
            // Create the transform if none exists. 
            if(compoundTransform == null)
                compoundTransform = new CompoundTransform();
            compoundTransform.matrix = value; // CompoundTransform will create a clone
            
            dispatchFillChangedEvent("x", oldX, compoundTransform.x);
            dispatchFillChangedEvent("y", oldY, compoundTransform.y);
            dispatchFillChangedEvent("scaleX", oldScaleX, compoundTransform.scaleX);
            dispatchFillChangedEvent("scaleY", oldScaleY, compoundTransform.scaleY);
            dispatchFillChangedEvent("rotation", oldRotation, compoundTransform.rotationZ);
        }
    }
    
	//----------------------------------
	//  originX
	//----------------------------------

	private var _originX:Number = 0;

	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
	[Deprecated(replacement="transformX", since="4.0")]
	
	/**
	 *  The horizontal origin for the bitmap fill.
	 *  The bitmap fill is offset so that this point appears at the origin.
	 *  Scaling and rotation of the bitmap are performed around this point.
	 *
	 *  @default 0 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get originX():Number
	{
		return transformX;
	}
	
	public function set originX(value:Number):void
	{
		transformX = value;
	}
	
	//----------------------------------
	//  originY
	//----------------------------------

	private var _originY:Number = 0;

	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
	[Deprecated(replacement="transformY", since="4.0")]
	
	/**
	 *  The vertical origin for the bitmap fill.
	 *  The bitmap fill is offset so that this point appears at the origin.
	 *  Scaling and rotation of the bitmap are performed around this point.
	 *
	 *  @default 0 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get originY():Number
	{
		return transformY;
	}
	
	public function set originY(value:Number):void
	{
		transformY = value;
	}

	//----------------------------------
	//  offsetX
	//----------------------------------
	private var _offsetX:Number = 0;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
	[Deprecated(replacement="x", since="4.0")]
	
	/**
	 *  How far the bitmap is horizontally offset from the origin.
	 *  This adjustment is performed after rotation and scaling.
	 *
	 *  @default 0
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get offsetX():Number
	{
		return x;
	}
	
	public function set offsetX(value:Number):void
	{
		x = value;
	}

	//----------------------------------
	//  offsetY
	//----------------------------------
	private var _offsetY:Number = 0;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
	[Deprecated(replacement="y", since="4.0")]
	
	/**
	 *  How far the bitmap is vertically offset from the origin.
	 *  This adjustment is performed after rotation and scaling.
	 *
	 *  @default 0
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get offsetY():Number
	{
		return y;
	}
	
	public function set offsetY(value:Number):void
	{
		y = value;
	}

	//----------------------------------
	//  repeat
	//----------------------------------

	private var _repeat:Boolean = true;
	
	[Bindable("propertyChange")]
    [Inspectable(category="General")]

	
	/**
	 *  Whether the bitmap is repeated to fill the area.
	 *  Set to <code>true</code> to cause the fill to tile outward
	 *  to the edges of the filled region.
	 *  Set to <code>false</code> to end the fill at the edge of the region.
	 *
	 *  @default true
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get repeat():Boolean
	{
		return _repeat;
	}
	
	public function set repeat(value:Boolean):void
	{
		var oldValue:Boolean = _repeat;
		if (value != oldValue)
		{
			_repeat = value;
			dispatchFillChangedEvent("repeat", oldValue, value);
		}
	}

	//----------------------------------
	//  rotation
	//----------------------------------
	
	private var _rotation:Number = 0;

	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
	
	/**
	 *  The number of degrees to rotate the bitmap.
	 *  Valid values range from 0.0 to 360.0.
	 *  
	 *  @default 0
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
	
	public function set rotation(value:Number):void
	{      
        if (value != rotation)
        {
            var oldValue:Number = rotation;
            
            if (compoundTransform)
                compoundTransform.rotationZ = value;
            else
                _rotation = value;   
            dispatchFillChangedEvent("rotation", oldValue, value);
        }
	}

	//----------------------------------
	//  scaleX
	//----------------------------------
	
	private var _scaleX:Number = 1.0;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
	
	/**
	 *  The percent to horizontally scale the bitmap when filling,
	 *  from 0.0 to 1.0.
	 *  If 1.0, the bitmap is filled at its natural size.
	 *
	 *  @default 1.0
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get scaleX():Number
	{
        return compoundTransform ? compoundTransform.scaleX : _scaleX;
	}
	
    /**
     *  @private
     */  
	public function set scaleX(value:Number):void
	{
		if (value != scaleX)
		{
            var oldValue:Number = scaleX;
            
            if (compoundTransform)
                compoundTransform.scaleX = value;
            else
			    _scaleX = value;
			dispatchFillChangedEvent("scaleX", oldValue, value);
		}
	}

	//----------------------------------
	//  scaleY
	//----------------------------------
	
	private var _scaleY:Number = 1.0;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
	
	/**
	 *  The percent to vertically scale the bitmap when filling,
	 *  from 0.0 to 1.0.
	 *  If 1.0, the bitmap is filled at its natural size.
	 *
	 *  @default 1.0 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get scaleY():Number
	{
        return compoundTransform ? compoundTransform.scaleY : _scaleY;
	}
	
    /**
     *  @private
     */ 
	public function set scaleY(value:Number):void
	{
        if (value != scaleY)
        {
            var oldValue:Number = scaleY;
            
            if (compoundTransform)
                compoundTransform.scaleY = value;
            else
                _scaleY = value;
            dispatchFillChangedEvent("scaleY", oldValue, value);
        }
	}

	//----------------------------------
	//  source
	//----------------------------------

	private var _source:Object;

    [Inspectable(category="General")]

	/**
	 *  The source used for the bitmap fill.
	 *  The fill can render from various graphical sources,
	 *  including the following: 
	 *  <ul>
	 *   <li>A Bitmap or BitmapData instance.</li>
	 *   <li>A class representing a subclass of DisplayObject.
	 *   The BitmapFill instantiates the class
	 *   and creates a bitmap rendering of it.</li>
	 *   <li>An instance of a DisplayObject.
	 *   The BitmapFill copies it into a Bitmap for filling.</li>
	 *   <li>The name of a subclass of DisplayObject.
	 *   The BitmapFill loads the class, instantiates it, 
	 *   and creates a bitmap rendering of it.</li>
	 *  </ul>
	 *
	 *  @default null
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get source():Object 
	{
		return _source;
	}
	
	/**
	 *  @private
	 */
	public function set source(value:Object):void
	{
		if (value != _source)
        {
			var tmpSprite:DisplayObject;
			var oldValue:Object = _source;
			
			var bitmapData:BitmapData;
			
			if (value is Class)
			{
				var cls:Class = Class(value);
				value = new cls();
			}
			else if (value is String)
			{
				var tmpClass:Class = Class(getDefinitionByName(String(value)));
				value = new tmpClass();
			}
			
			if (value is BitmapData)
			{
				bitmapData = BitmapData(value);
			}
			else if (value is Bitmap)
			{
				bitmapData = value.bitmapData;
			}
			else if (value is DisplayObject)
			{
				tmpSprite = value as DisplayObject;
			}
			else if (value == null)
			{
				// This will set source to null
			}
			else
			{
				return;
			}
				
			if (!bitmapData && tmpSprite)
			{
				bitmapData = new BitmapData(tmpSprite.width, tmpSprite.height, true, 0);
				bitmapData.draw(tmpSprite, new Matrix());
			}
			
			_source = bitmapData;
			
			dispatchFillChangedEvent("source", oldValue, bitmapData);
        }
	}

	//----------------------------------
	//  smooth
	//----------------------------------

	private var _smooth:Boolean = false;
	
	[Inspectable(category="General")]
	[Bindable("propertyChange")]	
	
	/**
	 *  A flag indicating whether to smooth the bitmap data
	 *  when filling with it.
	 *
	 *  @default false
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get smooth():Boolean
	{
		return _smooth;
	}
	
	public function set smooth(value:Boolean):void
	{
		var oldValue:Boolean = _smooth;
		if (value != oldValue)
		{
			_smooth = value;
			dispatchFillChangedEvent("smooth", oldValue, value);
		}
	}
	
	//----------------------------------
    //  transformX
    //----------------------------------
    
    private var _transformX:Number = 0;
    
    [Inspectable(category="General")]

    /**
     *  The x position transform point of the fill.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get transformX():Number
    {
        return compoundTransform ? compoundTransform.transformX : _transformX;
    }

    /**
     *  @private
     */
    public function set transformX(value:Number):void
    {
        if (transformX == value)
            return;
                
        var oldValue:Number = transformX;   
        
        if (compoundTransform)
            compoundTransform.transformX = value;
        else
            _transformX = value;
        
        dispatchFillChangedEvent("transformX", oldValue, value);
    }

    //----------------------------------
    //  transformY
    //----------------------------------
    
    private var _transformY:Number = 0;
    
    [Inspectable(category="General")]

    /**
     *  The y position transform point of the fill.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get transformY():Number
    {
        return compoundTransform ? compoundTransform.transformY : _transformY;
    }

    /**
     *  @private
     */
    public function set transformY(value:Number):void
    {
        if (transformY == value)
            return;
        
        var oldValue:Number = transformY;    
        
        if (compoundTransform)
            compoundTransform.transformY = value;
        else
            _transformY = value;
        
        dispatchFillChangedEvent("transformY", oldValue, value);
    }

	
	//----------------------------------
	//  x
	//----------------------------------
	
    private var _x:Number = 0;
    
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
                compoundTransform.x = value; 
            else
                _x = value;
            dispatchFillChangedEvent("x", oldValue, value);
        }
    }
    
    //----------------------------------
	//  y
	//----------------------------------
    
    private var _y:Number = 0;
    
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
                compoundTransform.y = value;
            else
                _y = value;                
            
            dispatchFillChangedEvent("y", oldValue, value);
        }
    }

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public function begin(target:Graphics, bounds:Rectangle):void
	{		
		if (!source)
			return;
		
        if (compoundTransform)
        {
            transformMatrix = compoundTransform.matrix;
            transformMatrix.translate(bounds.left, bounds.top);
        }
        else
        {
            transformMatrix.identity();
            transformMatrix.translate(-transformX, -transformY);
            transformMatrix.scale(scaleX, scaleY);
            transformMatrix.rotate(rotation * RADIANS_PER_DEGREES);
            transformMatrix.translate(x + bounds.left + transformX, y + bounds.top + transformY);
        }
		target.beginBitmapFill(source as BitmapData, transformMatrix, repeat, smooth);
	}
	
	/**
	 *  @private
	 */
	public function end(target:Graphics):void
	{
		target.endFill();
	}
	
	/**
	 *  @private
	 */
	private function dispatchFillChangedEvent(prop:String, oldValue:*,
											  value:*):void
	{
        dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, prop,
															oldValue, value));
	}
}

}

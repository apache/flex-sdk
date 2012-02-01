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

package mx.filters
{

import flash.events.Event;	
import flash.events.EventDispatcher;
import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;
import mx.filters.IFlexBitmapFilter;

/**
 *  @review 
 *  Dispatched when a property value has changed. 
 */ 
[Event(name="change", type="flash.events.Event")]

/**
 *  @review 
 * 
 *  The ColorMatrixFilter class lets you apply a 4 x 5 matrix transformation on the 
 *  RGBA color and alpha values of every pixel in the input image to produce a result 
 *  with a new set of RGBA color and alpha values. It allows saturation changes, hue 
 *  rotation, luminance to alpha, and various other effects. You can apply the filter 
 *  to any display object (that is, objects that inherit from the DisplayObject class), 
 *  such as MovieClip, SimpleButton, TextField, and Video objects, as well as to 
 *  BitmapData objects.
 * 
 *  @see flash.filters.ColorMatrixFilter
 */
public class ColorMatrixFilter extends EventDispatcher implements IFlexBitmapFilter
{
	include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    	
	/**
	 * @copy flash.filters.ColorMatrixFilter
	 */ 
	public function ColorMatrixFilter(matrix:Object = null)
	{
		super();
		
		if (matrix != null)
		{
			this.matrix = matrix;
		} 
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------	
	
	//----------------------------------
    //  matrix
    //----------------------------------
	
	private var _matrix:Array =  [1,0,0,0,0,
								  0,1,0,0,0,
								  0,0,1,0,0,
								  0,0,0,1,0];
	
	/**
	 *  @review
	 * 
	 *  A comma delimited list of 20 doubles that comprise a 4x5 matrix applied to the 
	 *  rendered element.  The matrix is in row major order -- that is, the first five 
	 *  elements are multipled by the vector [srcR,srcG,srcB,srcA,1] to determine the 
	 *  output red value, the second five determine the output green value, etc.
	 * 
	 *  The value must either be an array or comma delimited string of 20 numbers. 
	 */
	public function get matrix():Object
	{
		return _matrix;
	}
	
	public function set matrix(value:Object):void
	{
		if (value != _matrix)
		{
			if (value is Array)
			{
				_matrix = value as Array;
			}
			else if (value is String)
			{
				_matrix = String(value).split(',');
			}
			
			notifyFilterChanged();
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
    
    /**
     * @private
     * Notify of a change to our filter, so that filter stack is ultimately 
     * re-applied by the framework.
     */ 	
	private function notifyFilterChanged():void
	{
		dispatchEvent(new Event(Event.CHANGE));
	}

	//--------------------------------------------------------------------------
	//
	//  IFlexBitmapFilter 
	//
	//--------------------------------------------------------------------------	

	/**
	 *  Creates a flash.filters.ColorMatrixFilter instance using the current 
	 *  property values. 
	 * 
	 *  @return flash.filters.ColorMatrixFilter instance
	 */	
	public function createBitmapFilter():BitmapFilter 
	{
		return new flash.filters.ColorMatrixFilter(_matrix);
	}
}
}

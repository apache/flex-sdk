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

package spark.filters
{
import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;
import mx.filters.BaseFilter;
import mx.filters.IBitmapFilter;
/**
 *  The ColorMatrixFilter class lets you apply a 4 x 5 matrix transformation on the 
 *  RGBA color and alpha values of every pixel in the input image to produce a result 
 *  with a new set of RGBA color and alpha values. It allows saturation changes, hue 
 *  rotation, luminance to alpha, and various other effects. You can apply the filter 
 *  to any display object (that is, objects that inherit from the DisplayObject class), 
 *  such as MovieClip, SimpleButton, TextField, and Video objects, as well as to 
 *  BitmapData objects.
 * 
 *  @mxml 
 *  <p>The <code>&lt;s:ColorMatrixFilter&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:ColorMatrixFilter
 *    <strong>Properties</strong>
 *    matrix="[1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0]"
 *  /&gt;
 *  </pre>
 * 
 *  @see flash.filters.ColorMatrixFilter
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ColorMatrixFilter extends BaseFilter implements IBitmapFilter
{
    /**
     * Constructor.
     *
     * @tiptext Initializes a new ColorMatrixFilter instance.
     *
     * @param matrix An array of 20 items arranged as a 4 x 5 matrix.
     *
     * @langversion 3.0
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @productversion Flex 4
     */
    
    public function ColorMatrixFilter(matrix:Array = null)
    {
        super();
        
        if (matrix != null)
        {
            this.matrix = matrix;
        } 
    }
    
    //----------------------------------
    //  matrix
    //----------------------------------
    
    private var _matrix:Array =  [1,0,0,0,0,0,
                                  1,0,0,0,0,0,
                                  1,0,0,0,0,0,
                                  1,0];
    
    /**
     *  A comma delimited list of 20 doubles that comprise a 4x5 matrix applied to the 
     *  rendered element.  The matrix is in row major order -- that is, the first five 
     *  elements are multipled by the vector [srcR,srcG,srcB,srcA,1] to determine the 
     *  output red value, the second five determine the output green value, etc.
     * 
     *  <p>The value must either be an array or comma delimited string of 20 numbers. </p>
     *
     *  @default [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0]
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    
    /**
     * Returns a copy of this filter object.
     *
     * @return A new ColorMatrixFilter instance with all of the same
     * properties as the original one.
     *
     * @langversion 3.0
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @productversion Flex 4
     */
    
    public function clone():BitmapFilter
    {
        return new flash.filters.ColorMatrixFilter(_matrix);
    }
    
}
}

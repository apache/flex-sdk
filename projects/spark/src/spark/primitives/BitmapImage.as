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

package spark.primitives
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.getDefinitionByName;

import spark.primitives.supportClasses.GraphicElement;

/**
 *  A BitmapImage element defines a rectangular region in its parent element's 
 *  coordinate space, filled with bitmap data drawn from a source file.
 *  
 *  @includeExample examples/BitmapImageExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class BitmapImage extends GraphicElement
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
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function BitmapImage()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    private var _scaleGridBottom:Number;
    private var _scaleGridLeft:Number;
    private var _scaleGridRight:Number;
    private var _scaleGridTop:Number;
    
    private static var matrix:Matrix = new Matrix();  
    private var cachedSourceGrid:Array;
    private var cachedDestGrid:Array;
    
    private var previousUnscaledWidth:Number;
    private var previousUnscaledHeight:Number;
    
    //----------------------------------
    //  resizeMode
    //----------------------------------
    /**
     *  The default state.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected static const _NORMAL_UINT:uint = 0;

    /**
     *  Repeats the graphic.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected static const _REPEAT_UINT:uint = 1;

    /**
     *  Scales the graphic.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected static const _SCALE_UINT:uint = 2;

    /**
     *  Converts from the String to the uint
     *  representation of the enum values.
     *  
     *  @param value The String to convert.
     *  
     *  @return The uint representation of the enum values.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected static function resizeModeToUINT(value:String):uint
    {
        switch(value)
        {
            case BitmapImageResizeMode.REPEAT: return _REPEAT_UINT;
            case BitmapImageResizeMode.SCALE: return _SCALE_UINT;
            default: return _NORMAL_UINT;
        }
    }

    /**
     *  Converts from the uint to the String
     *  representation of the enum values.
     *  
     *  @param value The uint to convert.
     *  
     *  @return The String representation of the enum values.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected static function resizeModeToString(value:uint):String
    {
        switch(value)
        {
            case _REPEAT_UINT: return BitmapImageResizeMode.REPEAT;
            case _SCALE_UINT: return BitmapImageResizeMode.SCALE;
            default: return BitmapImageResizeMode.NORMAL;
        }
    }

    /**
     *  @private
     */
    protected var _resizeMode:uint = _REPEAT_UINT;
    
    [Inspectable(category="General")]
    
    /**
     *  The resizeMode determines how the bitmap fills in the dimensions. If you set the value
     *  of this property in a tag, use the string (such as "repeat"). If you set the value of 
     *  this property in ActionScript, use the constant (such as <code>BitmapImageResizeMode.NORMAL</code>).
     * 
     *  When set to <code>BitmapImageResizeMode.NORMAL</code> ("normal"), the bitmap
     *  ends at the edge of the region.
     * 
     *  When set to <code>BitmapImageResizeMode.REPEAT</code> ("repeat"), the bitmap 
     *  repeats to fill the region.
     *
     *  When set to <code>BitmapImageResizeMode.SCALE</code> ("scale"), the bitmap
     *  stretches to fill the region.
     * 
     *  @default <code>BitmapImageResizeMode.NORMAL</code>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get resizeMode():String 
    {
        return resizeModeToString(_resizeMode);
    }
    
    /**
     *  @private
     */
    public function set resizeMode(mode:String):void
    {
        var value:uint = resizeModeToUINT(mode);
        if (value != _resizeMode)
        {
            _resizeMode = value;
            invalidateDisplayList();
        }
    }

    //----------------------------------
    //  repeat
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  Whether the bitmap is repeated to fill the area. Set to <code>true</code> to cause 
     *  the fill to tile outward to the edges of the filled region. 
     *  Set to <code>false</code> to end the fill at the edge of the region.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get repeat():Boolean 
    {
        return _resizeMode == _REPEAT_UINT;
    }
    
    /**
     *  @private
     */
    public function set repeat(value:Boolean):void
    {        
        if (value != repeat)
        {
            resizeMode = value ? BitmapImageResizeMode.REPEAT : BitmapImageResizeMode.NORMAL;  
            invalidateDisplayList();
        }
    }

    //----------------------------------
    //  source
    //----------------------------------

    private var _source:Object;

    [Inspectable(category="General")]

    /**
     *  The source used for the bitmap fill. The fill can render from various graphical 
     *  sources, including the following: 
     *  <ul>
     *   <li>A Bitmap or BitmapData instance.</li>
     *   <li>A class representing a subclass of DisplayObject. The BitmapFill instantiates 
     *       the class and creates a bitmap rendering of it.</li>
     *   <li>An instance of a DisplayObject. The BitmapFill copies it into a Bitmap for filling.</li>
     *   <li>The name of a subclass of DisplayObject. The BitmapFill loads the class, instantiates it, 
     *       and creates a bitmap rendering of it.</li>
     *  </ul>
     *  
     *  <p>If you use an image file for the source, it can be of type PNG, GIF, or JPG.</p>
     *  
     *  <p>To specify an image as a source, you must use the &#64;Embed directive, as the following example shows:
     *  <pre>
     *  source="&#64;Embed('&lt;i&gt;image_location&lt;/i&gt;')"
     *  </pre>
     *  </p>
     *  
     *  <p>The image location can be a URL or file reference. If it is a file reference, its location is relative to
     *  the location of the file that is being compiled.</p>
     *  
     *  <p>The BitmapImage class is designed to work with embedded images, not with images that are 
     *  loaded at run time. You can use the Image control to load the image at run time,
     *  and then assign the Image control to the value of the BitmapImage's <code>source</code> property.</p>
     *  
     *  @see flash.display.Bitmap
     *  @see flash.display.BitmapData
     *  @see mx.graphics.BitmapFill
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
            var bitmapData:BitmapData;
            var tmpSprite:DisplayObject;
            
            // Clear the previous scaleGrid properties
            _scaleGridLeft = NaN;
            _scaleGridRight = NaN;
            _scaleGridTop = NaN;
            _scaleGridBottom = NaN;
            
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
                bitmapData = value as BitmapData;
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
                
                if (tmpSprite.scale9Grid)
                {
                    _scaleGridLeft = tmpSprite.scale9Grid.left;
                    _scaleGridRight = tmpSprite.scale9Grid.right;
                    _scaleGridTop = tmpSprite.scale9Grid.top;
                    _scaleGridBottom = tmpSprite.scale9Grid.bottom;
                }
            }       
            
            _source = bitmapData;
            
            // Flush the cached scale grid points
            cachedSourceGrid = null;
            cachedDestGrid = null;
            
            invalidateSize();
            invalidateDisplayList();
        }
    }
    
    //----------------------------------
    //  smooth
    //----------------------------------

    private var _smooth:Boolean = false;

    [Inspectable(category="General")]   
    
    /**
     *  @copy flash.display.GraphicsBitmapFill#smooth
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set smooth(value:Boolean):void
    {
        if (value != _smooth)
        {
            _smooth = value;
            invalidateDisplayList();
        }
    }
    
    /**
     *  @private
     */
    public function get  smooth():Boolean
    {
        return _smooth;
    } 
    
    //--------------------------------------------------------------------------
    //
    //  overriden methods from GraphicElement
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function measure():void
    {
        measuredWidth = source ? source.width : 0;
        measuredHeight = source ? source.height : 0;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function updateDisplayList(unscaledWidth:Number, 
                                                  unscaledHeight:Number):void
    {
        if (!source || !drawnDisplayObject || !(drawnDisplayObject is Sprite))
            return;
            
        // The base GraphicElement class has cleared the graphics for us.    
        var g:Graphics = Sprite(drawnDisplayObject).graphics;
        
        g.lineStyle();
        var repeatBitmap:Boolean = false;
        var fillScaleX:Number = 1;
        var fillScaleY:Number = 1;
    
        switch(_resizeMode)
        {
            case _REPEAT_UINT:
                if (source)
                {
                    repeatBitmap = true;
                }    
            break;

            case _SCALE_UINT:
                if (source)
                {
                    fillScaleX = unscaledWidth / source.width;
                    fillScaleY = unscaledHeight / source.height;
                }
            break;
        }

        // If no scaleGrid is defined or if resizeMode != SCALE, just draw the entire rect
        if (_resizeMode != _SCALE_UINT ||
            isNaN(_scaleGridTop) ||
            isNaN(_scaleGridBottom) ||
            isNaN(_scaleGridLeft) ||
            isNaN(_scaleGridRight))
        {
            matrix.identity();
            matrix.scale(fillScaleX, fillScaleY);
            matrix.translate(drawX, drawY);
            g.beginBitmapFill(_source as BitmapData, matrix, repeatBitmap, smooth);
        g.drawRect(drawX, drawY, unscaledWidth, unscaledHeight);
            g.endFill();
    }
        else
        {   
    
            // If we have scaleGrid, we draw 9 sections, each with a different scale factor based 
            // on the grid region.
            
            if (cachedSourceGrid == null)
            {
                // Generate the 16 points of the source (unscaled) grid
                cachedSourceGrid = [];
                cachedSourceGrid.push([new Point(0, 0), new Point(_scaleGridLeft, 0), 
                                new Point(_scaleGridRight, 0), new Point(_source.width, 0)]);
                cachedSourceGrid.push([new Point(0, _scaleGridTop), new Point(_scaleGridLeft, _scaleGridTop), 
                                new Point(_scaleGridRight, _scaleGridTop), new Point(_source.width, _scaleGridTop)]);
                cachedSourceGrid.push([new Point(0, _scaleGridBottom), new Point(_scaleGridLeft, _scaleGridBottom), 
                                new Point(_scaleGridRight, _scaleGridBottom), new Point(_source.width, _scaleGridBottom)]);
                cachedSourceGrid.push([new Point(0, _source.height), new Point(_scaleGridLeft, _source.height), 
                                new Point(_scaleGridRight, _source.height), new Point(_source.width, _source.height)]);                         
            }
            
            if (cachedDestGrid == null || 
                previousUnscaledWidth != unscaledWidth || 
                previousUnscaledHeight != unscaledHeight)
            {
                // Generate teh 16 points of the destination (scaled) grid
                var destScaleGridBottom:Number = unscaledHeight - (_source.height - _scaleGridBottom);
                var destScaleGridRight:Number = unscaledWidth - (_source.width - _scaleGridRight);      
                cachedDestGrid = [];
                cachedDestGrid.push([new Point(0, 0), new Point(_scaleGridLeft, 0), 
                                new Point(destScaleGridRight, 0), new Point(unscaledWidth, 0)]);
                cachedDestGrid.push([new Point(0, _scaleGridTop), new Point(_scaleGridLeft, _scaleGridTop), 
                                new Point(destScaleGridRight, _scaleGridTop), new Point(unscaledWidth, _scaleGridTop)]);
                cachedDestGrid.push([new Point(0, destScaleGridBottom), new Point(_scaleGridLeft, destScaleGridBottom), 
                                new Point(destScaleGridRight, destScaleGridBottom), new Point(unscaledWidth, destScaleGridBottom)]);
                cachedDestGrid.push([new Point(0, unscaledHeight), new Point(_scaleGridLeft, unscaledHeight), 
                               new Point(destScaleGridRight, unscaledHeight), new Point(unscaledWidth, unscaledHeight)]);                     
            }                                                   

            var sourceSection:Rectangle = new Rectangle();
            var destSection:Rectangle = new Rectangle();
            
            // Iterate over the columns and rows. We draw each of the nine sections at a calculated
            // scale and translation.        
            for (var rowIndex:int=0; rowIndex < 3; rowIndex++) 
            {
                for (var colIndex:int = 0; colIndex < 3; colIndex++) 
                {   
                    // Create the source and destination rectangles for the current section
                    sourceSection.topLeft = cachedSourceGrid[rowIndex][colIndex];
                    sourceSection.bottomRight = cachedSourceGrid[rowIndex+1][colIndex+1];
                    
                    destSection.topLeft = cachedDestGrid[rowIndex][colIndex];
                    destSection.bottomRight = cachedDestGrid[rowIndex+1][colIndex+1];
                    
                    matrix.identity();
                    // Scale the bitmap by the ratio between the source and destination dimensions
                    matrix.scale(destSection.width / sourceSection.width, destSection.height / sourceSection.height);
                    // Translate based on the difference between the source and destination coordinates,
                    // making sure to account for the new scale.
                    matrix.translate(destSection.x - sourceSection.x * matrix.a, destSection.y - sourceSection.y * matrix.d);
                    matrix.translate(drawX, drawY);
                    
                    // Draw the bitmap for the current section
                    g.beginBitmapFill(_source as BitmapData, matrix);
                    g.drawRect(destSection.x + drawX, destSection.y + drawY, destSection.width, destSection.height);
                    g.endFill();
                 }
            }
        }
        
        previousUnscaledWidth = unscaledWidth;
        previousUnscaledHeight = unscaledHeight;
    }

}

}

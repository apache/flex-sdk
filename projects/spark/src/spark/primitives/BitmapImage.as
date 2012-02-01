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

package spark.primitives
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.LoaderContext;

import mx.graphics.BitmapFillMode;

import spark.primitives.supportClasses.GraphicElement; 

/**
 *  Dispatched when an input/output error occurs.
 *  @see flash.events.IOErrorEvent
 *
 *  @eventType flash.events.IOErrorEvent.IO_ERROR
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="ioError", type="flash.events.IOErrorEvent")]

/**
 *  Dispatched when a security error occurs.
 *  @see flash.events.SecurityErrorEvent
 *
 *  @eventType flash.events.SecurityErrorEvent.SECURITY_ERROR
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="securityError", type="flash.events.SecurityErrorEvent")]

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
    
    private var _bitmapData:BitmapData;
    
    private var _scaleGridBottom:Number;
    private var _scaleGridLeft:Number;
    private var _scaleGridRight:Number;
    private var _scaleGridTop:Number;
    private var bitmapDataCreated:Boolean = false;
    
    private static var matrix:Matrix = new Matrix();  
    private var cachedSourceGrid:Array;
    private var cachedDestGrid:Array;
    
    private var previousUnscaledWidth:Number;
    private var previousUnscaledHeight:Number;
    
    //----------------------------------
    //  fillMode
    //----------------------------------

    /**
     *  @private
     */
    protected var _fillMode:String = BitmapFillMode.SCALE;
    
    [Inspectable(category="General", enumeration="clip,repeat,scale", defaultValue="scale")]
    
    /**
     *  The fillMode determines how the bitmap fills in the dimensions. If you set the value
     *  of this property in a tag, use the string (such as "repeat"). If you set the value of 
     *  this property in ActionScript, use the constant (such as <code>BitmapFillMode.CLIP</code>).
     * 
     *  When set to <code>BitmapFillMode.CLIP</code> ("clip"), the bitmap
     *  ends at the edge of the region.
     * 
     *  When set to <code>BitmapFillMode.REPEAT</code> ("repeat"), the bitmap 
     *  repeats to fill the region.
     *
     *  When set to <code>BitmapFillMode.SCALE</code> ("scale"), the bitmap
     *  stretches to fill the region.
     * 
     *  @default <code>BitmapFillMode.SCALE</code>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get fillMode():String 
    {
        return _fillMode; 
    }
    
    /**
     *  @private
     */
    public function set fillMode(value:String):void
    {
        if (value != _fillMode)
        {
            _fillMode = value;
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
     *   <li>The name of an external image file. This file must have the extention
     *   .jpg, .jpeg, .gif, or .png.</li>
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
     *  <p>The BitmapImage class is designed to work with embedded images or images that are 
     *  loaded at run time</p>
     * 
     *  <p>If the source is a Bitmap or BitmapData instance or is an external image file, it
     *  is the responsibility of the caller to dispose of the source once it is no longer needed.
     *  If BitmapImage created the BitmapData instance, then it will dispose of the BitmapData once the 
     *  source has changed.</p>
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
            _source = value;
            var bitmapData:BitmapData;
            var tmpSprite:DisplayObject;
            
            // Clear the previous scaleGrid properties
            _scaleGridLeft = NaN;
            _scaleGridRight = NaN;
            _scaleGridTop = NaN;
            _scaleGridBottom = NaN;
            var currentBitmapCreated:Boolean = false;
            
            if (value is Class)
            {
                var cls:Class = Class(value);
                value = new cls();
                currentBitmapCreated = true;
            }
            else if (value is String)
            {
                loadExternal(value as String);
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
                currentBitmapCreated = true;
                
                if (tmpSprite.scale9Grid)
                {
                    _scaleGridLeft = tmpSprite.scale9Grid.left;
                    _scaleGridRight = tmpSprite.scale9Grid.right;
                    _scaleGridTop = tmpSprite.scale9Grid.top;
                    _scaleGridBottom = tmpSprite.scale9Grid.bottom;
                }
            }       
                        
            setBitmapData(bitmapData, currentBitmapCreated);
        }
    }
    
    //----------------------------------
    //  smooth
    //----------------------------------

    private var _smooth:Boolean = false;

    [Inspectable(category="General", enumeration="true,false")]   
    
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
        measuredWidth = _bitmapData ? _bitmapData.width : 0;
        measuredHeight = _bitmapData ? _bitmapData.height : 0;
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
        if (!_bitmapData || !drawnDisplayObject || !(drawnDisplayObject is Sprite))
            return;
            
        // The base GraphicElement class has cleared the graphics for us.    
        var g:Graphics = Sprite(drawnDisplayObject).graphics;
        
        g.lineStyle();
        var repeatBitmap:Boolean = false;
        var fillScaleX:Number = 1;
        var fillScaleY:Number = 1;
        var roundedDrawX:Number = Math.round(drawX);
        var roundedDrawY:Number = Math.round(drawY);
        var fillWidth:Number = unscaledWidth;
        var fillHeight:Number = unscaledHeight;
    
        switch(_fillMode)
        {
            case BitmapFillMode.REPEAT: 
                if (_bitmapData)
                {
                    repeatBitmap = true;
                }    
            break;

            case BitmapFillMode.SCALE:
                if (_bitmapData)
                {
                    fillScaleX = unscaledWidth / _bitmapData.width;
                    fillScaleY = unscaledHeight / _bitmapData.height;
                }
            break;
            
            case BitmapFillMode.CLIP:
                if (_bitmapData)
                {
                    fillWidth = Math.min(unscaledWidth, _bitmapData.width);
                    fillHeight = Math.min(unscaledHeight, _bitmapData.height);
                }
            break;
        }

        // If no scaleGrid is defined or if fillMode != SCALE, just draw the entire rect
        if (_fillMode != BitmapFillMode.SCALE ||
            isNaN(_scaleGridTop) ||
            isNaN(_scaleGridBottom) ||
            isNaN(_scaleGridLeft) ||
            isNaN(_scaleGridRight))
        {
             
            
            matrix.identity();
            matrix.scale(fillScaleX, fillScaleY);
            matrix.translate(roundedDrawX, roundedDrawY);
            g.beginBitmapFill(_bitmapData, matrix, repeatBitmap, smooth);
            g.drawRect(roundedDrawX, roundedDrawY, fillWidth, fillHeight);
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
                                new Point(_scaleGridRight, 0), new Point(_bitmapData.width, 0)]);
                cachedSourceGrid.push([new Point(0, _scaleGridTop), new Point(_scaleGridLeft, _scaleGridTop), 
                                new Point(_scaleGridRight, _scaleGridTop), new Point(_bitmapData.width, _scaleGridTop)]);
                cachedSourceGrid.push([new Point(0, _scaleGridBottom), new Point(_scaleGridLeft, _scaleGridBottom), 
                                new Point(_scaleGridRight, _scaleGridBottom), new Point(_bitmapData.width, _scaleGridBottom)]);
                cachedSourceGrid.push([new Point(0, _bitmapData.height), new Point(_scaleGridLeft, _bitmapData.height), 
                                new Point(_scaleGridRight, _bitmapData.height), new Point(_bitmapData.width, _bitmapData.height)]);                         
            }
            
            if (cachedDestGrid == null || 
                previousUnscaledWidth != unscaledWidth || 
                previousUnscaledHeight != unscaledHeight)
            {
                // Generate teh 16 points of the destination (scaled) grid
                var destScaleGridBottom:Number = unscaledHeight - (_bitmapData.height - _scaleGridBottom);
                var destScaleGridRight:Number = unscaledWidth - (_bitmapData.width - _scaleGridRight);      
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
                    matrix.translate(roundedDrawX, roundedDrawY);
                    
                    // Draw the bitmap for the current section
                    g.beginBitmapFill(_bitmapData, matrix);
                    g.drawRect(destSection.x + roundedDrawX, destSection.y + roundedDrawY, destSection.width, destSection.height);
                    g.endFill();
                 }
            }
        }
        
        previousUnscaledWidth = unscaledWidth;
        previousUnscaledHeight = unscaledHeight;
    }

    
    /**
     *  @private
     *  Utility function that sets the underlying bitmapData property.
     */
    private function setBitmapData(bitmapData:BitmapData, internallyCreated:Boolean = false):void
    {         
        // Clear previous bitmapData
        if (_bitmapData)
        {
            if (bitmapDataCreated) // Dispose the bitmap if we created it
                _bitmapData.dispose();
            _bitmapData = null;
        }
        
        bitmapDataCreated = internallyCreated; 

        _bitmapData = bitmapData;
        
        // Flush the cached scale grid points
        cachedSourceGrid = null;
        cachedDestGrid = null;
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    private function validImageFile(url:String):Boolean
    {
        // We only accept .jpg, .jpeg, .gif, and .png files
        // NOTE: This means queries that return images are not accepted: ie: myserver.com/fetch.php?image=12345
        var exten:String = url.substr(Math.max(url.length - 5, 0), Math.min(url.length, 5)).toLowerCase();
        
        if (exten.indexOf(".jpg") == -1 &&
            exten.indexOf(".jpeg") == -1 &&
            exten.indexOf(".gif") == -1 &&
            exten.indexOf(".png") == -1)
            return false;
        
        return true;
    }
    
    /**
     *  @private
     */
    private function loadExternal(url:String):void
    {
        if (!validImageFile(url))
            return;
            
        var loader:Loader = new Loader();
        var loaderContext:LoaderContext = new LoaderContext();
        
        loaderContext.checkPolicyFile = true;
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler, false, 0, true);
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler, false, 0, true);
        loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_securityErrorHandler, false, 0, true);
        try
        {
            loader.load(new URLRequest(url), loaderContext);
        }
        catch (error:SecurityError)
        {
            handleSecurityError(error);
        }
    }
   
    /**
     *  @private
     */
    private function loader_completeHandler(event:Event):void
    {
        var image:Bitmap = null;
        
        try
        {
            image = Bitmap((event.target as LoaderInfo).content);
            setBitmapData(image.bitmapData);
        }
        catch (error:SecurityError)
        {
            handleSecurityError(error);
        } 
    }
    
    /**
     *  @private
     */
    private function loader_ioErrorHandler(error:IOErrorEvent):void
    {
        // clear any current image
        setBitmapData(null);
        
        // forward the error
        dispatchEvent(error);
    }
    
    /**
     *  @private
     */
    private function loader_securityErrorHandler(error:SecurityErrorEvent):void
    {
        // clear any current image
        setBitmapData(null);
        
        // forward the error
        dispatchEvent(error);
    }
    
    /**
     *  @private
     */
    private function handleSecurityError(error:SecurityError):void
    {
        setBitmapData(null);
        dispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, error.message));
    }
}

}

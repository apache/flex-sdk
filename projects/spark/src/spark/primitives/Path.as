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

package mx.graphics
{

import flash.display.Graphics;
import flash.display.GraphicsPath;
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.utils.MatrixUtil;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  The Path class is a filled graphic element that draws a series of path segments.
 *  In vector graphics, a path is a series of points connected by straight or curved line segments. 
 *  Together the lines form an image. In Flex, you use the Path class to define a complex vector shape 
 *  constructed from a set of line segments. The LineSegment, CubicBezierSegment, and QuadraticBezierSegment 
 *  classes define the types of line segments that you can use. 
 * 
 *  <p>Typically, the first element of a path definition is a MoveSegment class to specify the starting pen 
 *  position of the graphic. You then use the LineSegment, CubicBezierSegment, and QuadraticBezierSegment 
 *  classes draw the lines of the graphic. When using these classes, you only specify the x and y coordinates 
 *  of the end point of the line; the x and y coordinate of the starting point is defined by the current 
 *  pen position.</p>
 *  
 *  <p>After drawing a line segment, the current pen position becomes the x and y coordinates of the end 
 *  point of the line. You can use multiple instances of the MoveSegment class in the path definition to 
 *  reposition the pen.</p>
 *  
 *  <p>The syntax used by the Path class to define the shape is the same as the SVG path syntax, 
 *  which makes it easy to convert SVG paths to Flex paths.</p>
 *  
 *  @includeExample examples/ArrowExample.mxml
 *  
 *  @see mx.graphics.MoveSegment
 *  @see mx.graphics.LineSegment
 *  @see mx.graphics.CubicBezierSegment
 *  @see mx.graphics.QuadraticBezierSegment
 */
public class Path extends FilledElement
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */
    public function Path()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  Vars holding the last scale set by setActualSize in order to
     *  resize the path.  Used to detect when setActualSize should
     *  call invalidateDisplayList(). 
     */    
    private var lastActualScaleX:Number = 0;
    private var lastActualScaleY:Number = 0;
    
    /**
     *  Dirty flag to indicate when path data has changed. 
     */ 
    private var graphicsPathChanged:Boolean = true;
    
    /**
     *  Documentation is not currently available.
     */ 
	protected var graphicsPath:GraphicsPath = new GraphicsPath(new Vector.<int>(), new Vector.<Number>());
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
        
    //----------------------------------
    //  data
    //----------------------------------
    
    private var _data:String;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  A string containing a compact represention of the path segments. This is an alternate
     *  way of setting the segments property. Setting this property overrides any values
     *  stored in the segments array property.
     *
     *  <p>The value is a space-delimited string describing each path segment. Each
     *  segment entry has a single character which denotes the segment type and
     *  two or more segment parameters.</p>
     * 
     *  <p>If the segment command is upper-case, the parameters are absolute values.
     *  If the segment command is lower-case, the parameters are relative values.</p>
     *
     *  <p>The following table shows the syntax for the segments:
     *  
     *  
     *  <table class="innertable">
     *    <tr>
     *      <th>Segment Type</th>
     *      <th>Command</th>
     *      <th>Parameters</th>
     *      <th>Example</th>
     *    </tr>
     *    <tr>
     *      <td>MoveSegment</td>
     *      <td>M/m</td>
     *      <td>x y</td>
     *      <td><code>M 10 20</code> - Move line to 10, 20.</td>
     *    </tr>
     *    <tr>
     *      <td>LineSegment</td>
     *      <td>L/l</td>
     *      <td>x y</td>
     *      <td><code>L 50 30</code> - Line to 50, 30.</td>
     *    </tr>
     *    <tr>
     *      <td>Horizontal line</td>
     *      <td>H/h</td>
     *      <td>x</td>
     *      <td><code>H 40</code> = Horizontal line to 40.</td>
     *    </tr>
     *    <tr>
     *      <td>Vertical line</td>
     *      <td>V/v</td>
     *      <td>y</td>
     *      <td><code>V 100</code> - Vertical line to 100.</td>
     *    </tr>
     *    <tr>
     *      <td>QuadraticBezierSegment</td>
     *      <td>Q/q</td>
     *      <td>controlX controlY x y</td>
     *      <td><code>Q 110 45 90 30</code> - Curve to 90, 30 with the control point at 110, 45.</td>
     *    </tr>
     *    <tr>
     *      <td>CubicBezierSegment</td>
     *      <td>C/c</td>
     *      <td>control1X control1Y control2X control2Y x y</td>
     *      <td><code>C 45 50 20 30 10 20</code> - Curve to 10, 20 with the first control point at 45, 50 and the second control point at 20, 30.</td>
     *    </tr>
     *    <tr>
     *      <td>Close path</td>
     *      <td>Z/z</td>
     *      <td>n/a</td>
     *      <td>Closes off the path.</td>
     *    </tr>
     *  </table>
     *  </p>
     *  
     *  @default null
     */
    public function set data(value:String):void
    {
        var oldValue:String = data;
        
        // Clear out the existing segments 
        segments = []; 
        
        // Split letter followed by number (ie "M3" becomes "M 3")
        var temp:String = value.replace(/([A-Za-z])([0-9\-\.])/g, "$1 $2");
        
        // Split number followed by letter (ie "3M" becomes "3 M")
        temp = temp.replace(/([0-9\.])([A-Za-z\-])/g, "$1 $2");
        
        // Split letter followed by letter (ie "zM" becomes "z M")
        temp = temp.replace(/([A-Za-z\-])([A-Za-z\-])/g, "$1 $2");
        
        // Replace commas with spaces
        temp = temp.replace(/,/g, " ");
        
        // Trim leading and trailing spaces
        temp = temp.replace(/^\s+/, "");
        temp = temp.replace(/\s+$/, ""); 
        
        // Finally, split the string into an array 
        var args:Array = temp.split(/\s+/);
        var newSegments:Array = [];
        
        var identifier:String;
        var prevX:Number = 0;
        var prevY:Number = 0;
        var x:Number;
        var y:Number;
        var controlX:Number;
        var controlY:Number;
        var control2X:Number;
        var control2Y:Number;
        
        var getNumber:Function = function(useRelative:Boolean, index:int, offset:Number):Number
        {
            var result:Number = args[index];
            
            if (useRelative)
                result += offset;
            
            return result;
        }
        
        for (var i:int = 0; i < args.length; )
        {
            if (isNaN(Number(args[i])))
            {
                identifier = args[i];
                i++;
            }
            
            var useRelative:Boolean = (identifier.toLowerCase() == identifier);
            
            switch (identifier.toLowerCase())
            {
                case "m":
                    x = getNumber(useRelative, i++, prevX);
                    y = getNumber(useRelative, i++, prevY);
                    newSegments.push(new MoveSegment(x, y));
                    break;
                
                case "l":
                    x = getNumber(useRelative, i++, prevX);
                    y = getNumber(useRelative, i++, prevY);
                    newSegments.push(new LineSegment(x, y));
                    break;
                
                case "h":
                    x = getNumber(useRelative, i++, prevX);
                    y = prevY;
                    newSegments.push(new LineSegment(x, y));
                    break;
                
                case "v":
                    x = prevX;
                    y = getNumber(useRelative, i++, prevY);
                    newSegments.push(new LineSegment(x, y));
                    break;
                
                case "q":
                    controlX = getNumber(useRelative, i++, prevX);
                    controlY = getNumber(useRelative, i++, prevY);
                    x = getNumber(useRelative, i++, prevX);
                    y = getNumber(useRelative, i++, prevY);
                    newSegments.push(new QuadraticBezierSegment(controlX, controlY, x, y));
                    break;
                
                case "t":
                    // control is a reflection of the previous control point
                    controlX = prevX + (prevX - controlX);
                    controlY = prevY + (prevY - controlY);
                    x = getNumber(useRelative, i++, prevX);
                    y = getNumber(useRelative, i++, prevY);
                    newSegments.push(new QuadraticBezierSegment(controlX, controlY, x, y));
                    break;
                    
                case "c":
                    controlX = getNumber(useRelative, i++, prevX);
                    controlY = getNumber(useRelative, i++, prevY);
                    control2X = getNumber(useRelative, i++, prevX);
                    control2Y = getNumber(useRelative, i++, prevY);
                    x = getNumber(useRelative, i++, prevX);
                    y = getNumber(useRelative, i++, prevY);
                    newSegments.push(new CubicBezierSegment(controlX, controlY, 
                                      control2X, control2Y, x, y));
                    break;
                
                case "s":
                    // Control1 is a reflection of the previous control2 point
                    controlX = prevX + (prevX - control2X);
                    controlY = prevY + (prevY - control2Y);
                    
                    control2X = getNumber(useRelative, i++, prevX);
                    control2Y = getNumber(useRelative, i++, prevY);
                    x = getNumber(useRelative, i++, prevX);
                    y = getNumber(useRelative, i++, prevY);
                    newSegments.push(new CubicBezierSegment(controlX, controlY,
                                        control2X, control2Y, x, y));
                    break;
                case "z":
                    newSegments.push(new CloseSegment());
                    break;
                
                default:
                    // unknown identifier, throw error?
                    return;
                    break;
            }
            
            prevX = x;
            prevY = y;
        }
        
        segments = newSegments;
        
        // Set the _data backing var as the last step since notifyElementChanged
        // clears the value.
        _data = value;
        
        dispatchPropertyChangeEvent("data", oldValue, value);
    }
    
    /** 
     *  @private
     */
    public function get data():String 
    {
        if (!_data)
        {
            _data = "";
            
            for (var i:int = 0; i < segments.length; i++)
            {
                var segment:PathSegment = segments[i];
                
                if (segment is MoveSegment)
                {
                    _data += "M " + segment.x + " " + segment.y + " ";
                }
                else if (segment is LineSegment)
                {
                    _data += "L " + segment.x + " " + segment.y + " ";
                }
                else if (segment is CubicBezierSegment)
                {
                    var cSeg:CubicBezierSegment = segment as CubicBezierSegment;
                    
                    _data += "C " + cSeg.control1X + " " + cSeg.control1Y + " " +
                            cSeg.control2X + " " + cSeg.control2Y + " " +
                            cSeg.x + " " + cSeg.y + " ";
                }
                else if (segment is QuadraticBezierSegment)
                {
                    var qSeg:QuadraticBezierSegment = segment as QuadraticBezierSegment;
                    
                    _data += "Q " + qSeg.control1X + " " + qSeg.control1Y + " " + 
                            qSeg.x + " " + qSeg.y + " ";
                }
                else if (segment is CloseSegment)
                {
                    _data += "Z ";
                }
                else
                {
                    // unknown segment, throw error?
                }
            }
        }
        
        return _data;
    }
    
    //----------------------------------
    //  segments
    //----------------------------------

    private var _segments:Array = [];
    
    [ArrayElementType("mx.graphics.PathSegment")]
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    /**
     *  The segments for the path. Each segment must be a subclass of PathSegment.
     *
     *  @default []
     */
    public function set segments(value:Array):void
    {
        _segments = value;
            
        for (var i:int = 0; i < _segments.length; i++)
        {
            _segments[i].segmentHost = this;
        }
        graphicsPathChanged = true;
        boundsChanged();
    }
    
    /** 
     *  @private
     */
    public function get segments():Array 
    {
        return _segments;
    }
    
    //----------------------------------
    //  winding
    //----------------------------------

    private var _winding:String = "evenOdd";
    
    /**
     *  Fill rule for intersecting or overlapping path segments. 
     *
     *  @default evenOdd
     */
    public function set winding(value:String):void
    {
    	if (_winding != value)
    	{
        	_winding = value;
        	graphicsPathChanged = true;
        	invalidateDisplayList();
     	} 
    }
    
    /** 
     *  @private
     */
    public function get winding():String 
    {
        return _winding; 
    }

    //----------------------------------
    //  bounds
    //----------------------------------

    private var _bounds:Rectangle;

    private function getBounds():Rectangle
    {
        if (_bounds)
            return _bounds;

        var s:Shape = new Shape();
        
        // Draw element at (0,0):
        drawElement(s.graphics);

        // Get bounds
        _bounds = s.getRect(s);

        return _bounds;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     */
    override protected function skipMeasure():Boolean
    {
        // Don't measure when bounds are up to date.
        return _bounds != null;
    }

    /**
     *  @inheritDoc
     */
    override protected function measure():void
    {
        var bounds:Rectangle = getBounds();
        measuredWidth = bounds.width;
        measuredHeight = bounds.height;
        measuredX = bounds.left;
        measuredY = bounds.top;
    }
 
    //----------------------------------
    //  scaleX
    //----------------------------------
    private var _userScaleX:Number = 1;
    
    override public function set scaleX(value:Number):void
    {
        super.scaleX = value;
        _userScaleX = value;
    }
    
    //----------------------------------
    //  scaleY
    //----------------------------------
    private var _userScaleY:Number = 1;
    
    override public function set scaleY(value:Number):void
    {
        super.scaleY = value;
        _userScaleY = value;        
    }
    private function setActualScale(sX:Number,sY:Number):void
    {
        layoutFeatures.layoutScaleX = sX;
        layoutFeatures.layoutScaleY = sY;
        invalidateTransform(false,false);
    }

    /**
     * @inheritDoc
     */
    override protected function drawElement(g:Graphics):void
    {
    	if (graphicsPathChanged)
    	{
    		graphicsPath.commands = null;
    		graphicsPath.data = null;
    		
	        // Always start by moving to 0, 0. Otherwise
	        // the path will begin at the previous pen location
	        // if it does not start with a MoveSegment.
	        graphicsPath.moveTo(0, 0);
	        var currentSubPathStartIndex:int = 0;
	        
	        for (var i:int = 0; i < segments.length; i++)
	        {
	            var segment:PathSegment = segments[i];
	                    
	            segment.draw(graphicsPath, (i > 0 ? segments[i - 1] : null));
	            
	            if (segment is CloseSegment)
	            {   
	                if (segments[currentSubPathStartIndex] is MoveSegment)
	                    graphicsPath.lineTo(segments[currentSubPathStartIndex].x, segments[currentSubPathStartIndex].y)
	                else
	                    graphicsPath.lineTo(0, 0);
	                    
	                currentSubPathStartIndex = i+1;
	            }
	        }
	        
	        graphicsPathChanged = false;
     	}
     	 
     	g.drawPath(graphicsPath.commands, graphicsPath.data, winding);
    }
    
    /**
     * @inheritDoc
     */
    override protected function endDraw(g:Graphics):void
    {
        // Set a transparent line style because filled, unclosed shapes will
        // automatically be closed by the Player. When they are, we want the line
        // to be invisible. 
        g.lineStyle();
        super.endDraw(g);
    } 
    
    // TODO!!! For now we create a DO. Once we figure out how to apply transforms
    // to each of the path segments, we can remove this. 
    override public function get needsDisplayObject():Boolean
    {
        return true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * @inheritDoc
     */
    public function segmentChanged(e:PathSegment):void 
    {
    	graphicsPathChanged = true;
        boundsChanged();
    }
    
    /**
     * @private
     */
    private function boundsChanged(): void
    {
        // Clear our cached measurement and data values
        clearBounds();
        _data = null;
        invalidateSize();
    }
   
    /**
     * @private
     */
    private function clearBounds():void
    {
        _bounds = null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  ILayoutItem
    //
    //--------------------------------------------------------------------------

    /**
     * @inheritDoc
     */
    override protected function computeMatrix(actualMatrix:Boolean):Matrix
    {
        var tmpScaleX:Number = actualMatrix ? super.scaleX : _userScaleX;
        var tmpScaleY:Number = actualMatrix ? super.scaleY : _userScaleY;

        if (tmpScaleX == 1 && tmpScaleY == 1 && rotation == 0)
            return null;

        return MatrixUtil.composeMatrix(x, y, tmpScaleX, tmpScaleY,
                                           rotation, transformX, transformY);
    }

    //----------------------------------
    //  actualSize
    //----------------------------------

    /**
     *  @inheritDoc
     */
    override public function get actualSize():Point
    {
        // Path always draws at bounds size
        var bounds:Rectangle = getBounds();
        return transformSizeForLayout(bounds.width, bounds.height, true /*actualMatrix*/);
    }

    /**
     *  @inheritDoc
     */
    override public function setActualSize(width:Number = Number.NaN, height:Number = Number.NaN):Point
    {
        // Reset scale
        setActualScale(_userScaleX,_userScaleY);

        // TODO EGeorgie: arbitrary 2d transforms for paths
        if (isNaN(width))
            width = preferredSize.x;
        if (isNaN(height))
            height = preferredSize.y;

        var w:Number = width;
        var h:Number = height;
        
        var bounds:Rectangle = getBounds();
        
        var bw:Number = bounds.width;
        var bh:Number = bounds.height;

        // Actual size is always the bounds size
        var oldWidth:Number = _width;
        var oldHeight:Number = _height;
        _width = bw;
        _height = bh;
        dispatchPropertyChangeEvent("width", oldWidth, _width);
        dispatchPropertyChangeEvent("height", oldHeight, _height);
            
        // Make sure we don't divide by zero while calculating the scale
        if (bw == 0)
            bw = 1;
        if (bh == 0)
            bh = 1;

        var stroke:IStroke = getStroke();
        if (!stroke)
        {
            setActualScale(w / bw,  h / bh);    
        }
        else if (stroke.weight == 0 )
        {
            setActualScale( (w - 1) / bw, (h - 1) / bh);
        }
        else if(stroke.scaleMode != LineScaleMode.NORMAL)
        {
            var strokeWeight:Number = stroke.weight;
            if (stroke.scaleMode == LineScaleMode.HORIZONTAL)
            {
                setActualScale(w / (bw + strokeWeight),(h - strokeWeight) / bh);
            }
            else if(stroke.scaleMode == LineScaleMode.VERTICAL)
            {
                setActualScale((w - strokeWeight) / bw,h / (bh + strokeWeight));                
            }
            else // LineScaleMode.NONE
            {
                setActualScale((w - strokeWeight) / bw,(h - strokeWeight) / bh);
            }
        }
        else
        {
            var t:Number = stroke.weight;
            t = t * t / 2;
            var t1:Number = t / ( bw * bw);
    
            // TODO EGeorige: the following equations don't 
            // account for skew components of the matrix.
            // Also, this can be greatly optimized.            
    
            // (1) w = bw * x + sqrt( x^2 * t + y^2 * t)
            // (2) h = bh * y + sqrt( x^2 * t + y^2 * t)
            // (1) - (2):
            // w - h = bw * x - bh * y
            // x = ( w - h + bh * y ) / bw
            // substitute back in (2):
            // h - bh * y = sqrt( (w - h + bh * y )^2 * t / bw^2 + y^2 * t )
            // h^2 - 2*h*bh*y +bh^2 * y^2 = ((w - h)^2 + 2 * (w-h) * bh * y + bh^2 * y^2 ) * t / bw^2 + y^2 * t
            // bh^2 * y^2 - 2*h*bh*y  + h ^2 = t1 * (w - h)^2 + 2 * t1 * (w-h) * bh * y + t1 * bh^2 * y^2 + t * y^2
            // bh^2 * y^2 - 2*h*bh*y  + h^2 = t1*(w-h)^2 + 2*t1*(w-h)*bh* y + (t1*bh^2 + t)*y^2
            // (bh^2 - t1*bh^2 - t) * y^2 -(2*h*bh +2*t1*(w-h)*bh) * y + (h^2 - t1*(w-h)^2) = 0 
            
            if( bw != 0 && bh != 0)
            {
                var A:Number = bh * bh - t1 * bh * bh - t;   
                var B:Number = -2 *h * bh - 2 * t1 * (w-h) * bh;            
                var C:Number = h * h - t1 * (w-h) * (w-h);                
    
                var D:Number = B * B - 4 * A * C;
                if (D >= 0)
                {
                    var y1:Number = (-B + Math.sqrt(D)) / (2 * A);
                    var y2:Number = (-B - Math.sqrt(D)) / (2 * A);
                    
                    var x1:Number = ( w - h + bh * y1 ) / bw;
                    var x2:Number = ( w - h + bh * y2 ) / bw;
                    
                    if (Math.abs(h - bh * y1 - Math.sqrt(x1 * x1 * t + y1 * y1 * t)) < 0.5 &&
                        Math.abs(w - bw * x1 - Math.sqrt(x1 * x1 * t + y1 * y1 * t)) < 0.5)
                    {
                        setActualScale(x1,y1);
                    }
                    else
                    if (Math.abs(h - bh * y2 - Math.sqrt(x2 * x2 * t + y2 *y2 * t)) < 0.5 &&
                        Math.abs(w - bw * x2 - Math.sqrt(x2 * x2 * t + y2 *y2 * t)) < 0.5)
                    {
                        setActualScale(x2,y2);
                    }
                }
            }
        }

        if (super.scaleX != lastActualScaleX || super.scaleY != lastActualScaleY)
        {
            lastActualScaleX = super.scaleX;
            lastActualScaleY = super.scaleY;
    
            invalidateDisplayList();
        }

        // TODO EGeorgie: move to commit properties
        // Finally, apply the transforms to the object
        applyComputedTransform();

        return actualSize;
    }
}

}

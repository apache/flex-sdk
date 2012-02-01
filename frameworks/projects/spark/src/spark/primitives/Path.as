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

import flash.display.Graphics;
import flash.display.GraphicsPath;
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.utils.MatrixUtil;
import mx.core.mx_internal;
import spark.primitives.pathSegments.LineSegment;
import spark.primitives.supportClasses.FilledElement;
import spark.primitives.pathSegments.CloseSegment;
import spark.primitives.pathSegments.CubicBezierSegment;
import spark.primitives.pathSegments.MoveSegment;
import spark.primitives.pathSegments.PathSegment;
import spark.primitives.pathSegments.QuadraticBezierSegment;



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
 *  @see spark.primitives.pathSegments.MoveSegment
 *  @see spark.primitives.pathSegments.LineSegment
 *  @see spark.primitives.pathSegments.CubicBezierSegment
 *  @see spark.primitives.pathSegments.QuadraticBezierSegment
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  Dirty flag to indicate when path data has changed. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    private var graphicsPathChanged:Boolean = true;
    
    /**
     *  A GraphicsPath object that contains the drawing 
     *  commands to draw this Path.  
     *  
     *  The data commands expressed in a Path's <code>data</code> 
     *  property are translated into drawing commands and 
     *  coordinate parameters for those commands, and then
     *  drawn to screen. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set data(value:String):void
    {        
        // Clear out the existing segments 
        segments = []; 
        
        //If there's no processing that needs to 
        //occur, exit early. 
        if (value == "")
    	{
    		_data = value;
    		return;
    	}
        
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
    
    [ArrayElementType("spark.primitives.pathSegments.PathSegment")]
    [Inspectable(category="General")]
    /**
     *  The segments for the path. Each segment must be a subclass of PathSegment.
     *
     *  @default []
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

    private static var boundsShape:Shape = new Shape();
    
    private function getBounds():Rectangle
    {
        if (_bounds)
            return _bounds;

        
        // Draw element at (0,0):
        renderGraphicsAtScale(0,0,1,1);
        boundsShape.graphics.clear();
        boundsShape.graphics.drawPath(graphicsPath.commands, graphicsPath.data, winding);

        // Get bounds
        _bounds = boundsShape.getRect(boundsShape);
        
        graphicsPathChanged = true;
        
        return _bounds;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
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
    override protected function skipMeasure():Boolean
    {
        // Don't measure when bounds are up to date.
        return _bounds != null;
    }

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
        var bounds:Rectangle = getBounds();
        measuredWidth = bounds.width;
        measuredHeight = bounds.height;
        measuredX = bounds.left;
        measuredY = bounds.top;
    }
    
    /**
     *  @private
     *  @return Returns the axis aligned bounding box of the path resized to width, height and then
     *  transformed with transformation matrix m.
     */
    private function getBoundingBox(width:Number, height:Number, m:Matrix):Rectangle
    {
        var naturalBounds:Rectangle = getBounds();
        var sx:Number = naturalBounds.width == 0 ? 1 : width / naturalBounds.width;
        var sy:Number = naturalBounds.height == 0 ? 1 : height / naturalBounds.height; 

        var currentSubPathStartIndex:int = 0;
        var prevSegment:PathSegment;
        var pathBBox:Rectangle;
        
        for (var i:int = 0; i < segments.length; i++)
        {
            var segment:PathSegment = segments[i];
            
            if (segment is CloseSegment)
            {   
                if (segments[currentSubPathStartIndex] is MoveSegment)
                    segment = new LineSegment(segments[currentSubPathStartIndex].x, segments[currentSubPathStartIndex].y);
                else
                    segment = new LineSegment();
                    
                currentSubPathStartIndex = i+1;
            }

            pathBBox = segment.getBoundingBox(prevSegment, sx, sy, m, pathBBox);
            prevSegment = segment;
        }
        // If path is empty, it's untransformed bounding box is (0,0), so we return transformed point (0,0)
        if (!pathBBox)
            pathBBox = new Rectangle(m.tx, m.ty);
        return pathBBox;
    }
    
    /**
     *  @private
     */
    override protected function transformWidthForLayout(width:Number,
                                                        height:Number,
                                                        postLayoutTransform:Boolean = true):Number
    {
        if (postLayoutTransform)
        {
            var m:Matrix = computeMatrix();
            if (m)
                width = getBoundingBox(width, height, m).width;
        }

        // Take stroke into account
        return width + getStrokeExtents().x;
    }

    /**
     *  @private
     */
    override protected function transformHeightForLayout(width:Number,
                                                         height:Number,
                                                         postLayoutTransform:Boolean = true):Number
    {
        if (postLayoutTransform)
        {
            var m:Matrix = computeMatrix();
            if (m)
                height = getBoundingBox(width, height, m).height;
        }

        // Take stroke into account
        return height + getStrokeExtents().y;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function getBoundsXAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
    {
        var strokeExtents:Point = getStrokeExtents(postLayoutTransform);
        var m:Matrix = postLayoutTransform ? computeMatrix() : null;

        if (!m)
        {
            // Check for a common case, BasicLayout measure() always hits this:
            if (isNaN(width))
                return strokeExtents.x * -0.5 + this.x + measuredX;
            else
                width = preferredWidthPreTransform();

            var naturalBounds:Rectangle = getBounds();
            var sx:Number = (naturalBounds.width == 0 || width == 0) ? 1 : width / naturalBounds.width;
            return strokeExtents.x * -0.5 + this.x + measuredX * sx;
        }
    
        if (!isNaN(width))
            width -= strokeExtents.x;

        if (!isNaN(height))
            height -= strokeExtents.y;

        // Calculate the width and height pre-transform:
        var newSize:Point = MatrixUtil.fitBounds(width, height, m,
                                                 preferredWidthPreTransform(),
                                                 preferredHeightPreTransform(),
                                                 minWidth, minHeight,
                                                 maxWidth, maxHeight);
        if (!newSize)
            newSize = new Point(minWidth, minHeight);
        return strokeExtents.x * -0.5 + getBoundingBox(newSize.x, newSize.y, m).x;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function getBoundsYAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
    {
        var strokeExtents:Point = getStrokeExtents(postLayoutTransform);
        var m:Matrix = postLayoutTransform ? computeMatrix() : null;

        if (!m)
        {
            // Check for a common case, BasicLayout measure() always hits this:
            if (isNaN(height))
                return strokeExtents.y * -0.5 + this.y + measuredY;
            else
                height = preferredHeightPreTransform();    

            var naturalBounds:Rectangle = getBounds();
            var sy:Number = (naturalBounds.height == 0 || height == 0) ? 1 : height / naturalBounds.height;
            return strokeExtents.y * -0.5 + this.y + measuredY * sy;
        }
    
        if (!isNaN(width))
            width -= strokeExtents.x;

        if (!isNaN(height))
            height -= strokeExtents.y;

        // Calculate the width and height pre-transform:
        var newSize:Point = MatrixUtil.fitBounds(width, height, m,
                                                 preferredWidthPreTransform(),
                                                 preferredHeightPreTransform(),
                                                 minWidth, minHeight,
                                                 maxWidth, maxHeight);
        if (!newSize)
            newSize = new Point(minWidth, minHeight);
        return strokeExtents.y * -0.5 + getBoundingBox(newSize.x, newSize.y, m).y;
    }

    /**
     *  @private
     */
    override public function getLayoutBoundsX(postLayoutTransform:Boolean = true):Number
    {
        var stroke:Number = -getStrokeExtents(postLayoutTransform).x * 0.5;
        var m:Matrix = postLayoutTransform ? computeMatrix() : null;
        if (!m)
        {
            if (measuredX == 0)
                return stroke + this.x;
            var naturalBounds:Rectangle = getBounds();
            var sx:Number = (naturalBounds.width == 0 || _width == 0) ? 1 : _width / naturalBounds.width;
            return stroke + this.x + measuredX * sx;
        }
        return stroke + getBoundingBox(_width, _height, m).x;
    }

    /**
     *  @private
     */
    override public function getLayoutBoundsY(postLayoutTransform:Boolean = true):Number
    {
        var stroke:Number = - getStrokeExtents(postLayoutTransform).y * 0.5;
        var m:Matrix = postLayoutTransform ? computeMatrix() : null;
        if (!m)
        {
            if (measuredY == 0)
                return stroke + this.y;
            var naturalBounds:Rectangle = getBounds();
            var sy:Number = (naturalBounds.height == 0 || _height == 0) ? 1 : _height / naturalBounds.height;
            return stroke + this.y + measuredY * sy;
        }
        return stroke + getBoundingBox(_width, _height, m).y;
    }
 
 	/**
 	 *  @private
 	 *  Use measuredX and measuredY instead of drawX and drawY
 	 */
 	override protected function beginDraw(g:Graphics):void
    {
        // Don't call super.beginDraw() since it will also set up an 
        // invisible fill.
        
        // Adjust the position by the internal scale factor
        var naturalBounds:Rectangle = getBounds();
        var sx:Number = naturalBounds.width == 0 ? 1 : width / naturalBounds.width;
        var sy:Number = naturalBounds.height == 0 ? 1 : height / naturalBounds.height; 


        var bounds:Rectangle = new Rectangle(drawX + measuredX * sx,
        									 drawY + measuredY * sy,
        									 width, 
        									 height);
        if (stroke)
            stroke.draw(g, bounds);
        else
            g.lineStyle();
        
        if (fill)
            fill.begin(g, bounds);
    }
 
    //TODO: these are a short term fix for MAX to work around the fact
    //that graphic elements can't differentiate between owning a display object
    //and sharing one.  The problem is, a previous graphic element might be
    //moving our display object around, messing with our drawX/drawY.
    //after MAX, we'll be cleaning up the sharing code, and putting graphics caching
    //into the GraphicElement base class.
    private var _drawBounds:Rectangle = new Rectangle(); 
    /**
     * @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */    
    override protected function drawElement(g:Graphics):void
    {
        //TODO: temporary check until DOsharing and graphics caching is cleaned up
        //after MAX.  See above.
        if(drawX !=  _drawBounds.x || drawY !=  _drawBounds.y ||
            width !=  _drawBounds.width || height !=  _drawBounds.height)
        {
            graphicsPathChanged = true;
            _drawBounds.x = drawX;
            _drawBounds.y = drawY;
            _drawBounds.width = width;
            _drawBounds.height = height;            
        }
        
    	if (graphicsPathChanged)
    	{
    	    var rcBounds:Rectangle = getBounds();
    	    var sx:Number = rcBounds.width == 0 ? 1 : width/rcBounds.width;
    	    var sy:Number = rcBounds.height == 0 ? 1 : height/rcBounds.height;
    	        	    
	        renderGraphicsAtScale(drawX,drawY,sx,sy);
	        graphicsPathChanged = false;
     	}
     	 
     	g.drawPath(graphicsPath.commands, graphicsPath.data, winding);
    }

    /**
     *  Workhorse method that iterates through the <code>segments</code>
     *  array and draws each path egment based on its control points. 
     *  
     *  Segments are drawn from the x and y position of the path. 
     *  Additionally, segments are drawn by taking into account the scale  
     *  applied to the path. 
     * 
     *  @param tx A Number representing the x position of where this 
     *  path segment should be drawn
     *  
     *  @param ty A Number representing the y position of where this  
     *  path segment should be drawn
     * 
     *  @param sx A Number representing the scaleX at which to draw 
     *  this path segment 
     * 
     *  @param sy A Number representing the scaleY at which to draw this
     *  path segment
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function renderGraphicsAtScale(tx:Number,ty:Number,sx:Number,sy:Number):void    
    {
        graphicsPath.commands = null;
        graphicsPath.data = null;
        

        // Always start by moving to drawX, drawY. Otherwise
        // the path will begin at the previous pen location
        // if it does not start with a MoveSegment.
        graphicsPath.moveTo(tx, ty);
        var currentSubPathStartIndex:int = 0;
        
        for (var i:int = 0; i < segments.length; i++)
        {
            var segment:PathSegment = segments[i];
                    
            segment.draw(graphicsPath, tx,ty,sx,sy, (i > 0 ? segments[i - 1] : null));
            
            if (segment is CloseSegment)
            {   
                if (segments[currentSubPathStartIndex] is MoveSegment)
                    graphicsPath.lineTo(tx + segments[currentSubPathStartIndex].x*sx, ty + segments[currentSubPathStartIndex].y*sy);
                else
                    graphicsPath.lineTo(tx, ty);
                    
                currentSubPathStartIndex = i+1;
            }
        }
    }
    
    /**
     * @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function endDraw(g:Graphics):void
    {
        // Set a transparent line style because filled, unclosed shapes will
        // automatically be closed by the Player. When they are, we want the line
        // to be invisible. 
        g.lineStyle();
        super.endDraw(g);
    } 
    

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Individual path segments notify the host Path that 
     *  the segment has changed in some way by invoking
     *  this method. When a segment has changed, the 
     *  bounds of the Path are re-calculated and the Path 
     *  will be re-renderered. 
     * 
     *  @param e The PathSegment that has changed 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function segmentChanged(e:PathSegment):void 
    {
    	graphicsPathChanged = true;
        boundsChanged();
    }

    /**
     *   @inheritDoc 
     */
    override protected function notifyElementLayerChanged():void
    {
        graphicsPathChanged = true;
        super.notifyElementLayerChanged();
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
        invalidateDisplayList();
    }
   
    /**
     * @private
     */
    private function clearBounds():void
    {
        _bounds = null;
    }
 
}

}

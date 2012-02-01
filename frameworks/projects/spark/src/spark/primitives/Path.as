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

import flash.display.Graphics;
import flash.display.GraphicsPath;
import flash.display.Shape;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.mx_internal;
import mx.utils.MatrixUtil;

import spark.primitives.supportClasses.FilledElement;

use namespace mx_internal;

/**
 *  The Path class is a filled graphic element that draws a series of path segments.
 *  In vector graphics, a path is a series of points connected by straight or curved line segments. 
 *  Together the lines form an image. In Flex, you use the Path class to define a complex vector shape 
 *  constructed from a set of line segments. 
 * 
 *  <p>Typically, the first element of a path definition is a Move segment to specify the starting pen 
 *  position of the graphic. You then use the Line, CubicBezier and QuadraticBezier segments to  
 *  draw the lines of the graphic. When using these classes, you only specify the x and y coordinates 
 *  of the end point of the line; the x and y coordinate of the starting point is defined by the current 
 *  pen position.</p>
 *  
 *  <p>After drawing a line segment, the current pen position becomes the x and y coordinates of the end 
 *  point of the line. You can use multiple Move segments in the path definition to 
 *  reposition the pen.</p>
 *  
 *  <p>The syntax used by the Path class to define the shape is the same as the SVG path syntax, 
 *  which makes it easy to convert SVG paths to Flex paths.</p>
 *  
 *  @includeExample examples/ArrowExample.mxml
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
     *  Private data structure to hold the parsed 
     *  path segment information  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    private var segments:Array = []; 
    
    /**
     *  A GraphicsPath object that contains the drawing 
     *  commands to draw this Path.  
     *  
     *  The data commands expressed in a Path's <code>data</code> 
     *  property are translated into drawing commands and 
     *  coordinate parameters for those commands, and then
     *  drawn to screen. 
     */ 
    mx_internal var graphicsPath:GraphicsPath = new GraphicsPath(new Vector.<int>(), new Vector.<Number>());
    
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
     *      <td>Move</td>
     *      <td>M/m</td>
     *      <td>x y</td>
     *      <td><code>M 10 20</code> - Move line to 10, 20.</td>
     *    </tr>
     *    <tr>
     *      <td>Line</td>
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
     *      <td>QuadraticBezier</td>
     *      <td>Q/q</td>
     *      <td>controlX controlY x y</td>
     *      <td><code>Q 110 45 90 30</code> - Curve to 90, 30 with the control point at 110, 45.</td>
     *    </tr>
     *    <tr>
     *      <td>CubicBezier</td>
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
        if (!value)
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
        var prevIdentifier:String = "";
        var prevX:Number = 0;
        var prevY:Number = 0;
        var lastMoveX:Number = 0;
        var lastMoveY:Number = 0;
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
            else if (prevIdentifier == "m" || prevIdentifier == "M")
            {
                // If a moveto is followed by multiple pairs of coordinates, 
                // the subsequent pairs are treated as implicit lineto commands. 
                identifier = prevIdentifier == "m" ? "l" : "L";
            }
            
            // Convert to lowercase to make the following comparison logic simpler
            prevIdentifier = prevIdentifier.toLowerCase();
            
            var useRelative:Boolean = (identifier.toLowerCase() == identifier);
            
            switch (identifier.toLowerCase())
            {
                case "m":
                    x = getNumber(useRelative, i++, prevX);
                    y = getNumber(useRelative, i++, prevY);
                    newSegments.push(new MoveSegment(x, y));
                    lastMoveX = x;
                    lastMoveY = y;
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
                    if (prevIdentifier == "t" || prevIdentifier == "q")
                    {
                        controlX = prevX + (prevX - controlX);
                        controlY = prevY + (prevY - controlY);
                    }
                    else
                    {
                        controlX = prevX;
                        controlY = prevY;
                    }
                    
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
                    if (prevIdentifier == "s" || prevIdentifier == "c")
                    {
                        controlX = prevX + (prevX - control2X);
                        controlY = prevY + (prevY - control2Y);
                    }
                    else
                    {
                        controlX = prevX;
                        controlY = prevY;
                    }
                    
                    control2X = getNumber(useRelative, i++, prevX);
                    control2Y = getNumber(useRelative, i++, prevY);
                    x = getNumber(useRelative, i++, prevX);
                    y = getNumber(useRelative, i++, prevY);
                    newSegments.push(new CubicBezierSegment(controlX, controlY,
                                        control2X, control2Y, x, y));
                    break;
                case "z":
					// For a close segment, we generate a LineSegment to the last move point instead. 
					x = lastMoveX;
					y = lastMoveY;
                    newSegments.push(new LineSegment(x, y));
                    break;
                
                default:
                    // unknown identifier, throw error?
                    return;
                    break;
            }
            
            prevX = x;
            prevY = y;
            prevIdentifier = identifier;
        }
        
        segments = newSegments;
        graphicsPathChanged = true;
        boundsChanged(); 
        
        // Set the _data backing var as the last step since notifyElementChanged
        // clears the value.
        _data = value;
    }
    
    /** 
     *  @private
     */
    public function get data():String 
    {
        return _data;
    }
    
    //----------------------------------
    //  winding
    //----------------------------------

    private var _winding:String = "evenOdd";
    
    /**
     *  Fill rule for intersecting or overlapping path segments. 
     *  Possible values are GraphicsPathWinding.EVEN_ODD or GraphicsPathWinding.NON_ZERO
     *
     *  @default evenOdd
     *  @see flash.display.GraphicPathWinding 
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

    private function getBounds():Rectangle
    {
        if (_bounds)
            return _bounds;

		// First, allocate temporary bounds, as getBoundingBox() requires
		// natual bounds to calculate a scaling factor
		_bounds = new Rectangle(0, 0, 1, 1);

		// Pass in the same size to getBoundingBox
		// so that the scaling factor is (1, 1).
		_bounds = getBoundingBox(1, 1, null /*Matrix*/);
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
    override protected function canSkipMeasurement():Boolean
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

        var prevSegment:PathSegment;
        var pathBBox:Rectangle;
        
        for (var i:int = 0; i < segments.length; i++)
        {
            var segment:PathSegment = segments[i];
            pathBBox = segment.getBoundingBox(prevSegment, sx, sy, m, pathBBox);
            prevSegment = segment;
        }

		// If path is empty, it's untransformed bounding box is (0,0), so we return transformed point (0,0)
        if (!pathBBox)
		{
			var x:Number = m ? m.tx : 0;
			var y:Number = m ? m.ty : 0;
            pathBBox = new Rectangle(x, y);
		}
        return pathBBox;
    }

    /**
     *  @private
     */
    override protected function transformWidthForLayout(width:Number,
                                                        height:Number,
                                                        postLayoutTransform:Boolean = true):Number
    {
        if (postLayoutTransform && hasComplexLayoutMatrix)
            width = getBoundingBox(width, height, layoutFeatures.layoutMatrix).width;

        // Take stroke into account
        return width + getStrokeExtents(postLayoutTransform).width;
    }

    /**
     *  @private
     */
    override protected function transformHeightForLayout(width:Number,
                                                         height:Number,
                                                         postLayoutTransform:Boolean = true):Number
    {
        if (postLayoutTransform && hasComplexLayoutMatrix)
            height = getBoundingBox(width, height, layoutFeatures.layoutMatrix).height;

        // Take stroke into account
        return height + getStrokeExtents(postLayoutTransform).height;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function getBoundsXAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
    {
        var strokeExtents:Rectangle = getStrokeExtents(postLayoutTransform);
        var m:Matrix = getComplexMatrix(postLayoutTransform);

        if (!m)
        {
            // Check for a common case, BasicLayout measure() always hits this:
            if (isNaN(width))
                return strokeExtents.left + this.x + measuredX;
            else
                width = preferredWidthPreTransform();

            var naturalBounds:Rectangle = getBounds();
            var sx:Number = (naturalBounds.width == 0 || width == 0) ? 1 : width / naturalBounds.width;
            return strokeExtents.left + this.x + measuredX * sx;
        }
    
        if (!isNaN(width))
            width -= strokeExtents.width;

        if (!isNaN(height))
            height -= strokeExtents.height;

        // Calculate the width and height pre-transform:
        var newSize:Point = MatrixUtil.fitBounds(width, height, m,
                                                 preferredWidthPreTransform(),
                                                 preferredHeightPreTransform(),
                                                 minWidth, minHeight,
                                                 maxWidth, maxHeight);
        if (!newSize)
            newSize = new Point(minWidth, minHeight);
        return strokeExtents.left + getBoundingBox(newSize.x, newSize.y, m).x;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function getBoundsYAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
    {
        var strokeExtents:Rectangle = getStrokeExtents(postLayoutTransform);
        var m:Matrix = getComplexMatrix(postLayoutTransform);

        if (!m)
        {
            // Check for a common case, BasicLayout measure() always hits this:
            if (isNaN(height))
                return strokeExtents.top + this.y + measuredY;
            else
                height = preferredHeightPreTransform();    

            var naturalBounds:Rectangle = getBounds();
            var sy:Number = (naturalBounds.height == 0 || height == 0) ? 1 : height / naturalBounds.height;
            return strokeExtents.top + this.y + measuredY * sy;
        }
    
        if (!isNaN(width))
            width -= strokeExtents.width;

        if (!isNaN(height))
            height -= strokeExtents.height;

        // Calculate the width and height pre-transform:
        var newSize:Point = MatrixUtil.fitBounds(width, height, m,
                                                 preferredWidthPreTransform(),
                                                 preferredHeightPreTransform(),
                                                 minWidth, minHeight,
                                                 maxWidth, maxHeight);
        if (!newSize)
            newSize = new Point(minWidth, minHeight);
        return strokeExtents.top + getBoundingBox(newSize.x, newSize.y, m).y;
    }

    /**
     *  @private
     */
    override public function getLayoutBoundsX(postLayoutTransform:Boolean = true):Number
    {
        var stroke:Number = getStrokeExtents(postLayoutTransform).left;
        var m:Matrix = getComplexMatrix(postLayoutTransform);
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
        var stroke:Number = getStrokeExtents(postLayoutTransform).top;
        var m:Matrix = getComplexMatrix(postLayoutTransform);
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
            stroke.apply(g, bounds);
        else
            g.lineStyle();
        
        if (fill)
            fill.begin(g, bounds);
    }
 
    // FIXME (egeorgie): these are a short term fix for MAX to work around the fact
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
    override protected function draw(g:Graphics):void
    {
        // FIXME (egeorgie): temporary check until DOsharing and graphics caching is cleaned up
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
            var sx:Number = rcBounds.width == 0 ? 1 : width / rcBounds.width;
            var sy:Number = rcBounds.height == 0 ? 1 : height / rcBounds.height;

            generateGraphicsPath(drawX, drawY, sx, sy);
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
     */
    mx_internal function generateGraphicsPath(tx:Number,ty:Number,sx:Number,sy:Number):void    
    {
        graphicsPath.commands = null;
        graphicsPath.data = null;
        
        // Always start by moving to drawX, drawY. Otherwise
        // the path will begin at the previous pen location
        // if it does not start with a MoveSegment.
        graphicsPath.moveTo(tx, ty);
        
        for (var i:int = 0; i < segments.length; i++)
        {
            var segment:PathSegment = segments[i];
            segment.draw(graphicsPath, tx, ty, sx, sy, (i > 0 ? segments[i - 1] : null));
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
     *  @inheritDoc
     */
    override protected function invalidateDisplayObjectSharing():void
    {
        graphicsPathChanged = true;
        super.invalidateDisplayObjectSharing();
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

//--------------------------------------------------------------------------
//
//  Internal Helper Class - PathSegment 
//
//--------------------------------------------------------------------------
import flash.display.GraphicsPath;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import spark.primitives.Path;
import mx.events.PropertyChangeEvent;

/**
 *  The PathSegment class is the base class for a segment of a path.
 *  This class is not created directly. It is the base class for 
 *  MoveSegment, LineSegment, CubicBezierSegment and QuadraticBezierSegment.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
class PathSegment extends Object
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     * 
     *  @param _x The x position of the pen in the current coordinate system.
     *  
     *  @param _y The y position of the pen in the current coordinate system.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function PathSegment(_x:Number = 0, _y:Number = 0)
    {
        super();
        x = _x;  
        y = _y; 
    }   

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  x
    //----------------------------------
    
	/**
     *  The ending x position for this segment.
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var x:Number = 0;
    
    //----------------------------------
    //  y
    //----------------------------------
    
	/**
     *  The ending y position for this segment.
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var y:Number = 0;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Draws this path segment. You can determine the current pen position by 
     *  reading the x and y values of the previous segment. 
     *
     *  @param g The graphics context to draw into.
     *  @param prev The previous segment drawn, or null if this is the first segment.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function draw(graphicsPath:GraphicsPath, dx:Number,dy:Number,sx:Number,sy:Number,prev:PathSegment):void
    {
        // Override to draw your segment
    }

    /**
     *  @param prev The previous segment drawn, or null if this is the first segment.
     *  @param sx Pre-transform scale factor for x coordinates.
     *  @param sy Pre-transform scale factor for y coordinates.
     *  @param m Transformation matrix.
     *  @param rect If non-null, rect is expanded to include the bounding box of the segment.
     *  @return Returns the union of rect and the axis aligned bounding box of the post-transformed
     *  path segment.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */    
    public function getBoundingBox(prev:PathSegment, sx:Number, sy:Number, m:Matrix, rect:Rectangle):Rectangle
    {
        // Override to calculate your segment's bounding box.
        return rect;
    }
}


//--------------------------------------------------------------------------
//
//  Internal Helper Class - LineSegment 
//
//--------------------------------------------------------------------------

import flash.display.GraphicsPath;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.utils.MatrixUtil;

/**
 *  The LineSegment draws a line from the current pen position to the coordinate located at x, y.
 *  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
class LineSegment extends PathSegment
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
     *  @param x The current location of the pen along the x axis. The <code>draw()</code> method uses 
     *  this value to determine where to draw to.
     * 
     *  @param y The current location of the pen along the y axis. The <code>draw()</code> method uses 
     *  this value to determine where to draw to.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function LineSegment(x:Number = 0, y:Number = 0)
    {
        super(x, y);
    }   
    
    //--------------------------------------------------------------------------
    //
    //  Methods
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
    override public function draw(graphicsPath:GraphicsPath, dx:Number,dy:Number,sx:Number,sy:Number,prev:PathSegment):void
    {
        graphicsPath.lineTo(dx + x*sx, dy + y*sy);
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function getBoundingBox(prev:PathSegment, sx:Number, sy:Number, m:Matrix, rect:Rectangle):Rectangle
    {
		pt = MatrixUtil.transformPoint(x * sx, y * sy, m);
		var x1:Number = pt.x;
		var y1:Number = pt.y;
		
		// If the previous segment actually draws, then only add the end point to the rectangle,
		// as the start point would have been added by the previous segment:
		if (prev != null && !(prev is MoveSegment))
			return MatrixUtil.rectUnion(x1, y1, x1, y1, rect); 
		
		var pt:Point = MatrixUtil.transformPoint(prev ? prev.x * sx : 0, prev ? prev.y * sy : 0, m);
		var x2:Number = pt.x;
		var y2:Number = pt.y;

		return MatrixUtil.rectUnion(Math.min(x1, x2), Math.min(y1, y2),
									Math.max(x1, x2), Math.max(y1, y2), rect); 
    }

}


//--------------------------------------------------------------------------
//
//  Internal Helper Class - MoveSegment 
//
//--------------------------------------------------------------------------
import flash.display.GraphicsPath;

/**
 *  The MoveSegment moves the pen to the x,y position. This class calls the <code>Graphics.moveTo()</code> method 
 *  from the <code>draw()</code> method.
 * 
 *  
 *  @see flash.display.Graphics
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
class MoveSegment extends PathSegment
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
     *  @param x The target x-axis location in 2-d coordinate space.
     *  
     *  @param y The target y-axis location in 2-d coordinate space.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function MoveSegment(x:Number = 0, y:Number = 0)
    {
        super(x, y);
    }   
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @inheritDoc
     * 
     *  The MoveSegment class moves the pen to the position specified by the
     *  x and y properties.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function draw(graphicsPath:GraphicsPath, dx:Number,dy:Number,sx:Number,sy:Number,prev:PathSegment):void
    {
        graphicsPath.moveTo(dx+x*sx, dy+y*sy);
    }
}

//--------------------------------------------------------------------------
//
//  Internal Helper Class - CubicBezierSegment 
//
//--------------------------------------------------------------------------

import flash.display.GraphicsPath;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.utils.MatrixUtil;

/**
 *  The CubicBezierSegment draws a cubic bezier curve from the current pen position 
 *  to x, y. The control1X and control1Y properties specify the first control point; 
 *  the control2X and control2Y properties specify the second control point.
 *
 *  <p>Cubic bezier curves are not natively supported in Flash Player. This class does
 *  an approximation based on the fixed midpoint algorithm and uses 4 quadratic curves
 *  to simulate a cubic curve.</p>
 *
 *  <p>For details on the fixed midpoint algorithm, see:<br/>
 *  http://timotheegroleau.com/Flash/articles/cubic_bezier_in_flash.htm</p>
 *  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
class CubicBezierSegment extends PathSegment
{
   
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
     *  <p>For a CubicBezierSegment, there are two control points, each with x and y coordinates. Control points 
     *  are points that define the direction and amount of curves of a Bezier curve. 
     *  The curved line never reaches the control points; however, the line curves as though being drawn 
     *  toward the control point.</p>
     *  
     *  @param _control1X The x-axis location in 2-d coordinate space of the first control point.
     *  
     *  @param _control1Y The y-axis location of the first control point.
     *  
     *  @param _control2X The x-axis location of the second control point.
     *  
     *  @param _control2Y The y-axis location of the second control point.
     *  
     *  @param x The x-axis location of the starting point of the curve.
     *  
     *  @param y The y-axis location of the starting point of the curve.
     *  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function CubicBezierSegment(
                _control1X:Number = 0, _control1Y:Number = 0,
                _control2X:Number = 0, _control2Y:Number = 0,
                x:Number = 0, y:Number = 0)
    {
        super(x, y);
        
        control1X = _control1X;
        control1Y = _control1Y;
        control2X = _control2X;
        control2Y = _control2Y;
    }   


    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private var _qPts:QuadraticPoints;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  control1X
    //----------------------------------
    
	/**
     *  The first control point x position.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var control1X:Number = 0;
    
    //----------------------------------
    //  control1Y
    //----------------------------------
    
	/**
     *  The first control point y position.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var control1Y:Number = 0;
    
    //----------------------------------
    //  control2X
    //----------------------------------
    
	/**
     *  The second control point x position.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var control2X:Number = 0;
    
    //----------------------------------
    //  control2Y
    //----------------------------------
    
	/**
     *  The second control point y position.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var control2Y:Number = 0;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Draws the segment.
     *
     *  @param g The graphics context where the segment is drawn.
     *  
     *  @param prev The previous location of the pen.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function draw(graphicsPath:GraphicsPath, dx:Number, dy:Number, sx:Number, sy:Number, prev:PathSegment):void
    {
        var qPts:QuadraticPoints = getQuadraticPoints(prev);
                    
        graphicsPath.curveTo(dx + qPts.control1.x*sx, dy+qPts.control1.y*sy, dx+qPts.anchor1.x*sx, dy+qPts.anchor1.y*sy);
        graphicsPath.curveTo(dx + qPts.control2.x*sx, dy+qPts.control2.y*sy, dx+qPts.anchor2.x*sx, dy+qPts.anchor2.y*sy);
        graphicsPath.curveTo(dx + qPts.control3.x*sx, dy+qPts.control3.y*sy, dx+qPts.anchor3.x*sx, dy+qPts.anchor3.y*sy);
        graphicsPath.curveTo(dx + qPts.control4.x*sx, dy+qPts.control4.y*sy, dx+qPts.anchor4.x*sx, dy+qPts.anchor4.y*sy);
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function getBoundingBox(prev:PathSegment, sx:Number, sy:Number,
                                            m:Matrix, rect:Rectangle):Rectangle
    {
        var qPts:QuadraticPoints = getQuadraticPoints(prev);
        
        rect = MatrixUtil.getQBezierSegmentBBox(prev ? prev.x : 0, prev ? prev.y : 0,
                                                qPts.control1.x, qPts.control1.y,
                                                qPts.anchor1.x, qPts.anchor1.y,
                                                sx, sy, m, rect); 

        rect = MatrixUtil.getQBezierSegmentBBox(qPts.anchor1.x, qPts.anchor1.y,
                                                qPts.control2.x, qPts.control2.y,
                                                qPts.anchor2.x, qPts.anchor2.y,
                                                sx, sy, m, rect); 

        rect = MatrixUtil.getQBezierSegmentBBox(qPts.anchor2.x, qPts.anchor2.y,
                                                qPts.control3.x, qPts.control3.y,
                                                qPts.anchor3.x, qPts.anchor3.y,
                                                sx, sy, m, rect); 

        rect = MatrixUtil.getQBezierSegmentBBox(qPts.anchor3.x, qPts.anchor3.y,
                                                qPts.control4.x, qPts.control4.y,
                                                qPts.anchor4.x, qPts.anchor4.y,
                                                sx, sy, m, rect); 
        return rect;
    }
    
    /** 
     *  @private
     *  Tim Groleau's method to approximate a cubic bezier with 4 quadratic beziers, 
     *  with endpoint and control point of each saved. 
     */
    private function getQuadraticPoints(prev:PathSegment):QuadraticPoints
    {
        if (_qPts)
            return _qPts;

        var p1:Point = new Point(prev ? prev.x : 0, prev ? prev.y : 0);
        var p2:Point = new Point(x, y);
        var c1:Point = new Point(control1X, control1Y);     
        var c2:Point = new Point(control2X, control2Y);
            
        // calculates the useful base points
        var PA:Point = Point.interpolate(c1, p1, 3/4);
        var PB:Point = Point.interpolate(c2, p2, 3/4);
    
        // get 1/16 of the [p2, p1] segment
        var dx:Number = (p2.x - p1.x) / 16;
        var dy:Number = (p2.y - p1.y) / 16;

        _qPts = new QuadraticPoints;
        
        // calculates control point 1
        _qPts.control1 = Point.interpolate(c1, p1, 3/8);
    
        // calculates control point 2
        _qPts.control2 = Point.interpolate(PB, PA, 3/8);
        _qPts.control2.x -= dx;
        _qPts.control2.y -= dy;
    
        // calculates control point 3
        _qPts.control3 = Point.interpolate(PA, PB, 3/8);
        _qPts.control3.x += dx;
        _qPts.control3.y += dy;
    
        // calculates control point 4
        _qPts.control4 = Point.interpolate(c2, p2, 3/8);
    
        // calculates the 3 anchor points
        _qPts.anchor1 = Point.interpolate(_qPts.control1, _qPts.control2, 0.5); 
        _qPts.anchor2 = Point.interpolate(PA, PB, 0.5); 
        _qPts.anchor3 = Point.interpolate(_qPts.control3, _qPts.control4, 0.5); 
    
        // the 4th anchor point is p2
        _qPts.anchor4 = p2;
        
        return _qPts;      
    }
}

//--------------------------------------------------------------------------
//
//  Internal Helper Class - QuadraticPoints  
//
//--------------------------------------------------------------------------
import flash.geom.Point;
    
/**
 *  Utility class to store the computed quadratic points.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
class QuadraticPoints
{
    public var control1:Point;
    public var anchor1:Point;
    public var control2:Point;
    public var anchor2:Point;
    public var control3:Point;
    public var anchor3:Point;
    public var control4:Point;
    public var anchor4:Point;
    
    /**
     * Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function QuadraticPoints()
    {
        super();
    }
}

//--------------------------------------------------------------------------
//
//  Internal Helper Class - QuadraticBezierSegment 
//
//--------------------------------------------------------------------------
import flash.display.GraphicsPath;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.utils.MatrixUtil;

/**
 *  The QuadraticBezierSegment draws a quadratic curve from the current pen position 
 *  to x, y. 
 *
 *  Quadratic bezier is the native curve type
 *  in Flash Player.
 *  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
class QuadraticBezierSegment extends PathSegment
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
     *  <p>For a QuadraticBezierSegment, there is one control point. A control point
     *  is a point that defines the direction and amount of a Bezier curve. 
     *  The curved line never reaches the control point; however, the line curves as though being drawn 
     *  toward the control point.</p>
     * 
     *  @param _control1X The x-axis location in 2-d coordinate space of the control point.
     *  
     *  @param _control1Y The y-axis location in 2-d coordinate space of the control point.
     *  
     *  @param x The x-axis location of the starting point of the curve.
     *  
     *  @param y The y-axis location of the starting point of the curve.
     * 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function QuadraticBezierSegment(
                _control1X:Number = 0, _control1Y:Number = 0, 
                x:Number = 0, y:Number = 0)
    {
        super(x, y);
        
        control1X = _control1X;
        control1Y = _control1Y;
    }   

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  control1X
    //----------------------------------
	
	/**
     *  The control point's x position.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var control1X:Number = 0;
    
    //----------------------------------
    //  control1Y
    //----------------------------------
	
	/**
     *  The control point's y position.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var control1Y:Number = 0;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Draws the segment using the control point location and the x and y coordinates. 
     *  This method calls the <code>Graphics.curveTo()</code> method.
     *  
     *  @see flash.display.Graphics
     *
     *  @param g The graphics context where the segment is drawn.
     *  
     *  @param prev The previous location of the pen.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function draw(graphicsPath:GraphicsPath, dx:Number,dy:Number,sx:Number,sy:Number,prev:PathSegment):void
    {
        graphicsPath.curveTo(dx+control1X*sx, dy+control1Y*sy, dx+x*sx, dy+y*sy);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function getBoundingBox(prev:PathSegment, sx:Number, sy:Number,
                                            m:Matrix, rect:Rectangle):Rectangle
    {
        return MatrixUtil.getQBezierSegmentBBox(prev ? prev.x : 0, prev ? prev.y : 0,
                                                control1X, control1Y, x, y, sx, sy, m, rect);
    }
}

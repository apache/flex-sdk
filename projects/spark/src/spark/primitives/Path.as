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

package flex.graphics
{

import flash.display.Graphics;
import flash.display.LineScaleMode;
import flash.events.EventDispatcher;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.Shape;

import mx.core.mx_internal;
import mx.graphics.IStroke;

use namespace mx_internal;

/**
 *  The Path class is a filled graphic element that draws a series of path segments.
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
     *  way of setting the segments property. Setting this property will override any values
     *  stored in the segments array property.
     *
     *  <p>The value is a space-delimited string describing each path segment. Each
     *  segment entry has a single character which denotes the segment type and
     *  two or more segment parameters.</p>
     * 
     *  <p>If the segment command is upper-case, the parameters are absolute values.
     *  If the segment command is lower-case, the parameters are relative values.</p>
     *
     *  <p>Here is the syntax for the segments:</p>
     *  Segment Type     Command       Parameters       Example
     *  ------------     -------       ----------       -------
     *  MoveSegment      M/m           x y              M 10 20 - Move to 10, 20
     *  LineSegment      L/l           x y              L 50 30 - Line to 50, 30
     *   horiz. line     H/h           x                H 40 - Horizontal line to 40
     *   vert. line      V/v           y                V 100 - Vertical line to 100 
     *  QuadraticBezier  Q/q           controlX 
     *                                 controlY 
     *                                 x y              Q 110 45 90 30
     *                                                  - Curve to 90, 30 with the control
     *                                                    point at 110, 45
     *  CubicBezier      C/c           control1X
     *                                 control1Y
     *                                 control2X
     *                                 control2Y
     *                                 x y              C 45 50 20 30 10 20
     *                                                  - Curve to 10, 20 with the first
     *                                                    control point at 45, 50 and the
     *                                                    second control point at 20, 30
     *  close path       Z/z           none             Closes off the path 
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
    
    [ArrayElementType("flex.graphics.PathSegment")]
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
        
        boundsChanged();
    }
    
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
        _winding = value;
    }
    
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
        // Always start by moving to 0, 0. Otherwise
        // the path will begin at the previous pen location
        // if it does not start with a MoveSegment.
        g.moveTo(0, 0);
        var currentSubPathStartIndex:int = 0;
        
        for (var i:int = 0; i < segments.length; i++)
        {
            var segment:PathSegment = segments[i];
                    
            segment.draw(g, (i > 0 ? segments[i - 1] : null));
            
            if (segment is CloseSegment)
            {   
                if (segments[currentSubPathStartIndex] is MoveSegment)
                    g.lineTo(segments[currentSubPathStartIndex].x, segments[currentSubPathStartIndex].y)
                else
                    g.lineTo(0, 0);
                    
                currentSubPathStartIndex = i+1;
            }
        }
    }
    
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
        boundsChanged();
    }
    
    private function boundsChanged(): void
    {
        // Clear our cached measurement and data values
        clearBounds();
        _data = null;
        invalidateSize();
    }
   
    private function clearBounds():void
    {
        _bounds = null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  ILayoutItem
    //
    //--------------------------------------------------------------------------

    override protected function computeMatrix(actualMatrix:Boolean):Matrix
    {
        var tmpScaleX:Number = actualMatrix ? super.scaleX : _userScaleX;
        var tmpScaleY:Number = actualMatrix ? super.scaleY : _userScaleY;

        if (tmpScaleX == 1 && tmpScaleY == 1 && rotation == 0)
            return null;

        return TransformUtil.composeMatrix(x, y, tmpScaleX, tmpScaleY,
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
     *  <code>setActualSize</code> modifies the item size/transform so that
     *  its TBounds have the specified <code>width</code> and <code>height</code>.
     *  
     *  If one of the desired TBounds dimensions is left unspecified, it's size
     *  will be picked such that item can be optimally sized to fit the other
     *  TBounds dimension. This is useful when the layout doesn't want to 
     *  overconstrain the item in cases where the item TBounds width and height
     *  are dependent (text, components with complex transforms, etc.)
     * 
     *  If both TBounds dimensions are left unspecified, the item will have its
     *  preferred size set.
     * 
     *  <code>setActualSize</code> does not clip against <code>minSize</code> and
     *  <code>maxSize</code> properties.
     * 
     *  <code>setActualSize</code> must preserve the item's TBounds position,
     *  which means that in some cases it will move the item in addition to
     *  changing its size.
     * 
     *  @return Returns the TBounds of the new item size.
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

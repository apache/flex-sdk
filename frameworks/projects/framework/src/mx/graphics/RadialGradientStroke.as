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

package mx.graphics
{

import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.GraphicsGradientFill;
import flash.display.GraphicsStroke;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.mx_internal;

use namespace mx_internal; 
    
/**
 *  The RadialGradientStroke class lets you specify a gradient filled stroke.
 *  You use the RadialGradientStroke class, along with the GradientEntry class,
 *  to define a gradient stroke.
 *  
 *  @see mx.graphics.Stroke
 *  @see mx.graphics.GradientEntry
 *  @see mx.graphics.RadialGradient 
 *  @see flash.display.Graphics
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class RadialGradientStroke extends GradientStroke
{
    /**
     *  Constructor.
     *
     *  @param weight Specifies the line weight, in pixels.
     *  This parameter is optional,
     *  with a default value of <code>1</code>. 
     *
     *  @param pixelHinting A Boolean value that specifies
     *  whether to hint strokes to full pixels.
     *  This affects both the position of anchors of a curve
     *  and the line stroke size itself.
     *  With <code>pixelHinting</code> set to <code>true</code>,
     *  Flash Player and AIR hint line widths to full pixel widths.
     *  With <code>pixelHinting</code> set to <code>false</code>,
     *  disjoints can  appear for curves and straight lines. 
     *  This parameter is optional,
     *  with a default value of <code>false</code>. 
     *
     *  @param scaleMode A value from the LineScaleMode class
     *  that specifies which scale mode to use.
     *  Valid values are <code>LineScaleMode.HORIZONTAL</code>,
     *  <code>LineScaleMode.NONE</code>, <code>LineScaleMode.NORMAL</code>,
     *  and <code>LineScaleMode.VERTICAL</code>.
     *  This parameter is optional,
     *  with a default value of <code>LineScaleMode.NORMAL</code>. 
     *
     *  @param caps A value from the CapsStyle class
     *  that specifies the type of caps at the end of lines.
     *  Valid values are <code>CapsStyle.NONE</code>,
     *  <code>CapsStyle.ROUND</code>, and <code>CapsStyle.SQUARE</code>.
     *  A <code>null</code> value is equivalent to
     *  <code>CapsStyle.ROUND</code>.
     *  This parameter is optional,
     *  with a default value of <code>CapsStyle.ROUND</code>. 
     *
     *  @param joints A value from the JointStyle class
     *  that specifies the type of joint appearance used at angles.
     *  Valid values are <code>JointStyle.BEVEL</code>,
     *  <code>JointStyle.MITER</code>, and <code>JointStyle.ROUND</code>.
     *  A <code>null</code> value is equivalent to
     *  <code>JointStyle.ROUND</code>.
     *  This parameter is optional,
     *  with a default value of <code>JointStyle.ROUND</code>. 
     *
     *  @param miterLimit A number that indicates the limit
     *  at which a miter is cut off. 
     *  Valid values range from 1 to 255
     *  (and values outside of that range are rounded to 1 or 255). 
     *  This value is only used if the <code>jointStyle</code> property 
     *  is set to <code>miter</code>.
     *  The <code>miterLimit</code> value represents the length that a miter
     *  can extend beyond the point at which the lines meet to form a joint.
     *  The value expresses a factor of the line <code>thickness</code>.
     *  For example, with a <code>miterLimit</code> factor of 2.5 and a 
     *  <code>thickness</code> of 10 pixels, the miter is cut off at 25 pixels. 
     *  This parameter is optional,
     *  with a default value of <code>3</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function RadialGradientStroke(weight:Number = 1,
                                         pixelHinting:Boolean = false,
                                         scaleMode:String = "normal",
                                         caps:String = "round",
                                         joints:String = "round",
                                         miterLimit:Number = 3)
    {
        super(weight, pixelHinting, scaleMode, caps, joints, miterLimit);
    }
    
    /**
     *  @private
     */
    private static var commonMatrix:Matrix = new Matrix();
    
    //----------------------------------
    //  focalPointRatio
    //----------------------------------

    /**
     *  @private
     *  Storage for the focalPointRatio property.
     */
    private var _focalPointRatio:Number = 0.0;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  Sets the location of the start of the radial fill.
     *
     *  <p>Valid values are from <code>-1.0</code> to <code>1.0</code>.
     *  A value of <code>-1.0</code> sets the focal point
     *  (or, start of the gradient fill)
     *  on the left of the bounding Rectangle.
     *  A value of <code>1.0</code> sets the focal point
     *  on the right of the bounding Rectangle.
     *  
     *  <p>If you use this property in conjunction
     *  with the <code>angle</code> property, 
     *  this value specifies the degree of distance
     *  from the center that the focal point occurs. 
     *  For example, with an angle of 45
     *  and <code>focalPointRatio</code> of 0.25,
     *  the focal point is slightly lower and to the right of center.
     *  If you set <code>focalPointRatio</code> to <code>0</code>,
     *  the focal point is in the middle of the bounding Rectangle.</p>
     *  If you set <code>focalPointRatio</code> to <code>1</code>,
     *  the focal point is all the way to the bottom right corner
     *  of the bounding Rectangle.</p>
     *
     *  @default 0.0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get focalPointRatio():Number
    {
        return _focalPointRatio;
    }
    
    /**
     *  @private
     */
    public function set focalPointRatio(value:Number):void
    {
        var oldValue:Number = _focalPointRatio;
        if (value != oldValue)
        {
            _focalPointRatio = value;
            
            dispatchGradientChangedEvent("focalPointRatio",
                                                      oldValue, value);
        }
    }

    //----------------------------------

	//  matrix
	//----------------------------------
    
    /**
     *  @private
     */
    override public function set matrix(value:Matrix):void
    {
    	scaleX = NaN;
    	scaleY = NaN;
    	super.matrix = value;
    }

    //----------------------------------
    //  scaleX
    //----------------------------------
    
    private var _scaleX:Number;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  The horizontal scale of the gradient transform, which defines the width of the (unrotated) gradient
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
            {
                // If we have a compoundTransform, only non-NaN values are allowed
                if (!isNaN(value))
                    compoundTransform.scaleX = value;
            }
            else
            {
                _scaleX = value;
            }
            dispatchGradientChangedEvent("scaleX", oldValue, value);
        }
    }
    
    //----------------------------------
    //  scaleY
    //----------------------------------
    
    private var _scaleY:Number;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  The vertical scale of the gradient transform, which defines the height of the (unrotated) gradient
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
            {
                // If we have a compoundTransform, only non-NaN values are allowed
                if (!isNaN(value))
                    compoundTransform.scaleY = value;
            }
            else
            {
                _scaleY = value;
            }
            dispatchGradientChangedEvent("scaleY", oldValue, value);
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
    override public function apply(graphics:Graphics, targetBounds:Rectangle, targetOrigin:Point):void
    {
    	commonMatrix.identity();
    	
        graphics.lineStyle(weight, 0, 1, pixelHinting, scaleMode,
                    caps, joints, miterLimit);
        
        if (targetBounds)
        	calculateTransformationMatrix(targetBounds, commonMatrix, targetOrigin); 
	        
        graphics.lineGradientStyle(GradientType.RADIAL, colors,
                            alphas, ratios, commonMatrix, 
                            spreadMethod, interpolationMethod, 
                            focalPointRatio);                       
    }
    
    /**
     *  @private
     */
    override public function createGraphicsStroke(targetBounds:Rectangle, targetOrigin:Point):GraphicsStroke
    {
        // The parent class sets the gradient stroke properties common to 
        // LinearGradientStroke and RadialGradientStroke 
        var graphicsStroke:GraphicsStroke = super.createGraphicsStroke(targetBounds, targetOrigin);
         
        if (graphicsStroke)
        {
            // Set other properties specific to this RadialGradientStroke  
            GraphicsGradientFill(graphicsStroke.fill).type = GradientType.RADIAL; 
            calculateTransformationMatrix(targetBounds, commonMatrix, targetOrigin);
            GraphicsGradientFill(graphicsStroke.fill).matrix = commonMatrix; 
            GraphicsGradientFill(graphicsStroke.fill).focalPointRatio = focalPointRatio;
            
        }
        
        return graphicsStroke; 
    } 
    
    /**
     *  @private
     *  Calculates this RadialGradientStroke's transformation matrix 
     */
    private function calculateTransformationMatrix(targetBounds:Rectangle, matrix:Matrix, targetOrigin:Point):void
    {
    	matrix.identity();
    	
        if (!compoundTransform)
        {   
            var w:Number = !isNaN(scaleX) ? scaleX : targetBounds.width;
	    	var h:Number = !isNaN(scaleY) ? scaleY : targetBounds.height;
			var regX:Number = !isNaN(x) ? x + targetOrigin.x : targetBounds.left + targetBounds.width / 2;
			var regY:Number = !isNaN(y) ? y + targetOrigin.y : targetBounds.top + targetBounds.height / 2;
                
            matrix.scale (w / GRADIENT_DIMENSION, h / GRADIENT_DIMENSION);
	        matrix.rotate(!isNaN(_angle) ? _angle : rotationInRadians);
	        matrix.translate(regX, regY);	    
        }             
        else
        {                     
            matrix.scale(1 / GRADIENT_DIMENSION, 1 / GRADIENT_DIMENSION);
            matrix.concat(compoundTransform.matrix);
            matrix.translate(targetOrigin.x, targetOrigin.y);
        }   
    }
    
}
}

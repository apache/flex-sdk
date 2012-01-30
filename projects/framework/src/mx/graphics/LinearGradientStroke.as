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

import flash.display.GradientType;
import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import mx.skins.RectangularBorder;

/**
 *  The LinearGradientStroke class lets you specify a gradient filled stroke.
 *  You use the LinearGradientStroke class, along with the GradientEntry class,
 *  to define a gradient stroke.
 *  
 *  @see mx.graphics.Stroke
 *  @see mx.graphics.GradientEntry
 *  @see mx.graphics.RadialGradient 
 *  @see flash.display.Graphics
 */
public class LinearGradientStroke extends GradientStroke implements IStroke
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
     *  @param weight Specifies the line weight, in pixels.
     *  This parameter is optional,
     *  with a default value of <code>0</code>. 
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
     *  with a default value of <code>LineScaleMode.NONE</code>. 
     *
     *  @param caps A value from the CapsStyle class
     *  that specifies the type of caps at the end of lines.
     *  Valid values are <code>CapsStyle.NONE</code>,
     *  <code>CapsStyle.ROUND</code>, and <code>CapsStyle.SQUARE</code>.
     *  A <code>null</code> value is equivalent to
     *  <code>CapsStyle.ROUND</code>.
     *  This parameter is optional,
     *  with a default value of <code>null</code>. 
     *
     *  @param joints A value from the JointStyle class
     *  that specifies the type of joint appearance used at angles.
     *  Valid values are <code>JointStyle.BEVEL</code>,
     *  <code>JointStyle.MITER</code>, and <code>JointStyle.ROUND</code>.
     *  A <code>null</code> value is equivalent to
     *  <code>JoinStyle.ROUND</code>.
     *  This parameter is optional,
     *  with a default value of <code>null</code>. 
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
     *  with a default value of <code>0</code>.
     */
    public function LinearGradientStroke(weight:Number = 0,
                                         pixelHinting:Boolean = false,
                                         scaleMode:String = "normal",
                                         caps:String = null,
                                         joints:String = null,
                                         miterLimit:Number = 0)
    {
        super(weight, pixelHinting, scaleMode, caps, joints, miterLimit);
        
        matrix = new Matrix();
    }
     
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     */
	private static var commonMatrix:Matrix = new Matrix();

	[Deprecated(replacement="draw")]
    /**
     *  Applies the properties to the specified Graphics object.
     *  
     *  @param g The Graphics object to which the LinearGradientStroke styles
     *  are applied.
     */
    public function apply(g:Graphics):void
    {
        g.lineStyle(weight, 0, 1, pixelHinting, scaleMode,
                    caps, joints, miterLimit);
               
        g.lineGradientStyle(GradientType.LINEAR, mx_internal::colors,
                            mx_internal::alphas, mx_internal::ratios,
                            null /* matrix */, spreadMethod,
                            interpolationMethod);
    }
    
    public function draw(g:Graphics, rc:Rectangle):void
    {
    	g.lineStyle(weight, 0, 1, pixelHinting, scaleMode,
                    caps, joints, miterLimit);
    	
    	var w:Number = !isNaN(scaleX) ? scaleX : rc.width;
		var bX:Number = !isNaN(x) ? x + rc.left : rc.left;
		var bY:Number = !isNaN(y) ? y + rc.top : rc.top;
        
        commonMatrix.createGradientBox(w, rc.height, 
								!isNaN(mx_internal::_angle) ? 
									mx_internal::_angle : mx_internal::rotationInRadians,
								 bX, bY);	
								 
		g.lineGradientStyle(GradientType.LINEAR, mx_internal::colors,
                            mx_internal::alphas, mx_internal::ratios,
                            commonMatrix, spreadMethod,
                            interpolationMethod);						 
    }
}

}

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
 
import flash.display.Graphics;
import flash.display.GraphicsGradientFill; 
import flash.display.GraphicsStroke;
import flash.display.GradientType;  
import flash.geom.Matrix;
import flash.geom.Rectangle;

import mx.core.mx_internal; 

use namespace mx_internal; 

/**
 *  The LinearGradientStroke class lets you specify a gradient filled stroke.
 *  You use the LinearGradientStroke class, along with the GradientEntry class,
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
public class LinearGradientStroke extends GradientStroke
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
     *  with a default value of <code>LineScaleMode.NONE</code>. 
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
    public function LinearGradientStroke(weight:Number = 1,
                                         pixelHinting:Boolean = false,
                                         scaleMode:String = "normal",
                                         caps:String = "round",
                                         joints:String = "round",
                                         miterLimit:Number = 3)
    {
        super(weight, pixelHinting, scaleMode, caps, joints, miterLimit);
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private static var commonMatrix:Matrix = new Matrix();

    [Deprecated(replacement="LinearGradientStroke.draw()")]
    /**
     *  Applies the properties to the specified Graphics object.
     *  
     *  @param g The Graphics object to which the LinearGradientStroke styles
     *  are applied.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function apply(g:Graphics):void
    {
        g.lineStyle(weight, 0, 1, pixelHinting, scaleMode,
                    caps, joints, miterLimit);
               
        g.lineGradientStyle(GradientType.LINEAR, colors,
                            alphas, ratios, null /* matrix */, 
                            spreadMethod, interpolationMethod);
    }
    
    /**
     *  @private
     */
    override public function draw(g:Graphics, rc:Rectangle):void
    {
        g.lineStyle(weight, 0, 1, pixelHinting, scaleMode,
                    caps, joints, miterLimit);
        
        calculateTransformationMatrix(rc, commonMatrix); 
        
        g.lineGradientStyle(GradientType.LINEAR, colors,
                            alphas, ratios,
                            commonMatrix, spreadMethod,
                            interpolationMethod);                        
    }
    
    /**
     *  @private
     */
    override public function generateGraphicsStroke(rect:Rectangle):GraphicsStroke
    {
        // The parent class sets the gradient stroke properties common to 
        // LinearGradientStroke and RadialGradientStroke 
        var graphicsStroke:GraphicsStroke = super.generateGraphicsStroke(rect); 
        
        if (graphicsStroke)
        {
            // Set other properties specific to this LinearGradientStroke  
            GraphicsGradientFill(graphicsStroke.fill).type = GradientType.LINEAR; 
            calculateTransformationMatrix(rect, commonMatrix);
            GraphicsGradientFill(graphicsStroke.fill).matrix = commonMatrix; 
        }
        
        return graphicsStroke; 
    }
    
    /**
     *  @private
     *  Calculates this LinearGradientStroke's transformation matrix.  
     */
    private function calculateTransformationMatrix(rect:Rectangle, matrix:Matrix):void
    {
        if (!compoundTransform)
        {
            var w:Number = !isNaN(scaleX) ? scaleX : rect.width;
            var bX:Number = !isNaN(x) ? x + rect.left : rect.left;
            var bY:Number = !isNaN(y) ? y + rect.top : rect.top;
            
            matrix.createGradientBox(w, rect.height, 
                                    !isNaN(_angle) ? 
                                        _angle : rotationInRadians,
                                     bX, bY);   
        }
        else
        {
            matrix.identity();
            matrix.scale(rect.width / GRADIENT_DIMENSION, 1);
            matrix.translate(rect.left + rect.width / 2, 0);
            matrix.concat(compoundTransform.matrix);  
        }
    }
    
}

}

package mx.graphics
{
    
import flash.display.GradientType;
import flash.display.Graphics;
import flash.geom.Rectangle;
import mx.core.mx_internal;
import flash.geom.Matrix;
    
/**
 *  The RadialGradientStroke class lets you specify a gradient filled stroke.
 *  You use the RadialGradientStroke class, along with the GradientEntry class,
 *  to define a gradient stroke.
 *  
 *  @see mx.graphics.Stroke
 *  @see mx.graphics.GradientEntry
 *  @see mx.graphics.RadialGradient 
 *  @see flash.display.Graphics
 */
public class RadialGradientStroke extends GradientStroke implements IStroke
{
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
     *  with a default value of <code>LineScaleMode.NORMAL</code>. 
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
    public function RadialGradientStroke(weight:Number = 0,
                                         pixelHinting:Boolean = false,
                                         scaleMode:String = "normal",
                                         caps:String = null,
                                         joints:String = null,
                                         miterLimit:Number = 0)
    {
        super(weight, pixelHinting, scaleMode, caps, joints, miterLimit);
    }
    
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
            
            mx_internal::dispatchGradientChangedEvent("focalPointRatio",
                                                      oldValue, value);
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
     */
    public function get scaleY():Number
    {
        return _scaleY; 
    }
    
    /**
     *  @private
     */
    public function set scaleY(value:Number):void
    {
        var oldValue:Number = _scaleY;
        if (value != oldValue)
        {
            _scaleY = value;
            mx_internal::dispatchGradientChangedEvent("scaleY", oldValue, value);
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
    public function apply(g:Graphics):void
    {
        // No-op. Need to deprecate. Was never implemented for this class
    }
    
    /**
     *  @inheritDoc
     */
	private static var commonMatrix:Matrix = new Matrix();

    /**
     *  Draws the stroke. 
     *  
     *  @param g The graphics context where the stroke is drawn.
     *  
     *  @param rc 
     */
    public function draw(g:Graphics, rc:Rectangle):void
    {
        g.lineStyle(weight, 0, 1, pixelHinting, scaleMode,
                    caps, joints, miterLimit);
        
        var w:Number = !isNaN(scaleX) ? scaleX : rc.width;
        var h:Number = !isNaN(scaleY) ? scaleY : rc.height;
        var bX:Number = !isNaN(x) ? x + rc.left : rc.left;
        var bY:Number = !isNaN(y) ? y + rc.top : rc.top;
        
        commonMatrix.createGradientBox(w, h, 
                                 mx_internal::rotationInRadians,
                                 bX, bY);   
                                 
        g.lineGradientStyle(GradientType.RADIAL, mx_internal::colors,
                            mx_internal::alphas, mx_internal::ratios,
                            commonMatrix, spreadMethod,
                            interpolationMethod, focalPointRatio);                       
    }
    
}
}
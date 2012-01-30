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
import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.GraphicsGradientFill;
import flash.display.GraphicsStroke;
import flash.display.JointStyle;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.mx_internal;

use namespace mx_internal; 

/**
 *  The GradientStroke class lets you specify a gradient filled stroke.
 *  You use the GradientStroke class, along with the GradientEntry class,
 *  to define a gradient stroke.
 *  
 *  @see mx.graphics.Stroke
 *  @see mx.graphics.GradientEntry
 *  @see flash.display.Graphics
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class GradientStroke extends GradientBase implements IStroke 
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
    public function GradientStroke(weight:Number = 1,
                                     pixelHinting:Boolean = false,
                                     scaleMode:String = "normal",
                                     caps:String = "round",
                                     joints:String = "round",
                                     miterLimit:Number = 3)
    {
        super();

        this.weight = weight;
        this.pixelHinting = pixelHinting;
        this.scaleMode = scaleMode;
        this.caps = caps;
        this.joints = joints;
        this.miterLimit = miterLimit;
    }
    
    //----------------------------------
    //  caps
    //----------------------------------

    /**
     *  @private
     *  Storage for the caps property.
     */
    private var _caps:String = CapsStyle.ROUND;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General", enumeration="round,square,none", defaultValue="round")]

    /**
     *  Specifies the appearance of the ends of lines.
     *
     *  <p>Valid values are <code>CapsStyle.NONE</code>,
     *  <code>CapsStyle.ROUND</code>, and <code>CapsStyle.SQUARE</code>.
     *  A <code>null</code> value is equivalent to
     *  <code>CapsStyle.ROUND</code>.</p>
     *
     *  @default CapsStyle.ROUND
     * 
     *  @see flash.display.CapStyle
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get caps():String
    {
        return _caps;
    }
    
    /**
     *  @private
     */
    public function set caps(value:String):void
    {
        var oldValue:String = _caps;
        if (value != oldValue)
        {
            _caps = value;
            
            dispatchGradientChangedEvent("caps", oldValue, value);
        }
    }
        
    //----------------------------------
    //  joints
    //----------------------------------

    /**
     *  @private
     *  Storage for the joints property.
     */
    private var _joints:String = JointStyle.ROUND;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General", enumeration="round,bevel,miter", defaultValue="round")]

    /**
     *  A value from the JointStyle class that specifies the type
     *  of joint appearance used at angles.
     *
     *  <p>Valid values are <code>JointStyle.BEVEL</code>,
     *  <code>JointStyle.MITER</code>, and <code>JointStyle.ROUND</code>.
     *  A <code>null</code> value is equivalent to
     *  <code>JointStyle.ROUND</code>.</p>
     *  
     *  @default JointStyle.ROUND
     * 
     *  @see flash.display.JointStyle
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get joints():String
    {
        return _joints;
    }
    
    /**
     *  @private
     */
    public function set joints(value:String):void
    {
        var oldValue:String = _joints;
        if (value != oldValue)
        {
            _joints = value;
            
            dispatchGradientChangedEvent("joints", oldValue, value);
        }
    }
    
    //----------------------------------
    //  miterLimit
    //----------------------------------

    /**
     *  @private
     *  Storage for the miterLimit property.
     */
    private var _miterLimit:Number = 3;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General", minValue="1.0", maxValue="255.0")]
    
    /**
     *  A number that indicates the limit at which a miter is cut off. 
     *
     *  <p>Valid values range from 1 to 255
     *  (and values outside of that range are rounded to 1 or 255).</p>
     *
     *  <p>This value is only used if the <code>jointStyle</code> property 
     *  is set to <code>JointStyle.MITER</code>.</p>
     *
     *  <p>The value of the <code>miterLimit</code> property represents the length that a miter
     *  can extend beyond the point at which the lines meet to form a joint.
     *  The value expresses a factor of the line <code>thickness</code>.
     *  For example, with a <code>miterLimit</code> factor of 2.5
     *  and a <code>thickness</code> of 10 pixels,
     *  the miter is cut off at 25 pixels.</p>
     *  
     *  @default 3
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get miterLimit():Number
    {
        return _miterLimit;
    }
    
    /**
     *  @private
     */
    public function set miterLimit(value:Number):void
    {
        var oldValue:Number = _miterLimit;
        if (value != oldValue)
        {
            _miterLimit = value;
            
            dispatchGradientChangedEvent("miterLimit", oldValue, value);
        }
    }

    //----------------------------------
    //  pixelHinting
    //----------------------------------

    /**
     *  @private
     *  Storage for the pixelHinting property.
     */
    private var _pixelHinting:Boolean = false;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  A Boolean value that specifies whether to hint strokes to full pixels.
     *
     *  <p>This affects both the position of anchors of a curve
     *  and the line stroke size itself.</p>
     *
     *  <p>With <code>pixelHinting</code> set to <code>true</code>,
     *  Flash Player and AIR hint line widths to full pixel widths.
     *  With <code>pixelHinting</code> set to <code>false</code>,
     *  disjoints can appear for curves and straight lines.</p>
     *  
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get pixelHinting():Boolean
    {
        return _pixelHinting;
    }
    
    /**
     *  @private
     */
    public function set pixelHinting(value:Boolean):void
    {
        var oldValue:Boolean = _pixelHinting;
        if (value != oldValue)
        {
            _pixelHinting = value;
            
            dispatchGradientChangedEvent("pixelHinting", oldValue, value);
        }
    }
    
    //----------------------------------
    //  scaleMode
    //----------------------------------

    /**
     *  @private
     *  Storage for the scaleMode property.
     */
    private var _scaleMode:String = "normal";
    
    [Bindable("propertyChange")]
    [Inspectable(category="General", enumeration="normal,vertical,horizontal,none", defaultValue="normal")]

    /**
     *  Specifies which scale mode to use. Value valids are:
     * 
     *  <ul>
     *  <li>
     *  <code>LineScaleMode.NORMAL</code>&#151;
     *  Always scale the line thickness when the object is scaled  (the default).
     *  </li>
     *  <li>
     *  <code>LineScaleMode.NONE</code>&#151;
     *  Never scale the line thickness.
     *  </li>
     *  <li>
     *  <code>LineScaleMode.VERTICAL</code>&#151;
     *  Do not scale the line thickness if the object is scaled vertically 
     *  <em>only</em>. 
     *  </li>
     *  <li>
     *  <code>LineScaleMode.HORIZONTAL</code>&#151;
     *  Do not scale the line thickness if the object is scaled horizontally 
     *  <em>only</em>. 
     *  </li>
     *  </ul>
     * 
     *  @default LineScaleMode.NORMAL
     *  
     *  @see flash.display.LineScaleMode
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get scaleMode():String
    {
        return _scaleMode;
    }
    
    /**
     *  @private
     */
    public function set scaleMode(value:String):void
    {
        var oldValue:String = _scaleMode;
        if (value != oldValue)
        {
            _scaleMode = value;
            
            dispatchGradientChangedEvent("scaleMode", oldValue, value);
        }
    }
    
    //----------------------------------
    //  weight
    //----------------------------------

    /**
     *  @private
     *  Storage for the weight property.
     */
    private var _weight:Number;

    [Bindable("propertyChange")]
    [Inspectable(category="General", minValue="0.0")]

    /**
     *  The stroke weight, in pixels.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get weight():Number
    {
        return _weight;
    }
    
    /**
     *  @private
     */
    public function set weight(value:Number):void
    {
        var oldValue:Number = _weight;
        if (value != oldValue)
        {
            _weight = value;
            
            dispatchGradientChangedEvent("weight", oldValue, value);
        }
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
     *  @productversion Flex 4
     */
    public function apply(g:Graphics, targetBounds:Rectangle, targetOrigin:Point):void
    {
        // Sub-classes must implement 
    }
    
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    public function createGraphicsStroke(targetBounds:Rectangle, targetOrigin:Point):GraphicsStroke
    {
        // Construct a new GraphicsStroke object and set all of 
        // its properties to match the gradient stroke's 
        // properties
        var graphicsStroke:GraphicsStroke = new GraphicsStroke(); 
        graphicsStroke.thickness = weight; 
        graphicsStroke.miterLimit = miterLimit; 
        graphicsStroke.pixelHinting = pixelHinting;
        graphicsStroke.scaleMode = scaleMode;   
                    
        // There is a bug in Drawing API-2 where if no caps is 
        // specified, a value of 'none' is used instead of 'round'
        graphicsStroke.caps = (!caps) ? CapsStyle.ROUND : caps; 
        
        // Create the GraphicsGradientFill matching the 
        // gradient stroke's properties and set that as the 
        // fill for the GraphicsStroke object  
        var graphicsGradientFill:GraphicsGradientFill = 
            new GraphicsGradientFill();
        
        graphicsGradientFill.colors = colors;  
        graphicsGradientFill.alphas = alphas;
        graphicsGradientFill.ratios = ratios;
        graphicsGradientFill.spreadMethod = spreadMethod;
        graphicsGradientFill.interpolationMethod = interpolationMethod;  
        
        graphicsStroke.fill = graphicsGradientFill;
        
        return graphicsStroke; 
    }
    
}

}

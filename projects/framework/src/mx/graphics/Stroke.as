////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2004-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.graphics
{

[Deprecated(replacement="SolidColorStroke", since="4.0")] 
/**
 *  The Stroke class defines the properties for a line. 
 *  
 *  You can define a Stroke object in MXML, but you must attach that Stroke to
 *  another object for it to appear in your application. The following example
 *  defines two Stroke objects and then uses them in the horizontalAxisRenderer
 *  of a LineChart control:
 *  
 *  <pre>
 *  ...
 *  &lt;mx:Stroke id="ticks" color="0xFF0000" weight="1"/&gt;
 *  &lt;mx:Stroke id="mticks" color="0x0000FF" weight="1"/&gt;
 *  
 *  &lt;mx:LineChart id="mychart" dataProvider="{ndxa}"&gt;
 *      &lt;mx:horizontalAxisRenderer&gt;
 *          &lt;mx:AxisRenderer placement="bottom" canDropLabels="true"&gt;
 *              &lt;mx:tickStroke&gt;{ticks}&lt;/mx:tickStroke&gt;
 *              &lt;mx:minorTickStroke&gt;{mticks}&lt;/mx:minorTickStroke&gt;
 *          &lt;/mx:AxisRenderer&gt;
 *      &lt;/mx:horizontalAxisRenderer&gt;
 *  &lt;/LineChart&gt;
 *  ...
 *  </pre>
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;mx:Stroke&gt;</code> tag inherits all the tag attributes
 *  of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:Stroke
 *    <b>Properties</b>
 *    alpha="1.0"
 *    caps="null|none|round|square"
 *    color="0x000000"
 *    joints="null|bevel|miter|round"
 *    miterLimit="0"
 *    pixelHinting="false|true"
 *    scaleMode="normal|none|noScale|vertical"
 *    weight="1 (<i>in most cases</i>)"
 *  /&gt;
 *  </pre>
 *
 *  @see flash.display.Graphics
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class Stroke extends SolidColorStroke 
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
     *  @param color Specifies the line color.
     *  The default value is 0x000000 (black).
     *
     *  @param weight Specifies the line weight, in pixels.
     *  The default value is 0.
     *
     *  @param alpha Specifies the alpha value in the range 0.0 to 1.0.
     *  The default value is 1.0 (opaque).
     *
     *  @param pixelHinting Specifies whether to hint strokes to full pixels.
     *  This value affects both the position of anchors of a curve
     *  and the line stroke size itself.
     *  The default value is false.
     *
     *  @param scaleMode A value from the LineScaleMode class
     *  that specifies which scale mode to use.
     *  Valid values are <code>LineScaleMode.HORIZONTAL</code>,
     *  <code>LineScaleMode.NONE</code>, <code>LineScaleMode.NORMAL</code>,
     *  and <code>LineScaleMode.VERTICAL</code>.
     *  This parameter is optional,
     *  with a default value of <code>LineScaleMode.NORMAL</code>. 
     *
     *  @param caps Specifies the type of caps at the end of lines.
     *  Valid values are <code>"round"</code>, <code>"square"</code>,
     *  and <code>"none"</code>.
     *  The default value is <code>null</code>.
     *
     *  @param joints Specifies the type of joint appearance used at angles.
     *  Valid values are <code>"round"</code>, <code>"miter"</code>,
     *  and <code>"bevel"</code>.
     *  The default value is <code>null</code>.
     *
     *  @param miterLimit Indicates the limit at which a miter is cut off.
     *  Valid values range from 0 to 255.
     *  The default value is 0.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function Stroke(color:uint = 0x000000,
                           weight:Number = 0,
                           alpha:Number = 1.0,
                           pixelHinting:Boolean = false,
                           scaleMode:String = "normal",
                           caps:String = null,
                           joints:String = null,
                           miterLimit:Number = 0)
    {
        super(color, weight, alpha, pixelHinting,
              scaleMode, caps, joints, miterLimit);
    }

}

}

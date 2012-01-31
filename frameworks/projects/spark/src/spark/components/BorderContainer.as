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

package spark.components
{
import mx.graphics.IFill;
import mx.graphics.IStroke;

import spark.components.SkinnableContainer;

/**
 *  Alpha level of the color defined by the <code>backgroundColor</code>
 *  property, or the image file defined by the <code>backgroundImage</code>
 *  style.
 *  Valid values range from 0.0 to 1.0. 
 *  
 *  @default 1.0
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="backgroundAlpha", type="Number", inherit="no")]

/**
 *  Background color of the container.
 *  
 *  The default value is <code>undefined</code>, which means it is not set.
 *  If both this style and the <code>backgroundImage</code> style
 *  are <code>undefined</code>, the component has a transparent background.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]

/**
 *  Background image of a container.  This can be an absolute or relative
 *  URL or class.  You can either have both a <code>backgroundColor</code> and a
 *  <code>backgroundImage</code> set at the same time. The background image is displayed
 *  on top of the background color.
 *  The default value is <code>undefined</code>, meaning "not set".
 *  If this style and the <code>backgroundColor</code> style are undefined,
 *  the component has a transparent background.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="backgroundImage", type="Object", format="File", inherit="no")]

/**
 *  The fillMode determines how the background image fills in the dimensions. If you set the value
 *  of this property in a tag, use the string (such as "repeat"). If you set the value of 
 *  this property in ActionScript, use the constant (such as <code>BitmapFillMode.CLIP</code>).
 * 
 *  When set to <code>BitmapFillMode.CLIP</code> ("clip"), the image
 *  ends at the edge of the region.
 * 
 *  When set to <code>BitmapFillMode.REPEAT</code> ("repeat"), the image 
 *  repeats to fill the region.
 *
 *  When set to <code>BitmapFillMode.SCALE</code> ("scale"), the image
 *  stretches to fill the region.
 * 
 *  @default <code>BitmapFillMode.SCALE</code>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="backgroundImageFillMode", type="String", enumeration="scale,clip,repeat", inherit="no")]

/**
 *  Alpha level of the color defined by the <code>borderColor</code> style.
 *  
 *  Valid values range from 0.0 to 1.0. 
 *  
 *  @default 1.0
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderAlpha", type="Number", inherit="no")]

/**
 *  Color of the border.
 *  The default value depends on the component class;
 *  if not overridden for the class, the default value is <code>0xB7BABC</code>.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderColor", type="uint", format="Color", inherit="no")]

/**
 *  Bounding box style.
 *  The possible values are <code>"solid"</code> and <code>"inset"</code>.
 * 
 *  @default solid
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderStyle", type="String", enumeration="inset,solid", inherit="no")]

/**
 *  Determines if the border is visible or not. If true, then no border will be visible,
 *  except a border set via the borderStroke property. 
 *   
 *  @default true
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderVisible", type="Boolean", inherit="no")]

/**
 *  The stroke weight for the border. 
 *
 *  @default 1
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderWeight", type="Number", format="Length", inherit="no")]

/**
 *  Radius of the curved corners of the border
 *  if not overriden for the class, the default value is 0.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="cornerRadius", type="Number", format="Length", inherit="no")]

/**
 *  Boolean property that specifies whether the container has a visible
 *  drop shadow.
 *  
 *  @default false
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="dropShadowVisible", type="Boolean", inherit="no")]

/**
 *  The Border class is a convenience class that provides a set of common styles that control
 *  the appearance of the border and background of a container. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
public class Border extends SkinnableContainer
{
    /**
     *  Constructor
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
	public function Border()
	{
	    super(); 
	}
     
    private var _backgroundFill:IFill;
    
    /**
     *  The backgroundFill is used to draw the background of the Border. 
     *  Setting this property will override the backgroundAlpha, 
     *  backgroundColor, backgroundImage and backgroundImageFillMode styles.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get backgroundFill():IFill
    {
        return _backgroundFill;
    }
    
    public function set backgroundFill(value:IFill):void
    {
        if (value == _backgroundFill)
           return;
        
        _backgroundFill = value;
        
        if (skin)
            skin.invalidateDisplayList();
    }
    
    private var _borderStroke:IStroke;
    
    /**
     *  The borderStroke draws the border of the Border. Setting this property will override 
     *  the borderAlpha, borderColor, borderStyle, borderVisible and borderWeight styles.  
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get borderStroke():IStroke
    {
        return _borderStroke;
    }
    
    public function set borderStroke(value:IStroke):void
    {
        if (value == _borderStroke)
           return;
        
        _borderStroke = value;
        
        if (skin)
            skin.invalidateDisplayList();
    }
}
}

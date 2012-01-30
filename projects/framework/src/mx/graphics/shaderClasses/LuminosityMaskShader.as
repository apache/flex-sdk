////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.graphics.shaderClasses
{
import flash.display.Shader;

/**
 *  Creates a blend shader that is equivalent 
 *  to the luminosity masking option (also known as soft masking) available  
 *  in Adobe Creative Suite tools. This mask type is not native to Flash, 
 *  but is available in tools like Adobe Illustrator and Adobe Photoshop. 
 * 
 *  <p>A luminosity mask type can be set on Flex groups and graphic  
 *  elements. The visual appearance in tools like Adobe Illustrator and 
 *  Adobe Photoshop will be mimicked through this blend shader.</p>
 *  
 *  @see spark.primitives.supportClasses.GraphicElement#maskType
 *  @see spark.components.supportClasses.GroupBase#maskType 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 *  
 *  @includeExample examples/LuminosityMaskShaderExample.mxml
 */

public class LuminosityMaskShader extends Shader
{
    [Embed(source="LuminosityMaskFilter.pbj", mimeType="application/octet-stream")]
    private static var ShaderClass:Class;

	/**
	 *  Constructor. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
    public function LuminosityMaskShader()
    {
        super(new ShaderClass());
    }

    /**
     *  A convenience field that takes into account whether luminosityClip and/or
     *  luminosityInvert are on or off. 
     * 
     *  <ul>
     *   <li>mode 0 = luminosityClip off, luminosityInvert off</li>
     *   <li>mode 1 = luminosityClip off, luminosityInvert on</li>
     *   <li>mode 2 = luminosityClip on, luminosityInvert off</li>
     *   <li>mode 3 = luminosityClip on, luminosityInvert on </li>
     *  </ul>
     * 
     *  @see spark.primitives.supportClasses.GraphicElement#luminosityClip
     *  @see spark.primitives.supportClasses.GraphicElement#luminosityInvert
     *  @see spark.components.supportClasses.GroupBase#luminosityClip 
     *  @see spark.components.supportClasses.GroupBase#luminosityInvert
	 * 
	 *  @langversion 3.0
 	 *  @playerversion Flash 10
 	 *  @playerversion AIR 1.5
 	 *  @productversion Flex 4
     */
    public function get mode():int
    {
        return this.data.mode.value;
    }

    public function set mode(v:int):void
    {
		if (mode ==-1)
				return; 
        this.data.mode.value=[v];
    }
}
}

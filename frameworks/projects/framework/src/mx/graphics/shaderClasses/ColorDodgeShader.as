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
 *  The ColorDodgeShader class creates a blend shader that is equivalent to 
 *  the 'Color Dodge' blend mode for RGB premultiplied colors available 
 *  in Adobe Creative Suite tools. This blend mode is not native to Flash, 
 *  but is available in tools like Adobe Illustrator and Adobe Photoshop. 
 * 
 *  The 'colordodge' blend mode can be set on Flex groups and graphic  
 *  elements and the visual appearance in tools like Adobe Illustrator and 
 *  Adobe Photoshop will be mimicked through this blend shader.  
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  
 *  @includeExample examples/ColorDodgeShaderExample.mxml
 */
public class ColorDodgeShader extends flash.display.Shader
{
    [Embed(source="ColorDodge.pbj", mimeType="application/octet-stream")]
    private static var ShaderClass:Class;
    
    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function ColorDodgeShader()
    {
        super(new ShaderClass());
    }

}
}

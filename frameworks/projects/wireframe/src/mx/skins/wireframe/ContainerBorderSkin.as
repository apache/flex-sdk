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

package mx.skins.wireframe {

/**
 *  Defines the border and background for the MX Container class's wireframe skin.
 *  
 *  @see mx.core.Container
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */     
public class ContainerBorderSkin extends BorderSkin
{
    public function ContainerBorderSkin()
    {
        super();
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void
    {
        // Push backgroundColor and backgroundAlpha directly.
        // Handle undefined backgroundColor by hiding the background object.
        if (isNaN(getStyle("backgroundColor")))
        {
            background.visible = false;
        }
        else
        {
            background.visible = true;
            bgFill.color = getStyle("backgroundColor");
            bgFill.alpha = getStyle("backgroundAlpha");
        }
        
        super.updateDisplayList(unscaledWidth, unscaledHeight);
    }

}
}
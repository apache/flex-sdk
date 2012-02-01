////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.skins.spark {

/**
 *  Defines the border and background for the MX Container class's Spark skin.
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
    /**
     *  Constructor.
     */
    public function ContainerBorderSkin()
    {
        super();
    }
    
    /**
     *  @private
     *  ContainerBorderSkin uses backgroundColor and backgroundAlpha
     *  instead of contentBackgroundColor and contentBackgroundAlpha.
     *  Override the contentItems getter here to return null. This
     *  removes the contentBackgroundColor/Alpha functionality.
     *  The backgroundColor/backgroundAlpha functionality is handled
     *  below in updateDisplayList.
     */
    override public function get contentItems():Array
    {
        return null;
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void
    {
        var cr:Number = getStyle("cornerRadius");
        
        if (cornerRadius != cr)
            cornerRadius = cr;
        
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

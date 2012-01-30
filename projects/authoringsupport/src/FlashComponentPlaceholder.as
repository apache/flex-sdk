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

package
{
import mx.controls.Image;

[IconFile("flash_component_icon_small.png")]
public class FlashComponentPlaceholder extends FlashContainerPlaceholder
{
    public function FlashComponentPlaceholder()
    {
        super();
    }
    
    override protected function createImage():Image
    {
        image1 = new Image();
        image1.source = _embed_mxml_flash_component_icon_png;
        image1.scaleContent = false;
        image1.percentHeight = 100;
        image1.percentWidth = 100;
        image1.setStyle('horizontalAlign' , 'center');
        image1.setStyle('verticalAlign' , 'middle');
        return image1;            
    }

    [Embed(source='flash_component_icon.png')]
    private var _embed_mxml_flash_component_icon_png:Class;
}
}
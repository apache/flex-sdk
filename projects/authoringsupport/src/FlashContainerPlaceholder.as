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
import flash.display.Shape;

import mx.containers.Canvas;
import mx.controls.Image;
import mx.flash.ContainerMovieClip;
import mx.flash.FlexContentHolder;

[IconFile("flash_container_icon_small.png")]
public class FlashContainerPlaceholder extends ContainerMovieClip
{
    protected var image1:Image;
    
    public function FlashContainerPlaceholder()
    {
        super();
        
        // 151, 151 is the size of the flex content holder image, 
        // so I'm going to make it that size by default.
        var shape:Shape = new Shape();
        shape.graphics.beginFill(0, 0);
        shape.graphics.drawRect(0, 0, 151, 151);
        shape.graphics.endFill();
        addChild(shape);

        var fch:FlexContentHolder = new MyFlexContentHolder();
        
        var canvas1:Canvas = new Canvas();
        canvas1.horizontalScrollPolicy = "off";
        canvas1.verticalScrollPolicy = "off";
        canvas1.setStyle('borderStyle', 'solid');
        canvas1.setStyle('borderThickness', '2');
        canvas1.setStyle('borderColor', '0xCCCCCC');
        canvas1.percentHeight = 100;
        canvas1.percentWidth = 100;
        canvas1.addChild(createImage());

        this.addChild(fch);
        
        this.content = canvas1;            
    }
    
    protected function createImage():Image
    {
        image1 = new Image();
        image1.source = _embed_mxml_flash_container_icon_png;
        image1.scaleContent = false;
        image1.percentHeight = 100;
        image1.percentWidth = 100;
        image1.setStyle('horizontalAlign' , 'center');
        image1.setStyle('verticalAlign' , 'middle');
        return image1;            
    }
    
    override public function setActualSize(newWidth:Number, newHeight:Number):void
    {
        if (image1 != null) {
            if (newWidth < 128 || newHeight < 128)
                image1.scaleContent = true;
            else
                image1.scaleContent = false;
        }

        super.setActualSize(newWidth, newHeight);
    }

    [Embed(source='flash_container_icon.png')]
    private var _embed_mxml_flash_container_icon_png:Class;
}
}